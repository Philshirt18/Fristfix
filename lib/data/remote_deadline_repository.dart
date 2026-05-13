import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deadline.dart';

/// Remote deadline storage using Firestore.
///
/// Firestore structure:
///   users/{userId}/deadlines/{deadlineId}
class RemoteDeadlineRepository {
  String? _userId;

  RemoteDeadlineRepository({String? userId}) : _userId = userId;

  bool get isAvailable => _userId != null;

  void setUserId(String? userId) {
    _userId = userId;
  }

  CollectionReference<Map<String, dynamic>> get _deadlinesRef {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('deadlines');
  }

  /// Upload a single deadline to Firestore.
  Future<void> save(Deadline deadline) async {
    if (!isAvailable) return;
    await _deadlinesRef.doc(deadline.id).set(deadline.toJson());
  }

  /// Upload all local deadlines to Firestore.
  Future<void> saveAll(List<Deadline> deadlines) async {
    if (!isAvailable) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final d in deadlines) {
      batch.set(_deadlinesRef.doc(d.id), d.toJson());
    }
    await batch.commit();
  }

  /// Fetch all deadlines from Firestore.
  Future<List<Deadline>> getAll() async {
    if (!isAvailable) return [];
    final snapshot = await _deadlinesRef.get();
    return snapshot.docs
        .map((doc) => Deadline.fromJson(doc.data()))
        .toList();
  }

  /// Delete a deadline from Firestore.
  Future<void> delete(String deadlineId) async {
    if (!isAvailable) return;
    await _deadlinesRef.doc(deadlineId).delete();
  }

  /// Delete all deadlines from Firestore.
  Future<void> deleteAll() async {
    if (!isAvailable) return;
    final snapshot = await _deadlinesRef.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
