import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../models/api_response.dart';

abstract class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {}

class RecordingInProgress extends RecordingState {}

class RecordingStopped extends RecordingState {
  final File? audioFile;

  const RecordingStopped(this.audioFile);

  @override
  List<Object?> get props => [audioFile];
}

class RecordingSubmitting extends RecordingState {}

class RecordingSubmitted extends RecordingState {
  final String jobId;

  const RecordingSubmitted(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

class RecordingProcessing extends RecordingState {
  final String jobId;
  final JobProgress? progress;

  const RecordingProcessing(this.jobId, [this.progress]);

  @override
  List<Object?> get props => [jobId, progress];
}

class RecordingComplete extends RecordingState {
  final String responseText;

  const RecordingComplete(this.responseText);

  @override
  List<Object> get props => [responseText];
}

class RecordingError extends RecordingState {
  final String message;

  const RecordingError(this.message);

  @override
  List<Object> get props => [message];
}
