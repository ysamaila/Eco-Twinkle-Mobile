import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;
  final String period;
  final Function(String) onPeriodChanged;

  const LeaderboardList({
    super.key,
    required this.entries,
    required this.period,
    required this.onPeriodChanged,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              _TabSwitcher(
                current: period,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading && entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (error != null)
            Center(
              child: Text(
                error!,
                style: const TextStyle(color: AppColors.error),
              ),
            )
          else if (entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No users ranked yet.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final rank = index + 1;
                return _LeaderboardItem(entry: entry, rank: rank);
              },
            ),
        ],
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final String current;
  final Function(String) onChanged;

  const _TabSwitcher({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: 'Week',
            active: current == 'week',
            onTap: () => onChanged('week'),
          ),
          _TabItem(
            label: 'Month',
            active: current == 'month',
            onTap: () => onChanged('month'),
          ),
          _TabItem(
            label: 'All',
            active: current == 'all',
            onTap: () => onChanged('all'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.black : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardItem({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    Widget rankIcon;
    if (rank == 1) {
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20);
    } else if (rank == 2) {
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 18);
    } else if (rank == 3) {
      rankIcon = const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 18);
    } else {
      rankIcon = Text(
        '#$rank',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Center(child: rankIcon)),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            radius: 16,
            child: Text(
              entry.firstName[0],
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${entry.count} services',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
