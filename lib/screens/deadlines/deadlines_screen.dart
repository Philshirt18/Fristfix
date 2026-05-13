import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_category.dart';
import '../../models/deadline_suggestion.dart';
import '../../widgets/deadline_card.dart';
import '../../widgets/empty_state.dart';

class DeadlinesScreen extends StatefulWidget {
  final void Function(String id) onOpenDetail;
  final VoidCallback onOpenSettings;
  final VoidCallback onAddDeadline;
  final void Function(DeadlineSuggestion suggestion) onAddFromSuggestion;

  const DeadlinesScreen({
    super.key,
    required this.onOpenDetail,
    required this.onOpenSettings,
    required this.onAddDeadline,
    required this.onAddFromSuggestion,
  });

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  String _selectedFilter = 'Alle';

  final List<String> _filters = [
    'Alle',
    'Bald wichtig',
    'Kritisch',
    'Verträge',
    'Ausweise',
    'Auto',
    'Wohnung',
    'Steuer',
    'Erledigt',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DeadlineProvider>(
      builder: (context, provider, _) {
        final hasAnyDeadlines =
            provider.activeDeadlines.isNotEmpty ||
            provider.completedDeadlines.isNotEmpty;

        // Global empty state: no deadlines at all
        if (!hasAnyDeadlines) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meine Fristen'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: widget.onOpenSettings,
                ),
              ],
            ),
            body: _buildGlobalEmptyState(),
          );
        }

        final deadlines = _getFilteredDeadlines(provider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meine Fristen'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: widget.onOpenSettings,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Alles, was du nicht vergessen möchtest.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  separatorBuilder: (_, a) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedFilter = filter),
                      backgroundColor: AppColors.cardOf(context),
                      selectedColor: AppColors.primaryLightOf(context),
                      checkmarkColor: AppColors.primaryOf(context),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryOf(context)
                            : AppColors.mutedOf(context),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryOf(context)
                              : AppColors.dividerOf(context),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: deadlines.isEmpty
                    ? EmptyState(
                        icon: Icons.check_circle_outline,
                        headline: _selectedFilter == 'Erledigt'
                            ? 'Keine erledigten Fristen'
                            : 'Keine Fristen in dieser Kategorie',
                        subline: _selectedFilter == 'Erledigt'
                            ? 'Erledigte Fristen erscheinen hier.'
                            : 'Alles entspannt. Wir melden uns rechtzeitig.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: deadlines.length + 1,
                        separatorBuilder: (_, a) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == deadlines.length) {
                            return const SizedBox(height: 80);
                          }
                          final deadline = deadlines[index];
                          return DeadlineCard(
                            deadline: deadline,
                            onTap: () => widget.onOpenDetail(deadline.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlobalEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.list_alt_outlined,
            size: 64,
            color: AppColors.mutedOf(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Noch keine Fristen gespeichert',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textOf(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Speichere deine erste Frist und FristFix erinnert dich rechtzeitig.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mutedOf(context),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onAddDeadline,
              child: const Text('Erste Frist hinzufügen'),
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Häufige Fristen',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textOf(context),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DeadlineSuggestion.defaults.map((s) {
              return Material(
                color: AppColors.cardOf(context),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => widget.onAddFromSuggestion(s),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.dividerOf(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 16, color: AppColors.primaryOf(context)),
                        const SizedBox(width: 6),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List _getFilteredDeadlines(DeadlineProvider provider) {
    switch (_selectedFilter) {
      case 'Bald wichtig':
        return provider.soonImportantDeadlines;
      case 'Kritisch':
        return provider.criticalDeadlines;
      case 'Verträge':
        return provider.activeDeadlines
            .where((d) =>
                d.category == DeadlineCategory.handyInternet ||
                d.category == DeadlineCategory.stromGas ||
                d.category == DeadlineCategory.versicherung)
            .toList();
      case 'Ausweise':
        return provider.filterByCategory(DeadlineCategory.ausweisPass);
      case 'Auto':
        return provider.filterByCategory(DeadlineCategory.autoTuev);
      case 'Wohnung':
        return provider.filterByCategory(DeadlineCategory.wohnungMiete);
      case 'Steuer':
        return provider.filterByCategory(DeadlineCategory.steuer);
      case 'Erledigt':
        return provider.completedDeadlines;
      default:
        return provider.activeDeadlines;
    }
  }
}
