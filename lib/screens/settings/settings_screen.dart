import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSignup;
  final VoidCallback onOpenLegal;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.onOpenPremium,
    required this.onOpenSignup,
    required this.onOpenLegal,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _defaultReminders = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Darstellung ---
          _sectionHeader(context, 'Darstellung'),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => _showThemePicker(context, themeProvider),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: AppColors.mutedOf(context)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Erscheinungsbild', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textOf(context))),
                      const SizedBox(height: 2),
                      Text(themeProvider.themeModeLabel, style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: AppColors.mutedOf(context)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Benachrichtigungen ---
          _sectionHeader(context, 'Benachrichtigungen'),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.notifications_outlined, color: AppColors.mutedOf(context)),
                const SizedBox(width: 16),
                Expanded(child: Text('Push-Benachrichtigungen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textOf(context)))),
                Switch.adaptive(value: _pushEnabled, onChanged: (v) => setState(() => _pushEnabled = v), activeTrackColor: AppColors.primaryOf(context)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Row(
              children: [
                Icon(Icons.alarm_outlined, color: AppColors.mutedOf(context)),
                const SizedBox(width: 16),
                Expanded(child: Text('Standard-Erinnerungen', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textOf(context)))),
                Switch.adaptive(value: _defaultReminders, onChanged: (v) => setState(() => _defaultReminders = v), activeTrackColor: AppColors.primaryOf(context)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Konto & Backup ---
          _sectionHeader(context, 'Konto & Backup'),
          const SizedBox(height: 12),
          if (!appState.isLoggedIn) ...[
            _item(context, Icons.cloud_outlined, 'Backup aktivieren', subtitle: 'Fristen beim Gerätewechsel sichern', onTap: widget.onOpenSignup),
          ] else ...[
            _item(context, Icons.cloud_done_outlined, 'Backup aktiv', subtitle: 'Angemeldet', onTap: () {}),
            _item(context, Icons.logout, 'Abmelden', onTap: () => _showSignOutDialog(context, appState)),
            _item(context, Icons.delete_forever_outlined, 'Konto löschen', onTap: () => _showDeleteAccountDialog(context), isDestructive: true),
          ],
          _trustHint(context, appState.isLoggedIn
            ? 'Mit Backup kannst du deine Fristen beim Gerätewechsel wiederherstellen.'
            : 'Ohne Konto bleiben deine Fristen nur auf diesem Gerät gespeichert.',
            icon: appState.isLoggedIn ? Icons.cloud_done_outlined : Icons.info_outline,
          ),

          const SizedBox(height: 24),

          // --- Premium ---
          _sectionHeader(context, 'Premium'),
          const SizedBox(height: 12),
          _item(context, Icons.star_outline, appState.isPremium ? 'Premium verwalten' : 'Premium aktivieren',
            subtitle: appState.isPremium ? 'Premium ist aktiv' : null, onTap: widget.onOpenPremium),
          if (!appState.isPremium)
            _item(context, Icons.restore, 'Käufe wiederherstellen', onTap: () => _handleRestore(context, appState)),
          if (!appState.isPremium)
            _item(context, Icons.card_giftcard_outlined, 'Code einlösen', onTap: () => _showPromoCodeDialog(context, appState)),

          const SizedBox(height: 24),

          // --- Rechtliches (single entry) ---
          _sectionHeader(context, 'Rechtliches'),
          const SizedBox(height: 12),
          _item(context, Icons.shield_outlined, 'Rechtliches',
            subtitle: 'Impressum, Datenschutz, AGB und Lizenzen',
            onTap: widget.onOpenLegal),

          const SizedBox(height: 24),

          // --- Hilfe & Kontakt ---
          _sectionHeader(context, 'Hilfe & Kontakt'),
          const SizedBox(height: 12),
          _item(context, Icons.mail_outline, 'Kontakt', onTap: () => _openEmail(context, 'Kontakt über FristFix')),
          _item(context, Icons.chat_bubble_outline, 'Feedback geben', onTap: () => _openEmail(context, 'FristFix Feedback')),
          _item(context, Icons.delete_outline, 'Daten löschen', onTap: () => _showDeleteDataDialog(context), isDestructive: true),

          const SizedBox(height: 32),
          Center(child: Text('FristFix v1.0.0', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context).withValues(alpha: 0.6)))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _sectionHeader(BuildContext context, String title) =>
    Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedOf(context), letterSpacing: 0.5));

  Widget _item(BuildContext context, IconData icon, String label, {String? subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    final color = isDestructive ? AppColors.criticalOf(context) : AppColors.mutedOf(context);
    final textColor = isDestructive ? AppColors.criticalOf(context) : AppColors.textOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context))) : null,
        trailing: Icon(Icons.chevron_right, size: 20, color: AppColors.mutedOf(context)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _trustHint(BuildContext context, String text, {required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLightOf(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryOf(context)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.primaryOf(context), height: 1.4))),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardOf(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Erscheinungsbild', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
              const SizedBox(height: 20),
              _themeOption(ctx, themeProvider, ThemeMode.system, 'System', Icons.settings_suggest_outlined),
              _themeOption(ctx, themeProvider, ThemeMode.light, 'Hell', Icons.light_mode_outlined),
              _themeOption(ctx, themeProvider, ThemeMode.dark, 'Dunkel', Icons.dark_mode_outlined),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, ThemeProvider tp, ThemeMode mode, String label, IconData icon) {
    final isSelected = tp.themeMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryOf(context) : AppColors.mutedOf(context)),
      title: Text(label, style: TextStyle(
        fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.primaryOf(context) : AppColors.textOf(context),
      )),
      trailing: isSelected ? Icon(Icons.check, color: AppColors.primaryOf(context)) : null,
      onTap: () { tp.setThemeMode(mode); Navigator.of(context).pop(); },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _openEmail(BuildContext context, String subject) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'appfactorymalaga@gmail.com',
      queryParameters: {'subject': subject},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-Mail: appfactorymalaga@gmail.com')),
      );
    }
  }

  Future<void> _handleRestore(BuildContext context, AppStateProvider appState) async {
    final result = await appState.restorePurchases();
    if (!context.mounted) return;
    switch (result) {
      case RestoreResult.premiumRestored:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium wurde wiederhergestellt.')));
      case RestoreResult.noPurchaseFound:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wir konnten kein aktives Premium finden.')));
      case RestoreResult.error:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Das hat leider nicht geklappt. Bitte versuche es später erneut.')));
    }
  }

  void _showSignOutDialog(BuildContext context, AppStateProvider appState) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Abmelden?'),
      content: const Text('Deine lokalen Fristen bleiben auf diesem Gerät erhalten.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
        TextButton(onPressed: () async {
          Navigator.of(ctx).pop();
          final authService = context.read<AuthService>();
          await authService.signOut();
          await appState.setLoggedIn(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abgemeldet. Deine lokalen Fristen bleiben erhalten.')));
          }
        }, child: const Text('Abmelden')),
      ],
    ));
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Konto löschen?'),
      content: const Text('Dein Konto und alle Cloud-Daten werden unwiderruflich gelöscht. Lokale Fristen bleiben erhalten.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
        TextButton(onPressed: () async {
          Navigator.of(ctx).pop();
          try {
            final authService = context.read<AuthService>();
            await authService.deleteAccount();
            final appState = context.read<AppStateProvider>();
            await appState.setLoggedIn(false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konto gelöscht. Deine lokalen Fristen bleiben erhalten.')));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte melde dich erneut an und versuche es dann nochmal.')));
            }
          }
        }, child: Text('Konto löschen', style: TextStyle(color: AppColors.criticalOf(context)))),
      ],
    ));
  }

  void _showPromoCodeDialog(BuildContext context, AppStateProvider appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Code einlösen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          autocorrect: false,
          decoration: const InputDecoration(hintText: 'Code eingeben'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () {
              final code = controller.text.trim().toUpperCase();
              Navigator.of(ctx).pop();
              if (code == 'FRISTFIX2026' || code == 'FRISTFIXPRO' || code == 'GRETAUNDLIA') {
                appState.activatePromoCode();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium aktiviert! Vielen Dank.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ungültiger Code.')),
                );
              }
            },
            child: const Text('Einlösen'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Alle Daten löschen?'),
      content: const Text('Alle gespeicherten Fristen und Einstellungen werden unwiderruflich gelöscht.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
        TextButton(onPressed: () {
          Navigator.of(ctx).pop();
          context.read<DeadlineProvider>().deleteAllDeadlines();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alle Fristen wurden gelöscht.')));
        }, child: Text('Löschen', style: TextStyle(color: AppColors.criticalOf(context)))),
      ],
    ));
  }
}
