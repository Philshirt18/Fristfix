import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../models/deadline_type.dart';
import '../../models/deadline_category.dart';
import '../../models/deadline_suggestion.dart';
import '../../models/recurrence.dart';
import '../../models/reminder.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/premium_paywall.dart';
import '../../widgets/signup_prompt_card.dart';
import '../../widgets/premium_hint_card.dart';
import '../../widgets/recurrence_selector.dart';
import '../../widgets/reminder_selector.dart';
import '../../utils/date_utils.dart';

class AddDeadlineScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSignup;
  final DeadlineSuggestion? initialSuggestion;

  const AddDeadlineScreen({
    super.key,
    required this.onComplete,
    required this.onCancel,
    required this.onOpenPremium,
    required this.onOpenSignup,
    this.initialSuggestion,
  });

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  int _step = 0;
  DeadlineType? _selectedType;
  DeadlineCategory? _selectedCategory;

  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _dueDate;
  DateTime? _contractEndDate;
  bool _showConfirmation = false;

  // Recurrence state
  RecurrenceType _recurrence = RecurrenceType.none;
  CustomRecurrence? _customRecurrence;

  // Reminder state (new flexible system)
  List<Reminder> _selectedFlexibleReminders = [
    Reminder.fromDaysBefore(90),
    Reminder.fromDaysBefore(30),
    Reminder.fromDaysBefore(7),
  ];

  // Post-save prompt state
  bool _showSignupAfterSave = false;
  bool _showPremiumHintAfterSave = false;

  @override
  void initState() {
    super.initState();
    // Apply preselection from suggestion chip
    if (widget.initialSuggestion != null) {
      _selectedType = widget.initialSuggestion!.type;
      _selectedCategory = widget.initialSuggestion!.category;
      _step = 1; // Skip to form, type & category already set
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      widget.onCancel();
    }
  }

  Future<void> _saveDeadline() async {
    if (_nameController.text.isEmpty || _dueDate == null) return;

    final provider = context.read<DeadlineProvider>();
    final appState = context.read<AppStateProvider>();
    final activeCount = provider.activeDeadlineCount;

    // Block at 5+ active (6th deadline) if not premium
    if (!appState.canAddNewDeadline(activeCount)) {
      final result = await PremiumPaywall.show(context);
      if (result != true) {
        return;
      }
      if (!mounted) return;
    }

    // Convert flexible reminders to legacy format for backward compat
    final legacyReminders = _selectedFlexibleReminders
        .where((r) => r.daysBefore != null)
        .map((r) => r.daysBefore!)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    await provider.addDeadline(
      title: _nameController.text,
      provider: _providerController.text.isEmpty
          ? null
          : _providerController.text,
      category: _selectedCategory ?? DeadlineCategory.sonstiges,
      type: _selectedType ?? DeadlineType.eigeneErinnerung,
      dueDate: _dueDate!,
      contractEndDate: _contractEndDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      reminders: legacyReminders.isNotEmpty ? legacyReminders : const [30, 7],
      flexibleReminders: _selectedFlexibleReminders,
      recurrence: _recurrence,
      customRecurrence: _customRecurrence,
    );

    // Check post-save prompts
    final newActiveCount = provider.activeDeadlineCount;

    if (appState.shouldShowSignupPrompt(newActiveCount)) {
      _showSignupAfterSave = true;
    }

    if (appState.shouldShowPremiumHint(newActiveCount)) {
      _showPremiumHintAfterSave = true;
    }

    setState(() => _showConfirmation = true);
  }

  void _resetForm() {
    setState(() {
      _step = 0;
      _selectedType = null;
      _selectedCategory = null;
      _nameController.clear();
      _providerController.clear();
      _notesController.clear();
      _dueDate = null;
      _contractEndDate = null;
      _recurrence = RecurrenceType.none;
      _customRecurrence = null;
      _selectedFlexibleReminders = [
        Reminder.fromDaysBefore(90),
        Reminder.fromDaysBefore(30),
        Reminder.fromDaysBefore(7),
      ];
      _showConfirmation = false;
      _showSignupAfterSave = false;
      _showPremiumHintAfterSave = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _showConfirmation ? widget.onComplete : _prevStep,
        ),
        title: Text(
            _showConfirmation ? 'Frist gespeichert' : 'Frist hinzufügen'),
      ),
      body: _showConfirmation ? _buildConfirmation() : _buildStep(),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildTypeSelection();
      case 1:
        return _buildForm();
      case 2:
        return _buildRecurrenceAndReminders();
      case 3:
        return _buildSummary();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTypeSelection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Was möchtest du speichern?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 24),
        ...DeadlineType.values.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTypeCard(type),
            )),
      ],
    );
  }

  Widget _buildTypeCard(DeadlineType type) {
    final isSelected = _selectedType == type;
    return AppCard(
      borderColor: isSelected ? AppColors.primaryOf(context) : null,
      onTap: () {
        setState(() => _selectedType = type);
        _nextStep();
      },
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryLightOf(context)
                  : AppColors.backgroundOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(type.imagePath, width: 36, height: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.mutedOf(context)),
        ],
      ),
    );
  }

  // --- Type-specific form customization ---

  String get _nameLabel {
    switch (_selectedType) {
      case DeadlineType.geburtstag:
        return 'Name der Person';
      default:
        return 'Name';
    }
  }

  String get _nameHint {
    switch (_selectedType) {
      case DeadlineType.kuendigungsfrist:
        return 'z. B. Handyvertrag Vodafone';
      case DeadlineType.ablaufdatum:
        return 'z. B. Personalausweis, Reisepass';
      case DeadlineType.termin:
        return 'z. B. Steuerberater, Bürgeramt';
      case DeadlineType.geburtstag:
        return 'z. B. Mama, Max, Lisa';
      case DeadlineType.eigeneErinnerung:
        return 'z. B. Wohnung kündigen, Reifen wechseln';
      default:
        return 'Name der Frist';
    }
  }

  bool get _showProviderField {
    switch (_selectedType) {
      case DeadlineType.kuendigungsfrist:
      case DeadlineType.ablaufdatum:
        return true;
      default:
        return false;
    }
  }

  String get _providerLabel {
    switch (_selectedType) {
      case DeadlineType.ablaufdatum:
        return 'Ausstellende Behörde (optional)';
      default:
        return 'Anbieter (optional)';
    }
  }

  String get _providerHint {
    switch (_selectedType) {
      case DeadlineType.kuendigungsfrist:
        return 'z. B. Vodafone, Allianz, E.ON';
      case DeadlineType.ablaufdatum:
        return 'z. B. Bürgeramt, Landratsamt';
      default:
        return 'z. B. Anbieter';
    }
  }

  bool get _showContractEndField {
    return _selectedType == DeadlineType.kuendigungsfrist;
  }

  String get _dateLabel {
    switch (_selectedType) {
      case DeadlineType.kuendigungsfrist:
        return 'Spätestes Kündigungsdatum';
      case DeadlineType.ablaufdatum:
        return 'Ablaufdatum';
      case DeadlineType.termin:
        return 'Datum des Termins';
      case DeadlineType.geburtstag:
        return 'Geburtstag';
      case DeadlineType.eigeneErinnerung:
        return 'Datum';
      default:
        return 'Relevantes Datum';
    }
  }

  String get _notesHint {
    switch (_selectedType) {
      case DeadlineType.kuendigungsfrist:
        return 'z. B. Kundennummer, Tarif, Vertragsnummer';
      case DeadlineType.ablaufdatum:
        return 'z. B. Ausweisnummer, Ausstellungsdatum';
      case DeadlineType.termin:
        return 'z. B. Adresse, Unterlagen mitbringen';
      case DeadlineType.geburtstag:
        return 'z. B. Geschenkidee, Alter';
      case DeadlineType.eigeneErinnerung:
        return 'z. B. Details, Hinweise';
      default:
        return 'z. B. Notizen';
    }
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Details eintragen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _nameLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: _nameHint,
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        if (_showProviderField) ...[
          Text(
            _providerLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _providerController,
            decoration: InputDecoration(
              hintText: _providerHint,
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
        ],
        if (_showContractEndField) ...[
          Text(
            'Vertragsende (optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOf(context),
            ),
          ),
          const SizedBox(height: 8),
          _buildDatePicker(
            date: _contractEndDate,
            hint: 'Datum wählen',
            onPicked: (d) => setState(() => _contractEndDate = d),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          _dateLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 8),
        _buildDatePicker(
          date: _dueDate,
          hint: 'Datum wählen',
          onPicked: (d) => setState(() => _dueDate = d),
          isRequired: true,
        ),
        const SizedBox(height: 20),
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
          decoration: InputDecoration(
            hintText: _notesHint,
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Weiter',
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bitte gib einen Namen ein.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            if (_dueDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bitte wähle ein Datum aus.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            _nextStep();
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDatePicker({
    required DateTime? date,
    required String hint,
    required ValueChanged<DateTime> onPicked,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
          locale: const Locale('de', 'DE'),
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerOf(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? AppDateUtils.formatDate(date) : hint,
                style: TextStyle(
                  fontSize: 15,
                  color: date != null
                      ? AppColors.textOf(context)
                      : AppColors.mutedOf(context),
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.mutedOf(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Recurrence + Reminders combined on one screen.
  Widget _buildRecurrenceAndReminders() {
    final appState = context.watch<AppStateProvider>();
    final isPremium = appState.isPremium;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Wiederholung & Erinnerungen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Stelle ein, wie oft die Frist wiederkehrt und wann wir dich erinnern sollen.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 24),

        // Recurrence section
        RecurrenceSelector(
          selected: _recurrence,
          customRecurrence: _customRecurrence,
          isPremium: isPremium,
          onChanged: (type) => setState(() => _recurrence = type),
          onCustomChanged: (custom) =>
              setState(() => _customRecurrence = custom),
          onPremiumTap: widget.onOpenPremium,
        ),

        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 20),

        // Reminder section
        ReminderSelector(
          selectedReminders: _selectedFlexibleReminders,
          isPremium: isPremium,
          onChanged: (reminders) =>
              setState(() => _selectedFlexibleReminders = reminders),
          onPremiumTap: widget.onOpenPremium,
        ),

        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Weiter zur Übersicht',
          onPressed: _nextStep,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Step 3: Summary before saving.
  Widget _buildSummary() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Zusammenfassung',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Name', _nameController.text),
              if (_providerController.text.isNotEmpty)
                _summaryRow('Anbieter', _providerController.text),
              if (_dueDate != null)
                _summaryRow('Datum', AppDateUtils.formatDate(_dueDate!)),
              if (_selectedType != null)
                _summaryRow('Typ', _selectedType!.label),
              _summaryRow('Wiederholung', _recurrenceLabel),
              _summaryRow(
                'Erinnerungen',
                _selectedFlexibleReminders.isEmpty
                    ? 'Keine'
                    : _selectedFlexibleReminders
                        .map((r) => r.label)
                        .join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Frist speichern',
          onPressed: _saveDeadline,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _prevStep,
            child: const Text('Zurück'),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  String get _recurrenceLabel {
    if (_recurrence == RecurrenceType.none) return 'Einmalig';
    if (_recurrence == RecurrenceType.custom && _customRecurrence != null) {
      return _customRecurrence!.label;
    }
    return _recurrence.label;
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedOf(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    final appState = context.watch<AppStateProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.successOf(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 32,
            color: AppColors.successOf(context),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Frist gespeichert',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _recurrence != RecurrenceType.none
              ? 'Wiederkehrende Frist gespeichert. Wir erinnern dich rechtzeitig.'
              : 'Wir erinnern dich rechtzeitig.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.mutedOf(context),
          ),
        ),
        const SizedBox(height: 32),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOf(context),
                ),
              ),
              if (_dueDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Datum: ${AppDateUtils.formatDate(_dueDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
              if (_recurrence != RecurrenceType.none) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.repeat, size: 14, color: AppColors.primaryOf(context)),
                    const SizedBox(width: 4),
                    Text(
                      _recurrenceLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryOf(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (_selectedFlexibleReminders.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Erinnerungen: ${_selectedFlexibleReminders.map((r) => r.label).join(', ')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedOf(context),
                  ),
                ),
              ],
            ],
          ),
        ),

        // --- Signup prompt after 3rd active deadline ---
        if (_showSignupAfterSave) ...[
          const SizedBox(height: 20),
          SignupPromptCard(
            onSignup: widget.onOpenSignup,
            onDismiss: () {
              appState.dismissSignupPrompt();
              setState(() => _showSignupAfterSave = false);
            },
          ),
        ],

        // --- Premium hint after 5th active deadline ---
        if (_showPremiumHintAfterSave) ...[
          const SizedBox(height: 20),
          PremiumHintCard(
            onViewPremium: () {
              appState.dismissPremiumHintAtFive();
              widget.onOpenPremium();
            },
            onDismiss: () {
              appState.dismissPremiumHintAtFive();
              setState(() => _showPremiumHintAfterSave = false);
            },
          ),
        ],

        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Weitere Frist hinzufügen',
          onPressed: _resetForm,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: widget.onComplete,
            child: const Text('Zur Übersicht'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
