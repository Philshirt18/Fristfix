import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationPrePrompt extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDismiss;

  const NotificationPrePrompt({
    super.key,
    required this.onAllow,
    required this.onDismiss,
  });

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => NotificationPrePrompt(
        onAllow: () => Navigator.of(sheetContext).pop(true),
        onDismiss: () => Navigator.of(sheetContext).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerOf(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.notifications_active_outlined,
              size: 48,
              color: AppColors.primaryOf(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Rechtzeitig erinnert werden',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'FristFix nutzt Benachrichtigungen, damit du wichtige Fristen nicht verpasst.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.mutedOf(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Du kannst Benachrichtigungen jederzeit in den Systemeinstellungen ändern.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedOf(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onAllow,
                child: const Text('Benachrichtigungen erlauben'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Später',
                  style: TextStyle(color: AppColors.mutedOf(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
