import 'package:flutter/material.dart';
import '../theme.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workouts',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Choose your training plan',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Strength', 'Cardio', 'HIIT', 'Yoga', 'Mobility']
                      .asMap()
                      .entries
                      .map((e) => _FilterChip(label: e.value, selected: e.key == 0))
                      .toList(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _workouts.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WorkoutCard(data: w),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _WkData {
  final String title;
  final String category;
  final String duration;
  final String level;
  final Color color;
  final IconData icon;
  final int exercises;
  const _WkData({
    required this.title,
    required this.category,
    required this.duration,
    required this.level,
    required this.color,
    required this.icon,
    required this.exercises,
  });
}

const _workouts = [
  _WkData(
    title: 'Full Body Blast',
    category: 'Strength',
    duration: '45 min',
    level: 'Intermediate',
    color: AppColors.primary,
    icon: Icons.fitness_center_rounded,
    exercises: 8,
  ),
  _WkData(
    title: 'Morning Cardio',
    category: 'Cardio',
    duration: '30 min',
    level: 'Beginner',
    color: Color(0xFFFF9F43),
    icon: Icons.directions_run_rounded,
    exercises: 5,
  ),
  _WkData(
    title: 'HIIT Power',
    category: 'HIIT',
    duration: '25 min',
    level: 'Advanced',
    color: Color(0xFFFF5A5F),
    icon: Icons.bolt_rounded,
    exercises: 10,
  ),
  _WkData(
    title: 'Core & Abs',
    category: 'Strength',
    duration: '20 min',
    level: 'Beginner',
    color: AppColors.accent,
    icon: Icons.accessibility_new_rounded,
    exercises: 6,
  ),
  _WkData(
    title: 'Zen Flow Yoga',
    category: 'Yoga',
    duration: '50 min',
    level: 'All Levels',
    color: Color(0xFFAB47BC),
    icon: Icons.self_improvement_rounded,
    exercises: 12,
  ),
  _WkData(
    title: 'Upper Body Focus',
    category: 'Strength',
    duration: '40 min',
    level: 'Intermediate',
    color: Color(0xFF5F7ADB),
    icon: Icons.sports_gymnastics_rounded,
    exercises: 7,
  ),
];

class _WorkoutCard extends StatelessWidget {
  final _WkData data;
  const _WorkoutCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Tag(label: data.category, color: data.color),
                    const SizedBox(width: 6),
                    _Tag(label: data.level, color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(data.duration, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 12),
                    Icon(Icons.format_list_numbered_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${data.exercises} exercises',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.play_arrow_rounded, color: data.color, size: 22),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
