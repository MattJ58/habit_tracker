import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/habit.dart';
import '../theme/app_colors.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({required this.habit, super.key});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final days = _recentDays();

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 7;
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final gap = width < 320 ? 6.0 : 7.0;
        final cellSize = (width - gap * (columns - 1)) / columns;
        final today = _normalizeDate(DateTime.now());

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final day in days)
              _HeatmapCell(
                day: day,
                size: cellSize,
                isToday: _isSameDate(day, today),
                progress: habit.progressFor(day),
                count: habit.completionsFor(day),
                requiredCount: habit.requiredCompletionsPerDay,
              ),
          ],
        );
      },
    );
  }

  List<DateTime> _recentDays() {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final firstDay = normalizedToday.subtract(const Duration(days: 27));
    return List<DateTime>.generate(
      28,
      (index) => firstDay.add(Duration(days: index)),
    );
  }
}

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

class _HeatmapCell extends StatefulWidget {
  const _HeatmapCell({
    required this.day,
    required this.size,
    required this.isToday,
    required this.progress,
    required this.count,
    required this.requiredCount,
  });

  final DateTime day;
  final double size;
  final bool isToday;
  final double progress;
  final int count;
  final int requiredCount;

  @override
  State<_HeatmapCell> createState() => _HeatmapCellState();
}

class _HeatmapCellState extends State<_HeatmapCell> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final label =
        '${dateKey(widget.day)} - ${widget.count}/${widget.requiredCount} completamenti';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        label: label,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onLongPressStart: (_) => setState(() => _pressed = true),
              onLongPressEnd: (_) {
                setState(() => _pressed = false);
                _showDayDetails(context);
              },
              child: AnimatedScale(
                scale: _pressed ? 0.9 : 1,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: _colorFor(widget.progress),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _borderColorFor(widget.progress),
                      width: widget.isToday ? 1.5 : 1,
                    ),
                    boxShadow: widget.progress > 0
                        ? [
                            BoxShadow(
                              color: AppColors.progressColor(widget.progress)
                                  .withValues(
                                    alpha: 0.08 + widget.progress * 0.04,
                                  ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            if (_hovered)
              Positioned(
                bottom: widget.size + 8,
                child: _HoverBubble(
                  day: widget.day,
                  count: widget.count,
                  requiredCount: widget.requiredCount,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: const Color(0xFF000000).withValues(alpha: 0.12),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CupertinoActionSheet(
            title: Text(_readableDate(widget.day)),
            message: Text(
              '${widget.count}/${widget.requiredCount} completamenti',
            ),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ),
        );
      },
    );
  }

  Color _colorFor(double progress) {
    final amount = progress.clamp(0, 1).toDouble();
    if (amount == 0) {
      return AppColors.zeroProgress;
    }
    return Color.lerp(AppColors.partial, AppColors.complete, amount)!;
  }

  Color _borderColorFor(double progress) {
    if (widget.isToday && progress <= 0) {
      return AppColors.darkControl.withValues(alpha: 0.18);
    }
    return AppColors.progressBorderColor(progress);
  }
}

class _HoverBubble extends StatelessWidget {
  const _HoverBubble({
    required this.day,
    required this.count,
    required this.requiredCount,
  });

  final DateTime day;
  final int count;
  final int requiredCount;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.darkControl.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.glassWhite(0.18)),
          ),
          child: Text(
            '${dateKey(day)}  $count/$requiredCount',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

String _shortMonth(DateTime date) {
  const months = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic',
  ];
  return months[date.month - 1];
}

String _readableDate(DateTime date) {
  return '${date.day} ${_shortMonth(date)} ${date.year}';
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
