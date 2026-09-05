import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/server_config_dialog.dart';
import '../../../shared/widgets/app_button.dart';

class BuyerProfileScreen extends ConsumerWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.buyerColor, Color(0xFF880E4F)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        child: Text(
                          user?.fullName.isNotEmpty == true ? user!.fullName[0] : '?',
                          style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.fullName ?? 'Buyer', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                      Text('B2B Buyer', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined, color: AppColors.buyerColor),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleLightDark(),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.dns_outlined, color: AppColors.buyerColor),
                      title: const Text('Server Configuration'),
                      subtitle: const Text('Switch between Localhost / Android / Production'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      contentPadding: EdgeInsets.zero,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const ServerConfigDialog(),
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.notifications_outlined, color: AppColors.buyerColor),
                      title: Text('Notifications'),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      contentPadding: EdgeInsets.zero,
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
