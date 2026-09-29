import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wählbare Akzentfarben.
const accentColors = <Color>[
  Color(0xFF5B6CFF), // Indigo
  Color(0xFF0E9F8E), // Petrol
  Color(0xFFD9534F), // Korall
  Color(0xFFE0982B), // Bernstein
  Color(0xFF8E5BD9), // Violett
  Color(0xFF4C8B3F), // Salbei
];

enum JournalFont { sans, serif, mono }

/// Die Schriften stammen vom jeweiligen Betriebssystem und werden nicht
/// mit der App ausgeliefert. Dadurch entstehen keine Lizenzfragen.
extension JournalFontFamily on JournalFont {
  String? get family => switch (this) {
        JournalFont.sans => null,
        JournalFont.serif => 'Georgia',
        JournalFont.mono => 'Courier New',
      };

  List<String> get fallback => switch (this) {
        JournalFont.sans => const [],
        JournalFont.serif => const ['Charter', 'Cambria', 'Times New Roman', 'serif'],
        JournalFont.mono => const ['Menlo', 'Courier', 'monospace'],
      };
}

/// Persönliche Darstellung, wird lokal gespeichert.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    themeMode = ThemeMode.values[_int('themeMode', 0, ThemeMode.values.length)];
    accent = _int('accent', 0, accentColors.length);
    font = JournalFont.values[_int('font', 0, JournalFont.values.length)];
    textScale = (_prefs?.getDouble('textScale') ?? 1.0).clamp(0.85, 1.4);
  }

  final SharedPreferences? _prefs;

  late ThemeMode themeMode;
  late int accent;
  late JournalFont font;
  late double textScale;

  Color get accentColor => accentColors[accent];

  int _int(String key, int fallback, int length) {
    final v = _prefs?.getInt(key) ?? fallback;
    return v >= 0 && v < length ? v : fallback;
  }

  void setThemeMode(ThemeMode v) {
    themeMode = v;
    _prefs?.setInt('themeMode', v.index);
    notifyListeners();
  }

  void setAccent(int v) {
    accent = v;
    _prefs?.setInt('accent', v);
    notifyListeners();
  }

  void setFont(JournalFont v) {
    font = v;
    _prefs?.setInt('font', v.index);
    notifyListeners();
  }

  void setTextScale(double v) {
    textScale = v;
    _prefs?.setDouble('textScale', v);
    notifyListeners();
  }
}
