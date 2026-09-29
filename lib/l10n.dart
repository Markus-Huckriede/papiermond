import 'package:flutter/widgets.dart';

/// Kleine eigene Übersetzung (Deutsch/Englisch), ohne Zusatzpakete.
/// Andere Sprachen fallen auf Englisch zurück.
abstract class S {
  static S of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'de' ? const _De() : const _En();

  static const supportedLocales = [Locale('de'), Locale('en')];

  const S();

  String get appName => 'Papiermond';
  String get newEntry;
  String get search;
  String get noEntries;
  String get noResults;
  String get pickEntry;
  String get onThisDay;
  String get untitled;
  String get titleHint;
  String get bodyHint;
  String get dictationTip;
  String get addImages;
  String get delete;
  String get deleteTitle;
  String get deleteBody;
  String get cancel;
  String get mood;
  String get settings;
  String get appearance;
  String get theme;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get accent;
  String get font;
  String get fontSans;
  String get fontSerif;
  String get fontMono;
  String get textSize;
  String get data;
  String get exportBackup;
  String get exportBackupHint;
  String get importBackup;
  String get importBackupHint;
  String get importDocs;
  String get importDocsHint;
  String get dataFolder;
  String get exported;
  String importedBackup(int added, int updated, int skipped);
  String importedDocs(int n);
  String importFailed(String reason);
  String unsupported(String ext);
  String get about;
  String get privacy;
  String get privacyText;
  String get backupReminder;
  String get licenses;
  String get previewMode;
  String get close;
  String yearsAgo(int years);
  String get moodTerrible;
  String get moodBad;
  String get moodOkay;
  String get moodGood;
  String get moodGreat;
}

class _De extends S {
  const _De();
  @override
  String get newEntry => 'Neuer Eintrag';
  @override
  String get search => 'Suchen …';
  @override
  String get noEntries => 'Noch keine Einträge.\nSchreib den ersten!';
  @override
  String get noResults => 'Nichts gefunden.';
  @override
  String get pickEntry => 'Wähle links einen Eintrag oder schreib einen neuen.';
  @override
  String get onThisDay => 'An diesem Tag';
  @override
  String get untitled => 'Ohne Titel';
  @override
  String get titleHint => 'Titel (optional)';
  @override
  String get bodyHint => 'Was beschäftigt dich heute?';
  @override
  String get dictationTip =>
      'Diktieren: macOS – Mikrofon-Taste oder Fn/Globe zweimal drücken · Windows – Win+H';
  @override
  String get addImages => 'Bilder hinzufügen';
  @override
  String get delete => 'Löschen';
  @override
  String get deleteTitle => 'Eintrag löschen?';
  @override
  String get deleteBody =>
      'Dieser Eintrag und seine Bilder werden unwiderruflich von diesem Gerät gelöscht.';
  @override
  String get cancel => 'Abbrechen';
  @override
  String get mood => 'Stimmung';
  @override
  String get settings => 'Einstellungen';
  @override
  String get appearance => 'Aussehen';
  @override
  String get theme => 'Design';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Hell';
  @override
  String get themeDark => 'Dunkel';
  @override
  String get accent => 'Akzentfarbe';
  @override
  String get font => 'Schrift';
  @override
  String get fontSans => 'Serifenlos';
  @override
  String get fontSerif => 'Serif';
  @override
  String get fontMono => 'Schreibmaschine';
  @override
  String get textSize => 'Textgröße';
  @override
  String get data => 'Daten';
  @override
  String get exportBackup => 'Backup exportieren';
  @override
  String get exportBackupHint => 'Alle Einträge und Bilder als ZIP-Datei speichern';
  @override
  String get importBackup => 'Backup importieren';
  @override
  String get importBackupHint => 'ZIP-Backup einlesen und mit den vorhandenen Einträgen zusammenführen';
  @override
  String get importDocs => 'Texte importieren';
  @override
  String get importDocsHint =>
      '.txt, .md, .docx (Word, Pages-Export) oder .odt – je Datei ein Eintrag';
  @override
  String get dataFolder => 'Speicherort';
  @override
  String get exported => 'Backup gespeichert.';
  @override
  String importedBackup(int added, int updated, int skipped) =>
      '$added neu, $updated aktualisiert, $skipped übersprungen.';
  @override
  String importedDocs(int n) => n == 1 ? '1 Eintrag importiert.' : '$n Einträge importiert.';
  @override
  String importFailed(String reason) => 'Import fehlgeschlagen: $reason';
  @override
  String unsupported(String ext) =>
      'Dateityp „.$ext“ wird nicht unterstützt. Pages-Dateien bitte in Pages als Word exportieren.';
  @override
  String get about => 'Über die App';
  @override
  String get privacy => 'Datenschutz';
  @override
  String get privacyText =>
      'Alle Einträge und Bilder bleiben auf diesem Gerät. Die App stellt keine '
      'Internetverbindung her, sammelt keine Daten und hat keine Benutzerkonten.';
  @override
  String get backupReminder =>
      'Es gibt keine Cloud: Mach regelmäßig ein Backup, sonst sind die Einträge '
      'bei Verlust oder Defekt des Geräts weg.';
  @override
  String get licenses => 'Open-Source-Lizenzen';
  @override
  String get previewMode => 'Vorschau-Modus: Einträge werden nicht dauerhaft gespeichert.';
  @override
  String get close => 'Schließen';
  @override
  String yearsAgo(int years) => years == 1 ? 'vor 1 Jahr' : 'vor $years Jahren';
  @override
  String get moodTerrible => 'Sehr schlecht';
  @override
  String get moodBad => 'Schlecht';
  @override
  String get moodOkay => 'Okay';
  @override
  String get moodGood => 'Gut';
  @override
  String get moodGreat => 'Sehr gut';
}

