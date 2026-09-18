import 'package:flutter/material.dart';
import '../theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      ('🔥', '7-Day Streak'),
      ('🏆', '1st Challenge'),
      ('💪', '50 Workouts'),
      ('⚡', 'HIIT Master'),
    ];
    final menuItems = [
      (Icons.edit_outlined, 'Edit Profile'),
      (Icons.notifications_outlined, 'Notifications'),
      (Icons.lock_outline_rounded, 'Privacy & Security'),
      (Icons.credit_card_outlined, 'Membership'),
      (Icons.help_outline_rounded, 'Help & Support'),
      (Icons.star_outline_rounded, 'Rate the App'),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Avatar + name
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF0B5FBF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('AR',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Alex Rivera',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('alex.rivera@gymapp.com',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Premium Member',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ),
            const SizedBox(height: 20),
            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ProfileStat(value: '24', label: 'Workouts'),
                  Container(width: 1, height: 36, color: AppColors.surfaceLight),
                  _ProfileStat(value: '11', label: 'Classes'),
                  Container(width: 1, height: 36, color: AppColors.surfaceLight),
                  _ProfileStat(value: '7', label: 'Day Streak'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Achievements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 6),
                      Text('Achievements',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: achievements.map((a) => _Achievement(emoji: a.$1, label: a.$2)).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: menuItems.asMap().entries.map((e) {
                  final isLast = e.key == menuItems.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(e.value.$1, color: AppColors.primary, size: 18),
                        ),
                        title: Text(e.value.$2,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
                        onTap: () {},
                      ),
                      if (!isLast)
                        Divider(height: 1, color: AppColors.surfaceLight, indent: 60),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Achievement extends StatelessWidget {
  final String emoji;
  final String label;
  const _Achievement({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ],
    );
  }
}
