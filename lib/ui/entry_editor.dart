import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n.dart';
import '../models/entry.dart';
import '../state/journal_controller.dart';
import 'mood.dart';

/// Editor für einen Eintrag. Änderungen werden automatisch gespeichert.
class EntryEditor extends StatefulWidget {
  const EntryEditor({super.key, required this.journal, required this.entry});

  final JournalController journal;
  final Entry entry;

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  Timer? _debounce;

  Entry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: entry.title);
    _body = TextEditingController(text: entry.body);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    entry.title = _title.text;
    entry.body = _body.text;
    // Beim Verlassen: speichern, leere Einträge verwerfen.
    widget.journal.commit(entry, discardEmpty: true);
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _changed() {
    entry.title = _title.text;
    entry.body = _body.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => widget.journal.commit(entry));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: entry.date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      entry.date = DateTime(picked.year, picked.month, picked.day, entry.date.hour,
          entry.date.minute);
    });
    widget.journal.commit(entry);
  }

  void _setMood(int index) {
    setState(() => entry.mood = entry.mood == index ? null : index);
    widget.journal.commit(entry);
  }

  Future<void> _addImages() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    for (final f in files) {
      final bytes = await f.readAsBytes();
      await widget.journal.addImage(entry, bytes, f.extension ?? 'jpg');
    }
    if (mounted) setState(() {});
  }

  Future<void> _removeImage(String name) async {
    await widget.journal.removeImage(entry, name);
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteTitle),
        content: Text(s.deleteBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _debounce?.cancel();
    await widget.journal.delete(entry);
    if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  void _showImage(String name) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(children: [
          Positioned.fill(
            child: FutureBuilder(
              future: widget.journal.image(name),
              builder: (context, snap) => snap.data == null
                  ? const SizedBox.shrink()
                  : InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 6,
                      child: Image.memory(snap.data!, fit: BoxFit.contain),
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filledTonal(
              tooltip: S.of(context).close,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final labels = moodLabels(s);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(DateFormat.yMMMMEEEEd(locale).format(entry.date)),
                ),
                for (var i = 0; i < moodIcons.length; i++)
                  IconButton(
                    tooltip: '${s.mood}: ${labels[i]}',
                    isSelected: entry.mood == i,
                    icon: Icon(moodIcons[i]),
                    selectedIcon: Icon(moodIcons[i]),
                    color: theme.colorScheme.outline,
                    style: IconButton.styleFrom(
                      foregroundColor: entry.mood == i
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.outline,
                      backgroundColor:
                          entry.mood == i ? theme.colorScheme.primaryContainer : null,
                    ),
                    onPressed: () => _setMood(i),
                  ),
                IconButton(
                  tooltip: s.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _delete,
                ),
              ],
            ),
            TextField(
              controller: _title,
              onChanged: (_) => _changed(),
              style: theme.textTheme.headlineSmall,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(hintText: s.titleHint),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _body,
              autofocus: entry.isEmpty,
              onChanged: (_) => _changed(),
              minLines: 10,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
              decoration: InputDecoration(hintText: s.bodyHint),
            ),
            const SizedBox(height: 8),
            if (entry.images.isNotEmpty)
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (final name in entry.images)
                  _Thumb(
                    journal: widget.journal,
                    name: name,
                    onTap: () => _showImage(name),
                    onRemove: () => _removeImage(name),
                  ),
              ]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(s.addImages),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.dictationTip,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.journal,
    required this.name,
    required this.onTap,
    required this.onRemove,
  });

  final JournalController journal;
  final String name;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    const size = 132.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder(
              future: journal.image(name),
              builder: (context, snap) {
                final bytes = snap.data;
                return InkWell(
                  onTap: bytes == null ? null : onTap,
                  child: bytes == null
                      ? ColoredBox(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: const Icon(Icons.broken_image_outlined),
                        )
                      : Image.memory(bytes,
                          fit: BoxFit.cover, cacheWidth: (size * 2).toInt()),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            icon: const Icon(Icons.close),
            onPressed: onRemove,
          ),
        ),
      ]),
    );
  }
}
