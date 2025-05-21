import 'package:equatable/equatable.dart';

abstract class QuestionnaireEvent extends Equatable {
  const QuestionnaireEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestionnaire extends QuestionnaireEvent {}

class AnswerQuestion extends QuestionnaireEvent {
  final String questionId;
  final String answer;

  const AnswerQuestion({required this.questionId, required this.answer});

  @override
  List<Object> get props => [questionId, answer];
}

class SubmitQuestionnaire extends QuestionnaireEvent {}

class CheckQuestionnaireJobStatus extends QuestionnaireEvent {
  final String jobId;

  const CheckQuestionnaireJobStatus(this.jobId);

  @override
  List<Object> get props => [jobId];
}
