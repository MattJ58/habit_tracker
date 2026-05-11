import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitStorageService {
  static const _habitsKey = 'habits';

  Future<List<Habit>> loadHabits() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_habitsKey);

    if (saved == null || saved.isEmpty) {
      return [];
    }

    try {
      return Habit.decodeList(saved);
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_habitsKey, Habit.encodeList(habits));
  }
}
