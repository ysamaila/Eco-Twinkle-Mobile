class AppConstants {
  // Base URL — change this to your deployed backend URL
  static const String baseUrl = 'https://eco-twinkle-be.onrender.com';

  // Storage keys
  static const String tokenKey = 'eco_twinkle_token';
  static const String userKey = 'eco_twinkle_user';

  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verify = '/verify';
  static const String dashboard = '/dashboard';
  static const String book = '/book';
  static const String profile = '/profile';
  static const String adminOverview = '/admin/overview';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminSupport = '/admin/support';
  static const String support = '/support';
  static const String analytics = '/analytics';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Loyalty threshold
  static const int loyaltyThreshold = 100;
  static const double loyaltyDiscountRate = 0.10;
}
