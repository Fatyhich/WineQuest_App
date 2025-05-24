import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording/recording_bloc.dart';
import '../bloc/recording/recording_event.dart';
import '../bloc/recording/recording_state.dart';
import 'result_screen.dart';
import '../widgets/loading_indicator.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordingBloc(),
      child: BlocListener<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingComplete) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => ResultScreen(responseText: state.responseText),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Запишите ваш опыт'),
            backgroundColor: Colors.deepPurple[100],
            centerTitle: true,
          ),
          body: const _RecordingScreenContent(),
        ),
      ),
    );
  }
}

class _RecordingScreenContent extends StatelessWidget {
  const _RecordingScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        if (state is RecordingSubmitting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Отправка записи...'),
              ],
            ),
          );
        } else if (state is RecordingProcessing ||
            state is RecordingSubmitted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: 16),
                Text(
                  state is RecordingProcessing && state.progress != null
                      ? 'Обработка: ${state.progress!.status}'
                      : 'Обработка вашего запроса...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is RecordingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RecordingBloc>().add(StartRecording());
                  },
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          );
        } else {
          return _buildRecordingUI(context, state);
        }
      },
    );
  }

  Widget _buildRecordingUI(BuildContext context, RecordingState state) {
    final isRecording = state is RecordingInProgress;
    final recordingReady = state is RecordingStopped && state.audioFile != null;

    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
          children: [
            Text(
              isRecording
                  ? 'Идет запись...'
                  : recordingReady
                  ? 'Запись завершена!'
                  : 'Запишите ваши винные предпочтения',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              isRecording
                  ? 'Нажмите кнопку, когда закончите'
                  : recordingReady
                  ? 'Нажмите отправить для обработки записи'
                  : 'Нажмите кнопку микрофона, чтобы начать запись ваших винных предпочтений и опыта',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            if (isRecording) _buildRecordingIndicator(),
            InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (isRecording) {
                  context.read<RecordingBloc>().add(StopRecording());
                } else if (!recordingReady) {
                  context.read<RecordingBloc>().add(StartRecording());
                }
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      isRecording
                          ? Colors.red
                          : Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isRecording ? Colors.red : Colors.deepPurple,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.white : Colors.deepPurple,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (recordingReady)
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.read<RecordingBloc>().add(
                    SubmitRecording(state.audioFile!),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Отправить запись',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Запись...',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
