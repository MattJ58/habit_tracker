import 'package:flutter_test/flutter_test.dart';
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
}
