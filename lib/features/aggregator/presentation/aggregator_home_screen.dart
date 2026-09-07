import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

final aggregatorDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getAggregatorDashboard();
});

class AggregatorHomeScreen extends ConsumerWidget {
  const AggregatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dashAsync = ref.watch(aggregatorDashboardProvider);
    final dash = dashAsync.valueOrNull;

    final clusterList = dash?['clusters'] as List?;
    final firstCluster = (clusterList != null && clusterList.isNotEmpty) ? clusterList.first as Map<String, dynamic> : null;
    final clusterName = firstCluster?['cluster_name']?.toString() ?? 'Varanasi Weavers Co-op';
    final totalArtisans = dash?['total_artisans']?.toString() ?? '48';
    final activeListings = dash?['total_active_listings']?.toString() ?? '142';
    final pendingInquiries = dash?['total_pending_inquiries']?.toString() ?? '6';
    const revenue = '₹ 4.8L';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(aggregatorDashboardProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Title ───────────────────────────────────────
                Text(
                  'Cluster Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$clusterName · $totalArtisans artisans',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                  ),
                ),
                const SizedBox(height: 18),

              // ── 4 Stats Grid Cards (2x2) ───────────────────────────
              Row(
                children: [
                  // Total Artisans Card
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            color: isDark ? AppColors.accent : Colors.white70,
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                totalArtisans,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : Colors.white,
                                ),
                              ),
                              Text(
                                'Total Artisans',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Active Listings Card
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black12 : const Color(0x04000000),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: isDark ? AppColors.accent : AppColors.primary,
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeListings,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                                ),
                              ),
                              Text(
                                'Active Listings',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  // Pending Inquiries Card
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black12 : const Color(0x04000000),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            color: isDark ? AppColors.accent : AppColors.primary,
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pendingInquiries,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                                ),
                              ),
                              Text(
                                'Pending Inquiries',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Cluster Revenue Card
                  Expanded(
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black12 : const Color(0x04000000),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.currency_rupee_rounded,
                            color: isDark ? const Color(0xFF10B981) : AppColors.primary,
                            size: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                revenue,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                                ),
                              ),
                              Text(
                                'Cluster Revenue',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Needs Attention Section Card ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black12 : const Color(0x04000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFD97706), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Needs Attention',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Artisan 1: Haniba Rabari
                    _buildAttentionItem(
                      name: 'Haniba Rabari',
                      craftLocation: 'Kutch Embroidery · Hodka',
                      avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=100',
                      badgeLabel: 'KYC Pending',
                      badgeBg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                      badgeColor: isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),

                    // Artisan 2: Muniyappa
                    _buildAttentionItem(
                      name: 'Muniyappa',
                      craftLocation: 'Lacquerware Toys · Channapatna',
                      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                      badgeLabel: 'Draft Only',
                      badgeBg: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                      badgeColor: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 18),

                    // Onboard New Artisan Button (Amber)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(RouteNames.artisanStudio),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                        label: const Text(
                          'Onboard New Artisan',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5A623),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── 2x2 Action Tiles ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.groups_outlined,
                      iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF),
                      title: 'Artisans Roster',
                      subtitle: 'Manage & verify',
                      onTap: () => context.push(RouteNames.aggregatorArtisans),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.bar_chart_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Analytics',
                      subtitle: 'Craft distribution',
                      onTap: () => context.push(RouteNames.aggregatorAnalytics),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.campaign_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Schemes',
                      subtitle: 'Broadcast & report',
                      onTap: () => context.push(RouteNames.aggregatorAlerts),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.person_add_alt_1_outlined,
                      iconColor: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                      title: 'Assist Artisan',
                      subtitle: 'AI Studio on behalf',
                      onTap: () => context.push(RouteNames.artisanStudio),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildAttentionItem({
    required String name,
    required String craftLocation,
    required String avatarUrl,
    required String badgeLabel,
    required Color badgeBg,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                craftLocation,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badgeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : const Color(0x04000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
