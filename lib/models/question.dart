class Question {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  String? answer;

  Question({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      question: json['question'],
      options: List<String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'answer': answer};
  }
}
