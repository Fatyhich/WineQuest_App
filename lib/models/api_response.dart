class JobResponse {
  final String jobId;
  final String status;

  JobResponse({required this.jobId, required this.status});

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(jobId: json['job_id'], status: json['status']);
  }
}

class JobProgress {
  final int current;
  final String status;
  final int total;

  JobProgress({
    required this.current,
    required this.status,
    required this.total,
  });

  factory JobProgress.fromJson(Map<String, dynamic> json) {
    return JobProgress(
      current: json['current'],
      status: json['status'],
      total: json['total'],
    );
  }
}

class JobStatus {
  final String status;
  final String? message;
  final JobProgress? progress;
  final Map<String, dynamic>? result;

  JobStatus({required this.status, this.message, this.progress, this.result});

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      status: json['status'],
      message: json['message'],
      progress:
          json['progress'] != null
              ? JobProgress.fromJson(json['progress'])
              : null,
      result: json['result'],
    );
  }

  String? get responseText {
    if (result != null && result!.containsKey('rag_response')) {
      return result!['rag_response'];
    }
    return null;
  }
}
