import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:papiermond/data/store.dart';
import 'package:papiermond/main.dart';
import 'package:papiermond/models/entry.dart';
import 'package:papiermond/state/journal_controller.dart';
import 'package:papiermond/state/settings_controller.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  testWidgets('Eintrag anlegen, suchen und Einstellungen öffnen', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = MemoryStore();
    await store.save(Entry.create(title: 'Spaziergang', body: 'Im Park war es schön.'));
    final journal = JournalController(store);
    await journal.load();

    await tester.pumpWidget(PapiermondApp(journal: journal, settings: SettingsController(null)));
    await tester.pumpAndSettle();
    expect(find.text('Spaziergang'), findsOneWidget);

    // Neuen Eintrag schreiben.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Heute war ein guter Tag.');
    await tester.pump(const Duration(seconds: 1));
    expect(journal.total, 2);
    expect(journal.selected!.body, 'Heute war ein guter Tag.');

    // Suche filtert.
    journal.setQuery('park');
    await tester.pumpAndSettle();
    expect(journal.visible.length, 1);
    expect(journal.visible.single.title, 'Spaziergang');
    journal.setQuery('');

    // Einstellungen.
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
  });

  testWidgets('Leerer Eintrag wird beim Verlassen verworfen', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final journal = JournalController(MemoryStore());
    await journal.load();
    await tester.pumpWidget(PapiermondApp(journal: journal, settings: SettingsController(null)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(journal.total, 1);

    journal.select(null);
    await tester.pumpAndSettle();
    expect(journal.total, 0);
  });
}
