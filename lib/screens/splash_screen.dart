
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF8AB4F8),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 55,
                color: Color(0xFF101827),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TaskFlow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Organize your day, your way.',
              style: TextStyle(
                color: Color(0xFF8AB4F8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 35),
            const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Color(0xFF8AB4F8),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
