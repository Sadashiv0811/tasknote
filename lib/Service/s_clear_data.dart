import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Service/batch_helper.dart';

class ClearDataService {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static final logger = Logger();

  // ############# Clear cloud data (Notes and Groups) #############

  static Future<bool> clearFirebaseGroups(String userId) async {
    try {
      // Get all groups belonging to the user's subcollection
      final querySnapshot = await db
          .collection('Users')
          .doc(userId)
          .collection('Groups')
          .get();

      // Initialize a write batch
      final batch = FirestoreBatchHelper(db);

      // Loop through documents and add them to the batch for deletion
      for (final doc in querySnapshot.docs) {
        await batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      logger.d('Error clearing Firebase groups: $e');
      return false;
    }
  }

  static Future<bool> clearFirebaseNotes(String userId) async {
    try {
      // Get all notes belonging to the user's specific subcollection
      final querySnapshot = await db
          .collection('Users')
          .doc(userId)
          .collection('Notes')
          .get();

      // Initialize a write batch
      final batch = FirestoreBatchHelper(db);

      // Loop through documents and add them to the batch for deletion
      for (final doc in querySnapshot.docs) {
        await batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      return true;
    } catch (e) {
      logger.d('Error clearing Firebase notes: $e');
      return false;
    }
  }

  // ############# Clear local data (Notes and Groups) #############
  static Future<bool> clearGroups() async {
    final isar = userController.isar;

    await isar.writeTxn(() async {
      await isar.groups.clear();
    });

    return true;
  }

  static Future<bool> clearNotes() async {
    final isar = userController.isar;

    await isar.writeTxn(() async {
      await isar.notes.clear();
    });

    return true;
  }
}
