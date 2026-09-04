import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/shimmer_loader.dart';

final _notificationsProvider = FutureProvider<List<AppNotificationModel>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(_notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final api = ref.read(apiClientProvider);
              await api.markAllNotificationsRead();
              ref.invalidate(_notificationsProvider);
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateView(
              title: 'No notifications',
              subtitle: 'You\'ll see inquiry, scheme, and verification alerts here',
              icon: Icons.notifications_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_notificationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, i) => _NotificationTile(
                notification: notifications[i],
                onTap: () async {
                  final api = ref.read(apiClientProvider);
                  await api.markNotificationRead(notifications[i].id);
                  ref.invalidate(_notificationsProvider);
                },
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = _getIconAndColor(notification.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(notification.title, style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700,
                      ))),
                      if (!notification.isRead)
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.message, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (notification.createdAt != null)
                    Text(AppFormatters.relative(notification.createdAt!), style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(String type) => switch (type) {
    'inquiry' => (Icons.mail_rounded, AppColors.info),
    'govt-scheme' || 'scheme' => (Icons.account_balance_rounded, AppColors.accent),
    'verification' => (Icons.verified_rounded, AppColors.success),
    'inventory' => (Icons.inventory_2_rounded, AppColors.warning),
    _ => (Icons.notifications_rounded, AppColors.primary),
  };
}
