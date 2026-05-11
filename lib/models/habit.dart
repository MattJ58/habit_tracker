import 'dart:convert';

class Habit {
  Habit({
    required this.id,
    required this.title,
    required this.requiredCompletionsPerDay,
    required this.completions,
  });

  final String id;
  final String title;
  final int requiredCompletionsPerDay;
  final Map<String, int> completions;

  Habit copyWith({
    String? id,
    String? title,
    int? requiredCompletionsPerDay,
    Map<String, int>? completions,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      requiredCompletionsPerDay:
          requiredCompletionsPerDay ?? this.requiredCompletionsPerDay,
      completions: completions ?? Map<String, int>.from(this.completions),
    );
  }

  int completionsFor(DateTime date) => completions[dateKey(date)] ?? 0;

  double progressFor(DateTime date) {
    if (requiredCompletionsPerDay <= 0) {
      return 0;
    }
    return (completionsFor(date) / requiredCompletionsPerDay)
        .clamp(0, 1)
        .toDouble();
  }

  Habit incrementDay(DateTime date) {
    final key = dateKey(date);
    final nextCompletions = Map<String, int>.from(completions);
    final current = nextCompletions[key] ?? 0;
    final next = (current + 1).clamp(0, requiredCompletionsPerDay);

    if (next == 0) {
      nextCompletions.remove(key);
    } else {
      nextCompletions[key] = next;
    }

    return copyWith(completions: nextCompletions);
  }

  Habit decrementDay(DateTime date) {
    final key = dateKey(date);
    final nextCompletions = Map<String, int>.from(completions);
    final current = nextCompletions[key] ?? 0;
    final next = (current - 1).clamp(0, requiredCompletionsPerDay);

    if (next == 0) {
      nextCompletions.remove(key);
    } else {
      nextCompletions[key] = next;
    }

    return copyWith(completions: nextCompletions);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requiredCompletionsPerDay': requiredCompletionsPerDay,
      'completions': completions,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      requiredCompletionsPerDay: json['requiredCompletionsPerDay'] as int,
      completions: (json['completions'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  static String encodeList(List<Habit> habits) {
    return jsonEncode(habits.map((habit) => habit.toJson()).toList());
  }

  static List<Habit> decodeList(String source) {
    final jsonList = jsonDecode(source) as List<dynamic>;
    return jsonList
        .map((item) => Habit.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

String dateKey(DateTime date) {
  final local = DateTime(date.year, date.month, date.day);
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
