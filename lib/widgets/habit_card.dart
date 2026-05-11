import 'package:flutter/cupertino.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import 'glass_panel.dart';
import 'heatmap_grid.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({required this.habit, required this.onLongPress, super.key});

  final Habit habit;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final currentStreak = _currentStreak(habit);
    final today = DateTime.now();
    final todayProgress = habit.progressFor(
      DateTime(today.year, today.month, today.day),
    );
    final isComplete = todayProgress >= 1;

    return GestureDetector(
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: todayProgress.clamp(0, 1)),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return AnimatedScale(
            scale: isComplete ? 1.004 : 1,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: GlassPanel(
              margin: const EdgeInsets.only(bottom: AppLayout.cardSpacing),
              borderRadius: AppLayout.cardRadius,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              opacity: isComplete ? 0.66 : 0.62,
              blur: 32,
              shadowOpacity: 0.06 + animatedProgress * 0.025,
              shadowBlur: 28 + animatedProgress * 4,
              shadowOffset: const Offset(0, 16),
              borderOpacity: isComplete ? 0.74 : 0.68,
              child: child!,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      color: isComplete
                          ? AppColors.progressTextColor(1)
                          : AppColors.primaryText,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.12,
                    ),
                    child: Text(
                      habit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StreakBadge(currentStreak: currentStreak),
              ],
            ),
            const SizedBox(height: AppLayout.spacingMd),
            const _HeatmapLegend(),
            const SizedBox(height: 10),
            HeatmapGrid(habit: habit),
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
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Andamento 4 settimane',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _LegendDot(color: AppColors.zeroProgress),
        const SizedBox(width: 5),
        const _LegendDot(color: AppColors.partialSoft),
        const SizedBox(width: 5),
        const _LegendDot(color: AppColors.partial),
        const SizedBox(width: 5),
        const _LegendDot(color: AppColors.complete),
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

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.currentStreak});

  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final hasStreak = currentStreak > 0;
    final value = currentStreak == 1 ? '1 giorno' : '$currentStreak giorni';
    final foreground = hasStreak
        ? AppColors.streakText
        : AppColors.secondaryText.withValues(alpha: 0.72);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minWidth: 78, minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: hasStreak
            ? AppColors.streakAccent.withValues(alpha: 0.12)
            : AppColors.glassWhite(0.34),
        borderRadius: BorderRadius.circular(15),
        border: hasStreak
            ? Border.all(color: AppColors.streakAccent.withValues(alpha: 0.18))
            : Border.all(color: AppColors.glassWhite(0.52)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: hasStreak
                      ? AppColors.streakAccent.withValues(alpha: 0.72)
                      : AppColors.secondaryText.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Streak',
                style: TextStyle(
                  color: foreground,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: foreground,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ],
      ),
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
