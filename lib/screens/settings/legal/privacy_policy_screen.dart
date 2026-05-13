import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PrivacyPolicyScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        title: const Text('Datenschutzerklärung'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text('Datenschutzerklärung\nfür FristFix',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textOf(context), height: 1.3)),
          const SizedBox(height: 8),
          Text('Stand: 30.04.2026', style: TextStyle(fontSize: 13, color: AppColors.mutedOf(context))),
          const SizedBox(height: 16),
          _body(context,
            'Wir freuen uns über dein Interesse an FristFix. Der Schutz deiner Daten ist uns wichtig. FristFix ist eine App, mit der du wichtige Fristen wie Kündigungsfristen, Ausweise, TÜV, Versicherungen, Steuertermine, Wohnungsunterlagen, Schule/Kita und sonstigen Papierkram manuell speichern und dich rechtzeitig erinnern lassen kannst.\n\n'
            'FristFix ist kein Vergleichsportal, vermittelt keine Verträge, zeigt keine Werbung und verdient nicht an Anbieterwechseln oder Kündigungen.'),
          _s(context, '1. Verantwortlicher',
            'Verantwortlich für die Datenverarbeitung ist:\n\n'
            'Philipp Schaefer\nCortijo las padillas 2\n29749 Almayate\nSpanien\nE-Mail: appfactorymalaga@gmail.com\n\n'
            'E-Mail für Datenschutzanfragen: appfactorymalaga@gmail.com'),
          _s(context, '2. Grundprinzipien von FristFix',
            'FristFix ist grundsätzlich lokal nutzbar.\n\nDas bedeutet:\n\n'
            '• Du kannst FristFix ohne Konto verwenden.\n'
            '• Deine Fristen werden zunächst nur auf deinem Gerät gespeichert.\n'
            '• Ohne Konto findet kein automatischer Cloud-Sync statt.\n'
            '• Ein Konto ist nur erforderlich, wenn du Funktionen wie Backup, Wiederherstellung oder spätere Synchronisierung nutzen möchtest.\n'
            '• Wir verkaufen keine personenbezogenen Daten.\n'
            '• Wir zeigen keine Werbung.\n'
            '• Wir vermitteln keine Verträge.\n'
            '• Wir erhalten keine Anbieter-Provisionen.'),
          _s(context, '3. Welche Daten verarbeitet FristFix?', ''),
          _s(context, '3.1 Lokal gespeicherte Fristdaten',
            'Wenn du FristFix ohne Konto nutzt, werden deine eingegebenen Fristen lokal auf deinem Gerät gespeichert.\n\nDazu können gehören:\n\n'
            '• Titel der Frist, z. B. „Handyvertrag"\n'
            '• Anbieter, falls du ihn eingibst\n'
            '• Kategorie, z. B. Versicherung, Auto & TÜV, Ausweis & Pass\n'
            '• Fristtyp, z. B. Kündigungsfrist, Ablaufdatum, wichtiger Termin\n'
            '• relevantes Datum\n'
            '• Erinnerungszeitpunkte\n'
            '• optionale Notizen\n'
            '• Status, z. B. aktiv, erledigt oder archiviert\n'
            '• Erstellungs- und Änderungsdatum\n\n'
            'Diese Daten werden ohne Konto grundsätzlich nicht an uns übertragen.\n\n'
            'Hinweis: Wenn du dein Gerät verlierst, die App löschst oder dein Gerät zurücksetzt, können lokal gespeicherte Daten verloren gehen, sofern du kein Backup aktiviert hast.'),
          _s(context, '3.2 Kontodaten bei optionaler Anmeldung',
            'Wenn du ein Konto erstellst, zum Beispiel um deine Fristen zu sichern oder später auf einem neuen Gerät wiederherzustellen, können folgende Daten verarbeitet werden:\n\n'
            '• E-Mail-Adresse\n'
            '• Nutzer-ID\n'
            '• Login-Anbieter, z. B. Apple, Google oder E-Mail\n'
            '• Zeitpunkt der Kontoerstellung\n'
            '• technische Authentifizierungsdaten\n\n'
            'Die Anmeldung erfolgt über Firebase Authentication von Google.'),
          _s(context, '3.3 Cloud-Backup und Synchronisierung',
            'Wenn du Backup oder Synchronisierung aktivierst, werden deine Fristdaten in der Cloud gespeichert, damit du sie wiederherstellen oder später geräteübergreifend nutzen kannst.\n\n'
            'Dabei können die unter 3.1 genannten Fristdaten verarbeitet werden.\n\n'
            'Cloud-Backup ist optional. Ohne aktiviertes Backup bleiben deine Fristen lokal auf deinem Gerät.'),
          _s(context, '3.4 Premium und Zahlungsdaten',
            'Wenn du FristFix Premium kaufst, wird die Zahlungsabwicklung über die App-Stores von Apple oder Google sowie über RevenueCat verarbeitet.\n\n'
            'Wir selbst erhalten keine vollständigen Zahlungsdaten wie Kreditkartennummern oder Bankdaten.\n\nVerarbeitet werden können insbesondere:\n\n'
            '• Kaufstatus\n'
            '• Abo-Status\n'
            '• Produkt-ID, z. B. Jahresabo\n'
            '• App-Store-Transaktionsinformationen\n'
            '• anonyme oder pseudonyme RevenueCat-Nutzer-ID\n'
            '• Informationen zur Wiederherstellung von Käufen\n\n'
            'RevenueCat hilft uns dabei, Premium-Zugänge zu verwalten und Käufe wiederherzustellen.'),
          _s(context, '3.5 Technische Daten',
            'Beim Betrieb der App können technische Daten verarbeitet werden, etwa:\n\n'
            '• Geräteinformationen\n'
            '• Betriebssystemversion\n'
            '• App-Version\n'
            '• technische Fehlerdaten\n'
            '• Zeitpunkte technischer Ereignisse\n'
            '• Sprache und Regionseinstellungen\n\n'
            'Diese Daten dienen der technischen Bereitstellung, Fehlerbehebung, Sicherheit und Stabilität der App.'),
          _s(context, '4. Zwecke der Verarbeitung',
            'Wir verarbeiten Daten zu folgenden Zwecken:\n\n'
            '• Bereitstellung der App-Funktionen\n'
            '• Speicherung und Anzeige deiner Fristen\n'
            '• Erinnerung an gespeicherte Fristen\n'
            '• Verwaltung erledigter oder archivierter Fristen\n'
            '• optionale Kontoerstellung\n'
            '• optionales Backup und Wiederherstellung\n'
            '• Verwaltung von Premium-Funktionen\n'
            '• Wiederherstellung von Käufen\n'
            '• technische Sicherheit und Stabilität der App\n'
            '• Fehlerbehebung und Support'),
          _s(context, '5. Rechtsgrundlagen der Verarbeitung',
            'Die Verarbeitung personenbezogener Daten erfolgt auf Grundlage der Datenschutz-Grundverordnung.\n\nJe nach Funktion kommen insbesondere folgende Rechtsgrundlagen in Betracht:'),
          _s(context, '5.1 Vertragserfüllung, Art. 6 Abs. 1 lit. b DSGVO',
            'Soweit die Verarbeitung erforderlich ist, um dir die App-Funktionen bereitzustellen, erfolgt sie zur Erfüllung des Nutzungsverhältnisses.\n\nDas betrifft insbesondere:\n\n'
            '• Speichern und Anzeigen deiner Fristen\n'
            '• Erinnerungsfunktionen\n'
            '• Konto- und Backup-Funktionen\n'
            '• Premium-Funktionen'),
          _s(context, '5.2 Einwilligung, Art. 6 Abs. 1 lit. a DSGVO',
            'Wenn eine Verarbeitung nur mit deiner Einwilligung erfolgt, zum Beispiel bei optionalen Berechtigungen oder bestimmten Benachrichtigungen, verarbeiten wir Daten auf Grundlage deiner Einwilligung.\n\n'
            'Du kannst eine Einwilligung jederzeit mit Wirkung für die Zukunft widerrufen.'),
          _s(context, '5.3 Berechtigte Interessen, Art. 6 Abs. 1 lit. f DSGVO',
            'Bestimmte technische Verarbeitungen erfolgen auf Grundlage berechtigter Interessen.\n\nUnsere berechtigten Interessen sind insbesondere:\n\n'
            '• sicherer Betrieb der App\n'
            '• Verhinderung von Missbrauch\n'
            '• Fehlerbehebung\n'
            '• Verbesserung der Stabilität\n'
            '• Verwaltung von Premium-Zugängen'),
          _s(context, '5.4 Gesetzliche Pflichten, Art. 6 Abs. 1 lit. c DSGVO',
            'Soweit wir gesetzlich verpflichtet sind, bestimmte Daten zu speichern oder offenzulegen, erfolgt die Verarbeitung auf Grundlage gesetzlicher Pflichten.'),
          _s(context, '6. App-Berechtigungen', ''),
          _s(context, '6.1 Benachrichtigungen',
            'FristFix kann dich bitten, Benachrichtigungen zu erlauben, damit du rechtzeitig an gespeicherte Fristen erinnert werden kannst.\n\n'
            'Du kannst Benachrichtigungen jederzeit in den Systemeinstellungen deines Geräts deaktivieren.'),
          _s(context, '6.2 Keine Kamera- oder Scanpflicht im MVP',
            'FristFix ist im aktuellen MVP manual-first. Das bedeutet:\n\n'
            '• Du trägst Fristen manuell ein.\n'
            '• Es findet keine automatische Dokumentenerkennung statt.\n'
            '• Es ist keine Scan- oder OCR-Funktion erforderlich.\n'
            '• Es werden keine Ausweise, Verträge oder Dokumente automatisch ausgelesen.\n\n'
            'Falls solche Funktionen später eingeführt werden, wird diese Datenschutzerklärung entsprechend aktualisiert.'),
          _s(context, '7. Lokale Speicherung',
            'Wenn du FristFix ohne Konto nutzt, werden deine Fristen lokal auf deinem Gerät gespeichert.\n\n'
            'Diese Daten werden nicht automatisch an uns übertragen.\n\n'
            'Du kannst lokale Daten in der App löschen, indem du einzelne Fristen löschst oder die App-Daten beziehungsweise die App auf deinem Gerät entfernst.'),
          _s(context, '8. Firebase',
            'Wir verwenden Firebase-Dienste von Google Ireland Limited beziehungsweise Google LLC, um optionale Funktionen wie Anmeldung, Authentifizierung, Cloud-Backup und technische App-Infrastruktur bereitzustellen.\n\n'
            'Je nach Implementierung können insbesondere folgende Firebase-Dienste eingesetzt werden:\n\n'
            '• Firebase Authentication\n'
            '• Cloud Firestore\n'
            '• Firebase Cloud Messaging, falls später Push-Funktionen über Firebase genutzt werden\n'
            '• gegebenenfalls Firebase Crashlytics, falls technische Fehleranalyse aktiviert wird\n\n'
            'Firebase verarbeitet Daten im Rahmen der jeweiligen Dienstleistung. Google stellt für Firebase Datenverarbeitungs- und Sicherheitsbedingungen bereit.\n\n'
            'Wenn du kein Konto erstellst und kein Backup aktivierst, werden deine Fristdaten grundsätzlich nicht für Cloud-Backup an Firebase übertragen.'),
          _s(context, '9. RevenueCat',
            'Wir verwenden RevenueCat zur Verwaltung von In-App-Käufen und Premium-Abonnements.\n\n'
            'RevenueCat verarbeitet Informationen zum Kauf- und Abo-Status, damit wir erkennen können, ob Premium-Funktionen freigeschaltet werden sollen und damit Käufe wiederhergestellt werden können.\n\n'
            'Wir erhalten über RevenueCat keine vollständigen Zahlungsdaten wie Kreditkarten- oder Bankdaten.'),
          _s(context, '10. Apple App Store und Google Play',
            'Wenn du FristFix über den Apple App Store oder Google Play installierst oder dort ein Premium-Abo abschließt, verarbeiten Apple beziehungsweise Google personenbezogene Daten in eigener Verantwortung.\n\n'
            'Für diese Verarbeitung gelten die Datenschutzbestimmungen von Apple beziehungsweise Google.'),
          _s(context, '11. Keine Werbung, kein Tracking zu Werbezwecken',
            'FristFix zeigt keine Werbung.\n\n'
            'FristFix verkauft keine personenbezogenen Daten.\n\n'
            'FristFix vermittelt keine Verträge und erhält keine Anbieter-Provisionen.\n\n'
            'Wir nutzen deine Fristdaten nicht, um dir Anbieterwechsel, Versicherungen, Verträge oder sonstige kommerzielle Angebote zu verkaufen.'),
          _s(context, '12. Keine automatisierten Entscheidungen',
            'FristFix trifft keine automatisierten Entscheidungen mit rechtlicher Wirkung oder ähnlich erheblicher Beeinträchtigung im Sinne von Art. 22 DSGVO.\n\n'
            'Die App erinnert dich lediglich an Daten, die du selbst eingetragen hast.'),
          _s(context, '13. Empfänger personenbezogener Daten',
            'Personenbezogene Daten können, soweit erforderlich, an folgende Kategorien von Empfängern übermittelt werden:\n\n'
            '• technische Dienstleister\n'
            '• Hosting- und Cloud-Anbieter\n'
            '• Authentifizierungsanbieter\n'
            '• Zahlungs- und Abo-Verwaltungsdienste\n'
            '• App-Store-Betreiber\n'
            '• Support- und Wartungsdienstleister\n'
            '• Behörden, sofern gesetzlich erforderlich\n\n'
            'Eine Weitergabe zu Werbezwecken findet nicht statt.'),
          _s(context, '14. Drittlandübermittlungen',
            'Bei der Nutzung von Firebase, Google-Diensten, Apple, Google Play oder RevenueCat kann eine Verarbeitung personenbezogener Daten außerhalb der Europäischen Union beziehungsweise des Europäischen Wirtschaftsraums stattfinden.\n\n'
            'Soweit Daten in Drittländer übertragen werden, erfolgt dies nur unter Beachtung der gesetzlichen Voraussetzungen, insbesondere auf Grundlage geeigneter Garantien wie Standardvertragsklauseln, Angemessenheitsbeschlüssen oder vergleichbarer Schutzmechanismen.'),
          _s(context, '15. Speicherdauer',
            'Wir speichern personenbezogene Daten nur so lange, wie es für die jeweiligen Zwecke erforderlich ist.\n\n'
            'Lokal gespeicherte Fristen bleiben auf deinem Gerät gespeichert, bis du sie löschst, archivierst, die App-Daten entfernst oder die App löschst.\n\n'
            'Cloud-Backup-Daten bleiben gespeichert, solange dein Konto besteht oder bis du die Daten löschst.\n\n'
            'Premium- und Kaufstatusdaten werden gespeichert, solange dies für die Verwaltung deines Abos, die Wiederherstellung von Käufen oder gesetzliche Nachweispflichten erforderlich ist.'),
          _s(context, '16. Deine Rechte',
            'Du hast nach Maßgabe der DSGVO insbesondere folgende Rechte:\n\n'
            '• Recht auf Auskunft\n'
            '• Recht auf Berichtigung\n'
            '• Recht auf Löschung\n'
            '• Recht auf Einschränkung der Verarbeitung\n'
            '• Recht auf Datenübertragbarkeit\n'
            '• Recht auf Widerspruch gegen bestimmte Verarbeitungen\n'
            '• Recht auf Widerruf erteilter Einwilligungen\n'
            '• Recht auf Beschwerde bei einer Datenschutzaufsichtsbehörde'),
          _s(context, '17. Widerruf von Einwilligungen',
            'Wenn eine Verarbeitung auf deiner Einwilligung beruht, kannst du diese Einwilligung jederzeit mit Wirkung für die Zukunft widerrufen.\n\n'
            'Beispiel: Du kannst Push-Benachrichtigungen jederzeit in den Systemeinstellungen deines Geräts deaktivieren.'),
          _s(context, '18. Löschung deiner Daten',
            'Du kannst gespeicherte Fristen in der App löschen.\n\n'
            'Wenn du ein Konto nutzt, kannst du die Löschung deiner personenbezogenen Daten oder deines Kontos über folgende E-Mail-Adresse verlangen:\n\n'
            'appfactorymalaga@gmail.com\n\n'
            'Optional in der App: Wenn eine Konto-Löschfunktion implementiert ist, kannst du dein Konto auch direkt in den Einstellungen löschen.'),
          _s(context, '19. Datensicherheit',
            'Wir treffen technische und organisatorische Maßnahmen, um personenbezogene Daten vor Verlust, Missbrauch, unbefugtem Zugriff und unbefugter Offenlegung zu schützen.\n\nDazu gehören je nach Implementierung insbesondere:\n\n'
            '• lokale Speicherung auf dem Gerät\n'
            '• Zugriffsbeschränkungen\n'
            '• verschlüsselte Übertragung, soweit Cloud-Dienste genutzt werden\n'
            '• Zugriff nur auf erforderliche Daten\n'
            '• sichere Authentifizierungsverfahren\n'
            '• regelmäßige technische Updates'),
          _s(context, '20. Kinder und Jugendliche',
            'FristFix richtet sich nicht gezielt an Kinder unter 16 Jahren.\n\n'
            'Wenn du jünger als 16 Jahre bist, solltest du FristFix nur mit Zustimmung deiner Eltern oder Erziehungsberechtigten verwenden.'),
          _s(context, '21. Änderungen dieser Datenschutzerklärung',
            'Wir können diese Datenschutzerklärung anpassen, wenn sich Funktionen der App, eingesetzte Dienste oder rechtliche Anforderungen ändern.\n\n'
            'Die jeweils aktuelle Version ist in der App unter „Datenschutz" abrufbar.'),
          _s(context, '22. Kontakt',
            'Bei Fragen zum Datenschutz kannst du uns kontaktieren:\n\n'
            'Philipp Schaefer\nCortijo las padillas 2\n29749 Almayate\nSpanien\nE-Mail: appfactorymalaga@gmail.com'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(text, style: TextStyle(fontSize: 14, color: AppColors.textOf(context), height: 1.6)),
    );
  }

  Widget _s(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textOf(context))),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(body, style: TextStyle(fontSize: 14, color: AppColors.textOf(context), height: 1.6)),
          ],
        ],
      ),
    );
  }
}
