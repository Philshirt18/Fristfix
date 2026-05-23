# FristFix – Legal Launch Checklist

Interne Checkliste für den rechtssicheren App-Launch.

---

## 1. Impressum

- [ ] Impressum in der App unter Einstellungen → Rechtliches → Impressum
- [ ] Impressum auf der Website (falls vorhanden)
- [ ] Vollständige Angaben: Name, Anschrift, E-Mail
- [ ] **DSA/Trader-Hinweis:** Prüfen, ob als „Trader" im Sinne des Digital Services Act (DSA) eine zusätzliche Kennzeichnung in den App Stores erforderlich ist

## 2. Datenschutzerklärung

- [ ] Datenschutzerklärung in der App unter Einstellungen → Rechtliches → Datenschutzerklärung
- [ ] Datenschutzerklärung auf der Website (falls vorhanden)
- [ ] Alle genutzten SDKs und Drittanbieter aufgeführt (Firebase, RevenueCat etc.)
- [ ] Rechtsgrundlagen für jede Verarbeitung angegeben
- [ ] Hinweis auf Datenübermittlung in Drittländer (USA) inkl. Rechtsgrundlage
- [ ] Kontaktdaten für Datenschutzanfragen angegeben
- [ ] Hinweis auf Betroffenenrechte (Auskunft, Löschung, Widerspruch etc.)

## 3. AGB

- [ ] AGB in der App unter Einstellungen → Rechtliches → AGB
- [ ] Haftungsausschluss für verpasste Fristen enthalten
- [ ] Hinweis auf organisatorische Erinnerungshilfe (keine Rechtsberatung)
- [ ] Regelungen zu Premium, Zahlung, Kündigung enthalten
- [ ] Hinweis auf App-Store-Bedingungen

## 4. Abo & Widerruf

- [ ] Eigene Seite in der App unter Einstellungen → Rechtliches → Abo & Widerruf
- [ ] Preis klar angegeben (5,99 €/Jahr, ggf. Einführungsangebot 3,99 €)
- [ ] Automatische Verlängerung erwähnt
- [ ] Kündigungsweg über App Store beschrieben
- [ ] Widerrufs- und Erstattungshinweise enthalten
- [ ] Abo-Verlängerungshinweis im Paywall und Premium-Screen sichtbar

## 5. App Store Connect (Apple)

- [ ] Privacy Policy URL hinterlegt
- [ ] Terms of Use URL hinterlegt (falls erforderlich)
- [ ] App Privacy / Datenschutz-Labels korrekt ausgefüllt
- [ ] In-App-Käufe / Abos korrekt konfiguriert
- [ ] Abo-Beschreibung mit Preis, Laufzeit und Verlängerungshinweis
- [ ] DSA Trader Status geprüft und ggf. gesetzt

## 6. Google Play Console

- [ ] Datenschutzerklärung URL hinterlegt
- [ ] Datensicherheitsbereich korrekt ausgefüllt
- [ ] In-App-Käufe / Abos korrekt konfiguriert
- [ ] Abo-Beschreibung mit Preis, Laufzeit und Verlängerungshinweis
- [ ] DSA Trader Status geprüft und ggf. gesetzt

## 7. SDKs und Drittanbieter

- [ ] Firebase: Datenschutzerklärung deckt Firebase Analytics, Auth, Firestore ab
- [ ] RevenueCat: Datenschutzerklärung deckt Zahlungsabwicklung ab
- [ ] Alle SDKs in der Datenschutzerklärung aufgeführt
- [ ] Keine unerwarteten Tracking-SDKs enthalten
- [ ] App Tracking Transparency (ATT) geprüft – wird ATT-Prompt benötigt?

## 8. In-App Hinweise

- [ ] Haftungshinweis im Einstellungen-Screen (Rechtliches-Sektion)
- [ ] Abo-Verlängerungshinweis im Premium-Paywall (Bottom Sheet)
- [ ] Abo-Verlängerungshinweis im Premium-Screen
- [ ] Erinnerungshinweis im Add-Deadline-Formular
- [ ] Notification Pre-Prompt vor System-Berechtigungsabfrage
- [ ] Lizenzen-Seite über showLicensePage erreichbar

## 9. Website (falls vorhanden)

- [ ] Impressum auf der Website
- [ ] Datenschutzerklärung auf der Website
- [ ] AGB auf der Website (falls Abo auch über Website abschließbar)
- [ ] Cookie-Banner (falls Cookies oder Tracking eingesetzt werden)

## 10. Anwaltliche Prüfung

- [ ] AGB anwaltlich prüfen lassen
- [ ] Datenschutzerklärung anwaltlich prüfen lassen
- [ ] Abo- und Widerrufshinweise anwaltlich prüfen lassen
- [ ] App-Store-Compliance (DSA, Trader-Status) anwaltlich prüfen lassen
