import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/deadline.dart';
import '../../providers/deadline_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class DeadlineDetailsScreen extends StatelessWidget {
  final String deadlineId;
  final VoidCallback onBack;
  final void Function(Deadline) onEdit;

  const DeadlineDetailsScreen({
    super.key,
    required this.deadlineId,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DeadlineProvider>(
      builder: (context, provider, _) {
        final deadline = provider.deadlines
            .where((d) => d.id == deadlineId)
            .firstOrNull;

        if (deadline == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
            ),
            body: const Center(
              child: Text('Frist nicht gefunden.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            title: const Text('Fristdetails'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      deadline.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(status: deadline.status),
                ],
              ),
              const SizedBox(height: 24),

              // Main Card
              AppCard(
                borderColor: deadline.status.color.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.type.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppDateUtils.formatDate(deadline.dueDate),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOf(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deadline.daysRemainingText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: deadline.status.color,
                      ),
                    ),
                    if (deadline.reminders.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 16,
                            color: AppColors.mutedOf(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Wir erinnern dich ${AppDateUtils.reminderText(deadline.reminders)}.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedOf(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info Cards
              if (deadline.provider != null &&
                  deadline.provider!.isNotEmpty) ...[
                _buildInfoCard(
                  context,
                  icon: Icons.business_outlined,
                  label: 'Anbieter',
                  value: deadline.provider!,
                ),
                const SizedBox(height: 12),
              ],

              if (deadline.contractEndDate != null) ...[
                _buildInfoCard(
                  context,
                  icon: Icons.event_outlined,
                  label: 'Vertragsende',
                  value: AppDateUtils.formatDate(deadline.contractEndDate!),
                ),
                const SizedBox(height: 12),
              ],

              _buildInfoCard(
                context,
                icon: deadline.category.icon,
                label: 'Kategorie',
                value: deadline.category.label,
              ),
              const SizedBox(height: 12),

              if (deadline.notes != null &&
                  deadline.notes!.isNotEmpty) ...[
                _buildInfoCard(
                  context,
                  icon: Icons.note_outlined,
                  label: 'Notiz',
                  value: deadline.notes!,
                ),
                const SizedBox(height: 12),
              ],

              _buildInfoCard(
                context,
                icon: Icons.notifications_outlined,
                label: 'Erinnerungen',
                value: deadline.reminders.isEmpty
                    ? 'Keine Erinnerungen'
                    : '${deadline.reminders.length} aktiv – ${AppDateUtils.reminderText(deadline.reminders)}',
              ),

              // Recurrence info
              if (deadline.isRecurring) ...[
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  icon: Icons.repeat,
                  label: 'Wiederholung',
                  value: deadline.recurrenceLabel,
                ),
              ],

              const SizedBox(height: 32),

              // Actions
              if (!deadline.isCompleted)
                PrimaryButton(
                  label: deadline.isRecurring
                      ? 'Erledigt – nächste Frist erstellen'
                      : 'Als erledigt markieren',
                  onPressed: () {
                    provider.markAsCompleted(deadline.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          deadline.isRecurring
                              ? 'Erledigt. Nächste Frist wurde erstellt.'
                              : 'Erledigt. Diese Frist wurde archiviert.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    if (!deadline.isRecurring) onBack();
                  },
                ),

              if (!deadline.isCompleted && deadline.isRecurring) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      provider.stopRecurrence(deadline.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wiederholung beendet.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Wiederholung beenden'),
                  ),
                ),
              ],

              if (!deadline.isCompleted) const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => onEdit(deadline),
                  child: const Text('Bearbeiten'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    provider.archiveDeadline(deadline.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Frist archiviert.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    onBack();
                  },
                  child: const Text('Archivieren'),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _showDeleteDialog(context, provider, deadline),
                  child: Text(
                    'Löschen',
                    style: TextStyle(
                      color: AppColors.criticalOf(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightOf(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppColors.primaryOf(context)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bitte prüfe wichtige Fristen immer anhand deiner Originalunterlagen. FristFix hilft dir beim Erinnern, ersetzt aber keine rechtliche oder vertragliche Prüfung.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryOf(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.mutedOf(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, DeadlineProvider provider, Deadline deadline) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Frist löschen?'),
        content: const Text(
            'Diese Frist wird unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDeadline(deadline.id);
              Navigator.of(ctx).pop();
              onBack();
            },
            child: Text(
              'Löschen',
              style: TextStyle(color: AppColors.criticalOf(ctx)),
            ),
          ),
        ],
      ),
    );
  }
}
