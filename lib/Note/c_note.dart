import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Service/s_isar.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Service/s_note_security.dart';

class TaskStatus {
  final bool status;
  final String uid;
  const TaskStatus({required this.status, required this.uid});
}

class NoteController {
  final IsarService isarService = IsarService();
  final Logger logger = Logger();
  final NoteSecurityService noteSecurityService = NoteSecurityService.instance;

  late final Isar isar;

  Future<void> init() async {
    isar = await isarService.db;
  }

  // ----------------------------
  // ISAR DATABASE FUNCTIONS
  // ----------------------------

  // Insert (Checks Duplicate based on title)
  Future<TaskStatus> checkAndAddNote({
    required Note note,
    BuildContext? context,
  }) async {
    // Checks if note with same title exists.
    if (await noteExists(note.title)) {
      // ONLY show UI messages if context is provided and currently mounted
      if (context != null && context.mounted) {
        scaffoldMessenger("A note with this title already exists!");
      }

      return TaskStatus(status: false, uid: "null"); // Not added
    }

    int addedNoteId = 0;

    String uid = "";

    await isar.writeTxn(() async {
      final existing = await isar.notes
          .where()
          .uidEqualTo(note.uid)
          .findFirst();

      if (existing != null) {
        note.id = existing.id; // keep local Isar id
      }

      addedNoteId = await isar.notes.put(note);
      Note? n = await isar.notes.get(addedNoteId);
      uid = n!.uid.toString();
    });

    logger.d("Note added id: $addedNoteId\nuid: $uid");

    return TaskStatus(status: true, uid: uid); // added
  }

  // Update (Checks Duplicate based on title)
  Future<bool> checkAndUpdateNote({
    required Note oldNote,
    required Note newNote,
    BuildContext? context,
  }) async {
    // Check if the title has actually changed
    if (oldNote.title != newNote.title) {
      // Checks if note with same title exists.
      if (await noteExists(newNote.title)) {
        // ONLY show UI messages if context is provided and currently mounted
        if (context != null && context.mounted) {
          scaffoldMessenger("A note with this title already exists!");
        }

        return false; // Not added
      }
    }

    // Update
    await isar.writeTxn(() async {
      // Assign new values
      oldNote.title = newNote.title;
      oldNote.content = newNote.content;
      oldNote.createdAt = newNote.createdAt;
      oldNote.updatedAt = newNote.updatedAt;
      oldNote.decorColor = newNote.decorColor;

      await isar.notes.put(oldNote);
    });

    logger.d("Note updated id: ${oldNote.id}");
    return true; // Updated
  }

