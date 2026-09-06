import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/providers/locale_provider.dart';

final _selectedLocaleProvider = StateProvider<String>((ref) => 'en');

class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  static const _languages = [
    ('en', 'English', 'English', 'Latin'),
    ('hi', 'हिंदी', 'Hindi', 'Devanagari'),
    ('bn', 'বাংলা', 'Bengali', 'Bengali'),
    ('ta', 'தமிழ்', 'Tamil', 'Tamil'),
    ('te', 'తెలుగు', 'Telugu', 'Telugu'),
    ('mr', 'मराठी', 'Marathi', 'Devanagari'),
    ('kn', 'ಕನ್ನಡ', 'Kannada', 'Kannada'),
    ('gu', 'ગુજરાતી', 'Gujarati', 'Gujarati'),
  ];

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.splash);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedLocaleProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Top Bar: Back arrow + Step 1 of 4 + Dark/Light Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            size: 22,
                          ),
                          onPressed: () => _handleBack(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Step 1 of 4',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 22,
                      ),
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () => ref.read(themeModeProvider.notifier).toggleLightDark(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title & Subtitle
                Text(
                  'Choose Your Language',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'अपनी भाषा चुनें',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                  ),
                ),
                const SizedBox(height: 20),

                // 2-Column Grid of Language Cards
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, i) {
                      final (code, native, english, script) = _languages[i];
                      final isSelected = code == selected;

                      return _LanguageCard(
                        nativeName: native,
                        englishName: english,
                        script: script,
                        isSelected: isSelected,
                        onTap: () => ref.read(_selectedLocaleProvider.notifier).state = code,
                      );
                    },
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(localeProvider.notifier).setLocale(selected);
                        if (context.mounted) {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteNames.onboardingRole);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String nativeName;
  final String englishName;
  final String script;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.nativeName,
    required this.englishName,
    required this.script,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isSelected
        ? (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9))
        : (isDark ? AppColors.darkSurface : Colors.white);
    final borderColor = isSelected
        ? (isDark ? AppColors.accent : AppColors.primary)
        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: isDark ? Colors.transparent : const Color(0x06000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  englishName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  script,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextDisabled : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFDCE5EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 14, color: isDark ? AppColors.accent : AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
