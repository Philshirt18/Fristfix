import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/deadline_suggestion.dart';
import '../../widgets/deadline_card.dart';
import '../../widgets/app_card.dart';
import '../../widgets/signup_prompt_card.dart';
import '../../widgets/premium_hint_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onAddDeadline;
  final void Function(String id) onOpenDetail;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSignup;
  final void Function(DeadlineSuggestion suggestion) onAddFromSuggestion;

  const DashboardScreen({
    super.key,
    required this.onAddDeadline,
    required this.onOpenDetail,
    required this.onOpenSettings,
    required this.onOpenPremium,
    required this.onOpenSignup,
    required this.onAddFromSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeadlineProvider>();
    final appState = context.watch<AppStateProvider>();
    final active = provider.activeDeadlines;
    final activeCount = provider.activeDeadlineCount;
    final critical = provider.criticalDeadlines;
    final soonImportant = provider.soonImportantDeadlines;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_v2.png', height: 28, fit: BoxFit.contain),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: onOpenSettings),
        ],
      ),
      body: active.isEmpty
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusHeader(context, critical),
                const SizedBox(height: 20),
                if (critical.isEmpty) _buildAllGoodCard(context),
                if (critical.isNotEmpty)
                  ...critical.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeadlineCard(deadline: d, onTap: () => onOpenDetail(d.id)),
                      )),
                if (appState.shouldShowSignupPrompt(activeCount)) ...[
                  const SizedBox(height: 20),
                  SignupPromptCard(onSignup: onOpenSignup, onDismiss: () => appState.dismissSignupPrompt()),
                ],
                if (appState.shouldShowPremiumHint(activeCount)) ...[
                  const SizedBox(height: 20),
                  PremiumHintCard(
                    onViewPremium: () { appState.dismissPremiumHintAtFive(); onOpenPremium(); },
                    onDismiss: () => appState.dismissPremiumHintAtFive(),
                  ),
                ],
                if (soonImportant.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Bald wichtig', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
                  const SizedBox(height: 12),
                  ...soonImportant.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeadlineCard(deadline: d, onTap: () => onOpenDetail(d.id)),
                      )),
                ],
                if (active.length > (critical.length + soonImportant.length)) ...[
                  const SizedBox(height: 24),
                  Text('Im Blick', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
                  const SizedBox(height: 12),
                  ...active
                      .where((d) => !critical.contains(d) && !soonImportant.contains(d))
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DeadlineCard(deadline: d, onTap: () => onOpenDetail(d.id)),
                          )),
                ],
                if (!appState.isPremium && activeCount > 0 && activeCount < 5) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Noch ${5 - activeCount} von 5 kostenlosen Fristen verfügbar',
                      style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context)),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isSmall ? 16 : 32),
                Image.asset('assets/images/logo_v2.png', width: isSmall ? 100 : 120, fit: BoxFit.contain),
                SizedBox(height: isSmall ? 20 : 28),
                Text('Noch keine Fristen gespeichert',
                  style: TextStyle(fontSize: isSmall ? 20 : 22, fontWeight: FontWeight.w700, color: AppColors.textOf(context)),
                  textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Speichere deine erste Frist und FristFix erinnert dich rechtzeitig.',
                    style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context), height: 1.5),
                    textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onAddDeadline, child: const Text('Erste Frist hinzufügen'))),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Häufige Fristen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mutedOf(context))),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DeadlineSuggestion.defaults.map((s) => _SuggestionChip(
                    label: s.label, icon: s.icon, onTap: () => onAddFromSuggestion(s),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(BuildContext context, List critical) {
    if (critical.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bitte prüfen', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textOf(context))),
          const SizedBox(height: 4),
          Text(
            critical.length == 1 ? 'Eine Frist ist bald erreicht.' : '${critical.length} Fristen sind bald erreicht.',
            style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context)),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alles im Blick', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textOf(context))),
        const SizedBox(height: 4),
        Text('Keine kritischen Fristen diese Woche.', style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context))),
      ],
    );
  }

  Widget _buildAllGoodCard(BuildContext context) {
    return AppCard(
      borderColor: AppColors.successOf(context).withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.successOf(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle_outline, color: AppColors.successOf(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Du bist gut vorbereitet.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOf(context))),
                const SizedBox(height: 4),
                Text('Wir erinnern dich rechtzeitig, wenn eine Frist wichtig wird.',
                  style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardOf(context),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.dividerOf(context)),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textOf(context))),
        ),
      ),
    );
  }
}
