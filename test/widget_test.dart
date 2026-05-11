import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('renders the habit tracker home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Habit Tracker'), findsOneWidget);
    expect(find.text('Nessun habit'), findsOneWidget);
    expect(find.text('Aggiungi habit'), findsAtLeastNWidgets(1));
  });

  testWidgets('dashboard fits common phone layouts', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final todayKey = dateKey(today);
    final yesterdayKey = dateKey(today.subtract(const Duration(days: 1)));
    final habits = [
      Habit(
        id: 'water',
        title: 'Bevi acqua',
        requiredCompletionsPerDay: 2,
        completions: {todayKey: 2, yesterdayKey: 2},
      ),
      Habit(
        id: 'reading',
        title: 'Leggi',
        requiredCompletionsPerDay: 1,
        completions: {yesterdayKey: 1},
      ),
    ];

    for (final size in const [Size(393, 852), Size(412, 915)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      SharedPreferences.setMockInitialValues({
        'habits': Habit.encodeList(habits),
      });

      await tester.pumpWidget(const HabitTrackerApp());
      await tester.pumpAndSettle();

      expect(find.text('Ultime 4 settimane'), findsOneWidget);
      expect(find.text('Andamento 4 settimane'), findsNWidgets(habits.length));
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('today fits common phone layouts', (WidgetTester tester) async {
    final today = DateTime.now();
    final todayKey = dateKey(today);
    final habits = [
      Habit(
        id: 'water',
        title: 'Bevi acqua',
        requiredCompletionsPerDay: 2,
        completions: {todayKey: 1},
      ),
      Habit(
        id: 'reading',
        title: 'Leggi',
        requiredCompletionsPerDay: 1,
        completions: {todayKey: 1},
      ),
      Habit(
        id: 'walk',
        title: 'Cammina',
        requiredCompletionsPerDay: 1,
        completions: {},
      ),
    ];

    for (final size in const [Size(393, 852), Size(412, 915)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      SharedPreferences.setMockInitialValues({
        'habits': Habit.encodeList(habits),
      });

      await tester.pumpWidget(const HabitTrackerApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Oggi'), findsOneWidget);
      expect(find.text('Parziale 1 / 2'), findsOneWidget);
      expect(find.text('Completato'), findsOneWidget);
      expect(find.text('Da iniziare'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
