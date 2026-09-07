import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kThemeModeKey = 'kalasetu_theme_mode';
const _kDarkModeStyleKey = 'kalasetu_dark_mode_style';

/// Riverpod provider for ThemeMode with SharedPreferences persistence
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Riverpod provider for Dark Mode Style (#1C1C1C Onyx vs #2C2C2C Charcoal)
final darkModeStyleProvider = NotifierProvider<DarkModeStyleNotifier, DarkModeStyle>(
  DarkModeStyleNotifier.new,
);

class DarkModeStyleNotifier extends Notifier<DarkModeStyle> {
  @override
  DarkModeStyle build() {
    _loadFromPrefs();
    return DarkModeStyle.onyx;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kDarkModeStyleKey);
    if (saved != null) {
      final style = saved == 'charcoal' ? DarkModeStyle.charcoal : DarkModeStyle.onyx;
      AppColors.currentDarkStyle = style;
      state = style;
    }
  }

  Future<void> setStyle(DarkModeStyle style) async {
    state = style;
    AppColors.currentDarkStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDarkModeStyleKey, style == DarkModeStyle.charcoal ? 'charcoal' : 'onyx');
  }

  Future<void> toggleStyle() async {
    final next = state == DarkModeStyle.onyx ? DarkModeStyle.charcoal : DarkModeStyle.onyx;
    await setStyle(next);
  }
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromPrefs();
    return ThemeMode.system;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    if (saved != null) {
      state = _fromString(saved);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _toString(mode));
  }

  Future<void> toggleLightDark() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  /// Cycles: Light -> Dark Onyx (#1C1C1C) -> Dark Charcoal (#2C2C2C) -> Light
  Future<void> cycleTheme(WidgetRef ref) async {
    final currentStyle = ref.read(darkModeStyleProvider);
    if (state == ThemeMode.light) {
      await ref.read(darkModeStyleProvider.notifier).setStyle(DarkModeStyle.onyx);
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark && currentStyle == DarkModeStyle.onyx) {
      await ref.read(darkModeStyleProvider.notifier).setStyle(DarkModeStyle.charcoal);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  ThemeMode _fromString(String s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
}
