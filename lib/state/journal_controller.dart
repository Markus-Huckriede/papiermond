import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/backup.dart';
import '../data/store.dart';
import '../data/text_import.dart';
import '../models/entry.dart';

/// Hält alle Einträge im Speicher und schreibt Änderungen in den Store.
class JournalController extends ChangeNotifier {
  JournalController(this.store);

  final JournalStore store;

  List<Entry> _entries = [];
  String _query = '';
  String? _selectedId;
  bool loaded = false;
  final Map<String, Future<Uint8List?>> _imageCache = {};

  String get query => _query;
  String? get selectedId => _selectedId;

  Entry? get selected {
    for (final e in _entries) {
      if (e.id == _selectedId) return e;
    }
    return null;
  }

  int get total => _entries.length;

  /// Einträge, nach Suchbegriff gefiltert, neueste zuerst.
  List<Entry> get visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(_entries);
    return _entries
        .where((e) => e.title.toLowerCase().contains(q) || e.body.toLowerCase().contains(q))
        .toList();
  }

  /// Ältester Eintrag vom heutigen Kalendertag in einem früheren Jahr.
  Entry? get onThisDay {
    final now = DateTime.now();
    for (final e in _entries) {
      if (e.date.month == now.month && e.date.day == now.day && e.date.year < now.year) {
        return e;
      }
    }
    return null;
  }

  Future<void> load() async {
    _entries = await store.loadAll();
    _sort();
    loaded = true;
    notifyListeners();
  }

  void _sort() => _entries.sort((a, b) {
        final c = b.date.compareTo(a.date);
        return c != 0 ? c : b.updatedAt.compareTo(a.updatedAt);
      });

  // Änderungen dürfen auch beim Abbau von Widgets ausgelöst werden.
  // Deshalb wird erst nach dem aktuellen Frame benachrichtigt.
  void _notifyLater() => scheduleMicrotask(() {
        if (!_disposed) notifyListeners();
      });

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  /// Legt einen neuen Eintrag an. Er wird erst gespeichert, wenn er Inhalt hat.
  Entry createEntry() {
    final e = Entry.create();
    _entries.insert(0, e);
    _selectedId = e.id;
    _sort();
    notifyListeners();
    return e;
  }

  /// Speichert einen geänderten Eintrag. Ein leerer Eintrag bleibt zunächst
  /// stehen und wird mit [discardEmpty] (beim Verlassen des Editors) verworfen.
  Future<void> commit(Entry entry, {bool discardEmpty = false}) async {
    if (!_entries.contains(entry)) return;
    if (entry.isEmpty) {
      if (!discardEmpty) return;
      _entries.remove(entry);
      if (_selectedId == entry.id) _selectedId = null;
      await store.delete(entry);
    } else {
      entry.updatedAt = DateTime.now();
      _sort();
      await store.save(entry);
    }
    _notifyLater();
  }

  Future<void> delete(Entry entry) async {
    _entries.remove(entry);
    if (_selectedId == entry.id) _selectedId = null;
    await store.delete(entry);
    notifyListeners();
  }

  Future<Uint8List?> image(String name) =>
      _imageCache.putIfAbsent(name, () => store.readImage(name));

  Future<void> addImage(Entry entry, Uint8List bytes, String extension) async {
    final name = await store.addImage(bytes, extension);
    entry.images.add(name);
    await commit(entry);
  }

  Future<void> removeImage(Entry entry, String name) async {
    entry.images.remove(name);
    _imageCache.remove(name);
    await store.deleteImage(name);
    await commit(entry);
  }

  /// Legt aus einem Dokument einen neuen Eintrag an.
  Future<void> importDocument(String filename, Uint8List bytes, DateTime? date) async {
    final doc = parseDocument(filename, bytes);
    final entry = Entry.create(date: date, title: doc.title, body: doc.body);
    if (entry.isEmpty) return;
    _entries.add(entry);
    await store.save(entry);
    _sort();
    notifyListeners();
  }

  Future<Uint8List> exportBackup() => Backup.export(store);

  Future<ImportResult> importBackup(Uint8List zip) async {
    final result = await Backup.import(store, zip);
    _imageCache.clear();
    await load();
    return result;
  }
}
