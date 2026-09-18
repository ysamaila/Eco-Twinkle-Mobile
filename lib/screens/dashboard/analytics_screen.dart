import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/usage_chart.dart';
import '../../widgets/leaderboard_list.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).fetchUsageStats();
      ref.read(analyticsProvider.notifier).fetchLeaderboard('month');
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(analyticsProvider.notifier).fetchUsageStats();
          await ref.read(analyticsProvider.notifier).fetchLeaderboard(analyticsState.period);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            UsageChart(
              stats: analyticsState.usageStats,
              isLoading: analyticsState.isUsageLoading,
              error: analyticsState.usageError,
            ),
            LeaderboardList(
              entries: analyticsState.leaderboard,
              period: analyticsState.period,
              isLoading: analyticsState.isLeaderboardLoading,
              error: analyticsState.leaderboardError,
              onPeriodChanged: (p) =>
                  ref.read(analyticsProvider.notifier).setPeriod(p),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
