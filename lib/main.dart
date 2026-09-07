import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/network/api_endpoints.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_en.dart';
import 'l10n/app_localizations_hi.dart';
import 'shared/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiEndpoints.resolveBaseUrl();
  runApp(const ProviderScope(child: KalaSetuApp()));
}

class _SafeAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _SafeAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) {
    if (locale.languageCode == 'hi') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsHi());
    } else if (locale.languageCode == 'en') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsEn());
    }
    // Default fallback for other Indian languages (mr, bn, te, ta, gu, kn)
    return SynchronousFuture<AppLocalizations>(AppLocalizationsHi());
  }

  @override
  bool shouldReload(_SafeAppLocalizationsDelegate old) => false;
}

class KalaSetuApp extends ConsumerWidget {
  const KalaSetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'कलाSetu',
      debugShowCheckedModeBanner: false,

      // ── Theming ────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Router ─────────────────────────────────────────────────
      routerConfig: router,

      // ── Localization ───────────────────────────────────────────
      locale: locale,
      localizationsDelegates: const [
        _SafeAppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('bn'),
        Locale('te'),
        Locale('ta'),
        Locale('mr'),
        Locale('gu'),
        Locale('kn'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('en');
      },
    );
  }
}

