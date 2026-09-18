import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/order.dart';
import 'auth_provider.dart';

// ── Orders State ──────────────────────────────────────────────────────────

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
    bool clearError = false,
    bool clearSubmitError = false,
  }) =>
      OrdersState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        submitError: clearSubmitError ? null : (submitError ?? this.submitError),
        submitSuccess: submitSuccess ?? this.submitSuccess,
      );
}

// ── Orders Notifier ───────────────────────────────────────────────────────

class OrdersNotifier extends StateNotifier<OrdersState> {
  final ApiClient _api;

  OrdersNotifier(this._api) : super(const OrdersState());

  // ── Fetch single order by ID ──────────────────────────────────────────
  Future<Order?> fetchOrderById(int orderId) async {
    try {
      final response = await _api.get('/orders/$orderId');
      final raw = ApiClient.unwrap(response);
      if (raw is Map<String, dynamic>) return Order.fromJson(raw);
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Fetch user orders (paginated) ─────────────────────────────────────

  Future<void> fetchUserOrders(int userId, {int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get(
        '/orders/user/$userId',
        queryParameters: {'page': page, 'limit': 5},
      );

      // Unwrap: handles { data: [...] }, { data: { orders: [...] } }, or bare [...]
      dynamic raw = ApiClient.unwrap(response);
      if (raw is Map) {
        raw = raw['orders'] ?? raw['items'] ?? raw['data'] ?? [];
      }
      final List<dynamic> list = raw is List ? raw : [];
      final orders = list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      final meta = ApiClient.meta(response);
      state = state.copyWith(
        orders: page == 1 ? orders : [...state.orders, ...orders],
        isLoading: false,
        currentPage: page,
        totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _api.extractError(e),
      );
    }
  }

  // ── Create order (multipart) ──────────────────────────────────────────

  Future<void> createOrder({
    required int userId,
    required String service,
    required String item,
    required String date,
    required String time,
    required double price,
    File? receiptFile,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearSubmitError: true,
      submitSuccess: false,
    );
    try {
      final formData = FormData.fromMap({
        'userId': userId.toString(),
        'service': service,
        'item': item,
        'date': date,
        'time': time,
        'price': price.toString(),
        if (receiptFile != null)
          'file': await MultipartFile.fromFile(
            receiptFile.path,
            filename: receiptFile.path.split('/').last,
          ),
      });

      await _api.postForm('/orders', formData);
      state = state.copyWith(isSubmitting: false, submitSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: _api.extractError(e),
      );
    }
  }

  // ── Submit review ─────────────────────────────────────────────────────

  Future<String?> submitReview(
    int orderId,
    int rating,
    String comment,
  ) async {
    try {
      await _api.post(
        '/reviews/$orderId',
        data: {'rating': rating, 'comment': comment},
      );
      return null; // success
    } catch (e) {
      return _api.extractError(e);
    }
  }

  void resetSubmit() =>
      state = state.copyWith(submitSuccess: false, clearSubmitError: true);
}

// ── Provider ──────────────────────────────────────────────────────────────

final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.read(apiClientProvider));
});
