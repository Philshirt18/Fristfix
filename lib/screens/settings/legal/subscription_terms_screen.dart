import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SubscriptionTermsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SubscriptionTermsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Abo & Widerruf'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Abo & Widerruf\nfür FristFix',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.3)),
          const SizedBox(height: 8),
          Text('Stand: 30.04.2026', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
          const SizedBox(height: 24),

          _section(context, '1. Premium-Abo',
            'FristFix bietet ein optionales Premium-Abonnement mit erweiterten Funktionen.\n\n'
            'Der reguläre Preis beträgt:\n\n'
            '5,99 € pro Jahr\n\n'
            'Gegebenenfalls kann ein Einführungsangebot angeboten werden, z. B.:\n\n'
            '3,99 € im ersten Jahr, danach 5,99 € pro Jahr\n\n'
            'Der jeweils gültige Preis wird vor dem Kauf im App Store angezeigt.'),

          _section(context, '2. Laufzeit und Verlängerung',
            'Das Premium-Abo hat eine Laufzeit von einem Jahr ab dem Zeitpunkt des Kaufs.\n\n'
            'Das Abo verlängert sich automatisch um jeweils ein weiteres Jahr, sofern es nicht rechtzeitig gekündigt wird.\n\n'
            'Die automatische Verlängerung erfolgt zu dem zum Verlängerungszeitpunkt gültigen Preis.'),

          _section(context, '3. Kündigung',
            'Die Kündigung des Abos erfolgt über den jeweiligen App Store:\n\n'
            '• Apple App Store: Einstellungen → Apple-ID → Abonnements\n'
            '• Google Play: Play Store → Zahlungen & Abos → Abos\n\n'
            'Die Kündigung muss mindestens 24 Stunden vor Ablauf der aktuellen Laufzeit erfolgen, um eine Verlängerung zu vermeiden.\n\n'
            'Eine Kündigung direkt über FristFix oder per E-Mail ist nicht möglich, da die Aboverwaltung ausschließlich über den jeweiligen App Store erfolgt.'),

          _section(context, '4. Zahlung',
            'Die Zahlung erfolgt über den jeweiligen App Store (Apple App Store oder Google Play).\n\n'
            'Der Betrag wird dem mit dem App-Store-Konto verknüpften Zahlungsmittel belastet.\n\n'
            'Wir haben keinen Zugriff auf deine Zahlungsdaten.'),

          _section(context, '5. Widerruf und Erstattungen',
            'Für über den Apple App Store oder Google Play abgeschlossene Abonnements gelten die jeweiligen Widerrufs- und Erstattungsbedingungen des App-Store-Anbieters.\n\n'
            'Erstattungsanfragen sind direkt an den jeweiligen App Store zu richten:\n\n'
            '• Apple: https://reportaproblem.apple.com\n'
            '• Google: über die Google Play App oder https://play.google.com\n\n'
            'Wenn du Verbraucher in der EU bist, steht dir bei digitalen Inhalten grundsätzlich ein 14-tägiges Widerrufsrecht zu. Dieses kann entfallen, wenn du dem sofortigen Beginn der Leistung ausdrücklich zugestimmt und dabei auf dein Widerrufsrecht verzichtet hast. Die genauen Bedingungen richten sich nach den Regelungen des jeweiligen App Stores.'),

          _section(context, '6. Premium-Funktionen',
            'Das Premium-Abo umfasst insbesondere:\n\n'
            '• Unbegrenzt viele aktive Fristen\n'
            '• Mehrere Erinnerungen pro Frist\n'
            '• Backup- und Synchronisierungsfunktionen\n'
            '• Weitere zukünftige Zusatzfunktionen\n\n'
            'Die jeweils verfügbaren Premium-Funktionen werden in der App angezeigt.'),

          _section(context, '7. Kontakt',
            'Bei Fragen zu Abo und Widerruf erreichst du uns unter:\n\n'
            'Philipp Schaefer\n'
            'Cortijo las padillas 2\n'
            '29749 Almayate\n'
            'Spanien\n'
            'E-Mail: appfactorymalaga@gmail.com'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 14, color: AppColors.textOf(context), height: 1.6)),
        ],
      ),
    );
  }
}
