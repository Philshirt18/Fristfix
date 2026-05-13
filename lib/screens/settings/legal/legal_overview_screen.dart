import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LegalOverviewScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenImprint;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenSubscriptionTerms;

  const LegalOverviewScreen({
    super.key,
    required this.onBack,
    required this.onOpenImprint,
    required this.onOpenPrivacy,
    required this.onOpenTerms,
    required this.onOpenSubscriptionTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Rechtliches'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hier findest du alle rechtlichen Informationen zu FristFix.',
            style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerOf(context)),
            ),
            child: Text(
              'FristFix ist eine organisatorische Erinnerungs- und Planungshilfe. Die Verantwortung für die Richtigkeit, Prüfung und Einhaltung von Fristen liegt beim Nutzer.',
              style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context), height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          _item(context, Icons.info_outline, 'Impressum', 'Anbieterkennzeichnung', onOpenImprint),
          _item(context, Icons.lock_outlined, 'Datenschutz', 'Wie FristFix mit deinen Daten umgeht', onOpenPrivacy),
          _item(context, Icons.article_outlined, 'AGB', 'Nutzungsbedingungen', onOpenTerms),
          _item(context, Icons.credit_card_outlined, 'Abo & Widerruf', 'Informationen zu Premium, Laufzeit und Kündigung', onOpenSubscriptionTerms),
          _item(context, Icons.source_outlined, 'Lizenzen', 'Open-Source-Lizenzen', () {
            showLicensePage(context: context, applicationName: 'FristFix', applicationVersion: '1.0.0');
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppColors.mutedOf(context)),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textOf(context))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context))),
        trailing: Icon(Icons.chevron_right, size: 20, color: AppColors.mutedOf(context)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
