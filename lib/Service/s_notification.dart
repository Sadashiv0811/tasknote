import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tasknote/Reminder/Model/m_reminder.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();

  static final NotificationService _instance =
      NotificationService._privateConstructor();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  final logger = Logger();

  bool _initialized = false;

  /// Notification channel constants
  static const String _channelId = 'tasknote_channel_1';
  static const String _channelName = 'TaskNote Notifications';
  static const String _channelDescription = 'Notifications for task reminder';

  // Notifications channel, request permission

  /// Initialize Notifications and Timezones
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone database.
    tz.initializeTimeZones();

    // Set device local timezone.
    final String timeZoneName =
        await FlutterNativeTimezoneLatest.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    logger.d('Timezone from device: $timeZoneName');

    const androidSettings = AndroidInitializationSettings('ic_not');

    // iOS/macOS settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Combined initialization settings.
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await plugin.initialize(settings: settings);

    // Create Android notification channel.
    await _createNotificationChannel();

    // Ensure exact alarm capabilities are checked for Android 13/14+.
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final canSchedule =
          await androidPlugin.canScheduleExactNotifications() ?? false;
      logger.d('Can schedule exact notifications: $canSchedule');
    }

    // Notifiaction permission setup is done on home screen.

    _initialized = true;
  }

  /// Create Android notification channel.
  Future<void> _createNotificationChannel() async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() async {
    try {
      var status = await Permission.notification.status;
      if (status.isGranted) return true;

      if (!status.isPermanentlyDenied) {
        status = await Permission.notification.request();
        if (status.isGranted) return true;
      }
      return false;
    } catch (e) {
      logger.d('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Specifically handles Android 13/14+ Exact Alarm scheduling access
  Future<bool> checkAndRequestExactAlarms() async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true; // Not Android, skip

    try {
      // Check if we already have exact alarm scheduling permissions
      final bool canSchedule =
          await androidPlugin.canScheduleExactNotifications() ?? false;
      logger.d('Can schedule exact notifications: $canSchedule');

      if (!canSchedule) {
        logger.d(
          'Exact alarm permissions missing. Redirecting user to System Settings...',
        );
        // This directs Android users specifically to the "Alarms & Reminders" section
        // in their system settings where they can toggle it on.
        final status = await Permission.scheduleExactAlarm.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      logger.d('Error handling exact alarm permission: $e');
      return false;
    }
  }

  /// Shared notification details.
  NotificationDetails _notificationDetails({bool isPin = false}) {
    const androidDetailsSticky = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // THIS MAKES IT STICKY/PINNED
      autoCancel: false, // Prevents dismissal on tap
      playSound: false,

      // Required to show horizontal line/bar on disabled check note.
      styleInformation: DefaultStyleInformation(
        true, // htmlFormatContent
        true, // htmlFormatTitle
      ),
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,

      styleInformation: DefaultStyleInformation(
        true, // htmlFormatContent
        false, // htmlFormatTitle
      ),
    );

    const darwinDetails = DarwinNotificationDetails();

    return NotificationDetails(
      android: isPin ? androidDetailsSticky : androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  // Notifications id

  /// Generates stable notification IDs from item ID.
  /// hashCode should NOT be used because it changes between app launches.
  int _generateId(String noteUid, int salt) {
    final input = '$noteUid-$salt';

    final digest = md5.convert(utf8.encode(input));

    // Use first 4 bytes to create a stable positive int
    final id =
        (digest.bytes[0] << 24) |
        (digest.bytes[1] << 16) |
        (digest.bytes[2] << 8) |
        digest.bytes[3];

    return id & 0x7FFFFFFF;
  }

  /// Pin Reminder notification ID.
  int pinReminderId(String noteUid) => _generateId(noteUid, 1000);

  /// Schedule Reminder notification ID.
  int scheduleReminderId(String noteUid) => _generateId(noteUid, 2000);

  // Notifications schedule

  /// Schedule a Reminder
  Future<bool> scheduleTaskReminder(Reminder reminder) async {
    int uniqueId = scheduleReminderId(reminder.noteUID);

    // Cancel old notification before rescheduling.
    await plugin.cancel(id: uniqueId);

    tz.TZDateTime tzDate = tz.TZDateTime.from(reminder.scheduledDT!, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    // Prevent scheduling past dates.
    if (tzDate.isBefore(now)) {
      if (now.difference(tzDate).inMinutes == 0) {
        tzDate = tzDate.add(const Duration(minutes: 1));
      } else {
        logger.d("Not scheduled because time has passed");
        return false;
      }
    }

    try {
      await plugin.zonedSchedule(
        id: uniqueId, // Unique ID
        title: reminder.title, // Notification Title
        body: reminder.content, // Notification Body
        scheduledDate: tzDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: reminder.scheduledDT!.toIso8601String(),
      );
      logger.d("Successfully scheduled exact notification for $tzDate");
      return true;
    } catch (e) {
      logger.e("Failed to schedule notification: $e");
      return false;
    }
  }

  /// Pin to Status Bar
  Future<void> pinTaskToStatusBar(Reminder reminder) async {
    int uniqueId = pinReminderId(reminder.noteUID);

    await plugin.show(
      id: uniqueId,
      title: reminder.title,
      body: reminder.content,
      notificationDetails: _notificationDetails(isPin: true),
    );
  }

  // Notifications cancel

  // Clear all notifications
  Future<void> cancelAll() async {
    try {
      await plugin.cancelAll();
      logger.i(
        'All pending notifications and reminders have been successfully cleared.',
      );
    } catch (e) {
      logger.e('Failed to clear notifications: $e');
    }
  }

  /// Cancel a notification pinned to the status bar using the note's UID.
  Future<void> cancelPinnedTask(String noteUid) async {
    int uniqueId = pinReminderId(noteUid);
    await plugin.cancel(id: uniqueId);
    logger.d(
      'Cancelled pinned notification for note: $noteUid (ID: $uniqueId)',
    );
  }

  /// Cancel a scheduled reminder notification using the note's UID.
  Future<void> cancelScheduledTask(String noteUid) async {
    int uniqueId = scheduleReminderId(noteUid);
    await plugin.cancel(id: uniqueId);
    logger.d(
      'Cancelled scheduled notification for note: $noteUid (ID: $uniqueId)',
    );
  }

  /// Loops through all pending reminders and removes those whose scheduled date and time have already passed.
  Future<void> cleanExpiredReminders() async {
    try {
      // Timezones and plugin are initialized from at the beginning only

      // Fetch all pending notifications currently registered in the OS
      final pendingRequests = await plugin.pendingNotificationRequests();
      final now = DateTime.now();
      int clearCount = 0;

      for (final notification in pendingRequests) {
        // We only target reminders scheduled with our specific prefix salt
        final String? payload = notification.payload;

        if (payload != null) {
          final DateTime? scheduledDateTime = DateTime.tryParse(payload);

          // If the scheduled date time is in the past, cancel it
          if (scheduledDateTime != null && scheduledDateTime.isBefore(now)) {
            await plugin.cancel(id: notification.id);
            clearCount++;
          }
        }
      }

      if (clearCount > 0) {
        logger.d('Cleaned up $clearCount expired scheduled notification(s).');
      }
    } catch (e) {
      logger.e('Error during expired reminders cleanup: $e');
    }
  }

  // Notifications print

  // Print all notifications
  Future<void> printPendingNotifications() async {
    final pending = await plugin.pendingNotificationRequests();
    logger.d('Pending notification count: ${pending.length}');

    for (final notification in pending) {
      logger.d("""
        ID: ${notification.id}
        Title: ${notification.title}
        Body: ${notification.body}
      """);
    }
  }

  // Notifications Check

  /// Checks if a notification is currently active/pinned in the status bar.
  Future<bool> isTaskPinned(String noteUid) async {
    final int uniqueId = pinReminderId(noteUid);
    final activeNotifications = await plugin.getActiveNotifications();
    return activeNotifications.any(
      (notification) => notification.id == uniqueId,
    );
  }

  /// Checks if a reminder notification is currently scheduled for the future.
  Future<bool> isTaskScheduled(String noteUid) async {
    final int uniqueId = scheduleReminderId(noteUid);
    final pendingRequests = await plugin.pendingNotificationRequests();
    return pendingRequests.any((notification) => notification.id == uniqueId);
  }

  // Utility Functions

  // Returns the scheduled date
  Future<String?> getScheduledDate(String noteUid) async {
    final int uniqueId = scheduleReminderId(noteUid);
    final pendingRequests = await plugin.pendingNotificationRequests();

    try {
      // Find the specific notification by its ID
      final notification = pendingRequests.firstWhere(
        (element) => element.id == uniqueId,
      );

      // Return the payload (which you saved as the date string)
      return notification.payload;
    } catch (e) {
      // No pending notification found for this ID
      return null;
    }
  }

  /// Takes a list of note UIDs and returns a filtered list containing only
  /// the UIDs that have either an active pinned notification or a scheduled reminder.
  Future<List<String>> getNotesWithReminders(List<String> noteUids) async {
    // Map each UID to a Future that evaluates to true if it has any active reminder
    final checkFutures = noteUids.map((uid) async {
      // Run both checks in parallel for this specific UID
      final results = await Future.wait([
        isTaskPinned(uid),
        isTaskScheduled(uid),
      ]);

      // If either condition is true, this UID has a reminder
      return results[0] || results[1];
    });

    // Execute all UID checks concurrently
    final results = await Future.wait(checkFutures);

    // Filter the original list based on the boolean results
    final List<String> notesWithReminders = [];
    for (int i = 0; i < noteUids.length; i++) {
      if (results[i]) {
        notesWithReminders.add(noteUids[i]);
      }
    }

    return notesWithReminders;
  }
}
