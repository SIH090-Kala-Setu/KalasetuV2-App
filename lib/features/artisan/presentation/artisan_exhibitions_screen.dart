import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';

final _exhibitionsProvider = FutureProvider<List<ExhibitionModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getExhibitions();
});

class ArtisanExhibitionsScreen extends ConsumerWidget {
  const ArtisanExhibitionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exhibitionsAsync = ref.watch(_exhibitionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exhibitions & Events')),
      body: exhibitionsAsync.when(
        data: (exhibitions) {
          if (exhibitions.isEmpty) {
            return const EmptyStateView(
              title: 'No exhibitions',
              subtitle: 'Check back later for upcoming craft exhibitions',
              icon: Icons.festival_rounded,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_exhibitionsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exhibitions.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ExhibitionCard(exhibition: exhibitions[i], ref: ref),
              ),
            ),
          );
        },
        loading: () => ListView.builder(
          itemCount: 3,
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: ShimmerLoader(width: double.infinity, height: 140, borderRadius: 16),
          ),
        ),
        error: (e, _) => ErrorStateView(
          message: e.toString(),
          onRetry: () => ref.invalidate(_exhibitionsProvider),
        ),
      ),
    );
  }
}

class _ExhibitionCard extends StatelessWidget {
  final ExhibitionModel exhibition;
  final WidgetRef ref;

  const _ExhibitionCard({required this.exhibition, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final isRegistered = exhibition.status == 'pending' || exhibition.status == 'approved';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRegistered
              ? AppColors.success.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header with gradient
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.accent.withValues(alpha: 0.6)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.festival_rounded, color: Colors.white.withValues(alpha: 0.4), size: 56)),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRegistered ? AppColors.success : AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isRegistered ? '✓ Registered' : 'Open',
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exhibition.name, style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (exhibition.location != null) ...[
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(exhibition.location!, style: AppTextStyles.bodySmall),
                      const SizedBox(width: 16),
                    ],
                    if (exhibition.dates != null) ...[
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(exhibition.dates!, style: AppTextStyles.bodySmall),
                    ],
                  ],
                ),
                if (exhibition.boothNumber != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Booth ${exhibition.boothNumber}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                  ),
                ],
                const SizedBox(height: 12),
                if (!isRegistered)
                  AppButton(
                    label: 'Register for Exhibition',
                    leadingIcon: Icons.how_to_reg_rounded,
                    height: 44,
                    onPressed: () async {
                      final api = ref.read(apiClientProvider);
                      await api.registerForExhibition(exhibition.id);
                      ref.invalidate(_exhibitionsProvider);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
