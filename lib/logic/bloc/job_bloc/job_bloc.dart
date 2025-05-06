import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../data/models/job_models.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final ApiRepository apiRepository;
  Timer? _statusCheckTimer;

  JobBloc({required this.apiRepository}) : super(JobInitial()) {
    on<SubmitJob>(_onSubmitJob);
    on<CheckJobStatus>(_onCheckJobStatus);
    on<ResetJob>(_onResetJob);
  }

  Future<void> _onSubmitJob(SubmitJob event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      final response = await apiRepository.submitJob(
        event.imageFile,
        event.text,
      );
      if (response.jobId != null) {
        emit(JobSubmitted(jobId: response.jobId!));

        // Start polling for status
        _startStatusPolling(response.jobId!);
      } else {
        emit(const JobError(message: 'No job ID returned from server'));
      }
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onCheckJobStatus(
    CheckJobStatus event,
    Emitter<JobState> emit,
  ) async {
    try {
      final response = await apiRepository.checkJobStatus(event.jobId);

      if (response.isProcessing && response.progress != null) {
        final progress = JobProgress.fromJson(response.progress!);
        emit(JobInProgress(jobId: event.jobId, progress: progress));
      } else if (response.isCompleted && response.result != null) {
        _stopStatusPolling();
        final result = apiRepository.parseJobResult(response.result!);
        emit(JobCompleted(result: result));
      } else if (response.isError) {
        _stopStatusPolling();
        emit(JobError(message: response.message ?? 'Unknown error'));
      }
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  void _onResetJob(ResetJob event, Emitter<JobState> emit) {
    _stopStatusPolling();
    emit(JobInitial());
  }

  void _startStatusPolling(String jobId) {
    _stopStatusPolling();
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => add(CheckJobStatus(jobId: jobId)),
    );
  }

  void _stopStatusPolling() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  @override
  Future<void> close() {
    _stopStatusPolling();
    return super.close();
  }
}
