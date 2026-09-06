import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AggregatorShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const AggregatorShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AggregatorShell> createState() => _AggregatorShellState();
}

class _AggregatorShellState extends ConsumerState<AggregatorShell> {
  DateTime? _lastBackPressTime;

  static const _items = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Artisans'),
    NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
    NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Alerts'),
  ];

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _handlePopInvoked(didPop),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (i) => widget.navigationShell.goBranch(
            i, initialLocation: i == widget.navigationShell.currentIndex),
          destinations: _items,
        ),
      ),
    );
  }
}
