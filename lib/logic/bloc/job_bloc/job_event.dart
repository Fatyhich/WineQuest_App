import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class SubmitJob extends JobEvent {
  final File imageFile;
  final String text;

  const SubmitJob({required this.imageFile, required this.text});

  @override
  List<Object> get props => [imageFile, text];
}

class CheckJobStatus extends JobEvent {
  final String jobId;

  const CheckJobStatus({required this.jobId});

  @override
  List<Object> get props => [jobId];
}

class ResetJob extends JobEvent {}
