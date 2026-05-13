import 'package:flutter/material.dart';
import '../models/deadline.dart';
import '../models/deadline_status.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import 'status_badge.dart';
import 'app_card.dart';

class DeadlineCard extends StatelessWidget {
  final Deadline deadline;
  final VoidCallback? onTap;

  const DeadlineCard({
    super.key,
    required this.deadline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = deadline.status == DeadlineStatus.kritisch ||
        deadline.status == DeadlineStatus.bittePruefen;

    return AppCard(
      onTap: onTap,
      accentColor: isCritical ? AppColors.criticalOf(context) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: AppColors.backgroundOf(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                deadline.type.imagePath,
                width: 28,
                height: 28,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deadline.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOf(context),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: deadline.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${deadline.type.label}: ${AppDateUtils.formatDate(deadline.dueDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      deadline.daysRemainingText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    switch (deadline.status) {
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
