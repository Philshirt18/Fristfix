import 'dart:convert';
import 'deadline_category.dart';
import 'deadline_type.dart';
import 'deadline_status.dart';
import 'recurrence.dart';
import 'reminder.dart';

class Deadline {
  final String id;
  final String title;
  final String? provider;
  final DeadlineCategory category;
  final DeadlineType type;
  final DateTime dueDate;
  final DateTime? contractEndDate;
  final DateTime? cancellationDate;
  final String? notes;

  /// Legacy reminders: days before due date (kept for backward compatibility).
  final List<int> reminders;

  /// New flexible reminders (can be relative or absolute).
  final List<Reminder> flexibleReminders;

  /// Recurrence configuration.
  final RecurrenceType recurrence;
  final CustomRecurrence? customRecurrence;

  /// Next occurrence date for recurring deadlines.
  final DateTime? nextOccurrenceDate;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isArchived;

  /// Whether this deadline is currently active (not completed, not archived).
  bool get isActive => !isCompleted && !isArchived;

  Deadline({
    required this.id,
    required this.title,
    this.provider,
    required this.category,
    required this.type,
    required this.dueDate,
    this.contractEndDate,
    this.cancellationDate,
    this.notes,
    this.reminders = const [90, 30, 7],
    this.flexibleReminders = const [],
    this.recurrence = RecurrenceType.none,
    this.customRecurrence,
    this.nextOccurrenceDate,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.isArchived = false,
  });

  DeadlineStatus get status {
    if (isCompleted) return DeadlineStatus.erledigt;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final daysLeft = due.difference(today).inDays;

    if (daysLeft < 0) return DeadlineStatus.bittePruefen;
    if (daysLeft <= 7) return DeadlineStatus.kritisch;
    if (daysLeft <= 60) return DeadlineStatus.baldWichtig;
    return DeadlineStatus.imBlick;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  String get daysRemainingText {
    final days = daysRemaining;
    if (days < 0) return 'Vor ${-days} Tagen fällig';
    if (days == 0) return 'Heute fällig';
    if (days == 1) return 'Noch 1 Tag';
    return 'Noch $days Tage';
  }

  /// Whether this deadline has recurrence configured.
  bool get isRecurring => recurrence != RecurrenceType.none;

  /// Human-readable recurrence label.
  String get recurrenceLabel {
    if (!isRecurring) return 'Einmalig';
    if (recurrence == RecurrenceType.custom && customRecurrence != null) {
      return customRecurrence!.label;
    }
    return recurrence.label;
  }

  /// Get all effective reminders (combining legacy and flexible).
  /// If flexibleReminders is non-empty, use those. Otherwise convert legacy.
  List<Reminder> get effectiveReminders {
    if (flexibleReminders.isNotEmpty) return flexibleReminders;
    return reminders.map((days) => Reminder.fromDaysBefore(days)).toList();
  }

  Deadline copyWith({
    String? id,
    String? title,
    String? provider,
    DeadlineCategory? category,
    DeadlineType? type,
    DateTime? dueDate,
    DateTime? contractEndDate,
    DateTime? cancellationDate,
    String? notes,
    List<int>? reminders,
    List<Reminder>? flexibleReminders,
    RecurrenceType? recurrence,
    CustomRecurrence? customRecurrence,
    DateTime? nextOccurrenceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    bool? isArchived,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      category: category ?? this.category,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      notes: notes ?? this.notes,
      reminders: reminders ?? this.reminders,
      flexibleReminders: flexibleReminders ?? this.flexibleReminders,
      recurrence: recurrence ?? this.recurrence,
      customRecurrence: customRecurrence ?? this.customRecurrence,
      nextOccurrenceDate: nextOccurrenceDate ?? this.nextOccurrenceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'category': category.name,
      'type': type.name,
      'dueDate': dueDate.toIso8601String(),
      'contractEndDate': contractEndDate?.toIso8601String(),
      'cancellationDate': cancellationDate?.toIso8601String(),
      'notes': notes,
      'reminders': reminders,
      'flexibleReminders':
          flexibleReminders.map((r) => r.toJson()).toList(),
      'recurrence': recurrence.name,
      'customRecurrence': customRecurrence?.toJson(),
      'nextOccurrenceDate': nextOccurrenceDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'isArchived': isArchived,
    };
  }

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String?,
      category: DeadlineCategory.fromString(json['category'] as String),
      type: DeadlineType.fromString(json['type'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      contractEndDate: json['contractEndDate'] != null
          ? DateTime.parse(json['contractEndDate'] as String)
          : null,
      cancellationDate: json['cancellationDate'] != null
          ? DateTime.parse(json['cancellationDate'] as String)
          : null,
      notes: json['notes'] as String?,
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [90, 30, 7],
      flexibleReminders: (json['flexibleReminders'] as List<dynamic>?)
              ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recurrence: json['recurrence'] != null
          ? RecurrenceType.fromString(json['recurrence'] as String)
          : RecurrenceType.none,
      customRecurrence: json['customRecurrence'] != null
          ? CustomRecurrence.fromJson(
              json['customRecurrence'] as Map<String, dynamic>)
          : null,
      nextOccurrenceDate: json['nextOccurrenceDate'] != null
          ? DateTime.parse(json['nextOccurrenceDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Deadline.fromJsonString(String jsonString) {
    return Deadline.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
