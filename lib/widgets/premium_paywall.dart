import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../services/payment_service.dart';
import 'primary_button.dart';

class PremiumPaywall extends StatelessWidget {
  final VoidCallback onActivated;
  final VoidCallback onDismiss;

  const PremiumPaywall({
    super.key,
    required this.onActivated,
    required this.onDismiss,
  });

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PremiumPaywall(
        onActivated: () => Navigator.of(sheetContext).pop(true),
        onDismiss: () => Navigator.of(sheetContext).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Mehr als 5 Fristen speichern?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOf(context))),
            const SizedBox(height: 8),
            Text('Mit FristFix Premium kannst du unbegrenzt viele Fristen anlegen und mehrere Erinnerungen nutzen.',
              style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5)),
            const SizedBox(height: 24),
            _benefit(context, 'Unbegrenzt viele Fristen'),
            _benefit(context, 'Mehrere Erinnerungen pro Frist'),
            _benefit(context, 'Fristen beim Gerätewechsel sichern'),
            _benefit(context, 'Kalenderansicht'),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLightOf(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  if (appState.introOfferEnabled) ...[
                    Text('Einführungsangebot: 4,99 € im ersten Jahr',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryOf(context)),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text('Danach 6,99 € pro Jahr.', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
                  ] else ...[
                    Text('6,99 € pro Jahr',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryOf(context))),
                    const SizedBox(height: 2),
                    Text('Weniger als 60 Cent pro Monat.', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Premium aktivieren', onPressed: () => _handlePurchase(context)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: onDismiss, child: Text('Nicht jetzt', style: TextStyle(color: AppColors.mutedOf(context)))),
            ),
            const SizedBox(height: 8),
            Text('Du kannst auch eine bestehende Frist erledigen oder archivieren, um kostenlos weiterzumachen.',
              style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context), height: 1.4), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Keine Werbung. Keine Anbieter-Provisionen. Deine Daten bleiben privat.',
              style: TextStyle(fontSize: 11, color: AppColors.mutedOf(context)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              appState.introOfferEnabled
                ? 'Einführungsangebot: 4,99 € im ersten Jahr. Danach 6,99 € pro Jahr. Das Abo verlängert sich automatisch, sofern es nicht rechtzeitig im jeweiligen App Store gekündigt wird.'
                : '6,99 € pro Jahr. Das Abo verlängert sich automatisch, sofern es nicht rechtzeitig im jeweiligen App Store gekündigt wird.',
              style: TextStyle(fontSize: 10, color: AppColors.mutedOf(context), height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(BuildContext context) async {
    final appState = context.read<AppStateProvider>();
    final result = await appState.purchasePremium();
    if (!context.mounted) return;
    switch (result) {
      case PurchaseResult.success:
        HapticFeedback.lightImpact();
        onActivated();
      case PurchaseResult.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kauf abgebrochen. Du kannst Premium jederzeit später aktivieren.')));
      case PurchaseResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Das hat leider nicht geklappt. Bitte versuche es später erneut.')));
    }
  }

  Widget _benefit(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: AppColors.primaryOf(context)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textOf(context)))),
        ],
      ),
    );
  }
}
