import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt('themeMode') ?? 0;
    _themeMode = _intToThemeMode(stored);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeModeToInt(mode));
    notifyListeners();
  }

  int _themeModeToInt(ThemeMode m) {
    if (m == ThemeMode.light) return 1;
    if (m == ThemeMode.dark) return 2;
    return 0;
  }

  ThemeMode _intToThemeMode(int v) {
    if (v == 1) return ThemeMode.light;
    if (v == 2) return ThemeMode.dark;
    return ThemeMode.system;
  }
}
