import 'package:equatable/equatable.dart';
import '../../models/questionnaire.dart';
import '../../models/api_response.dart';

abstract class QuestionnaireState extends Equatable {
  const QuestionnaireState();

  @override
  List<Object?> get props => [];
}

class QuestionnaireInitial extends QuestionnaireState {}

class QuestionnaireLoading extends QuestionnaireState {}

class QuestionnaireLoaded extends QuestionnaireState {
  final Questionnaire questionnaire;

  const QuestionnaireLoaded(this.questionnaire);

  @override
  List<Object> get props => [questionnaire];
}

class QuestionnaireSubmitting extends QuestionnaireState {}

class QuestionnaireSubmitted extends QuestionnaireState {
  final String jobId;

  const QuestionnaireSubmitted(this.jobId);

  @override
  List<Object> get props => [jobId];
}

class QuestionnaireProcessing extends QuestionnaireState {
  final String jobId;
  final JobProgress? progress;

  const QuestionnaireProcessing(this.jobId, [this.progress]);

  @override
  List<Object?> get props => [jobId, progress];
}

class QuestionnaireComplete extends QuestionnaireState {
  final String responseText;

  const QuestionnaireComplete(this.responseText);

  @override
  List<Object> get props => [responseText];
}

class QuestionnaireError extends QuestionnaireState {
  final String message;

  const QuestionnaireError(this.message);

  @override
  List<Object> get props => [message];
}
