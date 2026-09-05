import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kBackendUrlKey = 'kalasetu_backend_url';

class ApiEndpoints {
  ApiEndpoints._();

  // ── Dynamic Base URL Resolution ─────────────────────────────
  static String? _cachedBaseUrl;

  static Future<String> resolveBaseUrl() async {
    // 1. Build-time env override
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) return _normalizeUrl(envUrl);

    // 2. Runtime SharedPreferences override
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kBackendUrlKey);
    if (saved != null && saved.isNotEmpty) {
      _cachedBaseUrl = _normalizeUrl(saved);
      return _cachedBaseUrl!;
    }

    // 3. Auto platform fallback
    return _platformDefault();
  }

  static String getBaseUrlSync() {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) return _normalizeUrl(envUrl);
    return _platformDefault();
  }

  static Future<void> setCustomBaseUrl(String url) async {
    _cachedBaseUrl = _normalizeUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBackendUrlKey, _cachedBaseUrl!);
  }

  static Future<void> clearCustomBaseUrl() async {
    _cachedBaseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBackendUrlKey);
  }

  static String get currentBaseUrl => getBaseUrlSync();

  static String _platformDefault() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000'; // iOS, Windows, macOS, Linux
  }

  /// Auto-fixes Android localhost → 10.0.2.2 mapping and ensures http protocol
  static String _normalizeUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return _platformDefault();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!kIsWeb && Platform.isAndroid) {
      url = url
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // ── Auth ─────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String fcmToken = '/auth/fcm-token';

  // ── AI Studio ────────────────────────────────────────────────
  static const String enhance = '/enhance';
  static const String enhanceBatch = '/enhance/batch';
  static const String catalog = '/catalog';
  static const String catalogVision = '/catalog/vision';
  static const String suggestPrice = '/suggest-price';
  static const String predictPrice = '/api/v1/pricing/predict-price';

  // ── Products ─────────────────────────────────────────────────
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
  static String productStatus(String id) => '/products/$id/status';
  static String productStock(String id) => '/products/$id/stock';
  static String productPrice(String id) => '/products/$id/price';
  static String productQr(String id) => '/products/$id/qr';
  static String productReviews(String id) => '/products/$id/reviews';

  // ── Inquiries ────────────────────────────────────────────────
  static const String inquiries = '/inquiries';
  static String respondInquiry(String id) => '/inquiries/$id/respond';

  // ── Artisan Profile & Portfolio ───────────────────────────────
  static const String artisanDashboard = '/artisan/dashboard';
  static const String artisanProfile = '/artisan/profile';
  static const String artisanAnalytics = '/artisan/analytics';
  static const String artisanReport = '/artisan/report';
  static String artisanPortfolio(String id) => '/artisan/$id/portfolio';

  // ── Exhibitions & Schemes ─────────────────────────────────────
  static const String exhibitions = '/admin/exhibitions';
  static String registerExhibition(String id) => '/admin/exhibitions/$id/register';
  static const String schemes = '/admin/schemes';

  // ── Aggregator ───────────────────────────────────────────────
  static const String aggregatorDashboard = '/aggregator/dashboard';
  static const String aggregatorArtisans = '/aggregator/artisans';
  static const String aggregatorOnboard = '/aggregator/artisans/onboard';
  static const String aggregatorRelayScheme = '/aggregator/schemes/relay';
  static const String aggregatorSubmitReport = '/aggregator/reports/submit';

  // ── Clusters ─────────────────────────────────────────────────
  static const String clusters = '/clusters';
  static const String myClusters = '/clusters/my-clusters';
  static String clusterArtisans(String id) => '/clusters/$id/artisans';
  static const String joinCluster = '/aggregator/join-cluster';

  // ── Buyer ────────────────────────────────────────────────────
  static const String buyerDashboard = '/buyer/dashboard';

  // ── Notifications ─────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';
}
