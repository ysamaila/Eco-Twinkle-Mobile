import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/order_card.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  final _scrollCtrl = ScrollController();
  bool _reloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _reload(),
    );
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _reloading = true);
    await ref.read(adminOrdersProvider.notifier).fetchAllOrders();
    if (mounted) setState(() => _reloading = false);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(adminOrdersProvider);
    if (!state.isLoading && state.currentPage < state.totalPages) {
      ref
          .read(adminOrdersProvider.notifier)
          .fetchAllOrders(page: state.currentPage + 1);
    }
  }

  Future<void> _changeStatus(Order order) async {
    final admin = ref.read(authProvider).user;
    if (admin == null) return;

    final statusOptions =
        OrderStatus.values.where((s) => s != order.status).toList();

    final chosen = await showModalBottomSheet<OrderStatus>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text('Update Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...statusOptions.map(
            (s) => ListTile(
              leading: StatusPill(status: s),
              title: Text(s.label),
              onTap: () => Navigator.pop(context, s),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (chosen == null) return;
    final err = await ref
        .read(adminOrdersProvider.notifier)
        .updateOrderStatus(order.id, chosen.toApiString(), admin.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Status updated to ${chosen.label}'),
        backgroundColor:
            err == null ? AppColors.statusCompleted : AppColors.error,
      ));
    }
  }

  Future<void> _deleteOrder(Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Order?'),
        content: Text(
            'Delete order #${order.id} — ${order.service}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm != true) return;

    final err =
        await ref.read(adminOrdersProvider.notifier).deleteOrder(order.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Order deleted'),
        backgroundColor: err == null ? AppColors.surface : AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'
            '${state.orders.isNotEmpty ? ' (${state.orders.length})' : ''}'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _reloading ? null : _reload,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _reloading
                  ? const SizedBox(
                      key: ValueKey('spin'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(
                      key: ValueKey('refresh'),
                      Icons.refresh_rounded,
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _reload,
          child: state.isLoading && state.orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.orders.isEmpty
                  ? const Center(
                      child: Text('No orders found',
                          style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      // +1 for bottom loader
                      itemCount: state.orders.length + 1,
                      itemBuilder: (ctx, i) {
                        // Last item = loading indicator or "all loaded"
                        if (i == state.orders.length) {
                          if (state.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (state.currentPage >= state.totalPages) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'All orders loaded',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSubtle),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final order = state.orders[i];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.userName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 4, left: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 12,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${order.userName} • ${order.userEmail ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            OrderCard(order: order, onRate: null),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                            color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(
                                          Icons.swap_horiz_rounded,
                                          size: 16),
                                      label: const Text('Status',
                                          style: TextStyle(fontSize: 12)),
                                      onPressed: () => _changeStatus(order),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _deleteOrder(order),
                                    child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
