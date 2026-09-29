import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papiermond/data/backup.dart';
import 'package:papiermond/data/store.dart';
import 'package:papiermond/data/text_import.dart';
import 'package:papiermond/models/entry.dart';

Uint8List _zip(Map<String, String> files) {
  final a = Archive();
  files.forEach((name, text) => a.addFile(ArchiveFile.string(name, text)));
  return ZipEncoder().encodeBytes(a);
}

void main() {
  test('IDs sind eindeutig', () {
    final ids = {for (var i = 0; i < 1000; i++) Entry.newId()};
    expect(ids.length, 1000);
  });

  test('Entry JSON round trip', () {
    final e = Entry.create(title: 'Hallo', body: 'Welt')
      ..mood = 3
      ..images = ['a.jpg'];
    final copy = Entry.fromJson(jsonDecode(jsonEncode(e.toJson())) as Map<String, dynamic>);
    expect(copy.title, 'Hallo');
    expect(copy.mood, 3);
    expect(copy.images, ['a.jpg']);
    expect(copy.date, e.date);
  });

  test('FileStore speichert, lädt und löscht Einträge samt Bildern', () async {
    final dir = await Directory.systemTemp.createTemp('papiermond_test');
    addTearDown(() => dir.delete(recursive: true));
    final store = FileStore(dir);

    final img = await store.addImage(Uint8List.fromList([1, 2, 3]), '.PNG');
    expect(img, endsWith('.png'));
    final e = Entry.create(title: 'T', body: 'B')..images = [img];
    await store.save(e);

    final loaded = await store.loadAll();
    expect(loaded.single.id, e.id);
    expect(await store.readImage(img), [1, 2, 3]);

    await store.delete(e);
    expect(await store.loadAll(), isEmpty);
    expect(await store.readImage(img), isNull);
  });

  test('Backup: Export und Import ergeben denselben Bestand', () async {
    final a = MemoryStore();
    final img = await a.addImage(Uint8List.fromList([9, 9]), 'jpg');
    final e = Entry.create(title: 'Tag 1', body: 'Text')..images = [img];
    await a.save(e);

    final zip = await Backup.export(a);
    final b = MemoryStore();
    final r = await Backup.import(b, zip);

    expect(r.added, 1);
    expect((await b.loadAll()).single.title, 'Tag 1');
    expect(await b.readImage(img), [9, 9]);

    // Erneuter Import ändert nichts (gleicher Stand).
    final again = await Backup.import(b, zip);
    expect(again.added, 0);
    expect(again.skipped, 1);
  });

  test('Backup: neuere Version überschreibt, ältere nicht', () async {
    final store = MemoryStore();
    final e = Entry.create(title: 'alt', body: 'x');
    await store.save(e);
    final older = Entry.fromJson(e.toJson())
      ..title = 'älter'
      ..updatedAt = e.updatedAt.subtract(const Duration(days: 1));
    final newer = Entry.fromJson(e.toJson())
      ..title = 'neuer'
      ..updatedAt = e.updatedAt.add(const Duration(days: 1));
    Uint8List zipOf(Entry x) => _zip({
          'manifest.json': jsonEncode({'format': Backup.format, 'version': 1}),
          'entries/${x.id}.json': jsonEncode(x.toJson()),
        });

    await Backup.import(store, zipOf(older));
    expect((await store.loadAll()).single.title, 'alt');
    await Backup.import(store, zipOf(newer));
    expect((await store.loadAll()).single.title, 'neuer');
  });

  test('Backup: fremde ZIP-Dateien werden abgelehnt', () {
    expect(() => Backup.import(MemoryStore(), _zip({'x.txt': 'hi'})),
        throwsA(isA<FormatException>()));
    expect(() => Backup.import(MemoryStore(), Uint8List.fromList([1, 2, 3])),
        throwsA(isA<FormatException>()));
  });

  test('Textimport: txt, docx und odt', () {
    final txt = parseDocument('Urlaub.txt', Uint8List.fromList(utf8.encode('Sonne\r\nMeer')));
    expect(txt.title, 'Urlaub');
    expect(txt.body, 'Sonne\nMeer');

    final docx = parseDocument(
      'Notiz.docx',
      _zip({
        'word/document.xml':
            '<w:document xmlns:w="w"><w:body>'
                '<w:p><w:r><w:t>Erster</w:t></w:r><w:r><w:t> Absatz</w:t></w:r></w:p>'
                '<w:p><w:r><w:t>Zweiter</w:t></w:r></w:p>'
                '</w:body></w:document>',
      }),
    );
    expect(docx.body, 'Erster Absatz\nZweiter');

    final odt = parseDocument(
      'Notiz.odt',
      _zip({
        'content.xml': '<o xmlns:text="t"><text:p>Ein<text:s text:c="2"/>Satz'
            '<text:span>!</text:span></text:p><text:p>Zwei</text:p></o>',
      }),
    );
    expect(odt.body, 'Ein  Satz!\nZwei');

    expect(() => parseDocument('x.pages', Uint8List(0)), throwsA(isA<UnsupportedFormat>()));
  });
}
