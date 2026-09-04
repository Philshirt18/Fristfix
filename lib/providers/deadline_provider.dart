import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/deadline.dart';
import '../models/deadline_category.dart';
import '../models/deadline_type.dart';
import '../models/deadline_status.dart';
import '../models/recurrence.dart';
import '../models/reminder.dart';
import '../data/local_deadline_repository.dart';
import '../services/sync_service.dart';
import '../services/notification_service.dart';
import '../services/recurrence_service.dart';

/// Manages deadline state. Uses local Hive storage as primary source.
/// Optionally syncs to cloud via SyncService when backup is enabled.
class DeadlineProvider extends ChangeNotifier {
  final LocalDeadlineRepository _localRepo;
  final SyncService _syncService;
  final NotificationService _notificationService;
  final RecurrenceService _recurrenceService = const RecurrenceService();

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

  /// Get all recurring deadlines.
  List<Deadline> get recurringDeadlines =>
      _deadlines.where((d) => d.isRecurring && !d.isArchived).toList();

  List<Deadline> filterByCategory(DeadlineCategory category) =>
      activeDeadlines.where((d) => d.category == category).toList();

  List<Deadline> filterByStatus(DeadlineStatus status) =>
      _deadlines.where((d) => d.status == status).toList();

  // --- CRUD ---

  Future<void> loadDeadlines() async {
    _isLoading = true;
    notifyListeners();

    _deadlines = await _localRepo.getAll();

    // Auto-advance recurring deadlines whose due date is in the past
    try {
      await _autoAdvanceRecurringDeadlines();
    } catch (e) {
      debugPrint('Auto-advance failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Automatically advance recurring deadlines whose due date has passed.
  /// This ensures notifications get rescheduled for the next occurrence
  /// even if the user didn't explicitly mark the deadline as completed.
  Future<void> _autoAdvanceRecurringDeadlines() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < _deadlines.length; i++) {
      final deadline = _deadlines[i];
      if (!deadline.isRecurring || deadline.isCompleted || deadline.isArchived) {
        continue;
      }

      final dueDay = DateTime(
        deadline.dueDate.year,
        deadline.dueDate.month,
        deadline.dueDate.day,
      );

      if (dueDay.isBefore(today)) {
        // Advance to the next future occurrence
        await _notificationService.cancelAllRemindersForDeadline(deadline);

        final nextDueDate =
            _recurrenceService.calculateNextFutureOccurrence(deadline);
        final updated = deadline.copyWith(
          dueDate: nextDueDate,
          isCompleted: false,
          updatedAt: DateTime.now(),
        );

        _deadlines[i] = updated;
        await _localRepo.save(updated);
        await _syncService.syncDeadline(updated);
        await _notificationService.scheduleDeadlineReminders(updated);
      }
    }
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
    List<Reminder> flexibleReminders = const [],
    RecurrenceType recurrence = RecurrenceType.none,
    CustomRecurrence? customRecurrence,
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
      flexibleReminders: flexibleReminders,
      recurrence: recurrence,
      customRecurrence: customRecurrence,
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

  /// Mark a deadline as completed.
  /// For recurring deadlines: advances to the next occurrence instead of archiving.
  Future<void> markAsCompleted(String id) async {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      final deadline = _deadlines[index];

      if (deadline.isRecurring) {
        // Recurring: advance to next occurrence
        await _advanceRecurringDeadline(index);
      } else {
        // One-time: mark as completed
        final updated = deadline.copyWith(
          isCompleted: true,
          updatedAt: DateTime.now(),
        );
        _deadlines[index] = updated;
        await _localRepo.save(updated);
        await _syncService.syncDeadline(updated);
        await _notificationService.cancelAllRemindersForDeadline(updated);
      }
      notifyListeners();
    }
  }

  /// Advance a recurring deadline to its next occurrence.
  Future<void> _advanceRecurringDeadline(int index) async {
    final current = _deadlines[index];
    await _notificationService.cancelAllRemindersForDeadline(current);

    // Create next occurrence with new due date
    final next = _recurrenceService.createNextOccurrence(current);
    _deadlines[index] = next;

    await _localRepo.save(next);
    await _syncService.syncDeadline(next);
    await _notificationService.scheduleDeadlineReminders(next);
  }

  /// Stop a recurring deadline (set recurrence to none).
  Future<void> stopRecurrence(String id) async {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = _deadlines[index].copyWith(
        recurrence: RecurrenceType.none,
        customRecurrence: null,
        updatedAt: DateTime.now(),
      );
      _deadlines[index] = updated;
      await _localRepo.save(updated);
      await _syncService.syncDeadline(updated);
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
