import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';

final _alertsSchemesProvider = FutureProvider<List<GovtSchemeModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getSchemes();
});

class AlertsReportingScreen extends ConsumerWidget {
  const AlertsReportingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemesAsync = ref.watch(_alertsSchemesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Schemes')),
      body: schemesAsync.when(
        data: (schemes) {
          if (schemes.isEmpty) return const EmptyStateView(title: 'No schemes available', icon: Icons.account_balance_rounded);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schemes.length,
            itemBuilder: (context, i) {
              final scheme = schemes[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.account_balance_rounded, color: AppColors.accent, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(scheme.name, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (scheme.category != null) Text(scheme.category!, style: AppTextStyles.bodySmall),
                      ])),
                    ]),
                    if (scheme.deadline != null) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text('Deadline: ${scheme.deadline}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning)),
                      ]),
                    ],
                    if (scheme.description != null) ...[
                      const SizedBox(height: 8),
                      Text(scheme.description!, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 12),
                    Row(children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.campaign_rounded, size: 16),
                        label: const Text('Relay to Artisans'),
                        onPressed: () async {
                          final api = ref.read(apiClientProvider);
                          await api.relayScheme(schemeId: scheme.id, targetState: 'all', targetCraft: 'all');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Scheme relayed to all artisans!')));
                          }
                        },
                      ),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(itemCount: 3, padding: const EdgeInsets.all(16),
          itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 14))),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
