import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/preferences_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final PreferencesService _prefs;

  LocaleNotifier(this._prefs) : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await _prefs.getLocale();
    state = Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    await _prefs.setLocale(languageCode);
    state = Locale(languageCode);
  }
}
