import 'package:equatable/equatable.dart';

class JobStatusResponse extends Equatable {
  final String status;
  final Map<String, dynamic>? progress;
  final Map<String, dynamic>? result;
  final String? message;
  final String? jobId;

  const JobStatusResponse({
    required this.status,
    this.progress,
    this.result,
    this.message,
    this.jobId,
  });

  factory JobStatusResponse.fromJson(Map<String, dynamic> json) {
    return JobStatusResponse(
      status: json['status'] as String,
      progress: json['progress'] as Map<String, dynamic>?,
      result: json['result'] as Map<String, dynamic>?,
      message: json['message'] as String?,
      jobId: json['job_id'] as String?,
    );
  }

  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isError => status == 'error';

  @override
  List<Object?> get props => [status, progress, result, message, jobId];
}

class JobProgress extends Equatable {
  final int current;
  final int total;
  final String status;

  const JobProgress({
    required this.current,
    required this.total,
    required this.status,
  });

  factory JobProgress.fromJson(Map<String, dynamic> json) {
    return JobProgress(
      current: json['current'] as int,
      total: json['total'] as int,
      status: json['status'] as String,
    );
  }

  double get progressPercentage => current / total;

  @override
  List<Object> get props => [current, total, status];
}

class JobResult extends Equatable {
  final String jobId;
  final String textInput;
  final bool textAnalyzed;
  final bool imageProcessed;
  final String mockLlmOutput;
  final String mockVlmOutput;
  final String imagePath;

  const JobResult({
    required this.jobId,
    required this.textInput,
    required this.textAnalyzed,
    required this.imageProcessed,
    required this.mockLlmOutput,
    required this.mockVlmOutput,
    required this.imagePath,
  });

  factory JobResult.fromJson(Map<String, dynamic> json) {
    return JobResult(
      jobId: json['job_id'] as String,
      textInput: json['text_input'] as String,
      textAnalyzed: json['text_analyzed'] as bool,
      imageProcessed: json['image_processed'] as bool,
      mockLlmOutput: json['mock_llm_output'] as String,
      mockVlmOutput: json['mock_vlm_output'] as String,
      imagePath: json['image_path'] as String,
    );
  }

  @override
  List<Object> get props => [
    jobId,
    textInput,
    textAnalyzed,
    imageProcessed,
    mockLlmOutput,
    mockVlmOutput,
    imagePath,
  ];
}
