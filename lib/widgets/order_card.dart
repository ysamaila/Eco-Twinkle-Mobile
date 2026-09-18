import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../core/theme.dart';
import 'order_detail_sheet.dart';

class OrderCard extends ConsumerWidget {
  final Order order;
  final VoidCallback? onRate;

  const OrderCard({super.key, required this.order, this.onRate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => OrderDetailSheet.show(context, order),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.service,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.item,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Meta(icon: Icons.calendar_today_outlined, label: order.date),
              const SizedBox(width: 16),
              _Meta(icon: Icons.access_time_outlined, label: order.time),
              const Spacer(),
              Text(
                order.price == 0
                    ? 'Contact for Quote'
                    : '₦${order.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ],
          ),
          if (order.discountApplied) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.local_offer_outlined,
                    size: 12, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  '10% loyalty discount applied',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (order.status == OrderStatus.completed && onRate != null) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onRate,
              child: Row(
                children: [
                  const Icon(Icons.star_outline_rounded,
                      size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'Rate this service',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  final OrderStatus status;
  const StatusPill({super.key, required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.approved:
        return AppColors.statusApproved;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
