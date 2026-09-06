import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_notifier.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.onboardingLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canContinue = _selectedRole != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
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
                // Top Bar: Back arrow + Step 2 of 4 + Dark/Light Theme Toggle
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
                          onPressed: _handleBack,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Step 2 of 4',
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
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How will you use Kala-Setu?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                  ),
                ),
                const SizedBox(height: 24),

                // 3 Role Cards
                _RoleOptionCard(
                  title: 'Artisan (कारीगर)',
                  subtitle: 'Sell your handmade craft, AI cataloging & fair prices.',
                  iconColor: const Color(0xFFF5A623),
                  icon: Icons.construction_rounded,
                  isSelected: _selectedRole == 'Artisan',
                  onTap: () => setState(() => _selectedRole = 'Artisan'),
                ),
                const SizedBox(height: 14),

                _RoleOptionCard(
                  title: 'Cluster Aggregator (समूह संचालक)',
                  subtitle: 'Manage artisan clusters, schemes & reports.',
                  iconColor: const Color(0xFF2E4057),
                  icon: Icons.groups_rounded,
                  isSelected: _selectedRole == 'Aggregator',
                  onTap: () => setState(() => _selectedRole = 'Aggregator'),
                ),
                const SizedBox(height: 14),

                _RoleOptionCard(
                  title: 'B2B Buyer (थोक खरीदार)',
                  subtitle: 'Source authentic verified crafts at wholesale rates.',
                  iconColor: const Color(0xFF10B981),
                  icon: Icons.shopping_bag_outlined,
                  isSelected: _selectedRole == 'Buyer',
                  onTap: () => setState(() => _selectedRole = 'Buyer'),
                ),

                const Spacer(),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: canContinue
                          ? () => context.go(
                                RouteNames.onboardingPhone,
                                extra: _selectedRole,
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFF94A3B8)),
                        foregroundColor: canContinue && isDark ? Colors.black : Colors.white,
                        disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFF94A3B8),
                        disabledForegroundColor: isDark ? AppColors.darkTextSecondary : Colors.white,
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
                              color: canContinue && isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: canContinue && isDark ? Colors.black : Colors.white,
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

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color iconColor;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isSelected
        ? (isDark ? AppColors.accent : AppColors.primary)
        : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.transparent : const Color(0x06000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Colored Squircle Icon Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),
            const SizedBox(width: 16),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
