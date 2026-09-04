import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/shimmer_loader.dart';

final _analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getAggregatorDashboard();
});

class ClusterAnalyticsScreen extends ConsumerWidget {
  const ClusterAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(_analyticsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: analyticsAsync.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Revenue card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.aggregatorColor, Color(0xFF1565C0)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cluster Revenue', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(AppFormatters.inr((data['monthly_revenue'] ?? 0).toDouble()),
                    style: AppTextStyles.priceHero.copyWith(color: Colors.white, fontSize: 36)),
                const SizedBox(height: 4),
                Text('This Month', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
              ]),
            ),
            const SizedBox(height: 20),
            // Breakdown stats
            ...[ 
              ('Total Artisans', '${data['total_artisans'] ?? 0}', AppColors.info),
              ('Verified Artisans', '${data['verified_artisans'] ?? 0}', AppColors.success),
              ('Active Products', '${data['active_products'] ?? 0}', AppColors.accent),
              ('Total Orders', '${data['total_orders'] ?? 0}', AppColors.aggregatorColor),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(item.$1, style: AppTextStyles.bodyMedium),
                  Text(item.$2, style: AppTextStyles.headlineSmall.copyWith(color: item.$3)),
                ]),
              ),
            )),
          ],
        ),
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerLoader(width: double.infinity, height: 60, borderRadius: 12)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
