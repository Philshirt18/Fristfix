import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme/app_colors.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/deadline.dart';
import '../../models/deadline_status.dart';
import '../../widgets/deadline_card.dart';

/// Fristenkalender – Monatsübersicht für gespeicherte Fristen.
/// Zeigt nur Fristen aus dem lokalen State, kein Netzwerkzugriff nötig.
/// Premium-Feature: Free-Nutzer sehen einen Upgrade-Hinweis.
class CalendarScreen extends StatefulWidget {
  final void Function(String id) onOpenDetail;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSettings;

  const CalendarScreen({
    super.key,
    required this.onOpenDetail,
    required this.onOpenPremium,
    required this.onOpenSettings,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeadlineProvider>();
    final appState = context.watch<AppStateProvider>();

    // --- Premium Gate ---
    if (!appState.isPremium) {
      return _buildPremiumGate(context);
    }

    final deadlines = provider.activeDeadlines;
    final selectedDay = _selectedDay ?? _focusedDay;
    final selectedDeadlines = _getDeadlinesForDay(selectedDay, deadlines);
    final monthHasDeadlines = _monthHasDeadlines(_focusedDay, deadlines);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fristenkalender'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: widget.onOpenSettings),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Deine gespeicherten Fristen im Monatsüberblick.',
              style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context)),
            ),
          ),
          const SizedBox(height: 8),

          // --- Monatsansicht ---
          TableCalendar<Deadline>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 730)),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Monat'},
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            eventLoader: (day) => _getDeadlinesForDay(day, deadlines),
            locale: 'de_DE',
            startingDayOfWeek: StartingDayOfWeek.monday,
            rowHeight: 44,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOf(context)),
              leftChevronIcon: Icon(Icons.chevron_left, size: 22, color: AppColors.mutedOf(context)),
              rightChevronIcon: Icon(Icons.chevron_right, size: 22, color: AppColors.mutedOf(context)),
              headerPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(4),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryOf(context).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: AppColors.primaryOf(context), fontWeight: FontWeight.w700, fontSize: 14),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryOf(context),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              defaultTextStyle: TextStyle(color: AppColors.textOf(context), fontSize: 14),
              weekendTextStyle: TextStyle(color: AppColors.textOf(context), fontSize: 14),
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerSize: 5,
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.8),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events.take(3).map((deadline) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _markerColorForStatus(context, deadline.status),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 11, color: AppColors.mutedOf(context), fontWeight: FontWeight.w600),
              weekendStyle: TextStyle(fontSize: 11, color: AppColors.mutedOf(context), fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 4),
          Divider(color: AppColors.dividerOf(context), height: 1),

          // --- Tagesansicht ---
          Expanded(
            child: !monthHasDeadlines
                ? _buildMonthEmpty(context)
                : selectedDeadlines.isEmpty
                    ? _buildDayEmpty(context)
                    : _buildDayList(context, selectedDeadlines),
          ),
        ],
      ),
    );
  }

  // --- Premium Gate Screen ---
  Widget _buildPremiumGate(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fristenkalender'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: widget.onOpenSettings),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 56, color: AppColors.primaryOf(context).withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text('Fristenkalender freischalten',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textOf(context)),
                textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('Sieh deine Fristen im Monatsüberblick und erkenne frühzeitig, was bald wichtig wird.',
                style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context), height: 1.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 28),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: widget.onOpenPremium, child: const Text('Premium ansehen'))),
            ],
          ),
        ),
      ),
    );
  }

  // --- Leerzustand: Monat ohne Fristen ---
  Widget _buildMonthEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Alles ruhig in diesem Monat.\nHier erscheinen deine gespeicherten Fristen.',
          style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // --- Leerzustand: Tag ohne Fristen ---
  Widget _buildDayEmpty(BuildContext context) {
    return Center(
      child: Text(
        'Keine Fristen an diesem Tag.',
        style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context)),
      ),
    );
  }

  // --- Fristenliste für ausgewählten Tag ---
  Widget _buildDayList(BuildContext context, List<Deadline> deadlines) {
    final count = deadlines.length;
    final headline = count == 1 ? '1 Frist an diesem Tag' : '$count Fristen an diesem Tag';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(headline, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedOf(context))),
        const SizedBox(height: 10),
        ...deadlines.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DeadlineCard(deadline: d, onTap: () => widget.onOpenDetail(d.id)),
        )),
      ],
    );
  }

  // --- Helpers ---

  List<Deadline> _getDeadlinesForDay(DateTime day, List<Deadline> deadlines) {
    return deadlines.where((d) => isSameDay(d.dueDate, day)).toList();
  }

  bool _monthHasDeadlines(DateTime month, List<Deadline> deadlines) {
    return deadlines.any((d) =>
        d.dueDate.year == month.year && d.dueDate.month == month.month);
  }

  /// Farbige Marker je nach Frist-Status
  Color _markerColorForStatus(BuildContext context, DeadlineStatus status) {
    switch (status) {
      case DeadlineStatus.kritisch:
      case DeadlineStatus.bittePruefen:
        return AppColors.criticalOf(context);
      case DeadlineStatus.baldWichtig:
        return AppColors.warningOf(context);
      case DeadlineStatus.imBlick:
        return AppColors.successOf(context);
      case DeadlineStatus.erledigt:
        return AppColors.mutedOf(context);
    }
  }
}
