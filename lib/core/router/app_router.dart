import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/language_picker_screen.dart';
import '../../features/onboarding/presentation/role_selection_screen.dart';
import '../../features/onboarding/presentation/phone_entry_screen.dart';
import '../../features/onboarding/presentation/otp_verification_screen.dart';
import '../../features/onboarding/presentation/registration_wizard_screen.dart';
import '../../features/onboarding/presentation/login_screen.dart';
import '../../features/artisan/presentation/artisan_shell.dart';
import '../../features/artisan/presentation/artisan_home_screen.dart';
import '../../features/artisan/presentation/ai_camera_studio_screen.dart';
import '../../features/artisan/presentation/artisan_catalogue_screen.dart';
import '../../features/artisan/presentation/artisan_inquiries_screen.dart';
import '../../features/artisan/presentation/artisan_exhibitions_screen.dart';
import '../../features/artisan/presentation/artisan_profile_screen.dart';
import '../../features/aggregator/presentation/aggregator_shell.dart';
import '../../features/aggregator/presentation/aggregator_home_screen.dart';
import '../../features/aggregator/presentation/artisans_list_screen.dart';
import '../../features/aggregator/presentation/cluster_analytics_screen.dart';
import '../../features/aggregator/presentation/alerts_reporting_screen.dart';
import '../../features/buyer/presentation/buyer_shell.dart';
import '../../features/buyer/presentation/buyer_marketplace_screen.dart';
import '../../features/buyer/presentation/product_detail_screen.dart';
import '../../features/buyer/presentation/my_inquiries_screen.dart';
import '../../features/buyer/presentation/buyer_profile_screen.dart';
import '../../features/portfolio/presentation/artisan_portfolio_screen.dart';
import '../../features/shared/presentation/notifications_screen.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      if (isLoading) return null; // Wait for auth to resolve

      final auth = authState.valueOrNull;
      if (auth == null) return null;

      final isOnboarding = state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation == RouteNames.splash ||
          state.matchedLocation == RouteNames.login;

      if (auth.isAuthenticated && isOnboarding) {
        // Redirect authenticated users to their home screen
        return switch (auth.status) {
          AuthStatus.authenticatedArtisan => RouteNames.artisanHome,
          AuthStatus.authenticatedAggregator => RouteNames.aggregatorHome,
          AuthStatus.authenticatedBuyer => RouteNames.buyerMarketplace,
          _ => null,
        };
      }

      if (!auth.isAuthenticated && !isOnboarding &&
          !state.matchedLocation.startsWith('/portfolio')) {
        return RouteNames.splash;
      }

      return null;
    },
    routes: [
      // ── Splash & Onboarding ──────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingLanguage,
        builder: (context, state) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingRole,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingPhone,
        builder: (context, state) {
          final role = state.extra as String? ?? 'Artisan';
          return PhoneEntryScreen(role: role);
        },
      ),
      GoRoute(
        path: RouteNames.onboardingOtp,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return OtpVerificationScreen(
            phone: extra['phone'] ?? '',
            role: extra['role'] ?? 'Artisan',
          );
        },
      ),
      GoRoute(
        path: RouteNames.onboardingRegister,
        builder: (context, state) {
          String role = 'Artisan';
          String? phone;
          if (state.extra is Map) {
            final map = state.extra as Map;
            role = map['role'] as String? ?? 'Artisan';
            phone = map['phone'] as String?;
          } else if (state.extra is String) {
            role = state.extra as String;
          }
          return RegistrationWizardScreen(role: role, phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Artisan Shell ────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ArtisanShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.artisanHome,
              builder: (context, state) => const ArtisanHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.artisanCatalogue,
              builder: (context, state) => const ArtisanCatalogueScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.artisanInquiries,
              builder: (context, state) => const ArtisanInquiriesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.artisanProfile,
              builder: (context, state) => const ArtisanProfileScreen(),
            ),
          ]),
        ],
      ),

      // Artisan Studio (outside shell — full screen)
      GoRoute(
        path: RouteNames.artisanStudio,
        builder: (context, state) => const AiCameraStudioScreen(),
      ),
      GoRoute(
        path: RouteNames.artisanExhibitions,
        builder: (context, state) => const ArtisanExhibitionsScreen(),
      ),

      // ── Aggregator Shell ─────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AggregatorShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.aggregatorHome,
              builder: (context, state) => const AggregatorHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.aggregatorArtisans,
              builder: (context, state) => const ArtisansListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.aggregatorAnalytics,
              builder: (context, state) => const ClusterAnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.aggregatorAlerts,
              builder: (context, state) => const AlertsReportingScreen(),
            ),
          ]),
        ],
      ),

      // ── Buyer Shell ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BuyerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.buyerMarketplace,
              builder: (context, state) => const BuyerMarketplaceScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.buyerInquiries,
              builder: (context, state) => const MyInquiriesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.buyerProfile,
              builder: (context, state) => const BuyerProfileScreen(),
            ),
          ]),
        ],
      ),

      // Buyer product detail (outside shell)
      GoRoute(
        path: '/buyer/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),

      // ── Portfolio (public, no auth required) ─────────────────
      GoRoute(
        path: '/portfolio/:artisanId',
        builder: (context, state) {
          final artisanId = state.pathParameters['artisanId']!;
          return ArtisanPortfolioScreen(artisanId: artisanId);
        },
      ),

      // ── Notifications ────────────────────────────────────────
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
