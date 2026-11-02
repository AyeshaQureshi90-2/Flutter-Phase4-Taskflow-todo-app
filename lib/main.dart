
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101827),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8AB4F8),
          surface: Color(0xFF1C2738),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
