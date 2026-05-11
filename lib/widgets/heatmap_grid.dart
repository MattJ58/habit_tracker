import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/habit.dart';

const _emptyCellColor = Color(0xFFF3F6F8);
const _completeCellColor = Color(0xFF63C77A);
const _emptyBorderColor = Color(0xFFE1E8EE);
const _completeBorderColor = Color(0xFF55B66B);

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({required this.habit, super.key});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final days = _recentDays();

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 10;
        const gap = 7.0;
        final cellSize = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final day in days)
              _HeatmapCell(
                day: day,
                size: cellSize,
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

class _HeatmapCell extends StatefulWidget {
  const _HeatmapCell({
    required this.day,
    required this.size,
    required this.progress,
    required this.count,
    required this.requiredCount,
  });

  final DateTime day;
  final double size;
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
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _borderColorFor(widget.progress)),
                    boxShadow: widget.progress > 0
                        ? [
                            BoxShadow(
                              color: _completeCellColor.withValues(
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
    return Color.lerp(_emptyCellColor, _completeCellColor, amount)!;
  }

  Color _borderColorFor(double progress) {
    final amount = progress.clamp(0, 1).toDouble();
    return Color.lerp(_emptyBorderColor, _completeBorderColor, amount)!;
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
            color: const Color(0xFF111111).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.18),
            ),
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
