import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/primary_button.dart';

class PremiumScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PremiumScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),

          if (appState.isPremium) ...[
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
              'Premium ist aktiv',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Du kannst unbegrenzt viele Fristen speichern und alle Funktionen nutzen.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mutedOf(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ] else ...[
            Text(
              'Mehr Fristen.\nWeniger Kopfstress.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Behalte alle wichtigen Fristen dauerhaft im Blick.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mutedOf(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ],

          _buildBenefit(context, Icons.all_inclusive, 'Unbegrenzt viele Fristen'),
          _buildBenefit(context, Icons.notifications_active_outlined,
              'Mehrere Erinnerungen pro Frist'),
          _buildBenefit(
              context, Icons.cloud_outlined, 'Fristen beim Gerätewechsel sichern'),
          _buildBenefit(context, Icons.calendar_month_outlined, 'Kalenderansicht'),

          const SizedBox(height: 32),

          if (!appState.isPremium) ...[
            AppCard(
              borderColor: AppColors.primaryOf(context),
              child: Column(
                children: [
                  // Intro offer pricing
                  if (appState.introOfferEnabled) ...[
                    Text(
                      'Einführungsangebot: 4,99 € im ersten Jahr',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryOf(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Danach 5,99 € pro Jahr.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '5,99 € pro Jahr',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weniger als 60 Cent pro Monat.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedOf(context),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Premium aktivieren',
                    onPressed: () => _handlePurchase(context, appState),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Restore purchases
            Center(
              child: TextButton(
                onPressed: () => _handleRestore(context, appState),
                child: Text(
                  'Käufe wiederherstellen',
                  style: TextStyle(
                    color: AppColors.mutedOf(context),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Trust
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLightOf(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline,
                    size: 18, color: AppColors.primaryOf(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keine Werbung. Keine Anbieter-Provisionen. Deine Daten bleiben privat.',
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
          const SizedBox(height: 12),
          Text(
            appState.introOfferEnabled
              ? 'Einführungsangebot: 3,99 € im ersten Jahr. Danach 5,99 € pro Jahr. Das Abo verlängert sich automatisch, sofern es nicht rechtzeitig im jeweiligen App Store gekündigt wird.'
              : '5,99 € pro Jahr. Das Abo verlängert sich automatisch, sofern es nicht rechtzeitig im jeweiligen App Store gekündigt wird.',
            style: TextStyle(fontSize: 11, color: AppColors.mutedOf(context), height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (!appState.isPremium)
            Center(
              child: TextButton(
                onPressed: onBack,
                child: const Text('Vielleicht später'),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
      BuildContext context, AppStateProvider appState) async {
    final result = await appState.purchasePremium();
    if (!context.mounted) return;

    switch (result) {
      case PurchaseResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium aktiviert!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case PurchaseResult.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Kauf abgebrochen. Du kannst Premium jederzeit später aktivieren.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case PurchaseResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Das hat leider nicht geklappt. Bitte versuche es später erneut.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _handleRestore(
      BuildContext context, AppStateProvider appState) async {
    final result = await appState.restorePurchases();
    if (!context.mounted) return;

    switch (result) {
      case RestoreResult.premiumRestored:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Premium wurde wiederhergestellt.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case RestoreResult.noPurchaseFound:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wir konnten kein aktives Premium finden.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case RestoreResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Das hat leider nicht geklappt. Bitte versuche es später erneut.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLightOf(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryOf(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
