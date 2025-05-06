import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/job_bloc/job_bloc.dart';
import '../../logic/bloc/job_bloc/job_event.dart';
import '../../logic/bloc/job_bloc/job_state.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainScreen({super.key, required this.cameras});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _imageFile;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (widget.cameras.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No camera available')));
      return;
    }

    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: widget.cameras.first),
      ),
    );

    if (result != null) {
      setState(() {
        _imageFile = result;
      });
    }
  }

  void _submitJob() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture first')),
      );
      return;
    }

    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some text')));
      return;
    }

    context.read<JobBloc>().add(
      SubmitJob(imageFile: _imageFile!, text: _textController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WineQuest App'),
        backgroundColor: Colors.brown[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5E9D0), // Light sandy background
        ),
        child: BlocConsumer<JobBloc, JobState>(
          listener: (context, state) {
            if (state is JobError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is JobCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(result: state.result),
                ),
              );
              context.read<JobBloc>().add(ResetJob());
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter text to analyze...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        state is JobLoading || state is JobInProgress
                            ? null
                            : _takePicture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[400],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Take Picture'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        state is JobLoading || state is JobInProgress
                            ? null
                            : _submitJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Analyze'),
                  ),
                  const SizedBox(height: 24),
                  if (state is JobLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is JobInProgress)
                    _buildProgressIndicator(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child:
          _imageFile == null
              ? const Center(child: Text('No image selected'))
              : ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
    );
  }

  Widget _buildProgressIndicator(JobInProgress state) {
    final progressPercentage = state.progress.progressPercentage;

    return Column(
      children: [
        LinearProgressIndicator(value: progressPercentage),
        const SizedBox(height: 8),
        Text(
          state.progress.status,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          '${state.progress.current}/${state.progress.total}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
