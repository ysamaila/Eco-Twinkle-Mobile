import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/support_ticket.dart';
import 'auth_provider.dart';

class SupportState {
  final List<SupportTicket> tickets;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;
  final String? submitError;
  final bool submitSuccess;
  final DateTime? lastViewedAt;

  const SupportState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
    this.submitError,
    this.submitSuccess = false,
    this.lastViewedAt,
  });

  SupportState copyWith({
    List<SupportTicket>? tickets,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
    DateTime? lastViewedAt,
    bool clearError = false,
    bool clearSubmitError = false,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      submitSuccess: submitSuccess ?? this.submitSuccess,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  final ApiClient _api;
  final StorageService _storage;

  SupportNotifier(this._api, this._storage) : super(const SupportState()) {
    _loadLastViewed();
  }

  Future<void> _loadLastViewed() async {
    final time = await _storage.getLastSupportViewTime();
    if (time != null) {
      state = state.copyWith(lastViewedAt: time);
    }
  }

  Future<void> markAsViewed() async {
    final now = DateTime.now();
    await _storage.saveLastSupportViewTime(now);
    state = state.copyWith(lastViewedAt: now);
  }

  void resetSubmit() {
    state = state.copyWith(submitSuccess: false, clearSubmitError: true);
  }

  Future<void> fetchCustomerTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get('/support/me');
      final data = ApiClient.unwrap(response) as List;
      final tickets = data.map((e) => SupportTicket.fromJson(e)).toList();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _api.extractError(e), isLoading: false);
    }
  }

  Future<void> fetchAdminTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.get('/support');
      final data = ApiClient.unwrap(response) as List;
      final tickets = data.map((e) => SupportTicket.fromJson(e)).toList();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: _api.extractError(e), isLoading: false);
    }
  }

  Future<void> createTicket(String content) async {
    state = state.copyWith(isSubmitting: true, clearSubmitError: true, submitSuccess: false);
    try {
      final response = await _api.post('/support', data: {'content': content});
      final newTicket = SupportTicket.fromJson(ApiClient.unwrap(response));
      state = state.copyWith(
        tickets: [newTicket, ...state.tickets],
        isSubmitting: false,
        submitSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        submitError: _api.extractError(e),
        isSubmitting: false,
      );
    }
  }

  Future<String?> respondToTicket(int ticketId, String responseText) async {
    try {
      final response = await _api.patch('/support/$ticketId/respond', data: {'response': responseText});
      final updatedTicket = SupportTicket.fromJson(ApiClient.unwrap(response));
      
      final updatedList = state.tickets.map((t) {
        return t.id == ticketId ? updatedTicket : t;
      }).toList();
      
      state = state.copyWith(tickets: updatedList);
      return null; // success
    } catch (e) {
      return _api.extractError(e);
    }
  }
}

final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  return SupportNotifier(
    ref.read(apiClientProvider),
    ref.read(storageServiceProvider),
  );
});
