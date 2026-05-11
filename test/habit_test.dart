import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  test('dateKey uses YYYY-MM-DD for local dates', () {
    expect(dateKey(DateTime(2026, 5, 6, 18, 45)), '2026-05-06');
    expect(dateKey(DateTime(2026, 1, 2)), '2026-01-02');
  });

  test('incrementDay stores real date keys and respects daily requirement', () {
    final day = DateTime(2026, 5, 6, 12);
    final habit = Habit(
      id: 'water',
      title: 'Water',
      requiredCompletionsPerDay: 2,
      completions: {},
    );

    final partial = habit.incrementDay(day);
    final complete = partial.incrementDay(day);
    final stillComplete = complete.incrementDay(day);

    expect(partial.completions, {'2026-05-06': 1});
    expect(complete.completions, {'2026-05-06': 2});
    expect(stillComplete.completions, {'2026-05-06': 2});
  });
}
