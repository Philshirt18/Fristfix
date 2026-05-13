import 'dart:convert';
import 'deadline_category.dart';
import 'deadline_type.dart';
import 'deadline_status.dart';

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
  final List<int> reminders; // Tage vorher
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isArchived;

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
      reminders: (json['reminders'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
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
