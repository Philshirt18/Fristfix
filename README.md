# FristFix

**Nie wieder wichtige Fristen verpassen.**

FristFix ist eine deutsche Mobile App, mit der Nutzer wichtige Fristen speichern und sich rechtzeitig erinnern lassen können.

## Features

- 📋 Fristen manuell anlegen (Kündigungsfrist, Ablaufdatum, Termin, Geburtstag, Eigene Erinnerung)
- 🔔 Push Notifications (90, 30, 7 und 1 Tag vorher)
- 📅 Fristenkalender mit Monatsübersicht (Premium)
- ☁️ Cloud Backup & Sync via Firebase
- 🔐 Login mit Google, Apple oder E-Mail
- 🌙 Dark Mode
- 🇩🇪 Komplett auf Deutsch
- 📱 iOS & Android

## Tech Stack

- **Flutter** (Dart)
- **Firebase** (Auth, Firestore)
- **Hive** (lokale Speicherung)
- **RevenueCat** (In-App Purchases)
- **Provider** (State Management)
- **flutter_local_notifications** (Push)

## Architektur

```
lib/
├── main.dart
├── app.dart
├── theme/          # Farben, Theme (Light/Dark)
├── models/         # Deadline, Category, Type, Status
├── data/           # Hive Repository, Firestore Repository
├── services/       # Auth, Payment, Sync, Notifications
├── providers/      # State Management
├── screens/        # UI Screens
├── widgets/        # Wiederverwendbare Komponenten
└── utils/          # Hilfsfunktionen
```

## Setup

```bash
flutter pub get
flutter run
```

### Firebase
Firebase ist bereits konfiguriert. Für eigene Projekte:
```bash
flutterfire configure --project=YOUR_PROJECT
```

### Android Release Build
```bash
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ipa --release
```

## Anbieter

Philipp Schaefer  
Cortijo las padillas 2  
29749 Almayate, Spanien  
E-Mail: appfactorymalaga@gmail.com

## Lizenz

Proprietär – Alle Rechte vorbehalten.
