import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'screens/intro_screen.dart'; // Kept for future use
import 'screens/recording_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      home: const RecordingScreen(),
    );
  }
}
