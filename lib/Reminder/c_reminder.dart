import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Reminder/Model/m_reminder.dart';
import 'package:tasknote/Service/s_isar.dart';
import 'package:tasknote/Service/s_notification.dart';

class ReminderController {
  final IsarService isarService = IsarService();
  final NotificationService notificationService = NotificationService();
  final Logger logger = Logger();

  late final Isar isar;

  Future<void> init() async {
    isar = await isarService.db;
  }

  // ----------------------------
  // ISAR DATABASE FUNCTIONS
  // ----------------------------
  // Insert
  Future<bool> addReminderInDB({required Reminder reminder}) async {
    bool inserted = false;

    await isar.writeTxn(() async {
      // Prevent duplicate reminder
      final existing = await isar.reminders.getByUid(reminder.uid);

      if (existing != null) {
        reminder.id = existing.id; // keep local Isar id
      }

      inserted = await isar.reminders.put(reminder) > 0;
    });

    logger.d("${reminder.title} reminder added");
    return inserted;
  }

  // Delete
  Future<bool> deleteReminder(Id id) async {
    return await isar.writeTxn(() async {
      return await isar.reminders.delete(id);
    });
  }

  Future<bool> deleteReminderByNoteUID(String noteUID) async {
    final reminder = await getReminderByNoteUid(noteUID);
    bool result = false;

    if (reminder == null) {
      logger.d("There is no reminder for note having uid: $noteUID");
      return result;
    }

    result = await deleteReminder(reminder.id);
    return result;
  }

  Future<Reminder?> getReminderByNoteUid(String noteUID) async {
    return await isar.reminders.filter().noteUIDEqualTo(noteUID).findFirst();
  }

  // Return list of reminders
  Future<List<Reminder>> getAllReminder() async {
    return isar.reminders.where().sortByTitle().findAll();
  }

  // To cancel reminders of a note
  Future<void> cancelReminders({Note? note, List<String>? uidList}) async {
    // Case 1: Single note provided
    if (note != null) {
      await cancelReminder(note);
      return;
    }

    // Case 2: List of UIDs provided
    if (uidList != null && uidList.isNotEmpty) {
      for (final uid in uidList) {
        final note = await isar.notes.where().uidEqualTo(uid).findFirst();

        if (note != null) await cancelReminder(note);
      }
    }
  }

  // Helper method of cancelReminders
  Future<void> cancelReminder(Note note) async {
    // Run both state checks at the exact same time
    final results = await Future.wait([
      notificationService.isTaskPinned(note.uid),
      notificationService.isTaskScheduled(note.uid),
    ]);

    final isPinned = results[0];
    final isScheduled = results[1];

    if (isPinned) {
      await notificationService.cancelPinnedTask(note.uid);
    }
    if (isScheduled) {
      await notificationService.cancelScheduledTask(note.uid);
    }
  }

  // Update note reminder when note is updated
  Future<void> updateNoteReminders(Note updatedNote) async {
    // Run status checks concurrently to save time
    final results = await Future.wait([
      notificationService.isTaskPinned(updatedNote.uid),
      notificationService.isTaskScheduled(updatedNote.uid),
    ]);

    final isPinned = results[0];
    final isScheduled = results[1];

    String content = updatedNote.content;
    String formattedContent = content;
    List<CheckNote> list = [];

    if (updatedNote.isCheckList) {
      list = NoteFunctions.convertContentToList(content) ?? [];
      formattedContent = NoteFunctions.getFormattedContent(list);
    }

    // If it's currently pinned, call show() again with the new note contents
    if (isPinned) {
      final reminder = Reminder(
        title: updatedNote.title,
        content: formattedContent,
        noteUID: updatedNote.uid,
        scheduledDT: null,
        isActive: true,
        isPinned: isPinned,
      );

      // Cancel old notification
      await notificationService.cancelPinnedTask(updatedNote.uid);

      // Delete old object
      await deleteReminderByNoteUID(updatedNote.uid);

      // Set updated note notification
      await notificationService.pinTaskToStatusBar(reminder);

      // Add new reminder object
      await addReminderInDB(reminder: reminder);

      notificationService.logger.d(
        'Refreshed pinned notification text for: ${updatedNote.uid}',
      );
    }

    // If it's scheduled for the future, fetch its payload date and reschedule it
    if (isScheduled) {
      final String? scheduledDateStr = await notificationService
          .getScheduledDate(updatedNote.uid);

      if (scheduledDateStr != null) {
        final DateTime? originalScheduledDate = DateTime.tryParse(
          scheduledDateStr,
        );

        if (originalScheduledDate != null) {
          final reminder = Reminder(
            title: updatedNote.title,
            content: formattedContent,
            noteUID: updatedNote.uid,
            scheduledDT: originalScheduledDate,
            isActive: true,
            isPinned: false,
          );

          // Cancel old notification
          await notificationService.cancelScheduledTask(updatedNote.uid);

          // Delete old object
          await deleteReminderByNoteUID(updatedNote.uid);

          // Set updated note notification
          final bool result = await notificationService.scheduleTaskReminder(
            reminder,
          );

          // Add new reminder object
          if (result) {
            await addReminderInDB(reminder: reminder);
          }

          notificationService.logger.d(
            'Refreshed scheduled notification text for: ${updatedNote.uid}',
          );
        }
      }
    }
  }

  // If user turned off notification and then turn on from app settings (manually), that time reminders are active but notification is cancelled. To handle this below reset method is used which is called on splash screen to check and schedule notification.
  Future<void> resetReminders(List<Note> unProtectedNotes) async {
    final List<String> failedReminderNoteUIDs = [];

    for (final note in unProtectedNotes) {
      final reminder = await getReminderByNoteUid(note.uid);

      if (reminder == null) continue;

      if (reminder.isPinned) {
        // Returns true if it is already active (Shown in notifications area)
        final bool active = await notificationService.isTaskPinned(
          reminder.noteUID,
        );

        // If not shown then only call the method
        if (active == false) {
          await notificationService.pinTaskToStatusBar(reminder);
        }

        continue;
      }

      final isScheduled = await notificationService.scheduleTaskReminder(
        reminder,
      );

      if (!isScheduled) {
        failedReminderNoteUIDs.add(reminder.noteUID);
      }
    }

    for (final noteUID in failedReminderNoteUIDs) {
      await deleteReminderByNoteUID(noteUID);
    }
  }
}
