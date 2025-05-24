import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/questionnaire/questionnaire_bloc.dart';
import '../bloc/questionnaire/questionnaire_event.dart';
import '../bloc/questionnaire/questionnaire_state.dart';
import '../models/question.dart';
import 'result_screen.dart';
import '../widgets/loading_indicator.dart';

class QuestionnaireScreen extends StatelessWidget {
  const QuestionnaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestionnaireBloc()..add(LoadQuestionnaire()),
      child: BlocListener<QuestionnaireBloc, QuestionnaireState>(
        listener: (context, state) {
          if (state is QuestionnaireComplete) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => ResultScreen(responseText: state.responseText),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Винные предпочтения'),
            backgroundColor: Colors.deepPurple[100],
            centerTitle: true,
          ),
          body: const _QuestionnaireScreenContent(),
        ),
      ),
    );
  }
}

class _QuestionnaireScreenContent extends StatelessWidget {
  const _QuestionnaireScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionnaireBloc, QuestionnaireState>(
      builder: (context, state) {
        if (state is QuestionnaireLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is QuestionnaireError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<QuestionnaireBloc>().add(LoadQuestionnaire());
                  },
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          );
        } else if (state is QuestionnaireSubmitting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Отправка ваших предпочтений...'),
              ],
            ),
          );
        } else if (state is QuestionnaireProcessing ||
            state is QuestionnaireSubmitted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingIndicator(),
                const SizedBox(height: 16),
                Text(
                  state is QuestionnaireProcessing && state.progress != null
                      ? 'Обработка: ${state.progress!.status}'
                      : 'Обработка вашего запроса...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is QuestionnaireLoaded) {
          return _buildQuestionnaireUI(context, state);
        }

        return const Center(child: Text('Что-то пошло не так'));
      },
    );
  }

  Widget _buildQuestionnaireUI(
    BuildContext context,
    QuestionnaireLoaded state,
  ) {
    final questionnaire = state.questionnaire;

    // Check if all questions have been answered
    bool allAnswered = questionnaire.questions.every((q) => q.answer != null);

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple[50]!, Colors.white],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Пожалуйста, ответьте на следующие вопросы:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: questionnaire.questions.length,
                itemBuilder: (context, index) {
                  final question = questionnaire.questions[index];
                  return _buildQuestionItem(context, question, index);
                },
                // Add caching for better performance
                cacheExtent: 1000.0,
                addAutomaticKeepAlives: true,
                physics: const AlwaysScrollableScrollPhysics(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    allAnswered
                        ? () {
                          HapticFeedback.mediumImpact();
                          context.read<QuestionnaireBloc>().add(
                            SubmitQuestionnaire(),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  'Отправить предпочтения',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(
    BuildContext context,
    Question question,
    int index,
  ) {
    return Card(
      key: ValueKey('question_${question.id}'),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.question}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...question.options.map(
              (option) => _buildOptionItem(context, option, question),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    String option,
    Question question,
  ) {
    final isSelected = question.answer == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('option_${question.id}_$option'),
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<QuestionnaireBloc>().add(
              AnswerQuestion(questionId: question.id, answer: option),
            );
          },
          splashColor: Colors.deepPurple.withOpacity(0.3),
          highlightColor: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.deepPurple.withOpacity(0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.deepPurple
                        : Colors.grey.withOpacity(0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.deepPurple : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.deepPurple : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
