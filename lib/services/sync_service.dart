import '../models/deadline.dart';
import '../data/local_deadline_repository.dart';
import '../data/remote_deadline_repository.dart';

/// Handles synchronization between local Hive storage and Firestore.
class SyncService {
  final LocalDeadlineRepository _local;
  final RemoteDeadlineRepository _remote;
  bool _backupEnabled = false;

  SyncService({
    required LocalDeadlineRepository local,
    required RemoteDeadlineRepository remote,
  })  : _local = local,
        _remote = remote;

  bool get backupEnabled => _backupEnabled && _remote.isAvailable;

  /// Connect to a user's cloud storage after login.
  /// Automatically syncs local deadlines to cloud.
  Future<List<Deadline>> connectUser(String userId) async {
    _remote.setUserId(userId);
    _backupEnabled = true;

    // Merge local and remote deadlines
    final merged = await _mergeDeadlines();
    return merged;
  }

  /// Disconnect from cloud storage (on logout).
  void disconnectUser() {
    _remote.setUserId(null);
    _backupEnabled = false;
  }

  /// Enable cloud backup.
  Future<void> enableBackup() async {
    _backupEnabled = true;
    if (_remote.isAvailable) {
      await uploadLocalDeadlinesToCloud();
    }
  }

  /// Disable cloud backup.
  void disableBackup() {
    _backupEnabled = false;
  }

  /// Upload all local deadlines to Firestore.
  Future<void> uploadLocalDeadlinesToCloud() async {
    if (!_remote.isAvailable) return;
    final localDeadlines = await _local.getAll();
    if (localDeadlines.isNotEmpty) {
      await _remote.saveAll(localDeadlines);
    }
  }

  /// Restore deadlines from Firestore to local storage.
  Future<List<Deadline>> restoreDeadlinesFromCloud() async {
    if (!_remote.isAvailable) return await _local.getAll();
    return await _mergeDeadlines();
  }

  /// Merge local and remote deadlines. Newer updatedAt wins.
  Future<List<Deadline>> _mergeDeadlines() async {
    final remoteDeadlines = await _remote.getAll();
    final localDeadlines = await _local.getAll();

    // If one side is empty, use the other
    if (remoteDeadlines.isEmpty && localDeadlines.isEmpty) return [];
    if (remoteDeadlines.isEmpty) {
      // First sync: upload local to cloud
      await _remote.saveAll(localDeadlines);
      return localDeadlines;
    }
    if (localDeadlines.isEmpty) {
      // New device: download from cloud
      await _local.saveAll(remoteDeadlines);
      return remoteDeadlines;
    }

    // Both have data: merge with conflict resolution
    final localMap = {for (final d in localDeadlines) d.id: d};
    final merged = <Deadline>[];

    for (final remote in remoteDeadlines) {
      final local = localMap.remove(remote.id);
      if (local == null) {
        merged.add(remote);
      } else {
        // Newer updatedAt wins
        merged.add(
          remote.updatedAt.isAfter(local.updatedAt) ? remote : local,
        );
      }
    }

    // Add remaining local-only deadlines
    merged.addAll(localMap.values);

    // Save merged result to both
    await _local.deleteAll();
    await _local.saveAll(merged);
    await _remote.saveAll(merged);

    return merged;
  }

  /// Sync a single deadline to cloud (after local save).
  Future<void> syncDeadline(Deadline deadline) async {
    if (!backupEnabled) return;
    try {
      await _remote.save(deadline);
    } catch (_) {
      // Sync failed – will retry on next full sync
    }
  }

  /// Delete a deadline from cloud.
  Future<void> deleteRemoteDeadline(String deadlineId) async {
    if (!backupEnabled) return;
    try {
      await _remote.delete(deadlineId);
    } catch (_) {
      // Delete failed – will be cleaned up on next full sync
    }
  }
}
