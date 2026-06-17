import 'package:flutter/material.dart';

enum DeadlineType {
  kuendigungsfrist('Kündigungsfrist', 'Für Verträge, Abos, Versicherungen', Icons.cancel_outlined, 'assets/images/icons/kuendigungsfrist.png'),
  ablaufdatum('Ablaufdatum', 'Für Ausweis, Pass, TÜV, Dokumente', Icons.event_outlined, 'assets/images/icons/ablaufdatum.png'),
  termin('Termin', 'Für Arzt, Behörde, Steuer, Schule', Icons.schedule_outlined, 'assets/images/icons/termin.png'),
  gesundheitFitness('Gesundheit & Fitness', 'Für Medizin, Gym, Vitamine', Icons.fitness_center_outlined, 'assets/images/icons/gesundheit_fitness.png'),
  geburtstag('Geburtstag', 'Für Familie, Freunde, Kollegen', Icons.cake_outlined, 'assets/images/icons/geburtstag.png'),
  eigeneErinnerung('Eigene Erinnerung', 'Für alles andere', Icons.notifications_outlined, 'assets/images/icons/eigene_erinnerung.png');

  final String label;
  final String description;
  final IconData icon; // Fallback
  final String imagePath;

  const DeadlineType(this.label, this.description, this.icon, this.imagePath);

  static DeadlineType fromString(String value) {
    if (value == 'wichtigerTermin') return DeadlineType.termin;
    return DeadlineType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DeadlineType.eigeneErinnerung,
    );
  }
}
