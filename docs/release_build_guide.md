# FristFix – Release Build Guide

## Android Release Build

### Schritt 1: Keystore erstellen (einmalig)

Führe diesen Befehl im Terminal aus:

```bash
keytool -genkey -v -keystore ~/fristfix-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias fristfix \
  -dname "CN=Philipp Schaefer, OU=FristFix, O=Philipp Schaefer, L=Almayate, S=Malaga, C=ES"
```

Wähle ein sicheres Passwort und merke es dir gut!

### Schritt 2: key.properties erstellen

Erstelle die Datei `android/key.properties` (NICHT in Git committen!):

```
storePassword=DEIN_PASSWORT
keyPassword=DEIN_PASSWORT
keyAlias=fristfix
storeFile=/Users/phil/fristfix-release.jks
```

### Schritt 3: build.gradle.kts anpassen

In `android/app/build.gradle.kts` vor `android {` einfügen:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Und `signingConfigs` + `buildTypes` anpassen:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = false
    }
}
```

### Schritt 4: Release APK / AAB bauen

```bash
# AAB für Google Play (empfohlen)
flutter build appbundle --release

# APK für direktes Testen
flutter build apk --release
```

---

## iOS Release Build

### Voraussetzungen
- Apple Developer Account (99 €/Jahr) ✅
- App in App Store Connect angelegt
- Xcode geöffnet mit ios/Runner.xcworkspace

### Schritt 1: In Xcode
1. Öffne `ios/Runner.xcworkspace`
2. Wähle Runner → Signing & Capabilities
3. Wähle dein Team (Philipp Schaefer)
4. Bundle ID: de.fristfix.fristfix

### Schritt 2: Archive erstellen
```bash
flutter build ipa --release
```

Oder in Xcode: Product → Archive

### Schritt 3: Upload zu App Store Connect
```bash
xcrun altool --upload-app -f build/ios/ipa/*.ipa \
  -t ios --apiKey KEY --apiIssuer ISSUER
```

Oder über Xcode: Window → Organizer → Distribute App

---

## Versionierung

Aktuelle Version: 1.0.0+1

Für Updates in pubspec.yaml erhöhen:
- `version: 1.0.1+2` (Bugfix)
- `version: 1.1.0+3` (neues Feature)
- `version: 2.0.0+4` (Major Update)

---

## .gitignore ergänzen

Füge zu .gitignore hinzu:
```
android/key.properties
*.jks
*.keystore
```
