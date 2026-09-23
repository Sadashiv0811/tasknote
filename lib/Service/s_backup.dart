import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/Group/Model/m_group.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Other_Views/v_splash.dart';
import 'package:tasknote/Service/batch_helper.dart';

class BackupService {
  // Backs up notes and groups to firebase
  static Future<bool> backupToCloud({required String userId}) async {
    final isar = userController.isar;
    final logger = Logger();
    final db = FirebaseFirestore.instance;

    try {
      // Fetch local data
      final localNotes = await isar.notes.where().findAll();
      final localGroups = await isar.groups.where().findAll();

      // Process both collections
      final collections = <String, List<dynamic>>{
        'Notes': localNotes,
        'Groups': localGroups,
      };

      for (final entry in collections.entries) {
        final collectionRef = db
            .collection('Users')
            .doc(userId)
            .collection(entry.key);

        final localData = entry.value;

        // Fetch remote documents
        final remoteSnapshot = await collectionRef.get();
        final remoteUids = remoteSnapshot.docs.map((doc) => doc.id).toSet();
        final localUids = localData.map((item) => item.uid as String).toSet();

        // Documents that exist remotely but not locally
        final toDelete = remoteUids.difference(localUids);

        final batch = FirestoreBatchHelper(db);

        // Upload or update local documents
        for (final item in localData) {
          await batch.set(collectionRef.doc(item.uid), item.toMap(userId));
        }

        // Delete removed documents
        for (final uid in toDelete) {
          await batch.delete(collectionRef.doc(uid));
        }

        await batch.commit();
      }

      logger.d("Manual Backup Complete.");
      return true;
    } catch (e, stackTrace) {
      logger.e('Manual Backup Error', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
