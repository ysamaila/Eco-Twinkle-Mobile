import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/verify_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/admin/admin_overview_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_support_screen.dart';
import 'screens/dashboard/support_screen.dart';
import 'screens/dashboard/analytics_screen.dart';

// ── RefreshListenable bridge ──────────────────────────────────────────────
// Keeps the GoRouter as ONE stable instance and pings it whenever auth changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}

// ── Router provider ───────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: AppConstants.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.uri.path;
      final status = authState.status;

      // Still loading stored credentials → stay on splash
      if (status == AuthStatus.initial) {
        return path == AppConstants.splash ? null : AppConstants.splash;
      }

      final isAuthenticated = status == AuthStatus.authenticated;
      final isPublicRoute = path == AppConstants.login ||
          path == AppConstants.signup ||
          path == AppConstants.verify ||
          path == AppConstants.forgotPassword ||
          path == AppConstants.resetPassword;

      // Unauthenticated trying to access protected route → login
      if (!isAuthenticated && !isPublicRoute && path != AppConstants.splash) {
        return AppConstants.login;
      }

      // Authenticated user sitting on splash or public routes → home
      if (isAuthenticated &&
          (path == AppConstants.splash || isPublicRoute)) {
        return authState.user?.isAdmin == true
            ? AppConstants.adminOverview
            : AppConstants.dashboard;
      }

      // Unauthenticated on splash → login
      if (!isAuthenticated && path == AppConstants.splash) {
        return AppConstants.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppConstants.verify,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyScreen(token: token);
        },
      ),
      GoRoute(
        path: AppConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: AppConstants.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.book,
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: AppConstants.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppConstants.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppConstants.adminOverview,
            builder: (context, state) => const AdminOverviewScreen(),
          ),
          GoRoute(
            path: AppConstants.adminOrders,
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: AppConstants.adminUsers,
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: AppConstants.adminSupport,
            builder: (context, state) => const AdminSupportScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
