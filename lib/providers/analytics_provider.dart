import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/usage_stat.dart';
import '../models/leaderboard_entry.dart';
import 'auth_provider.dart';

class AnalyticsState {
  final List<UsageStat> usageStats;
  final List<LeaderboardEntry> leaderboard;
  final bool isUsageLoading;
  final bool isLeaderboardLoading;
  final String? usageError;
  final String? leaderboardError;
  final String period; // week, month, all

  const AnalyticsState({
    this.usageStats = const [],
    this.leaderboard = const [],
    this.isUsageLoading = false,
    this.isLeaderboardLoading = false,
    this.usageError,
    this.leaderboardError,
    this.period = 'month',
  });

  AnalyticsState copyWith({
    List<UsageStat>? usageStats,
    List<LeaderboardEntry>? leaderboard,
    bool? isUsageLoading,
    bool? isLeaderboardLoading,
    String? usageError,
    String? leaderboardError,
    String? period,
    bool clearUsageError = false,
    bool clearLeaderboardError = false,
  }) {
    return AnalyticsState(
      usageStats: usageStats ?? this.usageStats,
      leaderboard: leaderboard ?? this.leaderboard,
      isUsageLoading: isUsageLoading ?? this.isUsageLoading,
      isLeaderboardLoading: isLeaderboardLoading ?? this.isLeaderboardLoading,
      usageError: clearUsageError ? null : (usageError ?? this.usageError),
      leaderboardError:
          clearLeaderboardError ? null : (leaderboardError ?? this.leaderboardError),
      period: period ?? this.period,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final ApiClient _api;

  AnalyticsNotifier(this._api) : super(const AnalyticsState());

  Future<void> fetchUsageStats() async {
    state = state.copyWith(isUsageLoading: true, clearUsageError: true);
    try {
      final response = await _api.get('/orders/stats/me');
      final data = ApiClient.unwrap(response) as List;
      final stats = data.map((e) => UsageStat.fromJson(e)).toList();
      state = state.copyWith(usageStats: stats, isUsageLoading: false);
    } catch (e) {
      state = state.copyWith(
        usageError: _api.extractError(e),
        isUsageLoading: false,
      );
    }
  }

  Future<void> fetchLeaderboard(String period) async {
    state = state.copyWith(
      isLeaderboardLoading: true,
      clearLeaderboardError: true,
      period: period,
    );
    try {
      final response = await _api.get('/orders/leaderboard',
          queryParameters: {'period': period});
      final data = ApiClient.unwrap(response) as List;
      final entries = data.map((e) => LeaderboardEntry.fromJson(e)).toList();
      state = state.copyWith(leaderboard: entries, isLeaderboardLoading: false);
    } catch (e) {
      state = state.copyWith(
        leaderboardError: _api.extractError(e),
        isLeaderboardLoading: false,
      );
    }
  }

  void setPeriod(String period) {
    if (state.period == period) return;
    fetchLeaderboard(period);
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.read(apiClientProvider));
});
