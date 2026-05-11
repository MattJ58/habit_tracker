import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../models/habit.dart';
import '../services/habit_storage_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/habit_card.dart';
import '../widgets/liquid_background.dart';

const _primaryTextColor = Color(0xFF111111);
const _secondaryTextColor = Color(0xFF6E6E73);
const _accentColor = Color(0xFF007AFF);
const _softGreen = Color(0xFF63C77A);

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitStorageService _storage = HabitStorageService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  int _selectedView = 0;
  DateTime _selectedTodayDate = _normalizeDate(DateTime.now());

  bool get _isDashboard => _selectedView == 0;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _storage.loadHabits();
    if (!mounted) {
      return;
    }
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _persist(List<Habit> habits) async {
    setState(() => _habits = habits);
    await _storage.saveHabits(habits);
  }

  Future<void> _addHabit(String title, int requiredCompletionsPerDay) async {
    final habit = Habit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      requiredCompletionsPerDay: requiredCompletionsPerDay,
      completions: {},
    );
    await _persist([..._habits, habit]);
  }

  Future<void> _incrementHabitOnDate(Habit habit, DateTime date) async {
    final updatedHabits = [
      for (final existing in _habits)
        if (existing.id == habit.id) existing.incrementDay(date) else existing,
    ];
    await _persist(updatedHabits);
  }

  Future<void> _decrementHabitOnDate(Habit habit, DateTime date) async {
    final updatedHabits = [
      for (final existing in _habits)
        if (existing.id == habit.id) existing.decrementDay(date) else existing,
    ];
    await _persist(updatedHabits);
  }

  void _goToPreviousTodayDate() {
    setState(() {
      _selectedTodayDate = _selectedTodayDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextTodayDate() {
    if (_isSameDay(_selectedTodayDate, DateTime.now())) {
      return;
    }
    setState(() {
      _selectedTodayDate = _selectedTodayDate.add(const Duration(days: 1));
    });
  }

  Future<void> _deleteHabit(Habit habit) async {
    final updatedHabits = [
      for (final existing in _habits)
        if (existing.id != habit.id) existing,
    ];
    await _persist(updatedHabits);
  }

  Future<void> _confirmDeleteHabit(Habit habit) async {
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: const Color(0xFF000000).withValues(alpha: 0.18),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: CupertinoActionSheet(
            title: Text('Eliminare "${habit.title}"?'),
            message: const Text('Questa habit verra rimossa definitivamente.'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteHabit(habit);
                },
                child: const Text('Elimina habit'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      child: LiquidBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
                      child: _Header(
                        habitCount: _habits.length,
                        isDashboard: _isDashboard,
                        selectedDate: _selectedTodayDate,
                        onPreviousDay: _goToPreviousTodayDate,
                        onNextDay: _goToNextTodayDate,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 13),
                      ),
                    )
                  else if (_habits.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 158),
                        child: Center(child: _EmptyState(onAdd: _showAddSheet)),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          key: ValueKey(_selectedView),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 158),
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < _habits.length;
                                index++
                              )
                                _HabitListItem(
                                  habit: _habits[index],
                                  index: index,
                                  isDashboard: _isDashboard,
                                  onDelete: () => _deleteHabit(_habits[index]),
                                  onConfirmDelete: () =>
                                      _confirmDeleteHabit(_habits[index]),
                                  onIncrementToday: () =>
                                      _incrementHabitOnDate(
                                        _habits[index],
                                        _selectedTodayDate,
                                      ),
                                  onDecrementToday: () =>
                                      _decrementHabitOnDate(
                                        _habits[index],
                                        _selectedTodayDate,
                                      ),
                                  selectedDate: _selectedTodayDate,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                right: 22,
                bottom: 124,
                child: _AddHabitButton(onPressed: _showAddSheet),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: _ViewSwitcher(
                    selectedView: _selectedView,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedView = value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSheet() async {
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: const Color(0xFF000000).withValues(alpha: 0.18),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: _AddHabitSheet(onSubmit: _addHabit),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.habitCount,
    required this.isDashboard,
    required this.selectedDate,
    required this.onPreviousDay,
    required this.onNextDay,
  });

  final int habitCount;
  final bool isDashboard;
  final DateTime selectedDate;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;

  @override
  Widget build(BuildContext context) {
    final canGoNext = !_isSameDay(selectedDate, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isDashboard
          ? [
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                habitCount == 1 ? '1 habit' : '$habitCount habits',
                style: const TextStyle(
                  color: _secondaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]
          : [
              const Text(
                'Habit Tracker',
                style: TextStyle(
                  color: _primaryTextColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _DayNavButton(
                        icon: CupertinoIcons.chevron_left,
                        onPressed: onPreviousDay,
                        isEnabled: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 118,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${selectedDate.day}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _primaryTextColor,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _todayDateLabel(selectedDate),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _DayNavButton(
                        icon: CupertinoIcons.chevron_right,
                        onPressed: onNextDay,
                        isEnabled: canGoNext,
                      ),
                    ),
                  ),
                ],
              ),
            ],
    );
  }
}

class _DayNavButton extends StatelessWidget {
  const _DayNavButton({
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isEnabled ? 1 : 0.34,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.46),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.7),
                ),
              ),
              child: Icon(icon, color: _primaryTextColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

String _monthName(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[date.month - 1];
}

String _todayDateLabel(DateTime date) {
  final label = '${_monthName(date)} ${date.year}';
  if (_isSameDay(date, DateTime.now())) {
    return '$label  today';
  }
  return label;
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.selectedView, required this.onChanged});

  final int selectedView;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 76,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.54),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF30415E).withValues(alpha: 0.12),
                    blurRadius: 36,
                    spreadRadius: -8,
                    offset: const Offset(0, 22),
                  ),
                  BoxShadow(
                    color: CupertinoColors.white.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 2;

                  return Stack(
                    children: [
                      AnimatedAlign(
                        alignment: selectedView == 0
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        child: _ActiveNavPill(width: itemWidth),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              icon: CupertinoIcons.chart_bar_alt_fill,
                              label: 'Dashboard',
                              isActive: selectedView == 0,
                              onTap: () => onChanged(0),
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: CupertinoIcons.today_fill,
                              label: 'Today',
                              isActive: selectedView == 1,
                              onTap: () => onChanged(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveNavPill extends StatelessWidget {
  const _ActiveNavPill({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.white.withValues(alpha: 0.28),
            CupertinoColors.white.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30415E).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xAD111111)
        : const Color(0xAD6E6E73);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.06 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitListItem extends StatelessWidget {
  const _HabitListItem({
    required this.habit,
    required this.index,
    required this.isDashboard,
    required this.selectedDate,
    required this.onDelete,
    required this.onConfirmDelete,
    required this.onIncrementToday,
    required this.onDecrementToday,
  });

  final Habit habit;
  final int index;
  final bool isDashboard;
  final DateTime selectedDate;
  final VoidCallback onDelete;
  final VoidCallback onConfirmDelete;
  final VoidCallback onIncrementToday;
  final VoidCallback onDecrementToday;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + index * 35),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: ValueKey(
          '${isDashboard ? 'dashboard' : dateKey(selectedDate)}-${habit.id}',
        ),
        direction: DismissDirection.endToStart,
        resizeDuration: const Duration(milliseconds: 220),
        movementDuration: const Duration(milliseconds: 220),
        background: const SizedBox.shrink(),
        secondaryBackground: const _DeleteBackground(),
        onDismissed: (_) => onDelete(),
        child: isDashboard
            ? HabitCard(habit: habit, onLongPress: onConfirmDelete)
            : _TodayHabitTile(
                habit: habit,
                selectedDate: selectedDate,
                onIncrement: onIncrementToday,
                onDecrement: onDecrementToday,
                onLongPress: onConfirmDelete,
              ),
      ),
    );
  }
}

class _TodayHabitTile extends StatefulWidget {
  const _TodayHabitTile({
    required this.habit,
    required this.selectedDate,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
  });

  final Habit habit;
  final DateTime selectedDate;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  @override
  State<_TodayHabitTile> createState() => _TodayHabitTileState();
}

class _TodayHabitTileState extends State<_TodayHabitTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.habit.completionsFor(widget.selectedDate);
    final required = widget.habit.requiredCompletionsPerDay;
    final progress = widget.habit.progressFor(widget.selectedDate);
    final isComplete = progress >= 1;

    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTapDown: isComplete ? null : (_) => setState(() => _pressed = true),
      onTapCancel: isComplete ? null : () => setState(() => _pressed = false),
      onTapUp: isComplete ? null : (_) => setState(() => _pressed = false),
      onTap: isComplete ? null : widget.onIncrement,
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: GlassPanel(
          margin: const EdgeInsets.only(bottom: 14),
          borderRadius: 24,
          padding: const EdgeInsets.all(18),
          opacity: 0.56,
          blur: 30,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primaryTextColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count / $required',
                      style: TextStyle(
                        color: isComplete
                            ? const Color(0xFF2F7D46)
                            : _secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProgressBar(progress: progress),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Column(
                children: [
                  _IncrementButton(isComplete: isComplete),
                  const SizedBox(height: 8),
                  _DecrementButton(
                    isEnabled: count > 0,
                    onPressed: widget.onDecrement,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.56),
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0, 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: 8,
              decoration: const BoxDecoration(color: _softGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncrementButton extends StatelessWidget {
  const _IncrementButton({required this.isComplete});

  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final buttonColor = isComplete ? _softGreen : const Color(0xFF111111);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: buttonColor.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: CupertinoColors.white.withValues(alpha: 0.14),
            blurRadius: 9,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  buttonColor.withValues(alpha: isComplete ? 0.76 : 0.82),
                  buttonColor.withValues(alpha: isComplete ? 0.52 : 0.62),
                ],
              ),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.36),
              ),
            ),
            child: Icon(
              isComplete ? CupertinoIcons.check_mark : CupertinoIcons.add,
              color: CupertinoColors.white,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}

class _DecrementButton extends StatefulWidget {
  const _DecrementButton({required this.isEnabled, required this.onPressed});

  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  State<_DecrementButton> createState() => _DecrementButtonState();
}

class _DecrementButtonState extends State<_DecrementButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.isEnabled ? widget.onPressed : () {},
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF111111).withValues(
                  alpha: widget.isEnabled ? 0.1 : 0.04,
                ),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(
                    alpha: widget.isEnabled ? 0.48 : 0.24,
                  ),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(
                      alpha: widget.isEnabled ? 0.76 : 0.46,
                    ),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.minus,
                  color: widget.isEnabled
                      ? _primaryTextColor
                      : _secondaryTextColor.withValues(alpha: 0.48),
                  size: 19,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddHabitButton extends StatefulWidget {
  const _AddHabitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddHabitButton> createState() => _AddHabitButtonState();
}

class _AddHabitButtonState extends State<_AddHabitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.91 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF111111).withValues(alpha: 0.24),
                blurRadius: 30,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: const Color(0xFF8AB89B).withValues(alpha: 0.16),
                blurRadius: 26,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF111111).withValues(alpha: 0.9),
                      const Color(0xFF111111).withValues(alpha: 0.72),
                    ],
                  ),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.26),
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  const _AddHabitSheet({required this.onSubmit});

  final Future<void> Function(String title, int requiredCompletionsPerDay)
  onSubmit;

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final TextEditingController _titleController = TextEditingController();
  int _requiredCompletions = 1;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canSubmit = _titleController.text.trim().isNotEmpty && !_isSaving;

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CupertinoColors.white.withValues(alpha: 0.68),
                    CupertinoColors.white.withValues(alpha: 0.5),
                    CupertinoColors.white.withValues(alpha: 0.34),
                  ],
                ),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.72),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF30415E).withValues(alpha: 0.16),
                    blurRadius: 42,
                    spreadRadius: -10,
                    offset: const Offset(0, -18),
                  ),
                  BoxShadow(
                    color: CupertinoColors.white.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E8E93).withValues(
                              alpha: 0.28,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Nuovo habit',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SheetField(
                        child: CupertinoTextField.borderless(
                          controller: _titleController,
                          autofocus: true,
                          placeholder: 'Titolo',
                          placeholderStyle: const TextStyle(
                            color: Color(0xFF8E8E93),
                          ),
                          style: const TextStyle(
                            color: _primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SheetField(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Completamenti giornalieri',
                              style: TextStyle(
                                color: _secondaryTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CupertinoSlidingSegmentedControl<int>(
                              groupValue: _requiredCompletions,
                              backgroundColor: CupertinoColors.white.withValues(
                                alpha: 0.32,
                              ),
                              thumbColor: CupertinoColors.white.withValues(
                                alpha: 0.74,
                              ),
                              children: {
                                for (var value = 1; value <= 5; value++)
                                  value: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      '$value',
                                      style: TextStyle(
                                        color: value == _requiredCompletions
                                            ? _primaryTextColor
                                            : _secondaryTextColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              },
                              onValueChanged: (value) {
                                if (value != null) {
                                  setState(() => _requiredCompletions = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: canSubmit ? 1 : 0.44,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(
                                        0xFF111111,
                                      ).withValues(alpha: 0.88),
                                      const Color(
                                        0xFF111111,
                                      ).withValues(alpha: 0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: CupertinoColors.white.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF111111,
                                      ).withValues(alpha: 0.18),
                                      blurRadius: 24,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: CupertinoButton(
                                  borderRadius: BorderRadius.circular(18),
                                  color: CupertinoColors.transparent,
                                  disabledColor: CupertinoColors.transparent,
                                  onPressed: canSubmit ? _submit : null,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: _isSaving
                                      ? const CupertinoActivityIndicator(
                                          color: CupertinoColors.white,
                                        )
                                      : const Text(
                                          'Aggiungi',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSubmit(title, _requiredCompletions);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.white.withValues(alpha: 0.5),
            CupertinoColors.white.withValues(alpha: 0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.62),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30415E).withValues(alpha: 0.06),
            blurRadius: 18,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      opacity: 0.64,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.white.withValues(alpha: 0.7),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.8),
              ),
            ),
            child: const Icon(
              CupertinoIcons.check_mark_circled,
              color: _accentColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nessun habit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aggiungi una routine e traccia i progressi degli ultimi giorni.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          CupertinoButton(
            borderRadius: BorderRadius.circular(18),
            color: _primaryTextColor,
            onPressed: onAdd,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: const Text(
              'Aggiungi habit',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30).withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.38),
              ),
            ),
            child: const Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
