import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

class PremiumHintCard extends StatelessWidget {
  final VoidCallback onViewPremium;
  final VoidCallback onDismiss;

  const PremiumHintCard({
    super.key,
    required this.onViewPremium,
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
                child: Icon(Icons.star_outline, size: 20, color: AppColors.primaryOf(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Du nutzt FristFix schon für 5 wichtige Fristen.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOf(context),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Mit Premium behältst du unbegrenzt viele Fristen im Blick.',
            style: TextStyle(fontSize: 14, color: AppColors.mutedOf(context), height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(onPressed: onViewPremium, child: const Text('Premium ansehen')),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDismiss,
              child: Text('Später', style: TextStyle(color: AppColors.mutedOf(context))),
            ),
          ),
        ],
      ),
    );
  }
}
