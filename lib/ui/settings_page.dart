import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/text_import.dart';
import '../l10n.dart';
import '../state/journal_controller.dart';
import '../state/settings_controller.dart';

const appVersion = '1.0.0';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.journal, required this.settings});

  final JournalController journal;
  final SettingsController settings;

  void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _export(BuildContext context) async {
    final s = S.of(context);
    try {
      final bytes = await journal.exportBackup();
      final name = 'papiermond-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.zip';
      final saved = await FilePicker.saveFile(
        fileName: name,
        bytes: bytes,
        mimeType: 'application/zip',
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (saved != null && context.mounted) _snack(context, s.exported);
    } catch (e) {
      if (context.mounted) _snack(context, s.importFailed('$e'));
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final s = S.of(context);
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (file == null) return;
    try {
      final r = await journal.importBackup(await file.readAsBytes());
      if (context.mounted) _snack(context, s.importedBackup(r.added, r.updated, r.skipped));
    } on FormatException catch (e) {
      if (context.mounted) _snack(context, s.importFailed(e.message));
    } catch (e) {
      if (context.mounted) _snack(context, s.importFailed('$e'));
    }
  }

  Future<void> _importDocs(BuildContext context) async {
    final s = S.of(context);
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: importableExtensions,
    );
    var count = 0;
    String? error;
    for (final f in files) {
      try {
        DateTime? date;
        try {
          date = await f.xFile.lastModified();
        } catch (_) {}
        await journal.importDocument(f.name, await f.readAsBytes(), date);
        count++;
      } on UnsupportedFormat catch (e) {
        error = s.unsupported(e.extension);
      } catch (e) {
        error = s.importFailed('${f.name}: $e');
      }
    }
    if (!context.mounted || files.isEmpty) return;
    _snack(context, error ?? s.importedDocs(count));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: settings,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _Header(s.appearance),
                _Labeled(
                  s.theme,
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: ThemeMode.system, label: Text(s.themeSystem)),
                      ButtonSegment(value: ThemeMode.light, label: Text(s.themeLight)),
                      ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (v) => settings.setThemeMode(v.first),
                  ),
                ),
                _Labeled(
                  s.accent,
                  Wrap(spacing: 12, children: [
                    for (var i = 0; i < accentColors.length; i++)
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => settings.setAccent(i),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: settings.accent == i
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: settings.accent == i
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                  ]),
                ),
                _Labeled(
                  s.font,
                  SegmentedButton<JournalFont>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: JournalFont.sans, label: Text(s.fontSans)),
                      ButtonSegment(value: JournalFont.serif, label: Text(s.fontSerif)),
                      ButtonSegment(value: JournalFont.mono, label: Text(s.fontMono)),
                    ],
                    selected: {settings.font},
                    onSelectionChanged: (v) => settings.setFont(v.first),
                  ),
                ),
                _Labeled(
                  s.textSize,
                  Slider(
                    value: settings.textScale,
                    min: 0.85,
                    max: 1.4,
                    divisions: 11,
                    onChanged: settings.setTextScale,
                  ),
                ),
                const SizedBox(height: 16),
                _Header(s.data),
                Card(
                  child: Column(children: [
                    ListTile(
                      leading: const Icon(Icons.archive_outlined),
                      title: Text(s.exportBackup),
                      subtitle: Text(s.exportBackupHint),
                      onTap: () => _export(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.unarchive_outlined),
                      title: Text(s.importBackup),
                      subtitle: Text(s.importBackupHint),
                      onTap: () => _importBackup(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(s.importDocs),
                      subtitle: Text(s.importDocsHint),
                      onTap: () => _importDocs(context),
                    ),
                    if (journal.store.location != null)
                      ListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(s.dataFolder),
                        subtitle: SelectableText(journal.store.location!),
                      ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(s.backupReminder,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 24),
                _Header(s.privacy),
                Text(s.privacyText, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                _Header(s.about),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: Text(s.licenses),
                    subtitle: Text('${s.appName} $appVersion · MIT License'),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: s.appName,
                      applicationVersion: appVersion,
                      applicationLegalese: 'MIT License · © Papiermond contributors',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          child,
        ]),
      );
}
