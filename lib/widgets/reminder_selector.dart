import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../theme/app_colors.dart';

/// Preset reminder options for the UI.
class _ReminderPreset {
  final Reminder reminder;
  final String label;
  final bool isPremium;

  const _ReminderPreset({
    required this.reminder,
    required this.label,
    required this.isPremium,
  });
}

/// Widget for selecting reminders for a deadline.
/// Free users can select one reminder from day-based presets.
/// Premium users can select multiple and use short-notice reminders.
class ReminderSelector extends StatelessWidget {
  final List<Reminder> selectedReminders;
  final bool isPremium;
  final ValueChanged<List<Reminder>> onChanged;
  final VoidCallback onPremiumTap;

  const ReminderSelector({
    super.key,
    required this.selectedReminders,
    required this.isPremium,
    required this.onChanged,
    required this.onPremiumTap,
  });

  static final List<_ReminderPreset> _presets = [
    _ReminderPreset(
      reminder: Reminder.fromDaysBefore(90),
      label: '3 Monate vorher',
      isPremium: false,
    ),
    _ReminderPreset(
      reminder: Reminder.fromDaysBefore(30),
      label: '1 Monat vorher',
      isPremium: false,
    ),
    _ReminderPreset(
      reminder: Reminder.fromDaysBefore(7),
      label: '7 Tage vorher',
      isPremium: false,
    ),
    _ReminderPreset(
      reminder: Reminder.fromDaysBefore(3),
      label: '3 Tage vorher',
      isPremium: false,
    ),
    _ReminderPreset(
      reminder: Reminder.fromDaysBefore(1),
      label: '1 Tag vorher',
      isPremium: false,
    ),
    _ReminderPreset(
      reminder: const Reminder.relative(120), // 2 hours
      label: '2 Stunden vorher',
      isPremium: true,
    ),
    _ReminderPreset(
      reminder: const Reminder.relative(60), // 1 hour
      label: '1 Stunde vorher',
      isPremium: true,
    ),
    _ReminderPreset(
      reminder: const Reminder.relative(30), // 30 minutes
      label: '30 Minuten vorher',
      isPremium: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Erinnerungen',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPremium
              ? 'Wähle beliebig viele Erinnerungen.'
              : 'Wähle eine Erinnerung. Mehr mit Premium.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 12),
        ..._presets.map((preset) => _buildPresetOption(context, preset)),
      ],
    );
  }

  Widget _buildPresetOption(BuildContext context, _ReminderPreset preset) {
    final isSelected = selectedReminders.contains(preset.reminder);
    final isLocked = preset.isPremium && !isPremium;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (isLocked) {
            onPremiumTap();
            return;
          }
          _toggleReminder(preset.reminder);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLightOf(context)
                : AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOf(context)
                  : AppColors.dividerOf(context),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: isSelected
                    ? AppColors.primaryOf(context)
                    : AppColors.mutedOf(context),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  preset.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isLocked
                        ? AppColors.mutedOf(context)
                        : AppColors.textOf(context),
                  ),
                ),
              ),
              if (isLocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightOf(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOf(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleReminder(Reminder reminder) {
    final updatedList = List<Reminder>.from(selectedReminders);

    if (updatedList.contains(reminder)) {
      updatedList.remove(reminder);
    } else {
      if (!isPremium) {
        // Free: only 1 reminder allowed
        updatedList.clear();
      }
      updatedList.add(reminder);
    }

    onChanged(updatedList);
  }
}
