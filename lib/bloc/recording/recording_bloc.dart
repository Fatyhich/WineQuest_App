import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../services/audio_service.dart';
import '../../services/api_service.dart';
import 'recording_event.dart';
import 'recording_state.dart';
import 'dart:convert';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  Timer? _pollingTimer;

  RecordingBloc() : super(RecordingInitial()) {
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<SubmitRecording>(_onSubmitRecording);
    on<CheckJobStatus>(_onCheckJobStatus);
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(RecordingInProgress());
      await _audioService.startRecording();
    } catch (e) {
      emit(RecordingError('Failed to start recording: $e'));
    }
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      final audioFile = await _audioService.stopRecording();
      emit(RecordingStopped(audioFile));
    } catch (e) {
      emit(RecordingError('Failed to stop recording: $e'));
    }
  }

  Future<void> _onSubmitRecording(
    SubmitRecording event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      emit(RecordingSubmitting());

      final response = await _apiService.sendAudioRecording(event.audioFile);

      emit(RecordingSubmitted(response.jobId));

      // Start polling for job status
      add(CheckJobStatus(response.jobId));
    } catch (e) {
      emit(RecordingError('Failed to submit recording: $e'));
    }
  }

  Future<void> _onCheckJobStatus(
    CheckJobStatus event,
    Emitter<RecordingState> emit,
  ) async {
    try {
      final status = await _apiService.checkJobStatus(event.jobId);

      if (status.status == 'completed') {
        // Convert the result object to a JSON string to pass to the result screen
        String jsonResponse = "";
        if (status.result != null) {
          jsonResponse = jsonEncode(status.result);
        }
        emit(RecordingComplete(jsonResponse));
      } else if (status.status == 'processing') {
        emit(RecordingProcessing(event.jobId, status.progress));

        // Schedule next check in 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        add(CheckJobStatus(event.jobId));
      } else if (status.status == 'failed') {
        emit(RecordingError('Processing failed: ${status.message}'));
      }
    } catch (e) {
      emit(RecordingError('Failed to check job status: $e'));
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _audioService.dispose();
    return super.close();
  }
}
