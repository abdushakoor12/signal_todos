import 'package:flutter/material.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:signal_todos/main.dart';
import 'package:signals/signals_flutter.dart';

final themeSignal = ThemeHelper.getTheme().toSignal();

class ThemeHelper {
  const ThemeHelper._();

  static Future<void> setTheme(ThemeMode themeMode) async {
    prefs.setInt('theme_mode', themeMode.index);
  }

  static Stream<ThemeMode> getTheme() {
    return prefs.getIntStream('theme_mode').map((index) {
      return index == null ? ThemeMode.light : ThemeMode.values[index];
    });
  }
}
