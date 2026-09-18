import 'package:flutter/material.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDailyActivity(),
                  _buildQuickActions(),
                  _buildUpcomingClasses(),
                  _buildChallenge(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Profile avatar with ring
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0B5FBF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text('AR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                const Text('Alex Rivera',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              ],
            ),
          ),
          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Daily Activity ────────────────────────────────────────────────────
  Widget _buildDailyActivity() {
    final stats = [
      (Icons.directions_run_rounded, AppColors.primary, 'Steps', '8,432', '+12%'),
      (Icons.local_fire_department_rounded, const Color(0xFFFF9F43), 'Calories', '450', '+5%'),
      (Icons.timer_rounded, AppColors.accent, 'Active', '45m', '+10%'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Activity',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('View Trends',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: stats.map((s) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: s == stats.last ? 0 : 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(s.$1, color: s.$2, size: 20),
                      const SizedBox(height: 8),
                      Text(s.$3.toUpperCase(),
                          style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                      const SizedBox(height: 2),
                      Text(s.$4, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(s.$5,
                          style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.event_available_rounded,
                  label: 'Book Class',
                  background: AppColors.primary.withOpacity(0.12),
                  border: AppColors.primary.withOpacity(0.3),
                  iconBg: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionBtn(
                  icon: Icons.play_arrow_rounded,
                  label: 'Start Plan',
                  background: AppColors.accent.withOpacity(0.12),
                  border: AppColors.accent.withOpacity(0.3),
                  iconBg: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upcoming Classes ──────────────────────────────────────────────────
  Widget _buildUpcomingClasses() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Classes',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('See All',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        SizedBox(
          height: 210,
          child: ListView(
            padding: const EdgeInsets.only(left: 16, right: 8),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: const [
              _ClassCard(
                imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
                tag: 'Today',
                tagColor: AppColors.accent,
                tagTextColor: Colors.black,
                title: 'HIIT & Strength',
                time: '5:30 PM',
                coach: 'Coach Sarah',
              ),
              SizedBox(width: 12),
              _ClassCard(
                imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&q=80',
                tag: 'Tomorrow',
                tagColor: AppColors.primary,
                tagTextColor: Colors.white,
                title: 'Zen Flow Yoga',
                time: '7:00 AM',
                coach: 'Marcus T.',
              ),
              SizedBox(width: 12),
              _ClassCard(
                imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80',
                tag: 'Wed',
                tagColor: Color(0xFFFF9F43),
                tagTextColor: Colors.black,
                title: 'Spin Cycle',
                time: '6:00 AM',
                coach: 'Coach Jamie',
              ),
              SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ── Challenge ─────────────────────────────────────────────────────────
  Widget _buildChallenge() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF0B4EBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Challenge!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('30 Days of Power',
                        style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: 0.65,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('12/20 Workouts completed',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Continue',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Button ────────────────────────────────────────────────────

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color border;
  final Color iconBg;
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.background,
    required this.border,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ── Class Card ─────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String title;
  final String time;
  final String coach;
  const _ClassCard({
    required this.imageUrl,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.title,
    required this.time,
    required this.coach,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceLight,
                      child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
                    ),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.surface],
                      ),
                    ),
                  ),
                  // Tag badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tag.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: tagTextColor)),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(time,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(width: 12),
                      const Icon(Icons.person_outline, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(coach,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
