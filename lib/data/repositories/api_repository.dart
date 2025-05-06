import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../models/job_models.dart';

class ApiRepository {
  final Dio _dio = Dio();

  // Submit image and text to processing
  Future<JobStatusResponse> submitJob(File imageFile, String text) async {
    final formData = FormData.fromMap({
      'text': text,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      ),
    });

    try {
      final response = await _dio.post(
        ApiConfig.getProcessUrl(),
        data: formData,
      );

      final jobStatus = JobStatusResponse.fromJson({...response.data});
      print(jobStatus.jobId);
      return jobStatus;
    } catch (e) {
      throw Exception('Failed to submit job: $e');
    }
  }

  // Check job status
  Future<JobStatusResponse> checkJobStatus(String jobId) async {
    try {
      final response = await _dio.get(ApiConfig.getStatusUrl(jobId));

      return JobStatusResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to check job status: $e');
    }
  }

  // Parse job result from response
  JobResult parseJobResult(Map<String, dynamic> result) {
    return JobResult.fromJson(result);
  }
}
