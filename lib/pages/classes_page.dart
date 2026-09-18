import 'package:flutter/material.dart';
import '../theme.dart';

class ClassesPage extends StatefulWidget {
  const ClassesPage({super.key});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  int _selectedDay = 0;
  final days = ['Today', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
                  const Text('Classes',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Book your next session',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          // Day selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(days.length, (i) {
                    final sel = i == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _classes.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ClassListCard(data: c),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClsData {
  final String name;
  final String time;
  final String duration;
  final String coach;
  final String spots;
  final Color color;
  final IconData icon;
  final bool booked;
  const _ClsData({
    required this.name,
    required this.time,
    required this.duration,
    required this.coach,
    required this.spots,
    required this.color,
    required this.icon,
    this.booked = false,
  });
}

const _classes = [
  _ClsData(
    name: 'HIIT & Strength',
    time: '5:30 PM',
    duration: '45 min',
    coach: 'Coach Sarah',
    spots: '3 spots left',
    color: AppColors.primary,
    icon: Icons.bolt_rounded,
    booked: true,
  ),
  _ClsData(
    name: 'Zen Flow Yoga',
    time: '7:00 AM',
    duration: '60 min',
    coach: 'Marcus T.',
    spots: '8 spots left',
    color: Color(0xFFAB47BC),
    icon: Icons.self_improvement_rounded,
  ),
  _ClsData(
    name: 'Spin Cycle',
    time: '6:00 AM',
    duration: '45 min',
    coach: 'Coach Jamie',
    spots: '5 spots left',
    color: Color(0xFFFF9F43),
    icon: Icons.directions_bike_rounded,
  ),
  _ClsData(
    name: 'Core Crush',
    time: '12:00 PM',
    duration: '30 min',
    coach: 'Coach Ana',
    spots: '12 spots left',
    color: AppColors.accent,
    icon: Icons.accessibility_new_rounded,
  ),
  _ClsData(
    name: 'Boxing Basics',
    time: '6:30 PM',
    duration: '50 min',
    coach: 'Coach Ray',
    spots: '2 spots left',
    color: Color(0xFFFF5A5F),
    icon: Icons.sports_mma_rounded,
  ),
];

class _ClassListCard extends StatelessWidget {
  final _ClsData data;
  const _ClassListCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.booked
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.time.split(' ')[0],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text(data.time.split(' ')[1],
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.surfaceLight, margin: const EdgeInsets.symmetric(horizontal: 12)),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(data.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    if (data.booked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Booked',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.accent)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(data.coach,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(data.duration,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: data.color),
                        const SizedBox(width: 4),
                        Text(data.spots,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: data.color)),
                      ],
                    ),
                    if (!data.booked)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: data.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Book',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
