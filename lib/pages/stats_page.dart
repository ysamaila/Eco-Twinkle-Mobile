import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  int _selectedRange = 1; // 0=Week, 1=Month, 2=Year

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Statistics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Your performance overview',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            // Range toggles
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['Week', 'Month', 'Year'].asMap().entries.map((e) {
                  final sel = e.key == _selectedRange;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRange = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          e.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Circular progress highlight
            _RingStats(anim: _anim),
            const SizedBox(height: 20),
            // Weekly bar chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workouts / Week',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  SizedBox(height: 100, child: _AnimatedBars(anim: _anim)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Stats grid
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Total Workouts', value: '24', icon: Icons.fitness_center_rounded, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Calories Burned', value: '14,320', icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF9F43))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatTile(label: 'Active Minutes', value: '1,080', icon: Icons.timer_rounded, color: AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Classes Joined', value: '11', icon: Icons.groups_rounded, color: const Color(0xFFAB47BC))),
              ],
            ),
            const SizedBox(height: 14),
            // Personal bests
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Bests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  ...[
                    ('Bench Press', '85 kg', 0.85, AppColors.primary),
                    ('5K Run', '22:14 min', 0.72, const Color(0xFFFF9F43)),
                    ('Plank Hold', '3:45 min', 0.90, AppColors.accent),
                  ].map((pb) => _PBRow(label: pb.$1, value: pb.$2, pct: pb.$3, color: pb.$4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingStats extends StatelessWidget {
  final Animation<double> anim;
  const _RingStats({required this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: anim,
                  builder: (_, __) => SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _RingPainter(anim.value),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('78%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent)),
                            Text('Goal', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Monthly Goal', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _RingLegend(color: AppColors.accent, label: 'Completed', value: '18/23'),
                const SizedBox(height: 16),
                _RingLegend(color: AppColors.primary, label: 'Streak', value: '7 days 🔥'),
                const SizedBox(height: 16),
                _RingLegend(color: const Color(0xFFFF9F43), label: 'Level', value: 'Intermediate'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final bg = Paint()..color = AppColors.surfaceLight..style = PaintingStyle.stroke..strokeWidth = 14;
    final fg = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      2 * math.pi * 0.78 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _RingLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        )
      ],
    );
  }
}

class _AnimatedBars extends StatelessWidget {
  final Animation<double> anim;
  const _AnimatedBars({required this.anim});

  final values = const [0.4, 0.75, 0.6, 1.0, 0.55, 0.8, 0.3];
  final labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 80 * values[i] * anim.value,
                decoration: BoxDecoration(
                  color: i == 3 ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(labels[i], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          );
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PBRow extends StatelessWidget {
  final String label;
  final String value;
  final double pct;
  final Color color;
  const _PBRow({required this.label, required this.value, required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
