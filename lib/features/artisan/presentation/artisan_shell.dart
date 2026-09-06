import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ArtisanShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const ArtisanShell({super.key, required this.navigationShell});

  @override
  ConsumerState<ArtisanShell> createState() => _ArtisanShellState();
}

class _ArtisanShellState extends ConsumerState<ArtisanShell> {
  DateTime? _lastBackPressTime;

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    final branchNavigator = widget.navigationShell.shellRouteContext.navigatorKey.currentState;
    if (branchNavigator != null && branchNavigator.canPop()) {
      branchNavigator.pop();
      return;
    }

    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return;
    }

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
                icon: Icon(Icons.home_outlined, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
                label: 'Catalogue',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6)),
                selectedIcon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                label: 'Inquiries',
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
