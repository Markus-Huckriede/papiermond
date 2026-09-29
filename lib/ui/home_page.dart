import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n.dart';
import '../models/entry.dart';
import '../state/journal_controller.dart';
import '../state/settings_controller.dart';
import 'entry_editor.dart';
import 'mood.dart';
import 'settings_page.dart';

/// Ab dieser Breite steht die Liste links und der Editor rechts.
const _wideBreakpoint = 840.0;

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.journal, required this.settings});

  final JournalController journal;
  final SettingsController settings;

  void _openSettings(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsPage(journal: journal, settings: settings),
        ),
      );

  void _openNarrow(BuildContext context, Entry entry) {
    journal.select(entry.id);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(),
            body: EntryEditor(key: ValueKey(entry.id), journal: journal, entry: entry),
          ),
        ))
        .then((_) => journal.select(null));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= _wideBreakpoint;
      final list = _EntryList(
        journal: journal,
        onSettings: () => _openSettings(context),
        onNew: () {
          final e = journal.createEntry();
          if (!wide) _openNarrow(context, e);
        },
        onOpen: (e) => wide ? journal.select(e.id) : _openNarrow(context, e),
      );
      if (!wide) return Scaffold(body: SafeArea(child: list));

      return Scaffold(
        body: SafeArea(
          child: Row(children: [
            SizedBox(width: 350, child: list),
            const VerticalDivider(width: 1),
            Expanded(
              child: ListenableBuilder(
                listenable: journal,
                builder: (context, _) {
                  final e = journal.selected;
                  if (e == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          s.pickEntry,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    );
                  }
                  return EntryEditor(key: ValueKey(e.id), journal: journal, entry: e);
                },
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.journal,
    required this.onSettings,
    required this.onNew,
    required this.onOpen,
  });

  final JournalController journal;
  final VoidCallback onSettings;
  final VoidCallback onNew;
  final void Function(Entry) onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Row(children: [
          Expanded(
            child: SearchBar(
              hintText: s.search,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              constraints: const BoxConstraints(minHeight: 44),
              onChanged: journal.setQuery,
            ),
          ),
          IconButton(
            tooltip: s.settings,
            icon: const Icon(Icons.tune),
            onPressed: onSettings,
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.edit_outlined),
            label: Text(s.newEntry),
          ),
        ),
      ),
      if (journal.store.location == null)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(s.previewMode,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
        ),
      Expanded(
        child: ListenableBuilder(
          listenable: journal,
          builder: (context, _) {
            final entries = journal.visible;
            if (entries.isEmpty) {
              return Center(
                child: Text(
                  journal.total == 0 ? s.noEntries : s.noResults,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              );
            }
            final memory = journal.query.isEmpty ? journal.onThisDay : null;
            final rows = <Widget>[];
            if (memory != null) {
              rows.add(_MemoryCard(entry: memory, onTap: () => onOpen(memory)));
            }
            String? lastMonth;
            for (final e in entries) {
              final month = DateFormat.yMMMM(locale).format(e.date);
              if (month != lastMonth) {
                lastMonth = month;
                rows.add(Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                  child: Text(month,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.primary)),
                ));
              }
              rows.add(_EntryTile(
                entry: e,
                selected: e.id == journal.selectedId,
                onTap: () => onOpen(e),
              ));
            }
            return ListView(padding: const EdgeInsets.only(bottom: 24), children: rows);
          },
        ),
      ),
    ]);
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.selected, required this.onTap});

  final Entry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final firstLine = entry.body.trim().split('\n').first;
    final title = entry.title.trim().isNotEmpty
        ? entry.title.trim()
        : (firstLine.isNotEmpty ? firstLine : s.untitled);
    final snippet = entry.title.trim().isNotEmpty ? entry.body.trim() : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: theme.colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [DateFormat.MMMEd(locale).format(entry.date), if (snippet.isNotEmpty) snippet]
              .join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (entry.images.isNotEmpty)
            Icon(Icons.image_outlined, size: 18, color: theme.colorScheme.outline),
          if (entry.mood != null) ...[
            const SizedBox(width: 6),
            Icon(moodIcons[entry.mood!], size: 20, color: theme.colorScheme.primary),
          ],
        ]),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.entry, required this.onTap});

  final Entry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final years = DateTime.now().year - entry.date.year;
    final text = entry.title.trim().isNotEmpty ? entry.title.trim() : entry.body.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.auto_awesome,
                    size: 16, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Text('${s.onThisDay} · ${s.yearsAgo(years)}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
              ]),
              const SizedBox(height: 6),
              Text(text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
            ]),
          ),
        ),
      ),
    );
  }
}
