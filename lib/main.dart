import 'package:flutter/material.dart';
import 'screens/intro_screen.dart';

void main() {
  runApp(const WineQuestApp());
}

class WineQuestApp extends StatelessWidget {
  const WineQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntroScreen(),
    );
  }
}
