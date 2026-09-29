# Papiermond

A private desktop journal. **Everything stays on your computer:** no cloud, no account, no ads, no data collection. The app never connects to the internet.

[Deutsche Version → README.de.md](README.de.md)

## Features

- Write entries with title, date and mood, saved automatically
- Add images to any entry
- Search, month overview and an "On this day" throwback
- Customizable: light/dark, six accent colors, three fonts, text size
- **Backup** export/import as a ZIP file (entries and images)
- **Import texts** from `.txt`, `.md`, `.docx` (Word, also exported from Pages) and `.odt`, e.g. notes you dictated or wrote on the go
- English and German
- Runs on macOS, Windows and Linux

## Install

Download the file for your system from **[Releases](../../releases/latest)**.

The builds are **not code-signed** (certificates cost money, this project is free). Your system will therefore show a warning on first launch. That is expected.

### Windows

1. Download `Papiermond-windows.zip` and **extract** it (right-click → "Extract All").
2. Run `papiermond.exe`.
3. If Windows shows "Windows protected your PC": **More info → Run anyway**.

### macOS

1. Download `Papiermond-macos.zip`, unzip it and drag **Papiermond** to *Applications*.
2. On first launch: right-click the app → **Open** → **Open** again.
3. If macOS still blocks it ("damaged" or "cannot be verified"), run in Terminal:

   ```bash
   xattr -dr com.apple.quarantine "/Applications/Papiermond.app"
   ```

### Linux

```bash
mkdir papiermond && tar -xzf Papiermond-linux.tar.gz -C papiermond
./papiermond/papiermond
```

Requires GTK 3 (usually present on Ubuntu/Debian: `sudo apt install libgtk-3-0`).

## Where is my data?

Entries are stored as plain files in one folder (the path is shown in *Settings → Data*):

| System  | Folder |
|---------|--------|
| Windows | `Documents\Papiermond` |
| Linux   | `~/Documents/Papiermond` |
| macOS   | `~/Library/Containers/org.papiermond.app/Data/Documents/Papiermond` |

Each entry is a readable `.json` file; images are in the `images` subfolder.

> ⚠️ **Back up regularly** (*Settings → Export backup*). There is no cloud. If your computer is lost or breaks, your entries are gone otherwise.

## Dictation

The app uses your operating system's built-in dictation, which works in any text field:

- **macOS:** microphone key (F5) or press **Fn/Globe twice** (enable once under *System Settings → Keyboard → Dictation*)
- **Windows:** **Win + H**
- **Linux:** depends on the desktop; not available everywhere

**Writing on the go?** Dictate or type in your phone's notes app, Pages or Word, save as `.txt`, `.docx` or `.odt`, then import the file on your computer via *Settings → Import texts*. For Pages files (`.pages`), first choose *File → Export To → Word*.

## Privacy

- All data stays on your device.
- No accounts, no analytics or tracking, no ads.
- The app contains no networking code and downloads nothing, not even fonts.
- As a result, the author processes no personal data about you. You alone are responsible for your entries and backups.

## Build from source

Requires [Flutter](https://docs.flutter.dev/get-started/install) (stable).

```bash
git clone <this-repository>
cd papiermond
flutter pub get
flutter test
flutter run -d macos      # or: windows, linux
flutter build macos       # or: windows, linux
```

- **macOS:** full Xcode (from the App Store)
- **Windows:** Visual Studio with "Desktop development with C++"
- **Linux:** `sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev`

The GitHub workflow [`build.yml`](.github/workflows/build.yml) builds installers for all three systems when a tag such as `v1.0.0` is pushed.

## Licenses

- Source code: [MIT License](LICENSE). Use, modify and share freely.
- **Fonts:** no font files are bundled. The app uses system fonts (default, Georgia, Courier New or fallbacks), so no font licenses apply.
- **Icons:** Google Material Icons (Apache-2.0), part of Flutter.
- **App icon:** drawn in code (see `tool/make_icon_test.dart`), released under the same MIT license.
- **Packages:** Flutter (BSD-3), `path_provider`, `shared_preferences`, `intl`, `path` (BSD-3), `file_picker`, `archive`, `xml` (MIT). Fully listed in the app under *Settings → Open-source licenses*.

## Note

This is a private hobby project provided free of charge and "as is", without warranty. There is no support and no maintenance commitment. Forks and further development are explicitly welcome.
