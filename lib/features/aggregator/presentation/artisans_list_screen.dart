import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/status_badge.dart';

final _artisansListProvider = FutureProvider<List<UserModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getAggregatorArtisans();
});

class ArtisansListScreen extends ConsumerStatefulWidget {
  const ArtisansListScreen({super.key});

  @override
  ConsumerState<ArtisansListScreen> createState() => _ArtisansListScreenState();
}

class _ArtisansListScreenState extends ConsumerState<ArtisansListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final artisansAsync = ref.watch(_artisansListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Artisans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _showOnboardSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchBar(
              hint: 'Search artisans...',
              onSearch: (q) => setState(() => _searchQuery = q),
            ),
          ),
          Expanded(
            child: artisansAsync.when(
              data: (artisans) {
                final filtered = _searchQuery.isEmpty
                    ? artisans
                    : artisans.where((a) =>
                        a.fullName.toLowerCase().contains(_searchQuery) ||
                        (a.craftType?.toLowerCase().contains(_searchQuery) ?? false)).toList();

                if (filtered.isEmpty) return const EmptyStateView(title: 'No artisans found', icon: Icons.people_outline);

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_artisansListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ArtisanListTile(artisan: filtered[i]),
                    ),
                  ),
                );
              },
              loading: () => ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ShimmerListTile(),
                ),
              ),
              error: (e, _) => ErrorStateView(message: e.toString(), onRetry: () => ref.invalidate(_artisansListProvider)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showOnboardSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Onboard Artisan'),
      ),
    );
  }

  void _showOnboardSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final craftCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.lightBorder, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Onboard New Artisan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            AppTextField(controller: nameCtrl, label: 'Full Name', prefixIcon: Icons.person_outline),
            const SizedBox(height: 12),
            AppTextField(controller: phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
            const SizedBox(height: 12),
            AppTextField(controller: craftCtrl, label: 'Craft Specialization', prefixIcon: Icons.palette_outlined),
            const SizedBox(height: 20),
            Consumer(builder: (ctx, ref, _) => AppButton(
              label: 'Onboard Artisan',
              leadingIcon: Icons.person_add_rounded,
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                await api.onboardArtisan(
                  fullName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  craftType: craftCtrl.text.trim(),
                );
                ref.invalidate(_artisansListProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ArtisanListTile extends StatelessWidget {
  final UserModel artisan;
  const _ArtisanListTile({required this.artisan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.aggregatorColor.withValues(alpha: 0.15),
            child: Text(
              artisan.fullName.isNotEmpty ? artisan.fullName[0] : '?',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.aggregatorColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(artisan.fullName, style: AppTextStyles.titleSmall)),
                if (artisan.isVerified) const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
              ]),
              if (artisan.craftType != null) Text(artisan.craftType!, style: AppTextStyles.bodySmall),
              if (artisan.district != null) Text(artisan.district!, style: AppTextStyles.caption.copyWith(color: AppColors.lightTextSecondary)),
            ]),
          ),
          StatusBadge(status: artisan.kycStatus == 'verified' ? BadgeStatus.verified : BadgeStatus.pending),
        ],
      ),
    );
  }
}
