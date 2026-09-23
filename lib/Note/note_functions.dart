import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasknote/Note/Protected/v_protected_notes.dart';
import 'package:tasknote/Note/c_note.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Note/common.dart';
import 'package:tasknote/Service/s_note_security.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Note/Protected/v_note_auth.dart';
import 'package:tasknote/Note/Protected/v_set_password.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class NoteFunctions {
  // Detect changes
  static bool hasChanges(Note oldNote, Note newNote) {
    if (oldNote.title != newNote.title) {
      return true;
    }
    if (oldNote.content != newNote.content) {
      return true;
    }
    if (oldNote.decorColor != newNote.decorColor) {
      return true;
    }
    return false;
  }

  // Resulting List
  // [
  //   CheckNote(title: 'b', isEnabled: true),
  //   CheckNote(title: 'v', isEnabled: true),
  //   CheckNote(title: 'a', isEnabled: false),
  // ]
  static List<CheckNote>? convertContentToList(String content) {
    if (content == "" || content.isEmpty) return null;
    try {
      final List<dynamic> data = jsonDecode(content);

      return data.map((item) {
        final Map<String, dynamic> value = item as Map<String, dynamic>;

        return CheckNote(
          title: value['title'] as String,
          isEnabled: value['isEnabled'] as bool,
        );
      }).toList();
    } catch (e, stackTrace) {
      logger.e("Error converting content to list: $e\n Stack: $stackTrace");
      return null;
    }
  }

  // Resulting JSON string
  //   [
  //      {"title":"b","isEnabled":true},
  //      {"title":"v","isEnabled":true},
  //      {"title":"a","isEnabled":true}
  //    ]
  static String? convertListToContent(List<CheckNote> list) {
    if (list.isEmpty) {
      logger.d("Empty List");
      return null;
    }

    try {
      final data = list.map((item) {
        return {'title': item.title, 'isEnabled': item.isEnabled};
      }).toList();

      final String text = jsonEncode(data);

      logger.d(text);

      return text;
    } catch (e, stackTrace) {
      logger.e("Error converting list to content: $e\nStack: $stackTrace");
      return null;
    }
  }

  // Format json content to display
  static String? formatContent(String content, {bool isVertical = true}) {
    if (content == "" || content.isEmpty) return null;
    try {
      final List<dynamic> data = jsonDecode(content);

      return data
          .map((item) {
            final Map<String, dynamic> value = item as Map<String, dynamic>;

            return '-${value['title']}';
          })
          .join(isVertical ? '\n' : " ");
    } catch (e, stackTrace) {
      logger.e("Error formatting content: $e\nStack: $stackTrace");
      return null;
    }
  }

  // Format content to display in notification
  static String getFormattedContent(List<CheckNote> list) {
    String formattedContent = "";

    String body = list
        .map((note) {
          if (note.isEnabled) {
            return note.title;
          }
          // HTML tag to show horizontal bar on text.
          return '<s>${note.title}</s>';
        })
        .join(' - ');

    formattedContent = "- $body";
    return formattedContent;
  }

  // Format json content to share
  static String? formatContentToShare(String content) {
    if (content == "" || content.isEmpty) return null;
    try {
      final List<dynamic> data = jsonDecode(content);

      return data
          .map((item) {
            final Map<String, dynamic> value = item as Map<String, dynamic>;

            return '-${value['title']} ${value['isEnabled'] ? "" : "[\u2713]"}'; // \u2713 means tick mark
          })
          .join('\n');
    } catch (e, stackTrace) {
      logger.e("Error formatting content: $e\nStack: $stackTrace");
      return null;
    }
  }

  // Building note object
  static Note buildNoteFromCurrentState({
    required bool isEdit,
    required bool isCheckList,
    required String title,
    required String content,
    required String decorColor,

    required bool isCalNote,
    required DateTime? selectedDate,

    required bool isGroupNote,

    required Note? eNote,
  }) {
    final note = Note(
      uid: isEdit ? eNote!.uid : '',
      title: title,
      content: content,
      isCheckList: isCheckList,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      decorColor: decorColor,
    );

    // Calendar note logic
    if (isCalNote == true) {
      if (isEdit == false) {
        // Add
        note.calNote = true;
        note.selectedD = selectedDate;
      } else {
        // Edit
        note.calNote = eNote!.calNote;
        note.selectedD = eNote.selectedD;
      }
    }

    // Grouped note logic
    if (isGroupNote == true) note.grouped = true;

    // Update created date
    if (isEdit) note.createdAt = eNote!.createdAt;

    return note;
  }

  // Created and Updated date format
  static String formatCustom(DateTime dt, {bool short = false}) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    String year = dt.year.toString().substring(2); // last two digits

    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;

    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'pm' : 'am';

    if (short) {
      // Output - 8 Dec 7.30 pm
      return "${dt.day.toString()} ${DateFormat('MMM').format(dt)} $hour.$minute $period";
    } else {
      // Output - 08/12/25 7.30 pm
      return "$day/$month/$year $hour.$minute $period";
    }
  }

  // Silently executed in background
  static Future<bool> performAddOrEditInBackground({
    required bool isEdit,
    required Note? eNote,
    required Note note,
    required bool isGrouped,
    required int? groupId,
  }) async {
    bool success = false; // Track if the operation succeeded

    // Edit note
    if (isEdit) {
      // Save changes silently if any exist
      if (hasChanges(eNote!, note)) {
        success = await noteController.checkAndUpdateNote(
          oldNote: eNote,
          newNote: note,
        );

        // If there is any reminder, then the reminder is updated, after note is updated.
        if (success) await reminderController.updateNoteReminders(note);
      } else {
        success = false; // No changes, so mark as false
      }
    }
    // Add note
    else {
      TaskStatus ts = await noteController.checkAndAddNote(note: note);
      success = ts.status;

      if (isGrouped) {
        await noteController.addNoteInGroup(groupId: groupId!, noteUid: ts.uid);
      }
    }

    return success;
  }

  // Executed on user tap
  static Future<void> performAddOrEditOnTap({
    required bool isEdit,
    required Note? eNote,
    required Note note,
    required bool isGrouped,
    required int? groupId,
    required BuildContext context,
  }) async {
    // Edit note
    if (isEdit) {
      // Check if title or content or color is changed
      if (NoteFunctions.hasChanges(eNote!, note)) {
        bool updated = await noteController.checkAndUpdateNote(
          oldNote: eNote,
          newNote: note,
          context: context,
        );

        // If there is any reminder, then the reminder is updated, after note is updated.
        await reminderController.updateNoteReminders(note);

        if (updated && context.mounted) {
          Navigator.pop(context, "Edited");
        }
      } else {
        // NO CHANGES DETECTED:
        // Skip the database update, but STILL let the user leave the screen!
        Navigator.pop(context);
      }
    }
    // Add note
    else {
      TaskStatus ts = await noteController.checkAndAddNote(
        note: note,
        context: context,
      );

      String noteUid = ts.uid;
      bool added = ts.status;

      // Add note id in group.notesIdList
      if (isGrouped) {
        await noteController.addNoteInGroup(
          groupId: groupId!,
          noteUid: noteUid,
        );
      }

      if (added && context.mounted) {
        Navigator.pop(context, "Added");
      }
    }
  }

  // Delete single note
  static Future<void> singleNoteDelete({required Note? eNote}) async {
    // Cancel reminder
    await reminderController.cancelReminders(note: eNote!);

    // Delete reminder object
    await reminderController.deleteReminderByNoteUID(eNote.uid);

    // Delete note object
    await noteController.deleteNote(eNote.id);
  }

  /// Password protected note related
  static Future<void> handleLockPressed(LockNote lockNote) async {
    final bool result =
        await showDialog<bool>(
          barrierDismissible: false,
          context: lockNote.context,
          builder: (context) {
            return ReminderCancelDialog();
          },
        ) ??
        false;

    if (result == false) return;

    // User must be logged in
    if (!lockNote.isLoggedIn ||
        lockNote.user == null ||
        lockNote.user?.uid == null) {
      if (lockNote.context.mounted) {
        scaffoldMessenger("Please log in to access password-protected notes.");
      }

      return;
    }

    // Check whether note security has been configured
    final String? encryptedMasterKey = lockNote.user?.encryptedMasterKey;

    if (!lockNote.context.mounted) return;

    // First-time setup
    if (encryptedMasterKey == null || encryptedMasterKey.trim().isEmpty) {
      await setupNewPasswordFlow(lockNote);
      return;
    }

    // Existing password
    await authenticateExistingUserFlow(lockNote, encryptedMasterKey);
  }

  static Future<encrypt.Key?> setupNoteSecurity({
    required BuildContext context,
    required MUser user,
  }) async {
    final String? newPassword = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SetPasswordDialog(),
    );

    if (newPassword == null || newPassword.trim().isEmpty) {
      return null;
    }

    final password = newPassword.trim();

    try {
      final securityService = NoteSecurityService.instance;

      // Generate Master Key
      final masterKey = securityService.generateMasterKey();

      // Encrypt Master Key with Password
      final encryptedMasterKey = securityService.encryptMasterKey(
        masterKey,
        password,
      );

      // Generate Recovery Key
      final recoveryKey = securityService.generateRecoveryKey();

      // Encrypt Master Key with Recovery Key
      final encryptedRecoveryMasterKey = securityService
          .encryptMasterKeyWithRecoveryKey(masterKey, recoveryKey);

      // Hash Recovery Key
      final recoveryKeyHash = securityService.hashRecoveryKey(recoveryKey);

      // Hash Password
      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      // Update user
      user.passwordHash = passwordHash;
      user.encryptedMasterKey = encryptedMasterKey;
      user.encryptedRecoveryMasterKey = encryptedRecoveryMasterKey;
      user.recoveryKeyHash = recoveryKeyHash;
      user.securityVersion = 1;

      // Save Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .update({
            "passwordHash": passwordHash,
            "encryptedMasterKey": encryptedMasterKey,
            "encryptedRecoveryMasterKey": encryptedRecoveryMasterKey,
            "recoveryKeyHash": recoveryKeyHash,
            "securityVersion": 1,
          });

      // Save Isar
      await userController.update(user);

      // Keep Master Key in memory
      securityService.setMasterKey(masterKey);

      // Show Recovery Key
      if (!context.mounted) return null;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ShowRecoveryKeyDialog(recoveryKey: recoveryKey),
      );

      if (confirmed != true) {
        return null;
      }

      return masterKey;
    } catch (e, stackTrace) {
      logger.e(
        "Failed to setup note security",
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        scaffoldMessenger("Failed to set up password protection.");
      }

      return null;
    }
  }

  /// CASE A:
  /// First time setting up password protection.
  static Future<void> setupNewPasswordFlow(LockNote lockNote) async {
    try {
      final masterKey = await setupNoteSecurity(
        context: lockNote.context,
        user: lockNote.user!,
      );

      if (masterKey == null) {
        return;
      }

      // Master Key is already stored in NoteSecurityService.

      await protectNoteAndNotify(lockNote, masterKey);
    } catch (e, stackTrace) {
      logger.e(
        "Failed to setup password protection",
        error: e,
        stackTrace: stackTrace,
      );

      if (lockNote.context.mounted) {
        scaffoldMessenger("Failed to set up password protection.");
      }
    }
  }

  /// CASE B:
  /// Existing password-protected user.
  /// NoteAuth verifies the password and stores the Master Key
  /// inside NoteSecurityService.
  static Future<void> authenticateExistingUserFlow(
    LockNote lockNote,
    String encryptedMasterKey,
  ) async {
    final bool? isAuthenticated = await showDialog<bool>(
      context: lockNote.context,
      barrierDismissible: true,
      builder: (context) => const NoteAuth(),
    );

    // NoteAuth has already:
    //
    // password
    //    ↓
    // decryptMasterKey()
    //    ↓
    // Master Key
    //    ↓
    // NoteSecurityService.instance.setMasterKey()
    if (isAuthenticated != true) return;

    if (!lockNote.context.mounted) return;

    final securityService = NoteSecurityService.instance;

    final masterKey = securityService.masterKey;

    // Safety check.
    if (masterKey == null) {
      scaffoldMessenger("Authentication failed. Please try again.");

      return;
    }

    await protectNoteAndNotify(lockNote, masterKey);
  }

  /// Encrypt the note using the Master Key and save it.
  static Future<void> protectNoteAndNotify(
    LockNote lockNote,
    encrypt.Key masterKey,
  ) async {
    try {
      // Grab the latest text from the controllers
      lockNote.eNote!.title = lockNote.title;

      lockNote.eNote!.content = lockNote.content;

      // Cancel reminder.
      await reminderController.deleteReminderByNoteUID(lockNote.eNote!.uid);

      await reminderController.cancelReminder(lockNote.eNote!);

      // Encrypt title + content using Master Key.
      final result = await noteController.protectNote(
        lockNote.eNote!,
        masterKey,
      );

      // Success.
      if (result && lockNote.context.mounted) {
        scaffoldMessenger("Note is protected.");

        // Immediately leave the editor so that the plaintext
        // controller cannot overwrite the encrypted note.
        Navigator.of(lockNote.context).pop();
      }
    } catch (e, stackTrace) {
      logger.e("Failed to protect note", error: e, stackTrace: stackTrace);

      if (lockNote.context.mounted) {
        scaffoldMessenger("Failed to protect note.");
      }
    }
  }
}

class LockNote {
  final BuildContext context;
  final bool isLoggedIn;
  final String title, content;
  MUser? user;
  Note? eNote;

  LockNote({
    required this.context,
    required this.isLoggedIn,
    required this.title,
    required this.content,
    required this.user,
    required this.eNote,
  });
}
