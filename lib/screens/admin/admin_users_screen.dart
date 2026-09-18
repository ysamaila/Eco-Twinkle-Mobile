import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
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
    await ref.read(adminUsersProvider.notifier).fetchUsers();
    if (mounted) setState(() => _reloading = false);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(adminUsersProvider);
    if (!state.isLoading && state.currentPage < state.totalPages) {
      ref
          .read(adminUsersProvider.notifier)
          .fetchUsers(page: state.currentPage + 1);
    }
  }

  Future<void> _editUser(User user) async {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final phoneCtrl = TextEditingController(text: user.whatsappNumber ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
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
            Text('Edit ${user.fullName}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstCtrl,
                    decoration:
                        const InputDecoration(labelText: 'First Name'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: lastCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Last Name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration:
                  const InputDecoration(labelText: 'WhatsApp Number'),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: Listenable.merge([firstCtrl, lastCtrl, phoneCtrl]),
              builder: (context, _) {
                final isValid = firstCtrl.text.trim().isNotEmpty &&
                    lastCtrl.text.trim().isNotEmpty &&
                    phoneCtrl.text.trim().isNotEmpty;
                
                return ElevatedButton(
                  onPressed: !isValid ? null : () async {
                    final err = await ref
                        .read(adminUsersProvider.notifier)
                        .updateUser(user.id, {
                      'firstName': firstCtrl.text.trim(),
                      'lastName': lastCtrl.text.trim(),
                      'whatsappNumber': phoneCtrl.text.trim(),
                    });
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err ?? 'User updated!'),
                        backgroundColor: err == null
                            ? AppColors.statusCompleted
                            : AppColors.error,
                      ));
                    }
                  },
                  child: const Text('Save Changes'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete User?'),
        content: Text('Delete ${user.fullName}? This cannot be undone.'),
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
        await ref.read(adminUsersProvider.notifier).deleteUser(user.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'User deleted'),
        backgroundColor: err == null ? AppColors.surface : AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'
            '${state.users.isNotEmpty ? ' (${state.users.length})' : ''}'),
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
          child: state.isLoading && state.users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.users.isEmpty
                  ? const Center(
                      child: Text('No users found',
                          style: TextStyle(color: AppColors.textMuted)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.users.length + 1,
                      itemBuilder: (ctx, i) {
                        // Last item = loading/all-done indicator
                        if (i == state.users.length) {
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
                                  'All users loaded',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSubtle),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }

                        final user = state.users[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: AppTheme.glassCard(),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: user.isAdmin
                                      ? AppColors.statusApproved
                                          .withValues(alpha: 0.2)
                                      : AppColors.primary
                                          .withValues(alpha: 0.12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${user.firstName[0]}${user.lastName[0]}'
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: user.isAdmin
                                          ? AppColors.statusApproved
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(user.fullName,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(user.email,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        _Pill(
                                          label: user.role,
                                          color: user.isAdmin
                                              ? AppColors.statusApproved
                                              : AppColors.primary,
                                        ),
                                        _Pill(
                                          label: user.status,
                                          color: user.isActive
                                              ? AppColors.statusCompleted
                                              : AppColors.statusPending,
                                        ),
                                        _Pill(
                                          label: '${user.points} pts',
                                          color: AppColors.gold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        color: AppColors.primary, size: 18),
                                    onPressed: () => _editUser(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: AppColors.error,
                                        size: 18),
                                    onPressed: () => _deleteUser(user),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
