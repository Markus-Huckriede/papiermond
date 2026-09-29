import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/store.dart';
import 'l10n.dart';
import 'state/journal_controller.dart';
import 'state/settings_controller.dart';
import 'ui/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    // Ohne gespeicherte Einstellungen starten wir mit den Standardwerten.
  }

  final journal = JournalController(await openDefaultStore());
  await journal.load();
  runApp(PapiermondApp(journal: journal, settings: SettingsController(prefs)));
}

class PapiermondApp extends StatelessWidget {
  const PapiermondApp({super.key, required this.journal, required this.settings});

  final JournalController journal;
  final SettingsController settings;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: settings.accentColor,
      brightness: brightness,
    );
    final family = settings.font.family;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
      fontFamilyFallback: settings.font.fallback,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Papiermond',
        debugShowCheckedModeBanner: false,
        themeMode: settings.themeMode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        supportedLocales: S.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supported) =>
            supported.firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => const Locale('en')),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: child!,
        ),
        home: HomePage(journal: journal, settings: settings),
      ),
    );
  }
}
