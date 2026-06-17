/// Types of reminders.
enum ReminderType {
  /// Relative reminder: offset before the due date (in minutes).
  relative,

  /// Absolute reminder: specific date/time.
  absolute,
}

/// A flexible reminder for a deadline.
/// Can be relative (X minutes before due date) or absolute (exact DateTime).
class Reminder {
  final ReminderType type;

  /// For relative reminders: minutes before the due date.
  /// Examples: 7*24*60 = 10080 (7 days), 3*24*60 = 4320 (3 days),
  /// 24*60 = 1440 (1 day), 120 (2 hours), 30 (30 minutes).
  final int? offsetMinutes;

  /// For absolute reminders: exact date and time.
  final DateTime? exactDateTime;

  const Reminder.relative(this.offsetMinutes)
      : type = ReminderType.relative,
        exactDateTime = null;

  const Reminder.absolute(this.exactDateTime)
      : type = ReminderType.absolute,
        offsetMinutes = null;

  const Reminder({
    required this.type,
    this.offsetMinutes,
    this.exactDateTime,
  });

  /// Whether this reminder requires premium (< 24 hours or absolute).
  bool get isPremium {
    if (type == ReminderType.absolute) return true;
    if (offsetMinutes != null && offsetMinutes! < 1440) return true; // < 24h
    return false;
  }

  /// Human-readable label for this reminder.
  String get label {
    if (type == ReminderType.absolute && exactDateTime != null) {
      return 'Am ${exactDateTime!.day}.${exactDateTime!.month}. um ${exactDateTime!.hour.toString().padLeft(2, '0')}:${exactDateTime!.minute.toString().padLeft(2, '0')} Uhr';
    }

    if (offsetMinutes == null) return 'Unbekannt';

    final minutes = offsetMinutes!;
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      if (days == 1) return '1 Tag vorher';
      if (days == 7) return '1 Woche vorher';
      if (days == 14) return '2 Wochen vorher';
      if (days == 30) return '1 Monat vorher';
      if (days == 60) return '2 Monate vorher';
      if (days == 90) return '3 Monate vorher';
      return '$days Tage vorher';
    }
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      if (hours == 1) return '1 Stunde vorher';
      return '$hours Stunden vorher';
    }
    if (minutes == 1) return '1 Minute vorher';
    return '$minutes Minuten vorher';
  }

  /// Convert days-before (legacy format) to a Reminder.
  static Reminder fromDaysBefore(int days) {
    return Reminder.relative(days * 1440); // days * 24 * 60
  }

  /// Get days-before value for legacy compatibility.
  /// Returns null if not a whole-day relative reminder.
  int? get daysBefore {
    if (type != ReminderType.relative || offsetMinutes == null) return null;
    if (offsetMinutes! % 1440 != 0) return null;
    return offsetMinutes! ~/ 1440;
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'offsetMinutes': offsetMinutes,
        'exactDateTime': exactDateTime?.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'absolute') {
      return Reminder.absolute(
        json['exactDateTime'] != null
            ? DateTime.parse(json['exactDateTime'] as String)
            : null,
      );
    }
    return Reminder.relative(json['offsetMinutes'] as int?);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder &&
          type == other.type &&
          offsetMinutes == other.offsetMinutes &&
          exactDateTime == other.exactDateTime;

  @override
  int get hashCode => Object.hash(type, offsetMinutes, exactDateTime);
}
