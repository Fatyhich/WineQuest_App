import 'question.dart';

class Questionnaire {
  final List<Question> questions;

  Questionnaire({required this.questions});

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    List<dynamic> questionJsonList = json['questions'];
    List<Question> questions =
        questionJsonList
            .map((questionJson) => Question.fromJson(questionJson))
            .toList();

    return Questionnaire(questions: questions);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> answersData = [];

    for (var question in questions) {
      if (question.answer != null) {
        answersData.add(question.toJson());
      }
    }

    return {'answers': answersData};
  }
}
