import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../models/entry.dart';
import 'store.dart';

class ImportResult {
  const ImportResult({this.added = 0, this.updated = 0, this.skipped = 0});
  final int added;
  final int updated;
  final int skipped;
}

/// Backup als ZIP: `manifest.json`, `entries/<id>.json`, `images/<datei>`.
/// Das Format ist offen und mit jedem Entpackprogramm lesbar.
class Backup {
  static const format = 'papiermond-backup';
  static const version = 1;

  static Future<Uint8List> export(JournalStore store) async {
    final archive = Archive();
    final entries = await store.loadAll();
    archive.addFile(ArchiveFile.string(
      'manifest.json',
      jsonEncode({
        'format': format,
        'version': version,
        'exportedAt': DateTime.now().toIso8601String(),
        'entries': entries.length,
      }),
    ));
    final used = <String>{};
    for (final e in entries) {
      archive.addFile(ArchiveFile.string(
        'entries/${e.id}.json',
        const JsonEncoder.withIndent('  ').convert(e.toJson()),
      ));
      used.addAll(e.images);
    }
    for (final name in used) {
      final bytes = await store.readImage(name);
      if (bytes != null) archive.addFile(ArchiveFile.bytes('images/$name', bytes));
    }
    return ZipEncoder().encodeBytes(archive);
  }

  /// Führt ein Backup mit dem vorhandenen Bestand zusammen.
  /// Bei gleicher ID gewinnt der Eintrag mit dem neueren Änderungsdatum.
  static Future<ImportResult> import(JournalStore store, Uint8List zipBytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw const FormatException('Keine gültige ZIP-Datei');
    }
    final manifest = archive.findFile('manifest.json');
    if (manifest == null ||
        (jsonDecode(utf8.decode(manifest.readBytes()!)) as Map)['format'] != format) {
      throw const FormatException('Kein Papiermond-Backup');
    }

    final existing = {for (final e in await store.loadAll()) e.id: e};
    var added = 0, updated = 0, skipped = 0;

    for (final f in archive) {
      if (!f.isFile) continue;
      final dir = p.posix.dirname(f.name);
      final name = p.posix.basename(f.name);
      if (dir == 'images') {
        await store.writeImage(name, f.readBytes()!);
      }
    }
    for (final f in archive) {
      if (!f.isFile || p.posix.dirname(f.name) != 'entries') continue;
      final Entry incoming;
      try {
        incoming = Entry.fromJson(
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, dynamic>);
      } catch (_) {
        skipped++;
        continue;
      }
      final current = existing[incoming.id];
      if (current == null) {
        await store.save(incoming);
        added++;
      } else if (incoming.updatedAt.isAfter(current.updatedAt)) {
        await store.save(incoming);
        updated++;
      } else {
        skipped++;
      }
    }
    return ImportResult(added: added, updated: updated, skipped: skipped);
  }
}
