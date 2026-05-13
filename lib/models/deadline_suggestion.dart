import 'package:flutter/material.dart';
import 'deadline_type.dart';
import 'deadline_category.dart';

class DeadlineSuggestion {
  final String label;
  final DeadlineType type;
  final DeadlineCategory category;
  final IconData icon;

  const DeadlineSuggestion({
    required this.label,
    required this.type,
    required this.category,
    required this.icon,
  });

  static const List<DeadlineSuggestion> defaults = [
    DeadlineSuggestion(
      label: 'Handyvertrag',
      type: DeadlineType.kuendigungsfrist,
      category: DeadlineCategory.handyInternet,
      icon: Icons.smartphone,
    ),
    DeadlineSuggestion(
      label: 'Ausweis',
      type: DeadlineType.ablaufdatum,
      category: DeadlineCategory.ausweisPass,
      icon: Icons.badge_outlined,
    ),
    DeadlineSuggestion(
      label: 'TÜV',
      type: DeadlineType.ablaufdatum,
      category: DeadlineCategory.autoTuev,
      icon: Icons.directions_car_outlined,
    ),
    DeadlineSuggestion(
      label: 'Versicherung',
      type: DeadlineType.kuendigungsfrist,
      category: DeadlineCategory.versicherung,
      icon: Icons.shield_outlined,
    ),
    DeadlineSuggestion(
      label: 'Steuer',
      type: DeadlineType.termin,
      category: DeadlineCategory.steuer,
      icon: Icons.receipt_long_outlined,
    ),
    DeadlineSuggestion(
      label: 'Stromvertrag',
      type: DeadlineType.kuendigungsfrist,
      category: DeadlineCategory.stromGas,
      icon: Icons.bolt,
    ),
    DeadlineSuggestion(
      label: 'Reisepass',
      type: DeadlineType.ablaufdatum,
      category: DeadlineCategory.ausweisPass,
      icon: Icons.card_travel_outlined,
    ),
  ];
}
