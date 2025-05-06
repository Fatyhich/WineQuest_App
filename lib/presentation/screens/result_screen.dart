import 'package:flutter/material.dart';
import '../../data/models/job_models.dart';

class ResultScreen extends StatelessWidget {
  final JobResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Complete',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ResultCard(title: 'Text Analysis', content: result.mockLlmOutput),
            const SizedBox(height: 16),
            ResultCard(
              title: 'Your Text Input',
              content: result.textInput,
              isSecondary: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const SizedBox(
                width: double.infinity,
                child: Center(child: Text('Back to Home')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isSecondary;

  const ResultCard({
    super.key,
    required this.title,
    required this.content,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSecondary ? 1 : 3,
      color: isSecondary ? Colors.grey[100] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSecondary ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: isSecondary ? Colors.grey[700] : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: isSecondary ? 14 : 16,
                color: isSecondary ? Colors.grey[800] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
