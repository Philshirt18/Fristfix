import 'package:flutter/material.dart';
import '../models/recurrence.dart';
import '../theme/app_colors.dart';

/// Widget for selecting recurrence type.
/// All recurrence options are available for free users.
class RecurrenceSelector extends StatelessWidget {
  final RecurrenceType selected;
  final CustomRecurrence? customRecurrence;
  final bool isPremium;
  final ValueChanged<RecurrenceType> onChanged;
  final ValueChanged<CustomRecurrence> onCustomChanged;
  final VoidCallback onPremiumTap;

  const RecurrenceSelector({
    super.key,
    required this.selected,
    this.customRecurrence,
    required this.isPremium,
    required this.onChanged,
    required this.onCustomChanged,
    required this.onPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wiederholung',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 8),
        ...RecurrenceType.values.map((type) => _buildOption(context, type)),
        if (selected == RecurrenceType.custom) ...[
          const SizedBox(height: 12),
          _buildCustomIntervalPicker(context),
        ],
      ],
    );
  }

  Widget _buildOption(BuildContext context, RecurrenceType type) {
    final isSelected = selected == type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(type),
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
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.primaryOf(context)
                    : AppColors.mutedOf(context),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textOf(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomIntervalPicker(BuildContext context) {
    final current = customRecurrence ?? const CustomRecurrence(interval: 1, unit: RecurrenceUnit.months);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benutzerdefiniertes Intervall',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Alle',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textOf(context),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  controller: TextEditingController(
                      text: current.interval.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed > 0) {
                      onCustomChanged(
                          CustomRecurrence(interval: parsed, unit: current.unit));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<RecurrenceUnit>(
                  initialValue: current.unit,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: RecurrenceUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.label),
                    );
                  }).toList(),
                  onChanged: (unit) {
                    if (unit != null) {
                      onCustomChanged(CustomRecurrence(
                          interval: current.interval, unit: unit));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
