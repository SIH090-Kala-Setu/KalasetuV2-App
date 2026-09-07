import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/shimmer_loader.dart';

final artisanDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getArtisanDashboard();
});

final artisanInquiriesProvider = FutureProvider.autoDispose<List<InquiryModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getInquiries();
});

final artisanSchemesProvider = FutureProvider.autoDispose<List<GovtSchemeModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getSchemes();
});

class ArtisanHomeScreen extends ConsumerWidget {
  const ArtisanHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;

    final dashAsync = ref.watch(artisanDashboardProvider);
    final dash = dashAsync.valueOrNull;

    final name = (user?.fullName.isNotEmpty == true)
        ? user!.fullName
        : (dash?['artisan_name']?.toString().isNotEmpty == true
            ? dash!['artisan_name'].toString()
            : 'Artisan');

    final isVerified = user?.isVerified == true || dash?['is_verified'] == true;

    final revenueVal = dash?['revenue_estimate'] as num? ?? 0;
    final earningsStr = '₹ ${revenueVal.toInt()}';
    final activeCount = (dash?['active_listings'] as num? ?? 0).toString();
    final viewsCount = (dash?['total_views'] as num? ?? 0).toString();

    final pendingInquiries = dash?['pending_inquiries'] as num?;
    final inqCount = pendingInquiries?.toInt() ?? 0;
    final inquiryBadgeText = inqCount > 0 ? '$inqCount New' : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    // Cluster resolution from dashboard response or user profile
    final clusterData = dash?['cluster'] as Map<String, dynamic>?;
    final clusterName = clusterData?['name'] as String? ??
        dash?['cluster_name'] as String? ??
        user?.clusterName ??
        'Varanasi Handloom & Silk Cluster';
    final craftSpecialization = clusterData?['craft'] as String? ??
        dash?['craft_type'] as String? ??
        user?.craftType ??
        'Traditional Handicraft';
    final clusterDistrict = clusterData?['district'] as String? ?? user?.district ?? 'Varanasi';
    final clusterState = clusterData?['state'] as String? ?? user?.region ?? 'Uttar Pradesh';
    final clusterMembers = (clusterData?['member_count'] as num?)?.toInt() ?? 35;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(artisanDashboardProvider);
            ref.invalidate(artisanInquiriesProvider);
            ref.invalidate(artisanSchemesProvider);
            await Future.wait([
              ref.read(artisanDashboardProvider.future),
              ref.read(artisanInquiriesProvider.future),
              ref.read(artisanSchemesProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Greeting & Profile Row ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'नमस्ते, $name 🙏',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                                  : (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified ? Icons.shield_rounded : Icons.pending_outlined,
                                  size: 14,
                                  color: isVerified
                                      ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF10B981))
                                      : (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'MoSJE Verified Artisan' : 'Artisan Profile Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isVerified
                                        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                                        : (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // User Avatar
                    GestureDetector(
                      onTap: () => context.push(RouteNames.artisanProfile),
                      child: AppAvatar(
                        photoUrl: user?.avatarUrl,
                        name: name,
                        radius: 23,
                        border: Border.all(color: const Color(0xFFF5A623), width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Dynamic Earnings Card ──────────────────────────────
                dashAsync.when(
                  loading: () => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoader(width: 180, height: 14, borderRadius: 6),
                        SizedBox(height: 14),
                        ShimmerLoader(width: 150, height: 34, borderRadius: 8),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            ShimmerLoader(width: 80, height: 36, borderRadius: 6),
                            SizedBox(width: 48),
                            ShimmerLoader(width: 80, height: 36, borderRadius: 6),
                          ],
                        ),
                      ],
                    ),
                  ),
                  error: (_, __) => _buildEarningsCard(
                    context,
                    earningsStr: '₹ 0',
                    activeCount: '0',
                    viewsCount: '0',
                  ),
                  data: (_) => _buildEarningsCard(
                    context,
                    earningsStr: earningsStr,
                    activeCount: activeCount,
                    viewsCount: viewsCount,
                  ),
                ),
                const SizedBox(height: 18),

                // ── 2x2 Action Cards ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        title: 'Add Product (AI Studio)',
                        icon: Icons.camera_alt_outlined,
                        iconBg: const Color(0xFFF5A623),
                        onTap: () => context.push(RouteNames.artisanStudio),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ActionTile(
                        title: 'My Catalogue',
                        icon: Icons.inventory_2_outlined,
                        iconBg: isDark ? const Color(0xFF334155) : const Color(0xFF1B2A4A),
                        onTap: () => context.push(RouteNames.artisanCatalogue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ActionTile(
                        title: 'Inquiries Inbox',
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBg: const Color(0xFF3B82F6),
                        badgeText: inquiryBadgeText,
                        onTap: () => context.push(RouteNames.artisanInquiries),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ActionTile(
                        title: 'Exhibitions & Melas',
                        icon: Icons.holiday_village_outlined,
                        iconBg: const Color(0xFF10B981),
                        onTap: () => context.push(RouteNames.artisanExhibitions),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Craft Cluster Membership Card ──────────────────────
                _ClusterCard(
                  clusterName: clusterName,
                  craftSpecialization: craftSpecialization,
                  district: clusterDistrict,
                  state: clusterState,
                  memberCount: clusterMembers,
                  isDark: isDark,
                  surface: surface,
                  border: border,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 24),

                // ── Recent B2B Inquiries (Dynamic) ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent B2B Inquiries',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.artisanInquiries),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, _) {
                    final inqsAsync = ref.watch(artisanInquiriesProvider);
                    return inqsAsync.when(
                      loading: () => const Column(
                        children: [
                          _InquirySkeletonLoader(),
                          SizedBox(height: 10),
                          _InquirySkeletonLoader(),
                        ],
                      ),
                      error: (err, _) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Could not load inquiries. Pull down to refresh.',
                                style: TextStyle(fontSize: 13, color: textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      data: (inquiries) {
                        if (inquiries.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 38,
                                  color: isDark ? AppColors.darkBorder : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No Inquiries Yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'When buyers request bulk quotes for your catalogue products, they will appear here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: textSecondary, height: 1.3),
                                ),
                              ],
                            ),
                          );
                        }

                        final displayInqs = inquiries.take(3).toList();
                        return Column(
                          children: displayInqs.map((inq) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _InquiryActionCard(
                                inquiry: inq,
                                onQuote: () => _handleQuoteInquiry(context, ref, inq),
                                onAccept: () => _handleAcceptInquiry(context, ref, inq),
                                onTap: () => context.push(RouteNames.artisanInquiries),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Welfare Schemes & Grants (Dynamic) ────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MoSJE Welfare Schemes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      'Govt Supported',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Consumer(
                  builder: (context, ref, _) {
                    final schemesAsync = ref.watch(artisanSchemesProvider);
                    return schemesAsync.when(
                      loading: () => Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border),
                        ),
                        child: const Column(
                          children: [
                            ShimmerLoader(width: double.infinity, height: 60, borderRadius: 8),
                            SizedBox(height: 12),
                            ShimmerLoader(width: double.infinity, height: 60, borderRadius: 8),
                          ],
                        ),
                      ),
                      error: (_, __) {
                        // Fallback to schemes returned in dashboard dict
                        final fallbackList = (dash?['welfare_schemes'] as List<dynamic>?) ?? [];
                        if (fallbackList.isNotEmpty) {
                          return _buildSchemesContainer(
                            context,
                            isDark: isDark,
                            surface: surface,
                            border: border,
                            schemes: fallbackList
                                .map((s) => GovtSchemeModel.fromJson(s as Map<String, dynamic>))
                                .toList(),
                          );
                        }
                        return _buildDefaultSchemesContainer(context, isDark: isDark, surface: surface, border: border);
                      },
                      data: (schemes) {
                        final list = schemes.isNotEmpty
                            ? schemes
                            : ((dash?['welfare_schemes'] as List<dynamic>?) ?? [])
                                .map((s) => GovtSchemeModel.fromJson(s as Map<String, dynamic>))
                                .toList();

                        if (list.isEmpty) {
                          return _buildDefaultSchemesContainer(context, isDark: isDark, surface: surface, border: border);
                        }
                        return _buildSchemesContainer(context, isDark: isDark, surface: surface, border: border, schemes: list);
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard(
    BuildContext context, {
    required String earningsStr,
    required String activeCount,
    required String viewsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Estimated Revenue',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                earningsStr,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeCount,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Active Listings',
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewsCount,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Catalog Views',
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () => context.push(RouteNames.artisanCatalogue),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFFF5A623)),
                    SizedBox(width: 6),
                    Text(
                      'Manage Catalogue Listings →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5A623),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchemesContainer(
    BuildContext context, {
    required bool isDark,
    required Color surface,
    required Color border,
    required List<GovtSchemeModel> schemes,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: isDark ? [] : const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF451A03).withValues(alpha: 0.5) : const Color(0xFFFEF9EE),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Active Welfare Schemes for You',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${schemes.length} Available',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),

          ...schemes.take(4).map((scheme) {
            final isLast = scheme == schemes.take(4).last;
            return Column(
              children: [
                _SchemeItem(
                  title: scheme.name,
                  description: scheme.description ??
                      'Financial subsidy and support under Government of India handicrafts development initiative.',
                  deadline: scheme.deadline ?? 'Ongoing',
                  eligibility: scheme.category,
                  onApply: () => _showSchemeDetailsModal(context, scheme),
                ),
                if (!isLast) Divider(height: 1, color: border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDefaultSchemesContainer(
    BuildContext context, {
    required bool isDark,
    required Color surface,
    required Color border,
  }) {
    final defaultSchemes = [
      const GovtSchemeModel(
        id: 'pm-vishwa',
        name: 'PM Vishwakarma Toolkit Incentive',
        description: 'Get up to ₹15,000 for purchasing new tools and collateral-free credit at 5% interest.',
        deadline: '31 Mar 2027',
        category: 'Verified Artisans',
        applyUrl: 'https://pmvishwakarma.gov.in',
      ),
      const GovtSchemeModel(
        id: 'ahvy-cluster',
        name: 'Ambedkar Hastshilp Vikas Yojana (AHVY)',
        description: 'Common Facility Centre access, design workshop training, and raw material support.',
        deadline: '31 Dec 2026',
        category: 'Cluster Artisans & SHGs',
        applyUrl: 'https://handicrafts.nic.in/Schemes.aspx',
      ),
    ];
    return _buildSchemesContainer(context, isDark: isDark, surface: surface, border: border, schemes: defaultSchemes);
  }

  void _showSchemeDetailsModal(BuildContext context, GovtSchemeModel scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Government Scheme',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        scheme.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(sheetCtx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Scheme Description',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              scheme.description ?? 'Detailed government welfare program supporting artisans and traditional craftspersons.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            if (scheme.category != null && scheme.category!.isNotEmpty) ...[
              Text(
                'Eligibility Criteria',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scheme.category!,
                        style: TextStyle(fontSize: 12, color: textPrimary, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 15, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Text(
                  'Valid Until / Deadline: ${scheme.deadline ?? "Ongoing"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final url = scheme.applyUrl ?? 'https://pmvishwakarma.gov.in';
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Application link copied: $url'),
                          backgroundColor: const Color(0xFF15803D),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Enrolled in scheme interest list: ${scheme.name}'),
                          backgroundColor: const Color(0xFF15803D),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Register Interest'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuoteInquiry(BuildContext context, WidgetRef ref, InquiryModel inq) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    final priceCtrl = TextEditingController(text: inq.unitPrice != null ? inq.unitPrice!.toInt().toString() : '');
    final msgCtrl = TextEditingController(text: 'Offer valid for 15 days. High quality handcrafted batch.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Send Quote to ${inq.buyerName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Order: ${inq.quantity} units · ${inq.productTitle}',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quoted Unit Price (₹) *',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Response Note to Buyer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final price = priceCtrl.text.trim();
                  final note = msgCtrl.text.trim();
                  if (price.isEmpty) return;
                  Navigator.pop(ctx);
                  try {
                    final api = ref.read(apiClientProvider);
                    await api.respondToInquiry(
                      inq.id,
                      'Quoted ₹$price per unit. $note',
                      status: 'Quoted',
                    );
                    ref.invalidate(artisanInquiriesProvider);
                    ref.invalidate(artisanDashboardProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quote sent to ${inq.buyerName}!'),
                          backgroundColor: const Color(0xFF15803D),
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send quote. Please try again.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Quotation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptInquiry(BuildContext context, WidgetRef ref, InquiryModel inq) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.respondToInquiry(
        inq.id,
        'Inquiry accepted by artisan. Order will be processed accordingly.',
        status: 'Accepted',
      );
      ref.invalidate(artisanInquiriesProvider);
      ref.invalidate(artisanDashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted inquiry from ${inq.buyerName}!'),
            backgroundColor: const Color(0xFF15803D),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update inquiry status.')),
        );
      }
    }
  }
}

// ── Craft Cluster Membership Card ──────────────────────────────────────
class _ClusterCard extends StatelessWidget {
  final String clusterName;
  final String craftSpecialization;
  final String district;
  final String state;
  final int memberCount;
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const _ClusterCard({
    required this.clusterName,
    required this.craftSpecialization,
    required this.district,
    required this.state,
    required this.memberCount,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF047857).withValues(alpha: 0.3) : const Color(0xFFA7F3D0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.45) : const Color(0xFFECFDF5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.hub_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MY CRAFT CLUSTER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text(
                        'CFC Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0)),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clusterName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Info tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildClusterChip(
                      icon: Icons.palette_outlined,
                      label: craftSpecialization,
                      isDark: isDark,
                    ),
                    _buildClusterChip(
                      icon: Icons.location_on_outlined,
                      label: '$district, $state',
                      isDark: isDark,
                    ),
                    _buildClusterChip(
                      icon: Icons.groups_rounded,
                      label: '$memberCount Artisans',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Benefits & Facilities preview
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 15, color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Common Facility Centre · Yarn & Raw Material Depot Access',
                        style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details Action Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showClusterDetailsModal(context),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('View Cluster Hub & Benefits'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF059669) : const Color(0xFF10B981),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterChip({required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  void _showClusterDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MoSJE Certified Cluster Hub',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                        ),
                      ),
                      Text(
                        clusterName,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textPrimary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Cluster Overview & Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 6),
            Text(
              'Located in $district, $state. Specializing in authentic $craftSpecialization with $memberCount active artisans, verified under the Ministry of Social Justice and Empowerment welfare program.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text('Common Facility Centre (CFC) Facilities', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 8),
            _facilityItem('Computerized Jacquard & Design Studio', 'Free CAD design sampling & digital punchcards for cluster members.'),
            _facilityItem('Eco-Friendly Dyeing & Finishing Lab', 'Zero liquid discharge washing, chemical testing, and uniform shade matching.'),
            _facilityItem('Subsidized Raw Material Bank', 'Silk yarn, natural pigments, and metal alloys at wholesale rates.'),
            _facilityItem('GI & Quality Assurance Tagging', 'On-site verification and authenticity tagging for premium exports.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected to cluster manager for $clusterName'),
                      backgroundColor: const Color(0xFF15803D),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Contact Cluster Coordinator', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _facilityItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                Text(desc, style: TextStyle(fontSize: 12, color: textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2x2 Action Tile ──────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final String? badgeText;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.iconBg,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: isDark ? [] : const [
            BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Inquiry Action Card (Dynamic) ────────────────────────────────────
class _InquiryActionCard extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback onQuote;
  final VoidCallback onAccept;
  final VoidCallback onTap;

  const _InquiryActionCard({
    required this.inquiry,
    required this.onQuote,
    required this.onAccept,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final iconBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9);

    final status = inquiry.status.toLowerCase();
    final isAccepted = status.contains('accept') || status.contains('final') || status.contains('complet');
    final isQuoted = status.contains('quote') || status.contains('respond');

    final desc = '${inquiry.quantity} units · ${inquiry.productTitle.isNotEmpty ? inquiry.productTitle : "Bulk Order"}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: isDark ? [] : const [
            BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.chat_bubble_outline_rounded, color: textSecondary, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          inquiry.buyerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (inquiry.buyerOrg != null && inquiry.buyerOrg!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${inquiry.buyerOrg})',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isAccepted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Accepted',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              )
            else if (isQuoted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Quoted',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: onQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Quote', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Scheme Item Widget ───────────────────────────────────────────────
class _SchemeItem extends StatelessWidget {
  final String title;
  final String description;
  final String deadline;
  final String? eligibility;
  final VoidCallback onApply;

  const _SchemeItem({
    required this.title,
    required this.description,
    required this.deadline,
    this.eligibility,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: $deadline',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.accent : const Color(0xFFF5A623),
              foregroundColor: isDark ? AppColors.primary : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Loader for Inquiries ────────────────────────────────────
class _InquirySkeletonLoader extends StatelessWidget {
  const _InquirySkeletonLoader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: const Row(
        children: [
          ShimmerLoader(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 120, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerLoader(width: 180, height: 12, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerLoader(width: 60, height: 34, borderRadius: 8),
        ],
      ),
    );
  }
}
