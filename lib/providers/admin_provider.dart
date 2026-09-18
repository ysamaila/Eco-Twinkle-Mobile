import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'auth_provider.dart';

// ── Admin Orders State ────────────────────────────────────────────────────

class AdminOrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;

  const AdminOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  AdminOrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) =>
      AdminOrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
      );
}

// ── Admin Users State ─────────────────────────────────────────────────────

class AdminUsersState {
  final List<User> users;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;

  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  AdminUsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) =>
      AdminUsersState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
      );
}

// ── Admin Orders Notifier ─────────────────────────────────────────────────

class AdminOrdersNotifier extends StateNotifier<AdminOrdersState> {
  final ApiClient _api;

  AdminOrdersNotifier(this._api) : super(const AdminOrdersState());

  Future<void> fetchAllOrders({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get(
        '/orders',
        queryParameters: {'page': page, 'limit': 5},
      );
      final raw = ApiClient.unwrap(response);
      final meta = ApiClient.meta(response);
      final List<dynamic> list = raw is List ? raw : [];
      final orders = list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        orders: page == 1 ? orders : [...state.orders, ...orders],
        isLoading: false,
        currentPage: page,
        // API returns meta.totalPages
        totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
    }
  }

  Future<String?> updateOrderStatus(
    int orderId,
    String status,
    int adminId,
  ) async {
    try {
      await _api.patch(
        '/orders/$orderId/status',
        data: {'status': status, 'adminId': adminId},
      );
      // Update locally
      final updated = state.orders.map<Order>((o) {
        if (o.id == orderId) {
          return Order(
            id: o.id,
            service: o.service,
            item: o.item,
            date: o.date,
            time: o.time,
            status: OrderStatus.fromString(status),
            price: o.price,
            receiptFile: o.receiptFile,
            generatedReceiptPath: o.generatedReceiptPath,
            discountApplied: o.discountApplied,
            createdAt: o.createdAt,
            user: o.user,
            approvedBy: o.approvedBy,
            completedBy: o.completedBy,
          );
        }
        return o;
      }).toList();
      state = state.copyWith(orders: updated);
      return null;
    } catch (e) {
      return _api.extractError(e);
    }
  }

  Future<String?> deleteOrder(int orderId) async {
    try {
      await _api.delete('/orders/$orderId');
      state = state.copyWith(
        orders: state.orders.where((o) => o.id != orderId).toList(),
      );
      return null;
    } catch (e) {
      return _api.extractError(e);
    }
  }
}

// ── Admin Users Notifier ──────────────────────────────────────────────────

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final ApiClient _api;

  AdminUsersNotifier(this._api) : super(const AdminUsersState());

  Future<void> fetchUsers({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get(
        '/users',
        queryParameters: {'page': page, 'limit': 5},
      );
      final raw = ApiClient.unwrap(response);
      final meta = ApiClient.meta(response);
      final List<dynamic> list = raw is List ? raw : [];
      final users = list
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        users: page == 1 ? users : [...state.users, ...users],
        isLoading: false,
        currentPage: page,
        totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _api.extractError(e));
    }
  }

  Future<String?> updateUser(int userId, Map<String, dynamic> data) async {
    try {
      await _api.patch('/users/$userId', data: data);
      await fetchUsers(page: 1);
      return null;
    } catch (e) {
      return _api.extractError(e);
    }
  }

  Future<String?> deleteUser(int userId) async {
    try {
      await _api.delete('/users/$userId');
      state = state.copyWith(
        users: state.users.where((u) => u.id != userId).toList(),
      );
      return null;
    } catch (e) {
      return _api.extractError(e);
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final adminOrdersProvider =
    StateNotifierProvider<AdminOrdersNotifier, AdminOrdersState>((ref) {
  return AdminOrdersNotifier(ref.read(apiClientProvider));
});

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ref.read(apiClientProvider));
});
