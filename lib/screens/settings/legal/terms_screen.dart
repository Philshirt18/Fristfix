import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const TermsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('AGB'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Allgemeine Geschäftsbedingungen\nfür FristFix',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.3)),
          const SizedBox(height: 8),
          Text('Stand: 30.04.2026', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
          const SizedBox(height: 24),

          _section(context, '1. Anbieter',
            'Diese Allgemeinen Geschäftsbedingungen gelten für die Nutzung der App „FristFix".\n\n'
            'Anbieter der App ist:\n\n'
            'Philipp Schaefer\n'
            'Cortijo las padillas 2\n'
            '29749 Almayate\n'
            'Spanien\n'
            'E-Mail: appfactorymalaga@gmail.com\n\n'
            'Nachfolgend „wir", „uns" oder „Anbieter" genannt.'),

          _section(context, '2. Gegenstand der App',
            'FristFix ist eine App zur manuellen Verwaltung und Erinnerung an Fristen, Termine und sonstige wichtige Daten.\n\n'
            'Nutzer können in der App beispielsweise folgende Fristen speichern:\n\n'
            '• Kündigungsfristen\n'
            '• Vertragsfristen\n'
            '• Ablaufdaten von Ausweisen oder Reisepässen\n'
            '• TÜV-Termine\n'
            '• Versicherungsfristen\n'
            '• Steuertermine\n'
            '• Schul-, Kita- oder Behördenfristen\n'
            '• sonstige persönliche Erinnerungen\n\n'
            'FristFix ist kein Vergleichsportal, vermittelt keine Verträge, bietet keine Rechtsberatung und ersetzt keine eigenständige Prüfung von Vertragsunterlagen, gesetzlichen Fristen oder behördlichen Vorgaben.'),

          _section(context, '3. Nutzung ohne Konto',
            'FristFix kann grundsätzlich ohne Konto genutzt werden.\n\n'
            'In diesem Fall werden die eingegebenen Fristen lokal auf dem Gerät des Nutzers gespeichert.\n\n'
            'Ohne Konto erfolgt kein automatischer Cloud-Sync und kein automatisches Backup. Bei Verlust des Geräts, Löschung der App oder Zurücksetzen des Geräts können lokal gespeicherte Daten verloren gehen.'),

          _section(context, '4. Optionales Konto und Backup',
            'Nutzer können optional ein Konto erstellen, um Funktionen wie Backup, Wiederherstellung oder spätere Synchronisierung zu nutzen.\n\n'
            'Ein Konto ist für die grundlegende Nutzung der App nicht erforderlich, kann aber für bestimmte Zusatzfunktionen notwendig sein.\n\n'
            'Die Einzelheiten zur Datenverarbeitung ergeben sich aus der Datenschutzerklärung.'),

          _section(context, '5. Premium-Funktionen',
            'FristFix kann kostenlose und kostenpflichtige Funktionen anbieten.\n\n'
            'Die kostenlose Version kann insbesondere auf eine bestimmte Anzahl aktiver Fristen beschränkt sein.\n\n'
            'FristFix Premium kann zusätzliche Funktionen enthalten, insbesondere:\n\n'
            '• unbegrenzt viele aktive Fristen\n'
            '• mehrere Erinnerungen pro Frist\n'
            '• Backup- und Synchronisierungsfunktionen\n'
            '• weitere zukünftige Zusatzfunktionen\n\n'
            'Die jeweils verfügbaren Premium-Funktionen werden in der App angezeigt.'),

          _section(context, '6. Preise und Zahlung',
            'Der Preis für FristFix Premium wird in der App angezeigt.\n\n'
            'Geplant ist insbesondere ein Jahresabo zum Preis von:\n\n'
            '5,99 € pro Jahr\n\n'
            'Gegebenenfalls kann ein Einführungsangebot angeboten werden, z. B.:\n\n'
            '3,99 € im ersten Jahr, danach 5,99 € pro Jahr\n\n'
            'Die Zahlung und Verwaltung von Abonnements erfolgt über den jeweiligen App Store, also insbesondere den Apple App Store oder Google Play.\n\n'
            'Für Abschluss, Verlängerung, Kündigung und Rückerstattung von App-Store-Abonnements gelten ergänzend die Bedingungen des jeweiligen App-Store-Anbieters.'),

          _section(context, '7. Laufzeit und Kündigung von Premium-Abos',
            'Premium-Abonnements verlängern sich entsprechend den Bedingungen des jeweiligen App Stores automatisch, sofern sie nicht rechtzeitig über den jeweiligen App Store gekündigt werden.\n\n'
            'Die Kündigung eines Abonnements muss über den jeweiligen App Store erfolgen.\n\n'
            'Wir haben keinen unmittelbaren Zugriff auf die Zahlungsdaten des Nutzers und können App-Store-Abonnements nur im Rahmen der von Apple oder Google bereitgestellten Möglichkeiten verwalten.'),

          _section(context, '8. Verantwortung des Nutzers',
            'Der Nutzer ist selbst dafür verantwortlich, dass die von ihm eingegebenen Daten richtig, vollständig und aktuell sind.\n\n'
            'Dies betrifft insbesondere:\n\n'
            '• Fristdaten\n'
            '• Kündigungsfristen\n'
            '• Vertragslaufzeiten\n'
            '• Erinnerungszeitpunkte\n'
            '• Anbieterangaben\n'
            '• Notizen\n'
            '• sonstige relevante Informationen\n\n'
            'Der Nutzer ist außerdem selbst dafür verantwortlich, wichtige Fristen anhand der jeweiligen Originalunterlagen, Verträge, behördlichen Schreiben oder gesetzlichen Vorgaben zu prüfen.\n\n'
            'FristFix erinnert nur an die vom Nutzer eingegebenen oder bestätigten Daten. Die App kann nicht garantieren, dass eine Frist rechtlich, vertraglich oder tatsächlich korrekt ist.'),

          _section(context, '9. Keine Rechts-, Steuer- oder Vertragsberatung',
            'FristFix bietet keine Rechtsberatung, Steuerberatung, Finanzberatung oder Vertragsberatung.\n\n'
            'Die App unterstützt Nutzer lediglich organisatorisch dabei, selbst eingetragene Fristen im Blick zu behalten.\n\n'
            'FristFix ersetzt insbesondere nicht:\n\n'
            '• die Prüfung von Verträgen\n'
            '• die Prüfung gesetzlicher Fristen\n'
            '• die Beratung durch Rechtsanwälte\n'
            '• die Beratung durch Steuerberater\n'
            '• die Beratung durch Verbraucherzentralen\n'
            '• die Prüfung durch Behörden oder Vertragspartner'),

          _section(context, '10. Erinnerungen und Benachrichtigungen',
            'FristFix kann Nutzer an gespeicherte Fristen erinnern.\n\n'
            'Benachrichtigungen können jedoch von verschiedenen Faktoren abhängen, insbesondere:\n\n'
            '• Geräteeinstellungen\n'
            '• Betriebssystemeinstellungen\n'
            '• aktivierten oder deaktivierten Push-Berechtigungen\n'
            '• Energiesparmodus\n'
            '• Internetverbindung\n'
            '• App-Berechtigungen\n'
            '• technischen Störungen\n'
            '• Änderungen am Betriebssystem\n'
            '• Löschung oder Deaktivierung der App\n\n'
            'Wir übernehmen keine Garantie dafür, dass jede Erinnerung zu jedem Zeitpunkt fehlerfrei, rechtzeitig oder überhaupt angezeigt wird.\n\n'
            'Der Nutzer bleibt selbst dafür verantwortlich, wichtige Fristen eigenständig zu prüfen und einzuhalten.'),

          _section(context, '11. Keine Garantie für Fristen',
            'FristFix übernimmt keine Garantie dafür, dass gespeicherte Fristen korrekt, vollständig, rechtzeitig, rechtlich zutreffend oder wirtschaftlich sinnvoll sind.\n\n'
            'Insbesondere übernehmen wir keine Garantie dafür, dass:\n\n'
            '• eine Kündigungsfrist korrekt berechnet wurde\n'
            '• ein Vertragsende richtig erfasst wurde\n'
            '• ein behördlicher Termin zutreffend gespeichert wurde\n'
            '• ein Nutzer rechtzeitig an eine Frist erinnert wird\n'
            '• eine Frist nicht versäumt wird\n'
            '• durch die Nutzung der App Kosten, Nachteile oder Schäden vermieden werden\n\n'
            'FristFix ist eine organisatorische Erinnerungs- und Planungshilfe. Die Verantwortung für die Einhaltung von Fristen liegt beim Nutzer.'),

          _section(context, '12. Haftung bei verpassten Fristen',
            'Der Nutzer erkennt an, dass FristFix lediglich eine unterstützende Erinnerungsfunktion bereitstellt.\n\n'
            'Wir haften nicht für Schäden, Kosten, Nachteile, Vertragsverlängerungen, versäumte Kündigungen, verpasste Termine, behördliche Nachteile oder sonstige Folgen, die dadurch entstehen, dass eine Frist nicht, falsch oder verspätet eingehalten wird, soweit dies gesetzlich zulässig ist.\n\n'
            'Dies gilt insbesondere, wenn die Fristversäumnis beruht auf:\n\n'
            '• falschen oder unvollständigen Eingaben des Nutzers\n'
            '• nicht aktualisierten Daten\n'
            '• deaktivierten Benachrichtigungen\n'
            '• fehlenden App-Berechtigungen\n'
            '• Geräteverlust\n'
            '• Löschung der App\n'
            '• technischen Störungen des Geräts\n'
            '• Betriebssystemproblemen\n'
            '• fehlender Internetverbindung\n'
            '• App-Store-, Firebase-, RevenueCat- oder sonstigen Drittanbieter-Störungen\n'
            '• unterlassener Prüfung der Originalunterlagen durch den Nutzer\n\n'
            'Die Pflicht des Nutzers, wichtige Fristen selbst zu prüfen und geeignete eigene Sicherungsmaßnahmen zu treffen, bleibt unberührt.'),

          _section(context, '13. Gesetzliche Haftungsgrenzen',
            'Unsere Haftung ist nicht ausgeschlossen oder beschränkt bei:\n\n'
            '• Vorsatz\n'
            '• grober Fahrlässigkeit\n'
            '• Verletzung von Leben, Körper oder Gesundheit\n'
            '• zwingender gesetzlicher Haftung\n'
            '• Ansprüchen nach dem Produkthaftungsgesetz\n'
            '• Verletzung wesentlicher Vertragspflichten, soweit gesetzlich erforderlich\n\n'
            'Bei leicht fahrlässiger Verletzung wesentlicher Vertragspflichten ist die Haftung, soweit gesetzlich zulässig, auf den vorhersehbaren, vertragstypischen Schaden begrenzt.\n\n'
            'Wesentliche Vertragspflichten sind solche Pflichten, deren Erfüllung die ordnungsgemäße Durchführung des Vertrags überhaupt erst ermöglicht und auf deren Einhaltung der Nutzer regelmäßig vertrauen darf.\n\n'
            'Im Übrigen ist die Haftung, soweit gesetzlich zulässig, ausgeschlossen.'),

          _section(context, '14. Verfügbarkeit der App',
            'Wir bemühen uns um einen zuverlässigen Betrieb der App.\n\n'
            'Wir gewährleisten jedoch keine ununterbrochene, fehlerfreie oder jederzeit verfügbare Nutzung.\n\n'
            'Die Verfügbarkeit kann insbesondere eingeschränkt sein durch:\n\n'
            '• Wartungsarbeiten\n'
            '• technische Störungen\n'
            '• Updates\n'
            '• Betriebssystemänderungen\n'
            '• App-Store-Vorgaben\n'
            '• Störungen bei Drittanbietern\n'
            '• höhere Gewalt'),

          _section(context, '15. Drittanbieter',
            'Für bestimmte Funktionen können Drittanbieter eingesetzt werden, insbesondere:\n\n'
            '• Apple App Store\n'
            '• Google Play\n'
            '• Firebase\n'
            '• RevenueCat\n'
            '• gegebenenfalls weitere technische Dienstleister\n\n'
            'Für Dienste und Systeme dieser Drittanbieter gelten ergänzend deren jeweilige Nutzungs- und Datenschutzbedingungen.\n\n'
            'Wir haften nicht für Störungen oder Ausfälle, die im Verantwortungsbereich von Drittanbietern liegen, soweit gesetzlich zulässig.'),

          _section(context, '16. Pflichten des Nutzers',
            'Der Nutzer verpflichtet sich, die App nur rechtmäßig zu verwenden.\n\n'
            'Unzulässig ist insbesondere:\n\n'
            '• missbräuchliche Nutzung der App\n'
            '• Manipulation der App\n'
            '• Umgehung von Premium-Beschränkungen\n'
            '• Nutzung automatisierter Zugriffe ohne Erlaubnis\n'
            '• Eingabe rechtswidriger Inhalte\n'
            '• Verletzung von Rechten Dritter'),

          _section(context, '17. Änderungen der App',
            'Wir dürfen die App weiterentwickeln, verbessern, ändern oder einzelne Funktionen anpassen, soweit dies für Nutzer zumutbar ist.\n\n'
            'Dies kann insbesondere erforderlich sein zur:\n\n'
            '• Verbesserung der Sicherheit\n'
            '• Fehlerbehebung\n'
            '• Anpassung an Betriebssysteme\n'
            '• Umsetzung rechtlicher Anforderungen\n'
            '• Einführung neuer Funktionen\n'
            '• Entfernung nicht mehr unterstützter Funktionen'),

          _section(context, '18. Änderungen dieser AGB',
            'Wir können diese AGB ändern, wenn dies aus sachlichen Gründen erforderlich ist, insbesondere bei:\n\n'
            '• Änderungen der App-Funktionen\n'
            '• Änderungen der Rechtslage\n'
            '• Änderungen technischer Abläufe\n'
            '• Einführung neuer Premium-Funktionen\n'
            '• Anpassungen an App-Store-Vorgaben\n\n'
            'Über wesentliche Änderungen informieren wir Nutzer in geeigneter Weise.'),

          _section(context, '19. Datenschutz',
            'Informationen zur Verarbeitung personenbezogener Daten enthält unsere Datenschutzerklärung.\n\n'
            'Diese ist in der App unter „Datenschutz" abrufbar.'),

          _section(context, '20. Widerrufsrecht',
            'Wenn der Nutzer Verbraucher ist, kann ihm bei kostenpflichtigen digitalen Leistungen ein gesetzliches Widerrufsrecht zustehen.\n\n'
            'Für über den Apple App Store oder Google Play abgeschlossene Käufe und Abonnements gelten die jeweiligen Widerrufs-, Erstattungs- und Kündigungsbedingungen des App-Store-Anbieters.'),

          _section(context, '21. Anwendbares Recht',
            'Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts.\n\n'
            'Wenn der Nutzer Verbraucher ist und seinen gewöhnlichen Aufenthalt in einem anderen Staat der Europäischen Union hat, bleiben zwingende Verbraucherschutzvorschriften dieses Staates unberührt.'),

          _section(context, '22. Streitbeilegung',
            'Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung bereit:\n\n'
            'https://ec.europa.eu/consumers/odr/\n\n'
            'Wir sind nicht verpflichtet und nicht bereit, an einem Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen, sofern keine gesetzliche Pflicht besteht.'),

          _section(context, '23. Schlussbestimmungen',
            'Sollten einzelne Bestimmungen dieser AGB unwirksam sein oder werden, bleibt die Wirksamkeit der übrigen Bestimmungen unberührt.\n\n'
            'Anstelle der unwirksamen Bestimmung gelten die gesetzlichen Vorschriften.'),

          _section(context, '24. Kontakt',
            'Bei Fragen zu diesen AGB erreichst du uns unter:\n\n'
            'Philipp Schaefer\n'
            'Cortijo las padillas 2\n'
            '29749 Almayate\n'
            'Spanien\n'
            'E-Mail: appfactorymalaga@gmail.com'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(fontSize: 14, color: AppColors.textOf(context), height: 1.6)),
        ],
      ),
    );
  }
}
