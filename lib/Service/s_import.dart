import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class ImportService {
  static final logger = Logger();
  static final db = FirebaseFirestore.instance;

  // Notes related
  static Future<FetchStatus> restoreNotes({
    required String userId,
    required QuerySnapshot querySnapshot,
  }) async {
    final isar = userController.isar;

    try {
      // Convert cloud documents to Note objects
      final List<Note> cloudNotes = querySnapshot.docs.map((doc) {
        return Note.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Get existing local notes
      final List<Note> localNotes = await isar.notes.where().findAll();
      final Map<String, Note> localNotesMap = {
        for (var n in localNotes) n.uid: n,
      };

      // Merge Cloud → Local
      // - Cloud note doesn't exist locally → insert
      // - Cloud note exists and is newer → update
      // - Local note is newer → keep local version

      await isar.writeTxn(() async {
        for (final cloudNote in cloudNotes) {
          final localNote = localNotesMap[cloudNote.uid];

          if (localNote == null) {
            // Note exists only in cloud.
            await isar.notes.put(cloudNote);
          } else if (cloudNote.updatedAt.isAfter(localNote.updatedAt)) {
            // Cloud version is newer.
            cloudNote.id = localNote.id;
            await isar.notes.put(cloudNote);
          }
          // Otherwise:
          // Local version is newer or same.
          // Keep the local note.
        }
      });

      logger.d(
        "Notes restore complete: "
        "${cloudNotes.length} cloud notes processed.",
      );
      return FetchStatus.fetched;
    } catch (e, stackTrace) {
      logger.e("Notes restore error", error: e, stackTrace: stackTrace);

      return FetchStatus.error;
    }
  }

  static Future<ImportData> checkNotesInFirebase({
    required String userId,
  }) async {
    QuerySnapshot querySnapshot = await db
        .collection('Users')
        .doc(userId)
        .collection('Notes')
        .get();

    return ImportData(
      isSnapEmpty: querySnapshot.docs.isEmpty,
      querySnapshot: querySnapshot,
    );
  }

  // Groups related
  static Future<FetchStatus> restoreGroups({
    required String userId,
    required QuerySnapshot querySnapshot,
  }) async {
    final isar = userController.isar;

    try {
      final List<Group> cloudGroups = querySnapshot.docs.map((doc) {
        return Group.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      final List<Group> localGroups = await isar.groups.where().findAll();
      final Map<String, Group> localGroupsMap = {
        for (var g in localGroups) g.uid: g,
      };

      await isar.writeTxn(() async {
        for (final cloudGroup in cloudGroups) {
          final localGroup = localGroupsMap[cloudGroup.uid];

          if (localGroup == null) {
            await isar.groups.put(cloudGroup);
          } else if (cloudGroup.updatedAt.isAfter(localGroup.updatedAt)) {
            cloudGroup.id = localGroup.id;
            await isar.groups.put(cloudGroup);
          }
        }
      });

      logger.d(
        "Groups restore complete: "
        "${cloudGroups.length} cloud groups processed.",
      );

      return FetchStatus.fetched;
    } catch (e, stackTrace) {
      logger.e("Groups restore error", error: e, stackTrace: stackTrace);

      return FetchStatus.error;
    }
  }

  static Future<ImportData> checkGroupsInFirebase({
    required String userId,
  }) async {
    QuerySnapshot querySnapshot = await db
        .collection('Users')
        .doc(userId)
        .collection('Groups')
        .get();

    return ImportData(
      isSnapEmpty: querySnapshot.docs.isEmpty,
      querySnapshot: querySnapshot,
    );
  }
}

class ImportData {
  final bool isSnapEmpty;
  final QuerySnapshot querySnapshot;
  const ImportData({required this.isSnapEmpty, required this.querySnapshot});
}
