import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/deadline.dart';
import '../models/deadline_category.dart';
import '../models/deadline_type.dart';
import '../models/deadline_status.dart';
import '../data/local_deadline_repository.dart';
import '../services/sync_service.dart';
import '../services/notification_service.dart';

/// Manages deadline state. Uses local Hive storage as primary source.
/// Optionally syncs to cloud via SyncService when backup is enabled.
class DeadlineProvider extends ChangeNotifier {
  final LocalDeadlineRepository _localRepo;
  final SyncService _syncService;
  final NotificationService _notificationService;

  List<Deadline> _deadlines = [];
  bool _isLoading = false;

  DeadlineProvider({
    required LocalDeadlineRepository localRepo,
    required SyncService syncService,
    required NotificationService notificationService,
  })  : _localRepo = localRepo,
        _syncService = syncService,
        _notificationService = notificationService;

  List<Deadline> get deadlines => _deadlines;
  bool get isLoading => _isLoading;

  // --- Active deadlines: not completed, not archived ---

  List<Deadline> get activeDeadlines =>
      _deadlines.where((d) => !d.isArchived && !d.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  int get activeDeadlineCount => activeDeadlines.length;

  List<Deadline> get completedDeadlines =>
      _deadlines.where((d) => d.isCompleted).toList();

  List<Deadline> get criticalDeadlines =>
      activeDeadlines
          .where((d) =>
              d.status == DeadlineStatus.kritisch ||
              d.status == DeadlineStatus.bittePruefen)
          .toList();

  List<Deadline> get soonImportantDeadlines =>
      activeDeadlines
          .where((d) => d.status == DeadlineStatus.baldWichtig)
          .toList();

  bool get hasCriticalDeadlines => criticalDeadlines.isNotEmpty;

  List<Deadline> filterByCategory(DeadlineCategory category) =>
      activeDeadlines.where((d) => d.category == category).toList();

  List<Deadline> filterByStatus(DeadlineStatus status) =>
      _deadlines.where((d) => d.status == status).toList();

  // --- CRUD ---

  Future<void> loadDeadlines() async {
    _isLoading = true;
    notifyListeners();

    _deadlines = await _localRepo.getAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDeadline({
    required String title,
    String? provider,
    required DeadlineCategory category,
    required DeadlineType type,
    required DateTime dueDate,
    DateTime? contractEndDate,
    DateTime? cancellationDate,
    String? notes,
    List<int> reminders = const [90, 30, 7],
  }) async {
    final now = DateTime.now();
    final deadline = Deadline(
      id: const Uuid().v4(),
      title: title,
      provider: provider,
      category: category,
      type: type,
      dueDate: dueDate,
      contractEndDate: contractEndDate,
      cancellationDate: cancellationDate,
      notes: notes,
      reminders: reminders,
      createdAt: now,
      updatedAt: now,
    );

    _deadlines.add(deadline);
    await _localRepo.save(deadline);
    await _syncService.syncDeadline(deadline);
    await _notificationService.scheduleDeadlineReminders(deadline);
    notifyListeners();
  }

  Future<void> updateDeadline(Deadline deadline) async {
    final index = _deadlines.indexWhere((d) => d.id == deadline.id);
    if (index != -1) {
      final updated = deadline.copyWith(updatedAt: DateTime.now());
      _deadlines[index] = updated;
      await _localRepo.save(updated);
      await _syncService.syncDeadline(updated);
      await _notificationService.cancelAllRemindersForDeadline(deadline);
      await _notificationService.scheduleDeadlineReminders(updated);
      notifyListeners();
    }
  }

  Future<void> markAsCompleted(String id) async {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = _deadlines[index].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      _deadlines[index] = updated;
      await _localRepo.save(updated);
      await _syncService.syncDeadline(updated);
      await _notificationService.cancelAllRemindersForDeadline(updated);
      notifyListeners();
    }
  }

  Future<void> archiveDeadline(String id) async {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = _deadlines[index].copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );
      _deadlines[index] = updated;
      await _localRepo.save(updated);
      await _syncService.syncDeadline(updated);
      await _notificationService.cancelAllRemindersForDeadline(updated);
      notifyListeners();
    }
  }

  Future<void> deleteDeadline(String id) async {
    final deadline = _deadlines.firstWhere((d) => d.id == id);
    _deadlines.removeWhere((d) => d.id == id);
    await _localRepo.delete(id);
    await _syncService.deleteRemoteDeadline(id);
    await _notificationService.cancelAllRemindersForDeadline(deadline);
    notifyListeners();
  }

  /// Delete all deadlines (used in settings).
  Future<void> deleteAllDeadlines() async {
    _deadlines.clear();
    await _localRepo.deleteAll();
    notifyListeners();
  }
}
