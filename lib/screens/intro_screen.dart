import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/intro/intro_bloc.dart';
import '../bloc/intro/intro_event.dart';
import '../bloc/intro/intro_state.dart';
import 'recording_screen.dart';
import 'questionnaire_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IntroBloc(),
      child: BlocListener<IntroBloc, IntroState>(
        listener: (context, state) {
          if (state is IntroNavigateToRecording) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RecordingScreen()),
            );
          } else if (state is IntroNavigateToQuestionnaire) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QuestionnaireScreen(),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Wine Quest'),
            backgroundColor: Colors.deepPurple[100],
            centerTitle: true,
          ),
          body: const _IntroScreenContent(),
        ),
      ),
    );
  }
}

class _IntroScreenContent extends StatelessWidget {
  const _IntroScreenContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[50]!, Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Do you have wine experience?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildOptionButton(
              context,
              'Yes',
              Icons.check_circle_outline,
              Colors.green,
              () {
                HapticFeedback.mediumImpact();
                context.read<IntroBloc>().add(IntroYesSelected());
              },
            ),
            const SizedBox(height: 20),
            _buildOptionButton(
              context,
              'No',
              Icons.help_outline,
              Colors.deepPurple,
              () {
                HapticFeedback.mediumImpact();
                context.read<IntroBloc>().add(IntroNoSelected());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5)),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
