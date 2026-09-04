import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'kalasetu_locale';
const _kBackendUrlKey = 'kalasetu_backend_url';
const _kOnboardingDoneKey = 'kalasetu_onboarding_done';
const _kSelectedRoleKey = 'kalasetu_selected_role';

final preferencesServiceProvider = Provider<PreferencesService>(
  (_) => PreferencesService(),
);

class PreferencesService {
  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Locale ────────────────────────────────────────────────────
  Future<void> setLocale(String languageCode) async {
    final p = await _getPrefs();
    await p.setString(_kLocaleKey, languageCode);
  }

  Future<String> getLocale() async {
    final p = await _getPrefs();
    return p.getString(_kLocaleKey) ?? 'en';
  }

  // ── Backend URL ───────────────────────────────────────────────
  Future<void> setBackendUrl(String url) async {
    final p = await _getPrefs();
    await p.setString(_kBackendUrlKey, url);
  }

  Future<String?> getBackendUrl() async {
    final p = await _getPrefs();
    return p.getString(_kBackendUrlKey);
  }

  Future<void> clearBackendUrl() async {
    final p = await _getPrefs();
    await p.remove(_kBackendUrlKey);
  }

  // ── Onboarding ────────────────────────────────────────────────
  Future<void> setOnboardingDone() async {
    final p = await _getPrefs();
    await p.setBool(_kOnboardingDoneKey, true);
  }

  Future<bool> isOnboardingDone() async {
    final p = await _getPrefs();
    return p.getBool(_kOnboardingDoneKey) ?? false;
  }

  // ── Selected Role ─────────────────────────────────────────────
  Future<void> setSelectedRole(String role) async {
    final p = await _getPrefs();
    await p.setString(_kSelectedRoleKey, role);
  }

  Future<String?> getSelectedRole() async {
    final p = await _getPrefs();
    return p.getString(_kSelectedRoleKey);
  }

  // ── Generic String ────────────────────────────────────────────
  Future<void> setString(String key, String value) async {
    final p = await _getPrefs();
    await p.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final p = await _getPrefs();
    return p.getString(key);
  }

  Future<void> remove(String key) async {
    final p = await _getPrefs();
    await p.remove(key);
  }

  Future<void> clearAll() async {
    final p = await _getPrefs();
    // Preserve locale during full clear
    final locale = p.getString(_kLocaleKey);
    await p.clear();
    if (locale != null) await p.setString(_kLocaleKey, locale);
  }
}
