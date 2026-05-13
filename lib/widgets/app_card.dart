import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? accentColor; // Left border accent

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : AppColors.cardBackground;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : isDark
                ? Border.all(color: AppColors.darkDivider, width: 0.5)
                : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: accentColor != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border(
                      left: BorderSide(color: accentColor!, width: 3),
                    ),
                  )
                : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
