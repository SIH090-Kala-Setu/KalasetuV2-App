import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class BuyerShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const BuyerShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          selectedIndex: navigationShell.currentIndex,
          height: 64,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined, color: Color(0xFF8A94A6)),
              selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primary),
              label: 'Market',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, color: Color(0xFF8A94A6)),
              selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF8A94A6)),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
