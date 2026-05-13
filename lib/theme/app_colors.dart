import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Light Mode ---
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);

  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color warning = Color(0xFFF59E0B);
  static const Color critical = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static const Color completed = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // --- Dark Mode ---
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextMuted = Color(0xFF9CA3AF);
  static const Color darkPrimary = Color(0xFF2DD4BF);
  static const Color darkPrimaryLight = Color(0xFF134E4A);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkCritical = Color(0xFFF87171);
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkDivider = Color(0xFF374151);
  static const Color darkCompleted = Color(0xFF6B7280);

  // --- Helpers ---

  static Color cardOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : cardBackground;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  static Color textOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkText : textDark;

  static Color mutedOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextMuted : textMuted;

  static Color dividerOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkDivider : divider;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimary : primary;

  static Color primaryLightOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimaryLight : primaryLight;

  static Color warningOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkWarning : warning;

  static Color criticalOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCritical : critical;

  static Color successOf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSuccess : success;
}
