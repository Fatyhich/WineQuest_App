import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../services/questionnaire_service.dart';
import '../../services/api_service.dart';
import '../../models/questionnaire.dart';
import 'questionnaire_event.dart';
import 'questionnaire_state.dart';

class QuestionnaireBloc extends Bloc<QuestionnaireEvent, QuestionnaireState> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  final ApiService _apiService = ApiService();
  Questionnaire? _questionnaire;

  QuestionnaireBloc() : super(QuestionnaireInitial()) {
    on<LoadQuestionnaire>(_onLoadQuestionnaire);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<SubmitQuestionnaire>(_onSubmitQuestionnaire);
    on<CheckQuestionnaireJobStatus>(_onCheckJobStatus);
  }

  Future<void> _onLoadQuestionnaire(
    LoadQuestionnaire event,
    Emitter<QuestionnaireState> emit,
  ) async {
    try {
      emit(QuestionnaireLoading());
      _questionnaire = await _questionnaireService.loadQuestionnaire();
      emit(QuestionnaireLoaded(_questionnaire!));
    } catch (e) {
      emit(QuestionnaireError('Failed to load questionnaire: $e'));
    }
  }

  void _onAnswerQuestion(
    AnswerQuestion event,
    Emitter<QuestionnaireState> emit,
  ) {
    if (_questionnaire == null) {
      emit(const QuestionnaireError('Questionnaire not loaded'));
      return;
    }

    try {
      // Find the question and update its answer
      for (var question in _questionnaire!.questions) {
        if (question.id == event.questionId) {
          question.answer = event.answer;
          break;
        }
      }

      // Emit the updated state
      emit(QuestionnaireLoaded(_questionnaire!));
    } catch (e) {
      emit(QuestionnaireError('Failed to answer question: $e'));
    }
  }

  Future<void> _onSubmitQuestionnaire(
    SubmitQuestionnaire event,
    Emitter<QuestionnaireState> emit,
  ) async {
    if (_questionnaire == null) {
      emit(const QuestionnaireError('Questionnaire not loaded'));
      return;
    }

    try {
      emit(QuestionnaireSubmitting());

      // Convert questionnaire to JSON and submit it
      final jsonData = _questionnaire!.toJson();
      final response = await _apiService.sendQuestionnaire(jsonData);

      emit(QuestionnaireSubmitted(response.jobId));

      // Start polling for job status
      add(CheckQuestionnaireJobStatus(response.jobId));
    } catch (e) {
      emit(QuestionnaireError('Failed to submit questionnaire: $e'));
    }
  }

  Future<void> _onCheckJobStatus(
    CheckQuestionnaireJobStatus event,
    Emitter<QuestionnaireState> emit,
  ) async {
    try {
      final status = await _apiService.checkJobStatus(event.jobId);

      if (status.status == 'completed' && status.responseText != null) {
        emit(QuestionnaireComplete(status.responseText!));
      } else if (status.status == 'processing') {
        emit(QuestionnaireProcessing(event.jobId, status.progress));

        // Schedule next check in 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        add(CheckQuestionnaireJobStatus(event.jobId));
      } else if (status.status == 'failed') {
        emit(QuestionnaireError('Processing failed: ${status.message}'));
      }
    } catch (e) {
      emit(QuestionnaireError('Failed to check job status: $e'));
    }
  }
}