class _En extends S {
  const _En();
  @override
  String get newEntry => 'New entry';
  @override
  String get search => 'Search …';
  @override
  String get noEntries => 'No entries yet.\nWrite your first one!';
  @override
  String get noResults => 'Nothing found.';
  @override
  String get pickEntry => 'Pick an entry on the left or write a new one.';
  @override
  String get onThisDay => 'On this day';
  @override
  String get untitled => 'Untitled';
  @override
  String get titleHint => 'Title (optional)';
  @override
  String get bodyHint => "What's on your mind today?";
  @override
  String get dictationTip =>
      'Dictation: macOS – microphone key or press Fn/Globe twice · Windows – Win+H';
  @override
  String get addImages => 'Add images';
  @override
  String get delete => 'Delete';
  @override
  String get deleteTitle => 'Delete entry?';
  @override
  String get deleteBody =>
      'This entry and its images will be permanently deleted from this device.';
  @override
  String get cancel => 'Cancel';
  @override
  String get mood => 'Mood';
  @override
  String get settings => 'Settings';
  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get accent => 'Accent color';
  @override
  String get font => 'Font';
  @override
  String get fontSans => 'Sans-serif';
  @override
  String get fontSerif => 'Serif';
  @override
  String get fontMono => 'Typewriter';
  @override
  String get textSize => 'Text size';
  @override
  String get data => 'Data';
  @override
  String get exportBackup => 'Export backup';
  @override
  String get exportBackupHint => 'Save all entries and images as a ZIP file';
  @override
  String get importBackup => 'Import backup';
  @override
  String get importBackupHint => 'Read a ZIP backup and merge it with your existing entries';
  @override
  String get importDocs => 'Import texts';
  @override
  String get importDocsHint =>
      '.txt, .md, .docx (Word, Pages export) or .odt – one entry per file';
  @override
  String get dataFolder => 'Storage location';
  @override
  String get exported => 'Backup saved.';
  @override
  String importedBackup(int added, int updated, int skipped) =>
      '$added new, $updated updated, $skipped skipped.';
  @override
  String importedDocs(int n) => n == 1 ? '1 entry imported.' : '$n entries imported.';
  @override
  String importFailed(String reason) => 'Import failed: $reason';
  @override
  String unsupported(String ext) =>
      'File type ".$ext" is not supported. For Pages files, export as Word from within Pages.';
  @override
  String get about => 'About';
  @override
  String get privacy => 'Privacy';
  @override
  String get privacyText =>
      'All entries and images stay on this device. The app makes no internet '
      'connections, collects no data and has no user accounts.';
  @override
  String get backupReminder =>
      'There is no cloud: back up regularly, otherwise your entries are lost '
      'if the device is lost or breaks.';
  @override
  String get licenses => 'Open-source licenses';
  @override
  String get previewMode => 'Preview mode: entries are not saved permanently.';
  @override
  String get close => 'Close';
  @override
  String yearsAgo(int years) => years == 1 ? '1 year ago' : '$years years ago';
  @override
  String get moodTerrible => 'Terrible';
  @override
  String get moodBad => 'Bad';
  @override
  String get moodOkay => 'Okay';
  @override
  String get moodGood => 'Good';
  @override
  String get moodGreat => 'Great';
}
