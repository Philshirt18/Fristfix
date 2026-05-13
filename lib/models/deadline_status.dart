import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum DeadlineStatus {
  imBlick('Im Blick', AppColors.success),
  baldWichtig('Bald wichtig', AppColors.warning),
  kritisch('Kritisch', AppColors.critical),
  bittePruefen('Bitte prüfen', AppColors.critical),
  erledigt('Erledigt', AppColors.completed);

  final String label;
  final Color color;

  const DeadlineStatus(this.label, this.color);
}
