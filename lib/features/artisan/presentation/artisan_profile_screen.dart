import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/server_config_dialog.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/status_badge.dart';

final _artisanAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getArtisanAnalytics();
});

class ArtisanProfileScreen extends ConsumerWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                          child: Text(
                            user?.fullName.isNotEmpty == true ? user!.fullName[0] : '?',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user?.fullName ?? 'Artisan',
                            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                        Text(user?.craftType ?? 'Master Artisan',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (user?.isVerified == true) ...[
                              const Icon(Icons.verified_rounded, color: AppColors.accent, size: 16),
                              const SizedBox(width: 4),
                              Text('MoSJE Certified', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
                            ] else
                              const StatusBadge(status: BadgeStatus.pending, customLabel: 'KYC Pending'),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_outlined, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(user?.district ?? 'India',
                                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => context.push(
                  RouteNames.artisanPortfolio(user?.id ?? ''),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Analytics summary
                    _AnalyticsSection(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Settings
                    Text('Settings', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleLightDark(),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'हिन्दी / English',
                      onTap: () => context.push(RouteNames.onboardingLanguage),
                    ),
                    _SettingsTile(
                      icon: Icons.account_balance_outlined,
                      title: 'Bank & UPI Details',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.link_rounded,
                      title: 'My Portfolio URL',
                      subtitle: 'Share your artisan profile',
                      onTap: () => context.push(RouteNames.artisanPortfolio(user?.id ?? '')),
                    ),
                    _SettingsTile(
                      icon: Icons.download_rounded,
                      title: 'Download Sales Report',
                      onTap: () async {
                        final api = ref.read(apiClientProvider);
                        await api.getArtisanReport();
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.settings_rounded,
                      title: 'Server Configuration',
                      onTap: () => ServerConfigDialog.show(context),
                    ),
                    const SizedBox(height: 24),
                    AppButton.danger(
                      label: 'Logout',
                      leadingIcon: Icons.logout_rounded,
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go(RouteNames.splash);
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'कलाSetu v2.0 | SIH 2025',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_artisanAnalyticsProvider);
    return analyticsAsync.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Performance', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _AnalyticCard(
                  label: 'Total Products',
                  value: '${data['total_products'] ?? 0}',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.info,
                )),
                const SizedBox(width: 12),
                Expanded(child: _AnalyticCard(
                  label: 'Total Orders',
                  value: '${data['total_orders'] ?? 0}',
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.success,
                )),
                const SizedBox(width: 12),
                Expanded(child: _AnalyticCard(
                  label: 'Revenue',
                  value: AppFormatters.inrCompact((data['revenue_estimate'] ?? 0).toDouble()),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.accent,
                )),
              ],
            ),
          ],
        );
      },
      loading: () => const ShimmerLoader(width: double.infinity, height: 80, borderRadius: 12),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 16) : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
