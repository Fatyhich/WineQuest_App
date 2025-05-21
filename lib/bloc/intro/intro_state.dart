import 'package:equatable/equatable.dart';

abstract class IntroState extends Equatable {
  const IntroState();

  @override
  List<Object> get props => [];
}

class IntroInitial extends IntroState {}

class IntroNavigateToRecording extends IntroState {}

class IntroNavigateToQuestionnaire extends IntroState {}
