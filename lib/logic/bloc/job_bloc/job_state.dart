import 'package:equatable/equatable.dart';
import '../../../data/models/job_models.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobSubmitted extends JobState {
  final String jobId;

  const JobSubmitted({required this.jobId});

  @override
  List<Object> get props => [jobId];
}

class JobInProgress extends JobState {
  final String jobId;
  final JobProgress progress;

  const JobInProgress({required this.jobId, required this.progress});

  @override
  List<Object> get props => [jobId, progress];
}

class JobCompleted extends JobState {
  final JobResult result;

  const JobCompleted({required this.result});

  @override
  List<Object> get props => [result];
}

class JobError extends JobState {
  final String message;

  const JobError({required this.message});

  @override
  List<Object> get props => [message];
}
