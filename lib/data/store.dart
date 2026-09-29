import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/entry.dart';

/// Speicher für Einträge und Bilder. Alles bleibt lokal.
abstract class JournalStore {
  /// Ordner, in dem die Daten liegen (nur zur Anzeige), oder null.
  String? get location;

  Future<List<Entry>> loadAll();
  Future<void> save(Entry entry);
  Future<void> delete(Entry entry);

  /// Speichert ein Bild und gibt den Dateinamen zurück.
  Future<String> addImage(Uint8List bytes, String extension);

  /// Schreibt ein Bild unter einem festen Namen (für den Import von Backups).
  Future<void> writeImage(String name, Uint8List bytes);
  Future<Uint8List?> readImage(String name);
  Future<void> deleteImage(String name);
  Future<List<String>> imageNames();
}

/// Öffnet den passenden Speicher für die aktuelle Plattform.
Future<JournalStore> openDefaultStore() async {
  if (kIsWeb) return MemoryStore(); // Nur für die Entwickler-Vorschau im Browser.
  final docs = await getApplicationDocumentsDirectory();
  return FileStore(Directory(p.join(docs.path, 'Papiermond')));
}

/// Eine JSON-Datei pro Eintrag, Bilder als normale Dateien.
/// Einfach zu sichern und auch ohne die App lesbar.
class FileStore implements JournalStore {
  FileStore(this.root);

  final Directory root;

  Directory get _entries => Directory(p.join(root.path, 'entries'));
  Directory get _images => Directory(p.join(root.path, 'images'));

  @override
  String? get location => root.path;

  Future<void> _ensure() async {
    await _entries.create(recursive: true);
    await _images.create(recursive: true);
  }

  @override
  Future<List<Entry>> loadAll() async {
    await _ensure();
    final result = <Entry>[];
    await for (final f in _entries.list()) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      try {
        final json = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
        result.add(Entry.fromJson(json));
      } catch (_) {
        // Beschädigte Datei überspringen, statt die App zu blockieren.
      }
    }
    return result;
  }

  File _entryFile(String id) => File(p.join(_entries.path, '$id.json'));

  @override
  Future<void> save(Entry entry) async {
    await _ensure();
    final target = _entryFile(entry.id);
    // Erst in eine temporäre Datei schreiben, dann umbenennen: kein halbes Schreiben bei Absturz.
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsString(jsonEncode(entry.toJson()), flush: true);
    await tmp.rename(target.path);
  }

  @override
  Future<void> delete(Entry entry) async {
    final f = _entryFile(entry.id);
    if (await f.exists()) await f.delete();
    for (final img in entry.images) {
      await deleteImage(img);
    }
  }

  @override
  Future<String> addImage(Uint8List bytes, String extension) async {
    await _ensure();
    final ext = extension.toLowerCase().replaceAll('.', '');
    final name = '${Entry.newId()}.${ext.isEmpty ? 'jpg' : ext}';
    await writeImage(name, bytes);
    return name;
  }

  @override
  Future<void> writeImage(String name, Uint8List bytes) async {
    await _ensure();
    await File(p.join(_images.path, p.basename(name))).writeAsBytes(bytes, flush: true);
  }

  @override
  Future<Uint8List?> readImage(String name) async {
    final f = File(p.join(_images.path, p.basename(name)));
    return await f.exists() ? f.readAsBytes() : null;
  }

  @override
  Future<void> deleteImage(String name) async {
    final f = File(p.join(_images.path, p.basename(name)));
    if (await f.exists()) await f.delete();
  }

  @override
  Future<List<String>> imageNames() async {
    await _ensure();
    return [
      await for (final f in _images.list())
        if (f is File) p.basename(f.path),
    ];
  }
}

/// Speicher im Arbeitsspeicher, für Tests und die Browser-Vorschau.
class MemoryStore implements JournalStore {
  final Map<String, Entry> _entries = {};
  final Map<String, Uint8List> _images = {};

  @override
  String? get location => null;

  @override
  Future<List<Entry>> loadAll() async =>
      _entries.values.map((e) => Entry.fromJson(e.toJson())).toList();

  @override
  Future<void> save(Entry entry) async =>
      _entries[entry.id] = Entry.fromJson(entry.toJson());

  @override
  Future<void> delete(Entry entry) async {
    _entries.remove(entry.id);
    entry.images.forEach(_images.remove);
  }

  @override
  Future<String> addImage(Uint8List bytes, String extension) async {
    final ext = extension.toLowerCase().replaceAll('.', '');
    final name = '${Entry.newId()}.${ext.isEmpty ? 'jpg' : ext}';
    _images[name] = bytes;
    return name;
  }

  @override
  Future<void> writeImage(String name, Uint8List bytes) async => _images[name] = bytes;

  @override
  Future<Uint8List?> readImage(String name) async => _images[name];

  @override
  Future<void> deleteImage(String name) async => _images.remove(name);

  @override
  Future<List<String>> imageNames() async => _images.keys.toList();
}
