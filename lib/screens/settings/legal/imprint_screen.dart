import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_colors.dart';

class ImprintScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ImprintScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Impressum'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Impressum', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.3)),
          const SizedBox(height: 24),

          _section(context, 'Angaben gemäß § 5 DDG',
            'Philipp Schaefer\n'
            'Cortijo las padillas 2\n'
            '29749 Almayate\n'
            'Spanien'),
          const SizedBox(height: 8),
          _emailRow(context),

          const SizedBox(height: 24),
          _section(context, 'Verantwortlich für den Inhalt',
            'Philipp Schaefer\n'
            'Cortijo las padillas 2\n'
            '29749 Almayate\n'
            'Spanien'),

          const SizedBox(height: 24),
          _section(context, 'Hinweis zur App',
            'FristFix ist kein Vergleichsportal, vermittelt keine Verträge und bietet keine Rechts-, Steuer- oder Vertragsberatung.\n\n'
            'FristFix ist eine organisatorische Erinnerungs- und Planungshilfe. Die Verantwortung für die Richtigkeit, Prüfung und Einhaltung von Fristen liegt beim Nutzer.'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
        const SizedBox(height: 8),
        Text(body, style: TextStyle(fontSize: 14, color: AppColors.textOf(context), height: 1.6)),
      ],
    );
  }

  Widget _emailRow(BuildContext context) {
    const email = 'appfactorymalaga@gmail.com';
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: email));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-Mail-Adresse kopiert.')),
        );
      },
      child: Row(
        children: [
          Text('E-Mail: ', style: TextStyle(fontSize: 14, color: AppColors.textOf(context))),
          Text(email, style: TextStyle(fontSize: 14, color: AppColors.primaryOf(context), fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
        ],
      ),
    );
  }
}
