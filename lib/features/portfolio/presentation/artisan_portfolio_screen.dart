import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/product_thumbnail.dart';
import '../../../shared/widgets/status_badge.dart';

final _portfolioProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, artisanId) async {
  final api = ref.read(apiClientProvider);
  return api.getArtisanPortfolio(artisanId);
});

class ArtisanPortfolioScreen extends ConsumerStatefulWidget {
  final String artisanId;
  const ArtisanPortfolioScreen({super.key, required this.artisanId});

  @override
  ConsumerState<ArtisanPortfolioScreen> createState() => _ArtisanPortfolioScreenState();
}

class _ArtisanPortfolioScreenState extends ConsumerState<ArtisanPortfolioScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(_portfolioProvider(widget.artisanId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: portfolioAsync.when(
        data: (data) {
          final user = data['artisan'] != null
              ? UserModel.fromJson(data['artisan'] as Map<String, dynamic>)
              : null;
          final products = (data['products'] as List? ?? [])
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: Text(
                  user?.fullName ?? 'Artisan Portfolio',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: 'Share Portfolio',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final url = 'https://kalasetu.gov.in/portfolio/${widget.artisanId}';
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Portfolio URL copied to clipboard!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  child: Column(
                    children: [
                      AppAvatar(
                        photoUrl: user?.avatarUrl,
                        name: user?.fullName,
                        radius: 44,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                        textColor: Colors.white,
                        fontSize: 34,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'Artisan',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.craftType ?? 'Master Craftsperson',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (user?.isVerified == true) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified_rounded, color: AppColors.accent, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    'MoSJE Certified',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (user?.district != null || user?.region != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    [user?.village, user?.district, user?.region]
                                        .where((s) => s != null && s.isNotEmpty)
                                        .take(2)
                                        .join(', '),
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatPill(
                              label: 'Products',
                              value: '${products.length}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatPill(
                              label: 'Experience',
                              value: '${user?.experienceYears ?? 0} yrs',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatPill(
                              label: 'Cluster',
                              value: user?.clusterName != null && user!.clusterName!.isNotEmpty
                                  ? user.clusterName!.split(' ').first
                                  : 'Independent',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  tabBar: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? AppColors.accent : AppColors.primary,
                    unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    indicatorColor: isDark ? AppColors.accent : AppColors.primary,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grid_view_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text('Products (${products.length})'),
                          ],
                        ),
                      ),
                      const Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('About Story'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Products Tab
                products.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No products listed yet',
                                style: AppTextStyles.headlineSmall.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check back soon for new artisan handmade items.',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, i) => _PortfolioProductCard(product: products[i]),
                      ),

                // About Tab
                ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    if (user?.bio != null && user!.bio!.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_stories_outlined, color: isDark ? AppColors.accent : AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Text('Artisan Heritage & Story', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user.bio!,
                              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, color: isDark ? AppColors.accent : AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text('Artisan Craft Profile', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (user != null) ...[
                            _AboutRow(icon: Icons.palette_outlined, label: 'Craft Specialization', value: user.craftType ?? 'Handicrafts'),
                            _AboutRow(icon: Icons.location_city_outlined, label: 'Village / Locality', value: user.village ?? user.district ?? 'India'),
                            _AboutRow(icon: Icons.map_outlined, label: 'State & Region', value: '${user.district ?? ""}, ${user.region ?? "India"}'),
                            _AboutRow(icon: Icons.work_history_outlined, label: 'Craft Experience', value: '${user.experienceYears ?? 0} years'),
                            _AboutRow(icon: Icons.groups_outlined, label: 'Artisan Cluster', value: user.clusterName ?? 'Independent Artisan'),
                            if (user.isVerified)
                              const _AboutRow(
                                icon: Icons.verified_user_outlined,
                                label: 'Verification Status',
                                value: 'Verified by Ministry of Social Justice & Empowerment (MoSJE)',
                              ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: isDark ? AppColors.accent : AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Error loading portfolio: $e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate({required this.tabBar, required this.backgroundColor});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PortfolioProductCard extends StatelessWidget {
  final ProductModel product;
  const _PortfolioProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push(RouteNames.productDetail(product.id)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductThumbnail(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: 135,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.titleEn,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.inr(product.retailPrice),
                      style: AppTextStyles.priceHero.copyWith(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (product.giTag)
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: StatusBadge(status: BadgeStatus.giTag),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.stock} in stock',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AboutRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isDark ? AppColors.accent : AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
