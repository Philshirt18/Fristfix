import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primaryOf(context)
                            : AppColors.dividerOf(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildValueScreen(),
                  _buildAhaScreen(),
                  _buildTrustScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Screen 1: Value Proposition ---

  Widget _buildValueScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxHeight < 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isSmall ? 24 : 48),
                Image.asset(
                  'assets/images/logo_v2.png',
                  width: isSmall ? 120 : 160,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: isSmall ? 32 : 48),
                Text(
                  'Nie wieder wichtige\nFristen verpassen.',
                  style: TextStyle(
                    fontSize: isSmall ? 26 : 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOf(context),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'FristFix erinnert dich rechtzeitig an Verträge, Ausweise, Auto, Steuer und Papierkram.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.mutedOf(context),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightOf(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: AppColors.primaryOf(context)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Privat. Werbefrei. Ohne Anbieter-Provisionen.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryOf(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmall ? 32 : 48),
                PrimaryButton(label: 'Loslegen', onPressed: _nextPage),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Screen 2: Aha-Moment ---

  Widget _buildAhaScreen() {
    const examples = [
      'Personalausweis',
      'Reisepass',
      'TÜV',
      'Handyvertrag',
      'Versicherung',
      'Steuertermin',
      'Kita/Schule',
      'Geburtstag',
      'Eigene Erinnerung',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Was möchtest du nicht\nmehr vergessen?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            'FristFix hilft dir bei typischen Fristen im Alltag.',
            style: TextStyle(fontSize: 15, color: AppColors.mutedOf(context), height: 1.5),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: examples.map((label) => _ahaChip(label)).toList(),
          ),
          const Spacer(),
          Text(
            'Du kannst später jede Frist selbst eintragen.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Weiter', onPressed: _nextPage),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _ahaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.dividerOf(context)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textOf(context)),
      ),
    );
  }

  // --- Screen 3: Trust & Privacy ---

  Widget _buildTrustScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Deine Fristen bleiben\ndeine Sache.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FristFix ist kein Vergleichsportal. Wir zeigen keine Werbung, vermitteln keine Verträge und verkaufen keine Daten.',
                    style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _trustRow(Icons.description_outlined, 'Keine Vertragsabschlüsse', 'FristFix erinnert dich nur. Du entscheidest selbst.'),
                  const SizedBox(height: 12),
                  _trustRow(Icons.shield_outlined, 'Keine Anbieter-Provisionen', 'Wir verdienen nicht an Wechseln oder Kündigungen.'),
                  const SizedBox(height: 12),
                  _trustRow(Icons.smartphone_outlined, 'Ohne Konto nutzbar', 'Deine Fristen bleiben lokal auf deinem Gerät, solange du kein Backup aktivierst.'),
                  const Spacer(),
                  const SizedBox(height: 16),
                  Text(
                    'Wir speichern nur, was du für deine Fristen einträgst.',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Erste Frist hinzufügen', onPressed: widget.onComplete),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(onPressed: widget.onComplete, child: const Text('Zur Übersicht')),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _trustRow(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primaryOf(context)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textOf(context))),
              const SizedBox(height: 2),
              Text(text, style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
