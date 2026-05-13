import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'de_DE');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  static String daysRemainingText(DateTime date) {
    final days = daysUntil(date);
    if (days < 0) return 'Vor ${-days} Tagen fällig';
    if (days == 0) return 'Heute fällig';
    if (days == 1) return 'Noch 1 Tag';
    return 'Noch $days Tage';
  }

  static String reminderText(List<int> reminders) {
    if (reminders.isEmpty) return 'Keine Erinnerungen';
    final sorted = [...reminders]..sort((a, b) => b.compareTo(a));
    final parts = sorted.map((d) {
      if (d >= 30 && d % 30 == 0) {
        final months = d ~/ 30;
        return months == 1 ? '1 Monat' : '$months Monate';
      }
      return '$d Tage';
    });
    return '${parts.join(' / ')} vorher';
  }
}
