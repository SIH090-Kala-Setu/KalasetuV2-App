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

    return Scaffold(
      body: portfolioAsync.when(
        data: (data) {
          final user = data['artisan'] != null
              ? UserModel.fromJson(data['artisan'] as Map<String, dynamic>)
              : null;
          final products = (data['products'] as List? ?? [])
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList();

          return CustomScrollView(
            slivers: [
              // Profile header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Share portfolio URL
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppAvatar(
                              photoUrl: user?.avatarUrl,
                              name: user?.fullName,
                              radius: 48,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                              textColor: Colors.white,
                              fontSize: 36,
                            ),
                            const SizedBox(height: 12),
                            Text(user?.fullName ?? 'Artisan', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
                            if (user?.craftType != null)
                              Text(user!.craftType!, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (user?.isVerified == true) ...[
                                  const Icon(Icons.verified_rounded, color: AppColors.accent, size: 16),
                                  const SizedBox(width: 4),
                                  Text('MoSJE Certified', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
                                  const SizedBox(width: 12),
                                ],
                                if (user?.district != null) ...[
                                  const Icon(Icons.location_on_outlined, color: Colors.white54, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user?.district}, ${user?.region ?? 'India'}',
                                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Quick stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatPill(label: 'Products', value: '${products.length}'),
                                _StatPill(label: 'Experience', value: '${user?.experienceYears ?? 0}y'),
                                _StatPill(label: 'Cluster', value: user?.clusterName?.split(' ').first ?? 'N/A'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: AppColors.accent,
                  tabs: const [
                    Tab(text: 'Products'),
                    Tab(text: 'About'),
                  ],
                ),
              ),

              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Products tab
                    products.isEmpty
                        ? const Center(child: Text('No products listed'))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, i) => _PortfolioProductCard(product: products[i]),
                          ),
                    // About tab
                    ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (user?.bio != null) ...[
                          Text('About', style: AppTextStyles.headlineSmall),
                          const SizedBox(height: 8),
                          Text(user!.bio!, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 20),
                        ],
                        if (user != null) ...[
                          _AboutRow(icon: Icons.palette_outlined, label: 'Craft', value: user.craftType ?? 'N/A'),
                          _AboutRow(icon: Icons.location_on_outlined, label: 'Village', value: user.village ?? user.district ?? 'N/A'),
                          _AboutRow(icon: Icons.business_center_outlined, label: 'Experience', value: '${user.experienceYears ?? 0} years'),
                          _AboutRow(icon: Icons.people_outline, label: 'Cluster', value: user.clusterName ?? 'N/A'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading portfolio: $e')),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
          Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(RouteNames.productDetail(product.id)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductThumbnail(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: 130,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.titleEn, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(AppFormatters.inr(product.retailPrice), style: AppTextStyles.priceHero.copyWith(color: AppColors.accent, fontSize: 16)),
                    if (product.giTag)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: StatusBadge(status: BadgeStatus.giTag),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.lightTextSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
