/// All route path constants for KalaSetuV2
class RouteNames {
  RouteNames._();

  // ── Root ─────────────────────────────────────────────────────
  static const String splash = '/';
  static const String serverConfig = '/server-config';

  // ── Onboarding ────────────────────────────────────────────────
  static const String onboardingLanguage = '/onboarding/language';
  static const String onboardingRole = '/onboarding/role';
  static const String onboardingPhone = '/onboarding/phone';
  static const String onboardingOtp = '/onboarding/otp';
  static const String onboardingRegister = '/onboarding/register';
  static const String login = '/login';

  // ── Artisan Shell ─────────────────────────────────────────────
  static const String artisanHome = '/artisan/home';
  static const String artisanStudio = '/artisan/studio';
  static const String artisanCatalogue = '/artisan/catalogue';
  static const String artisanInquiries = '/artisan/inquiries';
  static const String artisanExhibitions = '/artisan/exhibitions';
  static const String artisanProfile = '/artisan/profile';

  // ── Aggregator Shell ──────────────────────────────────────────
  static const String aggregatorHome = '/aggregator/home';
  static const String aggregatorArtisans = '/aggregator/artisans';
  static const String aggregatorAnalytics = '/aggregator/analytics';
  static const String aggregatorAlerts = '/aggregator/alerts';

  // ── Buyer Shell ───────────────────────────────────────────────
  static const String buyerMarketplace = '/buyer/marketplace';
  static const String buyerProductDetail = '/buyer/product/:productId';
  static const String buyerInquiries = '/buyer/inquiries';
  static const String buyerProfile = '/buyer/profile';

  // ── Portfolio ─────────────────────────────────────────────────
  static const String portfolio = '/portfolio/:artisanId';

  // ── Shared ────────────────────────────────────────────────────
  static const String notifications = '/notifications';

  // ── Helpers for dynamic routes ────────────────────────────────
  static String productDetail(String productId) =>
      '/buyer/product/$productId';
  static String artisanPortfolio(String artisanId) =>
      '/portfolio/$artisanId';
}
