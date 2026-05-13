import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

class SignupPromptCard extends StatelessWidget {
  final VoidCallback onSignup;
  final VoidCallback onDismiss;

  const SignupPromptCard({
    super.key,
    required this.onSignup,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.primaryOf(context).withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.cloud_outlined, size: 20, color: AppColors.primaryOf(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Fristen kostenlos sichern',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOf(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Du hast 3 wichtige Fristen gespeichert. Erstelle ein kostenloses Konto, damit deine Fristen beim Gerätewechsel erhalten bleiben.',
            style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(onPressed: onSignup, child: const Text('Kostenlos sichern')),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDismiss,
              child: Text('Später', style: TextStyle(color: AppColors.mutedOf(context))),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ohne Konto bleiben deine Fristen nur auf diesem Gerät gespeichert.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedOf(context), height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
