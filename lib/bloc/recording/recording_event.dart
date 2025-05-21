import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecording extends RecordingEvent {}

class StopRecording extends RecordingEvent {}

class SubmitRecording extends RecordingEvent {
  final File audioFile;

  const SubmitRecording(this.audioFile);

  @override
  List<Object?> get props => [audioFile];
}

class CheckJobStatus extends RecordingEvent {
  final String jobId;

  const CheckJobStatus(this.jobId);

  @override
  List<Object?> get props => [jobId];
}
