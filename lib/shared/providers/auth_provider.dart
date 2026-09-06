import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/storage/preferences_service.dart';
import '../../shared/models/models.dart';

// ── Auth State ────────────────────────────────────────────────
enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticatedArtisan,
  authenticatedAggregator,
  authenticatedBuyer,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.unauthenticated({String? error})
      : this(status: AuthStatus.unauthenticated, error: error);

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error ?? this.error,
      );

  bool get isAuthenticated => status == AuthStatus.authenticatedArtisan ||
      status == AuthStatus.authenticatedAggregator ||
      status == AuthStatus.authenticatedBuyer;

  bool get isArtisan => status == AuthStatus.authenticatedArtisan;
  bool get isAggregator => status == AuthStatus.authenticatedAggregator;
  bool get isBuyer => status == AuthStatus.authenticatedBuyer;
}

// ── Provider ──────────────────────────────────────────────────
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Try to restore session on startup
    final storage = ref.read(secureStorageProvider);
    final isLoggedIn = await storage.isLoggedIn();
    if (!isLoggedIn) return const AuthState.unauthenticated();

    try {
      final api = ref.read(apiClientProvider);
      final user = await api.getMe();
      return _stateFromUser(user);
    } catch (_) {
      await storage.clearAll();
      return const AuthState.unauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final storage = ref.read(secureStorageProvider);
      final prefs = ref.read(preferencesServiceProvider);

      final data = await api.login(username: username, password: password);
      final token = data['access_token'] as String? ?? '';
      await storage.saveAccessToken(token);

      UserModel user;
      if (data['user'] != null) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        user = await api.getMe();
      }
      await storage.saveUserId(user.id);
      await storage.saveUserRole(user.role);
      await prefs.setSelectedRole(user.role);

      return _stateFromUser(user);
    });
  }

  Future<void> register({
    required String username,
    required String password,
    required String role,
    String? phone,
    String? fullName,
    String? preferredLang,
    String? craftType,
    String? region,
    String? district,
    String? aadhaarNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final storage = ref.read(secureStorageProvider);

      final user = await api.register(
        username: username,
        password: password,
        role: role,
        phone: phone,
        fullName: fullName,
        preferredLang: preferredLang,
        craftType: craftType,
        region: region,
        district: district,
        aadhaarNumber: aadhaarNumber,
      );
      // After registration, log in automatically
      final loginData = await api.login(username: username, password: password);
      await storage.saveAccessToken(loginData['access_token'] as String? ?? '');
      await storage.saveUserId(user.id);
      await storage.saveUserRole(user.role);

      return _stateFromUser(user);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.clearAll();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  Future<void> refreshUser() async {
    try {
      final api = ref.read(apiClientProvider);
      final user = await api.getMe();
      state = AsyncValue.data(_stateFromUser(user));
    } catch (_) {
      // Silently ignore refresh errors
    }
  }

  AuthState _stateFromUser(UserModel user) {
    final role = user.role.toLowerCase();
    return AuthState(
      status: switch (role) {
        'artisan' => AuthStatus.authenticatedArtisan,
        'aggregator' => AuthStatus.authenticatedAggregator,
        'buyer' => AuthStatus.authenticatedBuyer,
        _ => AuthStatus.authenticatedArtisan,
      },
      user: user,
    );
  }
}
