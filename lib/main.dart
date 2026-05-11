import 'package:flutter/cupertino.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF007AFF),
        scaffoldBackgroundColor: Color(0xFFF5F5F7),
        barBackgroundColor: Color(0xF2F5F5F7),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF111111),
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            color: Color(0xFF111111),
            letterSpacing: 0,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
