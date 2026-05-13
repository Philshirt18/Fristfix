import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/deadline.dart';
import '../../models/deadline_category.dart';
import '../../providers/deadline_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/primary_button.dart';

class EditDeadlineScreen extends StatefulWidget {
  final Deadline deadline;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const EditDeadlineScreen({
    super.key,
    required this.deadline,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<EditDeadlineScreen> createState() => _EditDeadlineScreenState();
}

class _EditDeadlineScreenState extends State<EditDeadlineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _notesController;
  late DateTime _dueDate;
  late DeadlineCategory _category;
  late Set<int> _reminders;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deadline.title);
    _providerController =
        TextEditingController(text: widget.deadline.provider ?? '');
    _notesController =
        TextEditingController(text: widget.deadline.notes ?? '');
    _dueDate = widget.deadline.dueDate;
    _category = widget.deadline.category;
    _reminders = Set.from(widget.deadline.reminders);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;

    final updated = widget.deadline.copyWith(
      title: _nameController.text,
      provider: _providerController.text.isEmpty
          ? null
          : _providerController.text,
      category: _category,
      dueDate: _dueDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      reminders: _reminders.toList()..sort((a, b) => b.compareTo(a)),
    );

    await context.read<DeadlineProvider>().updateDeadline(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gespeichert. Wir erinnern dich rechtzeitig.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        title: const Text('Bearbeiten'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Name
          Text(
            'Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'z. B. Handyvertrag Vodafone',
            ),
          ),
          const SizedBox(height: 20),

          // Kategorie
          Text(
            'Kategorie',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DeadlineCategory.values.map((cat) {
              final isSelected = _category == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLightOf(context)
                        : AppColors.cardOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primaryOf(context) : AppColors.dividerOf(context),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon,
                          size: 16,
                          color: isSelected
                              ? AppColors.primaryOf(context)
                              : AppColors.mutedOf(context)),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? AppColors.primaryOf(context)
                              : AppColors.textOf(context),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Datum
          Text(
            'Datum',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2040),
                locale: const Locale('de', 'DE'),
              );
              if (picked != null) setState(() => _dueDate = picked);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dividerOf(context)),
              ),
              child: Row(
                children: [
                  Text(
                    AppDateUtils.formatDate(_dueDate),
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textOf(context),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today_outlined,
                      size: 20, color: AppColors.mutedOf(context)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Anbieter
          Text(
            'Anbieter (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _providerController,
            decoration: const InputDecoration(
              hintText: 'z. B. Vodafone',
            ),
          ),
          const SizedBox(height: 20),

          // Erinnerungen
          Text(
            'Erinnerungen',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildReminderToggle(90, '90 Tage vorher'),
          _buildReminderToggle(30, '30 Tage vorher'),
          _buildReminderToggle(7, '7 Tage vorher'),
          const SizedBox(height: 20),

          // Notiz
          Text(
            'Notiz (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'z. B. Kundennummer, Tarif',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          PrimaryButton(
            label: 'Änderungen speichern',
            onPressed: _save,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Abbrechen'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReminderToggle(int days, String label) {
    final isSelected = _reminders.contains(days);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _reminders.remove(days);
            } else {
              _reminders.add(days);
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLightOf(context)
                : AppColors.cardOf(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryOf(context) : AppColors.dividerOf(context),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: isSelected ? AppColors.primaryOf(context) : AppColors.mutedOf(context),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textOf(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
