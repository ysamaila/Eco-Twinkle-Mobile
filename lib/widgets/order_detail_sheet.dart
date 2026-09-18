import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../core/theme.dart';
import '../providers/orders_provider.dart';
import 'order_card.dart' show StatusPill;

class OrderDetailSheet extends ConsumerStatefulWidget {
  final Order initialOrder;

  const OrderDetailSheet({super.key, required this.initialOrder});

  static Future<void> show(BuildContext context, Order order) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailSheet(initialOrder: order),
    );
  }

  @override
  ConsumerState<OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends ConsumerState<OrderDetailSheet> {
  Order? _fullOrder;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final order = await ref
        .read(ordersProvider.notifier)
        .fetchOrderById(widget.initialOrder.id);
    if (mounted) {
      setState(() {
        _fullOrder = order ?? widget.initialOrder;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _fullOrder ?? widget.initialOrder;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      StatusPill(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else ...[
                    // Order Details
                    _SectionHeader(title: 'Order Details', icon: Icons.receipt_long_rounded),
                    _InfoRow(label: 'Service', value: order.service),
                    _InfoRow(label: 'Item', value: order.item),
                    _InfoRow(label: 'Date', value: order.date),
                    _InfoRow(label: 'Time', value: order.time),
                    _InfoRow(
                      label: 'Price',
                      value: order.price == 0 ? 'Quote Pending' : '₦${order.price.toStringAsFixed(2)}',
                      valueColor: AppColors.primary,
                      isBold: true,
                    ),
                    if (order.discountApplied)
                      const _InfoRow(
                        label: 'Discount',
                        value: 'Loyalty applied',
                        valueColor: AppColors.gold,
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Customer Details (if present)
                    if (order.user != null) ...[
                      _SectionHeader(title: 'Customer', icon: Icons.person_outline_rounded),
                      _UserBlock(user: order.user!),
                      const SizedBox(height: 24),
                    ],

                    // Admin Actions
                    if (order.approvedBy != null || order.completedBy != null) ...[
                      _SectionHeader(title: 'Admin Activity', icon: Icons.admin_panel_settings_outlined),
                      if (order.approvedBy != null) ...[
                        _InfoRow(label: 'Approved By', value: order.approvedBy!.fullName),
                      ],
                      if (order.completedBy != null) ...[
                        _InfoRow(label: 'Completed By', value: order.completedBy!.fullName),
                      ],
                      const SizedBox(height: 24),
                    ],

                    // Receipt Info
                    if (order.receiptUrl != null || order.generatedReceiptPath != null) ...[
                      _SectionHeader(title: 'Documents', icon: Icons.folder_open_rounded),
                      if (order.receiptUrl != null)
                        const _InfoRow(label: 'Uploaded File', value: 'Attached Image'),
                      if (order.generatedReceiptPath != null)
                        const _InfoRow(label: 'Invoice', value: 'Generated PDF'),
                      const SizedBox(height: 24),
                    ],

                    _InfoRow(
                      label: 'Created At',
                      value: DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt),
                      valueColor: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSubtle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserBlock extends StatelessWidget {
  final User user;
  const _UserBlock({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              if (user.whatsappNumber?.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(
                  user.whatsappNumber!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
