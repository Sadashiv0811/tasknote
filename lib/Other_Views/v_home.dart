import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Service/s_notification.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Other_Views/v_calender.dart';
import 'package:tasknote/Group/Views/v_groups.dart';
import 'package:tasknote/Note/Views/v_note.dart';
import 'package:tasknote/Other_Views/v_profile.dart';

class VHome extends ConsumerStatefulWidget {
  const VHome({super.key});

  @override
  ConsumerState<VHome> createState() => _VHomeState();
}

class _VHomeState extends ConsumerState<VHome> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isDialogShowing = false;
  bool _hasRestoredNotifications = false;

  final List<Widget> _screens = const [
    VNote(),
    VCalenderNote(),
    VGroups(),
    VProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();

    // Register lifecycle observer to detect when user comes back from App Settings
    WidgetsBinding.instance.addObserver(this);

    // Check permission shortly after frame render finishes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If user returns from device settings, automatically re-evaluate status
    if (state == AppLifecycleState.resumed) {
      _checkAndRequestPermission();
    }
  }

  /// Evaluates permission state and triggers appropriate UI responses
  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      logger.d("Permission Granted");
      // Dismiss the warning dialog if it is currently visible
      if (_isDialogShowing && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isDialogShowing = false);
      }

      // Only run rescheduling logic once, rather than every single time the app is resumed.
      if (!_hasRestoredNotifications) {
        _hasRestoredNotifications = true;

        try {
          // Safe check: Verify widget is still mounted before reading ref providers
          if (!mounted) return;

          final unProtectedNotes = await noteController
              .getUnProtectedNotesList();

          if (unProtectedNotes.isEmpty) {
            logger.d(
              'Notes are empty, so no scheduling pinned and future notifications.',
            );
            return;
          }

          // Reschedule reminder
          await reminderController.resetReminders(unProtectedNotes);

          logger.d(
            'Successfully restored and rescheduled pinned and future notifications.',
          );
        } catch (e) {
          // Reset flag so we can retry if a network/database error occurred
          _hasRestoredNotifications = false;
          logger.e('Failed to reschedule notifications: $e');
        }
      }
      return;
    }

    // Trigger dialog if permission isn't granted and no dialog is currently open
    if (!_isDialogShowing && mounted) {
      _showPermissionDialog(status);
    }
  }

  /// Displays custom dialog depending on whether permission is standard denied or permanently denied
  void _showPermissionDialog(PermissionStatus status) async {
    // Determine if we are on Android 13+ (API 33+)
    bool isAndroid13OrHigher = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      isAndroid13OrHigher = androidInfo.version.sdkInt >= 33;
    }

    if (!mounted) return;

    setState(() => _isDialogShowing = true);

    final isPermanentlyDenied =
        status.isPermanentlyDenied || (!isAndroid13OrHigher && status.isDenied);

    // On Android 12 and below, there is no system-level runtime prompt for notifications. Notifications are granted automatically when the app is installed.
    // On Android 13 and above, Google introduced a proper runtime permission popup (API 33) which show the official "Allow notifications?" popup.
    // (!isAndroid13OrHigher && status.isDenied) without this check the dialog was shown in a loop on Android 12 and below.

    showDialog(
      context: context,
      barrierDismissible: false,
      // Force user to address the permission
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          // Prevents Android physical back button dismissal
          child: _NotificationRequestDialog(
            negativeAction: () {
              Navigator.of(dialogContext).pop();
              setState(() => _isDialogShowing = false);
            },
            positiveAction: () async {
              // Dismiss dialog first before invoking async actions to avoid context leaks
              Navigator.of(dialogContext).pop();
              setState(() => _isDialogShowing = false);

              if (isPermanentlyDenied) {
                // Directs Android 12 users (who turned off notifications) straight to settings
                await openAppSettings();
              } else {
                // This block will run on Android 13+ or if permission is not yet determined
                final result = await Permission.notification.request();

                // If granted, request exact alarms if missing (this may pause the app again)
                if (result.isGranted) {
                  final androidPlugin = NotificationService().plugin
                      .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin
                      >();

                  final canSchedule =
                      await androidPlugin?.canScheduleExactNotifications() ??
                      true;

                  if (!canSchedule) {
                    // This will temporarily pause the app. When they return,
                    // didChangeAppLifecycleState will trigger the final scheduling check.
                    await Permission.scheduleExactAlarm.request();
                  }
                } else {
                  // If they denied the system prompt, re-evaluate to show the dialog again
                  _checkAndRequestPermission();
                }
              }
            },
            isPermanentlyDenied: isPermanentlyDenied,
          ),
        );
      },
    );
  }

  Future<void> _checkInternetConnection() async {
    // Now you can use await here
    if (await checkInternet()) {
      logger.d("Connected");
    } else {
      logger.d("Disconnected");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: const Offset(0, 0.1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: _CBottomNavBar(
              currentIndex: _selectedIndex,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}

// Stateless Widgets
class _CBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _CBottomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      {'icon': Icons.note, 'label': 'Notes', 'filled': Icons.note},
      {
        'icon': Icons.calendar_month,
        'label': 'Calender',
        'filled': Icons.calendar_month_rounded,
      },
      {'icon': Icons.folder, 'label': 'Folder', 'filled': Icons.folder_rounded},
      {
        'icon': Icons.person,
        'label': 'Account',
        'filled': Icons.person_rounded,
      },
    ];

    final Color containerBackgroundColor = isDark
        ? AppColors.dThirdColor
        : Color(0xFF54acbf);
    final Color activeColor = AppColors.primary;

    final Color activeTabBackground = isDark
        ? activeColor.withValues(alpha: 0.3)
        : AppColors.dSecondColor.withValues(alpha: 0.7);

    // Inactive colors
    final Color inactiveIconColor = isDark ? Colors.white70 : Colors.black54;
    final Color inactiveTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      height: 75,
      padding: const EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        color: containerBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.dSecondColor.withValues(alpha: 0.5),
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: const Offset(0, -4), // Shadow on top side
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? activeTabBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    items[index][isActive ? 'filled' : 'icon'] as IconData,
                    // Active icon uses Primary (Teal)
                    color: isActive ? activeColor : inactiveIconColor,
                    size: 27,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      color: isActive ? activeColor : inactiveTextColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationRequestDialog extends StatelessWidget {
  final VoidCallback negativeAction;
  final Future<void> Function() positiveAction;
  final bool isPermanentlyDenied;

  const _NotificationRequestDialog({
    required this.negativeAction,
    required this.positiveAction,
    required this.isPermanentlyDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Notification Permission Required"),
      content: Text(
        isPermanentlyDenied
            ? "Notifications are turned off. Please enable them in your device settings to receive reminder notifications."
            : "Please allow notifications so we can send you reminder alerts.",
      ),
      actions: [
        TextButton(
          onPressed: negativeAction,
          child: Text(
            "LATER",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            await positiveAction();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
            shadowColor: Theme.of(context).colorScheme.shadow,
          ),
          child: Text(
            isPermanentlyDenied ? "OPEN SETTINGS" : "GRANT PERMISSION",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
