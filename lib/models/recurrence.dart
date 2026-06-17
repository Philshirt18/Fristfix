/// Recurrence types for deadlines.
/// Weekly and custom are premium-only features.
enum RecurrenceType {
  none('Keine Wiederholung'),
  weekly('Wöchentlich'),       // PREMIUM
  monthly('Monatlich'),
  halfYearly('Halbjährlich'),
  yearly('Jährlich'),
  custom('Benutzerdefiniert'); // PREMIUM

  final String label;
  const RecurrenceType(this.label);

  /// All recurrence types are available in the free tier.
  bool get isPremium => false;

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrenceType.none,
    );
  }
}

/// Unit for custom recurrence intervals.
enum RecurrenceUnit {
  days('Tage'),
  weeks('Wochen'),
  months('Monate'),
  years('Jahre');

  final String label;
  const RecurrenceUnit(this.label);

  static RecurrenceUnit fromString(String value) {
    return RecurrenceUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrenceUnit.days,
    );
  }
}

/// Custom recurrence rule (e.g. every 3 months).
/// Only available for premium users.
class CustomRecurrence {
  final int interval;
  final RecurrenceUnit unit;

  const CustomRecurrence({
    required this.interval,
    required this.unit,
  });

  String get label => 'Alle $interval ${unit.label}';

  Map<String, dynamic> toJson() => {
        'interval': interval,
        'unit': unit.name,
      };

  factory CustomRecurrence.fromJson(Map<String, dynamic> json) {
    return CustomRecurrence(
      interval: json['interval'] as int,
      unit: RecurrenceUnit.fromString(json['unit'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomRecurrence &&
          interval == other.interval &&
          unit == other.unit;

  @override
  int get hashCode => Object.hash(interval, unit);
}
