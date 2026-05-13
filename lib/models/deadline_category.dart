import 'package:flutter/material.dart';

enum DeadlineCategory {
  handyInternet('Handy & Internet', Icons.smartphone),
  stromGas('Strom & Gas', Icons.bolt),
  versicherung('Versicherung', Icons.shield_outlined),
  ausweisPass('Ausweis & Pass', Icons.badge_outlined),
  autoTuev('Auto & TÜV', Icons.directions_car_outlined),
  wohnungMiete('Wohnung & Miete', Icons.home_outlined),
  steuer('Steuer', Icons.receipt_long_outlined),
  schuleKita('Schule & Kita', Icons.school_outlined),
  gesundheit('Gesundheit', Icons.favorite_outline),
  sonstiges('Sonstiges', Icons.more_horiz);

  final String label;
  final IconData icon;

  const DeadlineCategory(this.label, this.icon);

  static DeadlineCategory fromString(String value) {
    return DeadlineCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeadlineCategory.sonstiges,
    );
  }
}
