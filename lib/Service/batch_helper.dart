import 'package:cloud_firestore/cloud_firestore.dart';

// Advantages
// Reusable across your entire project.
// Automatically commits every 450 operations.
// Supports set, update, and delete.
// No duplicated batch management code.

class FirestoreBatchHelper {
  FirestoreBatchHelper(this._firestore, {this.maxOperations = 450})
    : _batch = _firestore.batch();

  final FirebaseFirestore _firestore;
  final int maxOperations;

  late WriteBatch _batch;
  int _operationCount = 0;

  Future<void> set(
    DocumentReference<Map<String, dynamic>> doc,
    Map<String, dynamic> data, {
    SetOptions? options,
  }) async {
    _batch.set(doc, data, options);
    await _increment();
  }

  Future<void> update(
    DocumentReference<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) async {
    _batch.update(doc, data);
    await _increment();
  }

  Future<void> delete(DocumentReference<Map<String, dynamic>> doc) async {
    _batch.delete(doc);
    await _increment();
  }

  Future<void> _increment() async {
    _operationCount++;

    if (_operationCount >= maxOperations) {
      await commit();
    }
  }

  Future<void> commit() async {
    if (_operationCount == 0) return;

    await _batch.commit();

    _batch = _firestore.batch();
    _operationCount = 0;
  }
}
