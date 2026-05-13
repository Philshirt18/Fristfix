import 'package:flutter/material.dart';
import '../models/deadline_status.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final DeadlineStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(context, status);

    return Semantics(
      label: status.label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _colorFor(BuildContext context, DeadlineStatus s) {
    switch (s) {
      case DeadlineStatus.imBlick:
        return AppColors.successOf(context);
      case DeadlineStatus.baldWichtig:
        return AppColors.warningOf(context);
      case DeadlineStatus.kritisch:
      case DeadlineStatus.bittePruefen:
        return AppColors.criticalOf(context);
      case DeadlineStatus.erledigt:
        return AppColors.mutedOf(context);
    }
  }
}
