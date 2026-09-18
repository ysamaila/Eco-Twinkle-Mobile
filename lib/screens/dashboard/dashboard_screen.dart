import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/support_provider.dart';
import '../../widgets/order_card.dart';
import '../../widgets/points_card.dart';
import '../../widgets/star_rating.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _scrollCtrl = ScrollController();
  bool _reloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final ordersState = ref.read(ordersProvider);
    final user = ref.read(authProvider).user;
    if (!ordersState.isLoading &&
        ordersState.currentPage < ordersState.totalPages &&
        user != null) {
      ref
          .read(ordersProvider.notifier)
          .fetchUserOrders(user.id, page: ordersState.currentPage + 1);
    }
  }

  Future<void> _loadOrders() async {
    final user = ref.read(authProvider).user;
    if (user != null) {
      ref.read(supportProvider.notifier).fetchCustomerTickets();
      await ref.read(ordersProvider.notifier).fetchUserOrders(user.id);
    }
  }

  Future<void> _reload() async {
    setState(() => _reloading = true);
    await _loadOrders();
    if (mounted) {
      setState(() => _reloading = false);
    }
  }

  Future<void> _showRatingSheet(int orderId) async {
    int rating = 0;
    final commentCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Rate this service',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Center(
                child: StarRating(
                  initialRating: rating,
                  onRatingChanged: (r) => setModal(() => rating = r),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: rating == 0
                    ? null
                    : () async {
                        final err = await ref
                            .read(ordersProvider.notifier)
                            .submitReview(
                              orderId,
                              rating,
                              commentCtrl.text,
                            );
                        if (context.mounted) {
                          final nav = Navigator.of(ctx);
                          final scaf = ScaffoldMessenger.of(context);
                          nav.pop();
                          scaf.showSnackBar(
                            SnackBar(
                              content: Text(err ?? 'Review submitted!'),
                              backgroundColor: err == null
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                          );
                        }
                      },
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final ordersState = ref.watch(ordersProvider);
    final supportState = ref.watch(supportProvider);
    final user = auth.user;

    final hasUnreadSupport = supportState.tickets.any((t) {
      final isResolved = t.response != null && t.response!.isNotEmpty;
      final isNewOrUpdated = supportState.lastViewedAt == null ||
          t.updatedAt.isAfter(supportState.lastViewedAt!);
      return isResolved && isNewOrUpdated;
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _loadOrders(),
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // App bar
              SliverAppBar(
                pinned: true,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Text('Eco-Twinkle'),
                  ],
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.help_outline_rounded),
                        onPressed: () => context.push(AppConstants.support),
                      ),
                      if (hasUnreadSupport)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined),
                    onPressed: () => context.push(AppConstants.analytics),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded),
                    onPressed: () => context.push(AppConstants.profile),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () =>
                        ref.read(authProvider.notifier).logout(),
                  ),
                ],
              ),

              // Headers & Static Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        'Hello, ${user?.firstName ?? ''}! 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Manage your bookings below.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),

                      // Points card
                      if (user != null) ...[
                        PointsCard(points: user.points),
                        const SizedBox(height: 20),
                      ],

                      // Book a service button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            size: 18),
                        label: const Text('Book a Service'),
                        onPressed: () => context.push(AppConstants.book),
                      ),
                      const SizedBox(height: 28),

                      // Orders header
                      Row(
                        children: [
                          const Text('My Orders',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (ordersState.orders.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${ordersState.orders.length}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary),
                              ),
                            ),
                          const Spacer(),
                          // Animated reload button
                          GestureDetector(
                            onTap: _reloading ? null : _reload,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _reloading
                                  ? const SizedBox(
                                      key: ValueKey('loading'),
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary),
                                    )
                                  : const Icon(
                                      key: ValueKey('icon'),
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Orders List or Empty State
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildOrdersSliver(ordersState),
              ),

              // Bottom Spacer
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersSliver(OrdersState ordersState) {
    if (ordersState.isLoading && ordersState.orders.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading your orders…',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (ordersState.error != null && ordersState.orders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 48, color: AppColors.textSubtle),
                const SizedBox(height: 12),
                Text(
                  ordersState.error!,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (ordersState.orders.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 48, color: AppColors.textSubtle),
                const SizedBox(height: 12),
                const Text('No orders yet',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text(
                  'Book your first service above!',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= ordersState.orders.length) {
            return ordersState.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          final order = ordersState.orders[index];
          return OrderCard(
            order: order,
            onRate: order.status == OrderStatus.completed
                ? () => _showRatingSheet(order.id)
                : null,
          );
        },
        childCount: ordersState.orders.length + (ordersState.isLoading ? 1 : 0),
      ),
    );
  }
}
