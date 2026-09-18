import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    int _tabIndex = 0;
    if (location == AppConstants.adminOrders) _tabIndex = 1;
    if (location == AppConstants.adminUsers) _tabIndex = 2;
    if (location == AppConstants.adminSupport) _tabIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Color(0xFF1A2B1A))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _AdminNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Overview',
                  selected: _tabIndex == 0,
                  onTap: () => context.go(AppConstants.adminOverview),
                ),
                _AdminNavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Orders',
                  selected: _tabIndex == 1,
                  onTap: () => context.go(AppConstants.adminOrders),
                ),
                _AdminNavItem(
                  icon: Icons.people_alt_rounded,
                  label: 'Users',
                  selected: _tabIndex == 2,
                  onTap: () => context.go(AppConstants.adminUsers),
                ),
                _AdminNavItem(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  selected: _tabIndex == 3,
                  onTap: () => context.go(AppConstants.adminSupport),
                ),
                _AdminNavItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  selected: false,
                  onTap: () => ref.read(authProvider.notifier).logout(),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (selected ? AppColors.primary : const Color(0xFF4A6A4A));
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: c)),
          ],
        ),
      ),
    );
  }
}
