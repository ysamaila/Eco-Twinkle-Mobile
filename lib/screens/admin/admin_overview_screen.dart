import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';

class AdminOverviewScreen extends ConsumerStatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  ConsumerState<AdminOverviewScreen> createState() =>
      _AdminOverviewScreenState();
}

class _AdminOverviewScreenState
    extends ConsumerState<AdminOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(authProvider).user;
    final state = ref.watch(adminOrdersProvider);
    final orders = state.orders;

    // Compute stats
    final total = orders.length;
    final byStatus = <OrderStatus, int>{};
    for (final o in orders) {
      byStatus[o.status] = (byStatus[o.status] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Overview'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco_rounded,
              color: AppColors.primary, size: 18),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              ref.read(adminOrdersProvider.notifier).fetchAllOrders(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${admin?.firstName ?? 'Admin'}! 👑',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text('Eco-Twinkle Control Panel',
                    style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 24),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Total orders banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.surfaceLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary, size: 26),
                        const SizedBox(height: 10),
                        Text(
                          '$total',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary),
                        ),
                        Text('Total Orders',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status breakdown grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _StatCard(
                        label: 'Pending',
                        count: byStatus[OrderStatus.pending] ?? 0,
                        color: AppColors.statusPending,
                        icon: Icons.hourglass_empty_rounded,
                      ),

                      _StatCard(
                        label: 'Approved',
                        count: byStatus[OrderStatus.approved] ?? 0,
                        color: AppColors.statusApproved,
                        icon: Icons.verified_outlined,
                      ),
                      _StatCard(
                        label: 'Completed',
                        count: byStatus[OrderStatus.completed] ?? 0,
                        color: AppColors.statusCompleted,
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      _StatCard(
                        label: 'Cancelled',
                        count: byStatus[OrderStatus.cancelled] ?? 0,
                        color: AppColors.statusCancelled,
                        icon: Icons.cancel_outlined,
                      ),
                      _StatCard(
                        label: 'w/ Discount',
                        count: orders
                            .where((o) => o.discountApplied)
                            .length,
                        color: AppColors.gold,
                        icon: Icons.local_offer_outlined,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
