import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = 'http://10.16.112.87:5000/api';
  final Dio _dio = Dio();

  // Send audio recording to the server
  Future<JobResponse> sendAudioRecording(File audioFile) async {
    try {
      FormData formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: 'recording.m4a',
        ),
      });

      final response = await _dio.post('$baseUrl/process', data: formData);

      return JobResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send audio recording: $e');
    }
  }

  // Send questionnaire data to the server
  Future<JobResponse> sendQuestionnaire(
    Map<String, dynamic> questionnaireData,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        'questionnaire': jsonEncode(questionnaireData),
      });

      final response = await _dio.post('$baseUrl/process', data: formData);

      return JobResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send questionnaire: $e');
    }
  }

  // Check job status
  Future<JobStatus> checkJobStatus(String jobId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/status/$jobId'));

      if (response.statusCode == 200) {
        return JobStatus.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check job status');
      }
    } catch (e) {
      throw Exception('Error checking job status: $e');
    }
  }

  // Poll for job completion
  Future<JobStatus> pollForCompletion(String jobId) async {
    const Duration pollingInterval = Duration(seconds: 2);
    const int maxAttempts = 30; // 1 minute timeout

    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      final status = await checkJobStatus(jobId);

      if (status.status == 'completed') {
        return status;
      } else if (status.status == 'failed') {
        throw Exception('Job processing failed: ${status.message}');
      }

      await Future.delayed(pollingInterval);
    }

    throw Exception('Job processing timed out');
  }
}