  // Delete
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
    logger.d("Note deleted id: $id");
  }

  // Multiple note select and delete
  Future<void> deleteMultipleNotes({required List<String> uidlist}) async {
    await isar.writeTxn(() async {
      for (var uid in uidlist) {
        // Delete reminder object
        await reminderController.deleteReminderByNoteUID(uid);

        // Delete note object
        await isar.notes.deleteByUid(uid);

        logger.d("Deleted note uid $uid");
      }
    });
  }

  // Get total no. of notes
  Future<int> getTotalNoteCount() async => (await isarService.db).notes.count();

  // Check if group exists
  Future<bool> noteExists(String title) async {
    final note = await isar.notes.filter().titleEqualTo(title).findFirst();

    return note != null;
  }

  // Returns list of notes where isProtected == false.
  Future<List<Note>> getUnProtectedNotesList() async {
    return await isar.notes.filter().isProtectedEqualTo(false).findAll();
  }

  // ----------------------------
  // STREAM FUNCTIONS
  // ----------------------------

  // Stream of List<Note> where calNote = false and grouped = false (NoteScreen)
  Stream<List<Note>> listenToNoteSchema(String sort) async* {
    final query = isar.notes
        .filter()
        .isProtectedEqualTo(false)
        .calNoteEqualTo(false)
        .groupedEqualTo(false);

    yield* query.watch(fireImmediately: true).asyncMap((_) async {
      switch (sort) {
        // All in Ascending Order except : Last updated and Created
        case "Created":
          return query.sortByCreatedAtDesc().findAll();
        case "Last updated":
          return query.sortByUpdatedAtDesc().findAll();
        case "Alphabetically":
          return query.sortByTitle().findAll();
        default:
          return query.sortByCreatedAt().findAll();
      }
    });
  }

  // Stream of List<Note> where calNote = true (CalenderScreen)
  Stream<List<Note>> listenToCalNoteSchema() async* {
    final query = isar.notes
        .filter()
        .calNoteEqualTo(true)
        .isProtectedEqualTo(false)
        .sortByUpdatedAtDesc();

    yield* query.watch(fireImmediately: true);
  }

  // Stream of List<Note> where grouped = true (GroupScreen)
  Stream<List<Note>> listenToGroupedNoteSchema() async* {
    final query = isar.notes
        .filter()
        .calNoteEqualTo(false)
        .groupedEqualTo(true)
        .isProtectedEqualTo(false)
        .sortByUpdatedAtDesc();

    yield* query.watch(fireImmediately: true);
  }

  // Stream of List<Note> where isProtected = true (ProtectedNotes)
  Stream<List<Note>> listenToProtectedNoteSchema(encrypt.Key masterKey) {
    final query = isar.notes
        .filter()
        .isProtectedEqualTo(true)
        .sortByUpdatedAtDesc();

    return query.watch(fireImmediately: true).map((encryptedNotes) {
      return encryptedNotes.map((note) {
        try {
          note.title = noteSecurityService.decryptText(note.title, masterKey);

          note.content = noteSecurityService.decryptText(
            note.content,
            masterKey,
          );

          return note;
        } catch (e) {
          logger.d("Failed to decrypt protected note ${note.id}: $e");

          note.title = "Decryption Error";
          note.content =
              "Failed to decrypt this note. The data may be corrupted.";

          return note;
        }
      }).toList();
    });
  }

  // ----------------------------
  // GROUP RELATED FUNCTIONS
  // ----------------------------

  // Batch Grouping/Ungrouping Helper to reduce code duplication
  Future<void> _toggleGroupStatus(
    List<String> uidList,
    String gName,
    bool status,
  ) async {
    await isar.writeTxn(() async {
      for (final uid in uidList) {
        final note = await isar.notes.getByUid(uid);
        if (note != null) {
          note.grouped = status;
          await isar.notes.put(note);
          logger.d(
            "Note $uid ${status ? 'added to' : 'removed from'} group: $gName",
          );
        }
      }
    });
  }

  // Multiple note select and make group
  Future<void> groupSelectedNotes({
    required List<String> uidList,
    required String gName,
  }) => _toggleGroupStatus(uidList, gName, true);

  // Ungroup notes
  Future<void> unGroupNotes({
    required List<String> uidList,
    required String gName,
  }) => _toggleGroupStatus(uidList, gName, false);

  // Group membership update helper
  Future<void> _modifyNoteInGroup({
    required int groupId,
    required String noteUid,
    required bool isAdding,
  }) async {
    Group? g = await groupController.getGroupById(groupId);

    if (g != null) {
      final idList = List<String>.from(g.notesUidsList ?? []);
      isAdding ? idList.add(noteUid) : idList.remove(noteUid);

      g.notesUidsList = idList;
      g.noteCount = idList.length;

      await isar.writeTxn(() => isar.groups.put(g));
      logger.d(
        "Note $noteUid ${isAdding ? 'added to' : 'removed from'} Group ID: $groupId",
      );
    }
  }

  // Add note inside group
  Future<void> addNoteInGroup({
    required int groupId,
    required String noteUid,
  }) => _modifyNoteInGroup(groupId: groupId, noteUid: noteUid, isAdding: true);

  // Remove note from group
  Future<void> removeNoteFromGroup({
    required int groupId,
    required String noteUid,
  }) => _modifyNoteInGroup(groupId: groupId, noteUid: noteUid, isAdding: false);

  // ----------------------------
  // PROTECTED NOTE RELATED FUNCTIONS
  // ----------------------------

  Future<bool> protectNote(Note note, encrypt.Key masterKey) async {
    try {
      final encryptedTitle = noteSecurityService.encryptText(
        note.title,
        masterKey,
      );

      final encryptedContent = noteSecurityService.encryptText(
        note.content,
        masterKey,
      );

      note.title = encryptedTitle;
      note.content = encryptedContent;
      note.isProtected = true;
      note.updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.notes.put(note);
      });

      return true;
    } catch (e, stackTrace) {
      logger.e("Error protecting note", error: e, stackTrace: stackTrace);

      return false;
    }
  }

  Future<bool> unprotectSingleNote(Note note, encrypt.Key masterKey) async {
    try {
      final decryptedTitle = noteSecurityService.decryptText(
        note.title,
        masterKey,
      );

      final decryptedContent = noteSecurityService.decryptText(
        note.content,
        masterKey,
      );

      note.title = decryptedTitle;
      note.content = decryptedContent;
      note.isProtected = false;
      note.updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.notes.put(note);
      });

      return true;
    } catch (e, stackTrace) {
      logger.e("Error unprotecting note", error: e, stackTrace: stackTrace);

      return false;
    }
  }

  Future<bool> unprotectNotes(List<Note> notes, encrypt.Key masterKey) async {
    try {
      await isar.writeTxn(() async {
        for (final note in notes) {
          // Fetch the encrypted version directly from Isar.
          final dbNote = await isar.notes.get(note.id);

          if (dbNote == null) continue;

          final decryptedTitle = noteSecurityService.decryptText(
            dbNote.title,
            masterKey,
          );

          final decryptedContent = noteSecurityService.decryptText(
            dbNote.content,
            masterKey,
          );

          dbNote.title = decryptedTitle;
          dbNote.content = decryptedContent;
          dbNote.isProtected = false;
          dbNote.updatedAt = DateTime.now();

          await isar.notes.put(dbNote);
        }
      });

      return true;
    } catch (e, stackTrace) {
      logger.e("Error unprotecting notes", error: e, stackTrace: stackTrace);

      return false;
    }
  }

  // ----------------------------
  // UTILITY FUNCTIONS
  // ----------------------------

  List<Note> getCalNotesForDay({
    required List<Note> sortedCalNoteList,
    required DateTime current,
  }) {
    return sortedCalNoteList.where((n) {
      final created = n.selectedD;
      return created!.year == current.year &&
          created.month == current.month &&
          created.day == current.day;
    }).toList();
  }

  // Wed, 8 December
  String formatDate(DateTime dt) => DateFormat('EEE, d MMMM').format(dt);
}
