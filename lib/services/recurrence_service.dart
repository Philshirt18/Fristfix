import '../models/deadline.dart';
import '../models/recurrence.dart';
import '../models/reminder.dart';

/// Service for calculating recurrence dates and managing recurring deadlines.
/// Pure business logic – no dependencies on UI or storage.
class RecurrenceService {
  const RecurrenceService();

  /// Calculate the next occurrence date based on the current due date
  /// and the recurrence configuration.
  DateTime calculateNextOccurrence(Deadline deadline) {
    final currentDue = deadline.dueDate;

    switch (deadline.recurrence) {
      case RecurrenceType.none:
        return currentDue;
      case RecurrenceType.weekly:
        return currentDue.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return _addMonths(currentDue, 1);
      case RecurrenceType.halfYearly:
        return _addMonths(currentDue, 6);
      case RecurrenceType.yearly:
        return _addMonths(currentDue, 12);
      case RecurrenceType.custom:
        return _calculateCustomNext(currentDue, deadline.customRecurrence);
    }
  }

  /// Create the next occurrence of a recurring deadline.
  /// Returns a new Deadline with updated dueDate and reset completion status.
  Deadline createNextOccurrence(Deadline deadline) {
    if (!deadline.isRecurring) return deadline;

    final nextDate = calculateNextOccurrence(deadline);

    return deadline.copyWith(
      dueDate: nextDate,
      nextOccurrenceDate: null, // Will be recalculated on next completion
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if a deadline should generate its next occurrence.
  /// A recurring deadline should advance when completed.
  bool shouldAdvance(Deadline deadline) {
    return deadline.isRecurring && deadline.isCompleted;
  }

  /// Calculate the next future occurrence date for a recurring deadline
  /// whose dueDate may be in the past. Advances until we find a future date.
  DateTime calculateNextFutureOccurrence(Deadline deadline) {
    if (!deadline.isRecurring) return deadline.dueDate;

    var nextDate = deadline.dueDate;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Advance until we get a date that is today or in the future
    int safety = 0;
    while (DateTime(nextDate.year, nextDate.month, nextDate.day)
            .isBefore(todayDate) &&
        safety < 1000) {
      final temp = deadline.copyWith(dueDate: nextDate);
      nextDate = calculateNextOccurrence(temp);
      safety++;
    }

    return nextDate;
  }

  /// Calculate all reminder DateTimes for a given deadline.
  /// For recurring deadlines whose dueDate is past, calculates reminders
  /// based on the next future occurrence.
  /// Returns a list of DateTime objects when reminders should fire.
  List<DateTime> calculateReminderDates(Deadline deadline) {
    final reminders = deadline.effectiveReminders;
    final dates = <DateTime>[];

    // For recurring deadlines, use the next future due date
    final effectiveDueDate = deadline.isRecurring
        ? calculateNextFutureOccurrence(deadline)
        : deadline.dueDate;

    for (final reminder in reminders) {
      final date = _reminderToDateTime(reminder, effectiveDueDate);
      if (date != null && date.isAfter(DateTime.now())) {
        dates.add(date);
      }
    }

    return dates;
  }

  /// Validate reminders for premium constraints.
  /// Returns reminders that are allowed for the user's tier.
  List<Reminder> filterRemindersForTier({
    required List<Reminder> reminders,
    required bool isPremium,
  }) {
    if (isPremium) return reminders;

    // Free users: max 1 reminder, no < 24h reminders
    final allowed = reminders.where((r) => !r.isPremium).toList();
    if (allowed.length > 1) {
      return [allowed.first];
    }
    return allowed;
  }

  /// Validate recurrence type for premium constraints.
  /// All recurrence types are now available for free users.
  RecurrenceType validateRecurrenceForTier({
    required RecurrenceType recurrence,
    required bool isPremium,
  }) {
    return recurrence;
  }

  // --- Private helpers ---

  DateTime _calculateCustomNext(
      DateTime currentDue, CustomRecurrence? custom) {
    if (custom == null) return currentDue;

    switch (custom.unit) {
      case RecurrenceUnit.days:
        return currentDue.add(Duration(days: custom.interval));
      case RecurrenceUnit.weeks:
        return currentDue.add(Duration(days: custom.interval * 7));
      case RecurrenceUnit.months:
        return _addMonths(currentDue, custom.interval);
      case RecurrenceUnit.years:
        return _addMonths(currentDue, custom.interval * 12);
    }
  }

  /// Add months to a date, clamping the day to the last valid day of the month.
  DateTime _addMonths(DateTime date, int months) {
    final newMonth = date.month + months;
    final year = date.year + (newMonth - 1) ~/ 12;
    final month = ((newMonth - 1) % 12) + 1;

    // Clamp day to last day of the target month
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;

    return DateTime(year, month, day, date.hour, date.minute);
  }

  /// Convert a Reminder to an absolute DateTime based on the due date.
  DateTime? _reminderToDateTime(Reminder reminder, DateTime dueDate) {
    switch (reminder.type) {
      case ReminderType.relative:
        if (reminder.offsetMinutes == null) return null;
        // Schedule at 9:00 AM for day-based reminders,
        // exact time for sub-day reminders
        if (reminder.offsetMinutes! >= 1440) {
          // Day-based: schedule at 9:00 AM
          final daysOffset = reminder.offsetMinutes! ~/ 1440;
          final reminderDate = dueDate.subtract(Duration(days: daysOffset));
          return DateTime(
            reminderDate.year,
            reminderDate.month,
            reminderDate.day,
            9,
            0,
          );
        } else {
          // Sub-day: exact offset from due date (assumed 9:00 AM on due day)
          final dueAt9 = DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
            9,
            0,
          );
          return dueAt9.subtract(Duration(minutes: reminder.offsetMinutes!));
        }
      case ReminderType.absolute:
        return reminder.exactDateTime;
    }
  }
}
