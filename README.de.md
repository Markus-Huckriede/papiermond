# Papiermond

Ein privates Tagebuch für den Desktop. **Alles bleibt auf deinem Rechner:** keine Cloud, kein Konto, keine Werbung, keine Datensammlung. Die App baut keine Internetverbindung auf.

[English version → README.md](README.md)

## Funktionen

- Einträge schreiben mit Titel, Datum und Stimmung, automatisch gespeichert
- Bilder zu jedem Eintrag hinzufügen
- Suche über alle Einträge, Monatsübersicht und „An diesem Tag“-Rückblick
- Anpassbar: hell/dunkel, sechs Akzentfarben, drei Schriftarten, Textgröße
- **Backup** als ZIP exportieren und importieren (Einträge und Bilder)
- **Texte importieren** aus `.txt`, `.md`, `.docx` (Word, auch aus Pages exportiert) und `.odt`, zum Beispiel etwas, das du unterwegs diktiert oder notiert hast
- Deutsch und Englisch
- Läuft unter macOS, Windows und Linux

## Installieren

Lade die Datei für dein System unter **[Releases](../../releases/latest)** herunter.

Die Programme sind **nicht signiert** (Zertifikate kosten Geld, das Projekt ist kostenlos). Deshalb zeigt dein System beim ersten Start eine Warnung. Das ist normal.

### Windows

1. `Papiermond-windows.zip` herunterladen und **entpacken** (Rechtsklick → „Alle extrahieren“).
2. `papiermond.exe` starten.
3. Bei der Meldung „Der Computer wurde durch Windows geschützt“: **Weitere Informationen → Trotzdem ausführen**.

### macOS

1. `Papiermond-macos.zip` herunterladen, entpacken und **Papiermond** in den Ordner *Programme* ziehen.
2. Beim ersten Start: Rechtsklick auf die App → **Öffnen** → nochmals **Öffnen**.
3. Falls macOS die App weiterhin blockiert („beschädigt“ oder „nicht überprüfbar“), im Terminal ausführen:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/Papiermond.app"
   ```

### Linux

```bash
mkdir papiermond && tar -xzf Papiermond-linux.tar.gz -C papiermond
./papiermond/papiermond
```

Benötigt GTK 3 (unter Ubuntu/Debian meist vorhanden: `sudo apt install libgtk-3-0`).

## Wo liegen meine Daten?

Die Einträge liegen als normale Dateien in einem Ordner (Pfad steht in den Einstellungen unter *Daten*):

| System  | Ordner |
|---------|--------|
| Windows | `Dokumente\Papiermond` |
| Linux   | `~/Documents/Papiermond` |
| macOS   | `~/Library/Containers/org.papiermond.app/Data/Documents/Papiermond` |

Jeder Eintrag ist eine lesbare `.json`-Datei, Bilder liegen im Unterordner `images`.

> ⚠️ **Mach regelmäßig ein Backup** (*Einstellungen → Backup exportieren*). Es gibt keine Cloud. Geht der Rechner verloren oder kaputt, sind die Einträge sonst weg.

## Diktieren

Die App nutzt die Diktierfunktion deines Betriebssystems. Sie funktioniert in jedem Textfeld:

- **macOS:** Mikrofon-Taste (F5) oder **Fn/Globe-Taste zweimal** drücken (einmalig unter *Systemeinstellungen → Tastatur → Diktat* aktivieren)
- **Windows:** **Win + H**
- **Linux:** je nach Desktop; nicht überall verfügbar

**Unterwegs schreiben?** Diktiere oder tippe in der Notizen-App deines Handys, in Pages oder Word, speichere als `.txt`, `.docx` oder `.odt` und importiere die Datei am Rechner über *Einstellungen → Texte importieren*. Bei Pages-Dateien (`.pages`) zuerst *Ablage → Exportieren → Word* wählen.

## Datenschutz

- Alle Daten bleiben lokal auf deinem Gerät.
- Keine Benutzerkonten, keine Analyse- oder Tracking-Werkzeuge, keine Werbung.
- Die App enthält keinen Netzwerkcode und lädt nichts nach, auch keine Schriften.
- Deshalb verarbeitet der Autor keine personenbezogenen Daten von dir. Verantwortlich für deine Einträge und Backups bist du selbst.

## Aus dem Quellcode bauen

Voraussetzung: [Flutter](https://docs.flutter.dev/get-started/install) (stable).

```bash
git clone <dieses-repository>
cd papiermond
flutter pub get
flutter test
flutter run -d macos      # oder: windows, linux
flutter build macos       # oder: windows, linux
```

- **macOS:** vollständiges Xcode (aus dem App Store)
- **Windows:** Visual Studio mit „Desktopentwicklung mit C++“
- **Linux:** `sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`

Fertige Installer für alle drei Systeme baut der GitHub-Workflow [`build.yml`](.github/workflows/build.yml), sobald ein Tag wie `v1.0.0` gepusht wird.

## Lizenzen

- Quellcode: [MIT-Lizenz](LICENSE). Du darfst die App frei nutzen, ändern und weitergeben.
- **Schriften:** Es werden keine Schriftdateien mitgeliefert. Die App verwendet die Systemschriften (Standard, Georgia, Courier New bzw. Ersatzschriften). Dafür fallen keine Lizenzen an.
- **Icons:** Material Icons von Google (Apache-2.0), Teil von Flutter.
- **App-Icon:** selbst gezeichnet (siehe `tool/make_icon_test.dart`), steht unter derselben MIT-Lizenz.
- **Pakete:** Flutter (BSD-3), `path_provider`, `shared_preferences`, `intl`, `path` (BSD-3), `file_picker`, `archive`, `xml` (MIT). In der App unter *Einstellungen → Open-Source-Lizenzen* vollständig aufgelistet.

## Hinweis

Dies ist ein privates Hobbyprojekt, das kostenlos und ohne Gewähr („as is“) bereitgestellt wird. Es gibt keinen Support und keine Wartungszusage. Forks und Weiterentwicklungen sind ausdrücklich erlaubt.
