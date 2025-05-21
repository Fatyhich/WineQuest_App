import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _path;

  // Check if microphone permissions are granted
  Future<bool> checkPermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    return hasPermission;
  }

  // Start recording
  Future<void> startRecording() async {
    if (await checkPermission()) {
      final directory = await getTemporaryDirectory();
      _path = '${directory.path}/audio_recording.m4a';

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _path!, // Use non-null assertion since we just set the path
      );

      _isRecording = true;
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  // Stop recording and return the file
  Future<File?> stopRecording() async {
    if (!_isRecording || _path == null) {
      return null;
    }

    final path = await _audioRecorder.stop();
    _isRecording = false;

    if (path == null) {
      return null;
    }

    return File(path);
  }

  // Check if currently recording
  bool get isRecording => _isRecording;

  // Dispose resources
  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
