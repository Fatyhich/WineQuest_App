import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/questionnaire.dart';

class QuestionnaireService {
  // Load questionnaire from the assets file
  Future<Questionnaire> loadQuestionnaire() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/config/questionnaire.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Create a Questionnaire object from the JSON data
      return Questionnaire.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load questionnaire: $e');
    }
  }
}
