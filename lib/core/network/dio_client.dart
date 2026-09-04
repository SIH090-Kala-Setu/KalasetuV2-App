import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  dio.options = BaseOptions(
    baseUrl: ApiEndpoints.getBaseUrlSync(),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  // Logging interceptor (debug only)
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => _logger.d(obj),
    ),
  );

  // Auth interceptor (JWT injection + 401 handling)
  dio.interceptors.add(ref.read(authInterceptorProvider));

  return dio;
});

/// Updates the Dio base URL at runtime (e.g. after user changes backend URL)
Future<void> updateDioBaseUrl(Dio dio, String newUrl) async {
  dio.options.baseUrl = newUrl;
}
