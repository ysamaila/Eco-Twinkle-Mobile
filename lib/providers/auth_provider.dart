import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/user.dart';

// ── Shared service providers ──────────────────────────────────────────────

final storageServiceProvider = Provider<StorageService>((_) => StorageService());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ApiClient(storage);
});

// ── Auth State ────────────────────────────────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final User? user;
  final String? token;
  final AuthStatus status;
  final bool isLoading;
  final String? error;
  final bool verifyEmailPending;
  final bool signupSuccess;

  const AuthState({
    this.user,
    this.token,
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.error,
    this.verifyEmailPending = false,
    this.signupSuccess = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    AuthStatus? status,
    bool? isLoading,
    String? error,
    bool? verifyEmailPending,
    bool? signupSuccess,
    bool clearError = false,
    bool clearUser = false,
    bool clearToken = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        token: clearToken ? null : (token ?? this.token),
        status: status ?? this.status,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        verifyEmailPending: verifyEmailPending ?? this.verifyEmailPending,
        signupSuccess: signupSuccess ?? this.signupSuccess,
      );
}

// ── Auth Notifier ─────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;
  final StorageService _storage;

  AuthNotifier(this._api, this._storage) : super(const AuthState()) {
    _loadFromStorage();
    // Wire force-logout from API interceptor
    ApiClient.onForceLogout = _forceLogout;
  }

  Future<void> _loadFromStorage() async {
    try {
      final token = await _storage.getToken();
      final userJson = await _storage.getUser();
      if (token != null && userJson != null) {
        state = state.copyWith(
          token: token,
          user: User.fromJson(userJson),
          status: AuthStatus.authenticated,
        );
        return;
      }
    } catch (_) {}
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  void _forceLogout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Login ─────────────────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      verifyEmailPending: false,
      signupSuccess: false,
    );
    try {
      final response = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = ApiClient.unwrap(response) as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

      await _storage.saveToken(token);
      await _storage.saveUser(user.toJson());

      state = state.copyWith(
        token: token,
        user: user,
        status: AuthStatus.authenticated,
        isLoading: false,
      );
    } catch (e) {
      final msg = _api.extractError(e);
      if (msg == 'Please verify your email first') {
        state = state.copyWith(
          isLoading: false,
          verifyEmailPending: true,
          error: msg,
        );
      } else {
        state = state.copyWith(isLoading: false, error: msg);
      }
    }
  }

  // ── Signup ────────────────────────────────────────────────────────────

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String whatsappNumber,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, signupSuccess: false);
    try {
      await _api.post('/auth/signup', data: {
        'firstName': firstName,
        'lastName': lastName,
        'whatsappNumber': whatsappNumber,
        'email': email,
        'password': password,
        'role': 'CUSTOMER',
      });
      state = state.copyWith(isLoading: false, signupSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
    }
  }

  // ── Email Verification ────────────────────────────────────────────────

  Future<String?> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.get('/auth/verify', queryParameters: {'token': token});
      state = state.copyWith(isLoading: false);
      return null; // success
    } catch (e) {
      final msg = _api.extractError(e);
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }

  // ── Profile Update ────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String whatsappNumber,
  }) async {
    if (state.user == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.patch(
        '/users/${state.user!.id}',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'whatsappNumber': whatsappNumber,
        },
      );
      final data = ApiClient.unwrap(response);
      final updated = data is Map<String, dynamic>
          ? User.fromJson(data)
          : state.user!.copyWith(
              firstName: firstName,
              lastName: lastName,
              whatsappNumber: whatsappNumber,
            );
      await _storage.saveUser(updated.toJson());
      state = state.copyWith(user: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
    }
  }

  // ── Password Reset ───────────────────────────────────────────────────

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.post('/auth/forgot-password', data: {'email': email});
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _api.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
      rethrow;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(apiClientProvider),
    ref.read(storageServiceProvider),
  );
});
