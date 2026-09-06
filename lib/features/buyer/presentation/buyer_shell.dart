import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class BuyerShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const BuyerShell({super.key, required this.navigationShell});

  @override
  ConsumerState<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends ConsumerState<BuyerShell> {
  DateTime? _lastBackPressTime;

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    // 1. If child navigator can pop (nested route inside branch)
    final branchNavigator = widget.navigationShell.shellRouteContext.navigatorKey.currentState;
    if (branchNavigator != null && branchNavigator.canPop()) {
      branchNavigator.pop();
      return;
    }

    // 2. If on non-home tab, navigate back to home tab (index 0)
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

    // 3. If on home tab, double-press to exit app
    final now = DateTime.now();
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
    } else {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : Colors.white;
    final navBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePopInvoked(didPop),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(top: BorderSide(color: navBorder, width: 1)),
          ),
          child: NavigationBar(
            backgroundColor: navBg,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            selectedIndex: widget.navigationShell.currentIndex,
            height: 64,
            onDestinationSelected: (i) => widget.navigationShell.goBranch(
              i,
              initialLocation: i == widget.navigationShell.currentIndex,
            ),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.storefront_rounded, color: AppColors.primary),
                label: 'Market',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.assignment_rounded, color: AppColors.primary),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
