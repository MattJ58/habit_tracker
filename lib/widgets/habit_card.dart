import 'package:flutter/cupertino.dart';

import '../models/habit.dart';
import 'glass_panel.dart';
import 'heatmap_grid.dart';

const _primaryTextColor = Color(0xFF111111);
const _secondaryTextColor = Color(0xFF6E6E73);

class HabitCard extends StatelessWidget {
  const HabitCard({required this.habit, required this.onLongPress, super.key});

  final Habit habit;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final currentStreak = _currentStreak(habit);

    return GestureDetector(
      onLongPress: onLongPress,
      child: GlassPanel(
        margin: const EdgeInsets.only(bottom: 16),
        borderRadius: 24,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        opacity: 0.56,
        blur: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _primaryTextColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const _HeatmapLegend(),
            const SizedBox(height: 12),
            HeatmapGrid(habit: habit),
            const SizedBox(height: 14),
            Text(
              currentStreak == 1
                  ? 'Streak di 1 giorno'
                  : 'Streak di $currentStreak giorni',
              style: const TextStyle(
                color: _secondaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapLegend extends StatelessWidget {
  const _HeatmapLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Ultime 4 settimane',
          style: TextStyle(
            color: _secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        _LegendDot(color: Color(0xFFF3F6F8)),
        SizedBox(width: 5),
        _LegendDot(color: Color(0xFFCFEBD6)),
        SizedBox(width: 5),
        _LegendDot(color: Color(0xFF99DAA8)),
        SizedBox(width: 5),
        _LegendDot(color: Color(0xFF63C77A)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const SizedBox(width: 11, height: 11),
    );
  }
}

int _currentStreak(Habit habit) {
  var streak = 0;
  final today = DateTime.now();
  var cursor = DateTime(today.year, today.month, today.day);

  while (habit.completionsFor(cursor) >= habit.requiredCompletionsPerDay) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return streak;
}
