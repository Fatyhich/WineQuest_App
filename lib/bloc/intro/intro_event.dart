import 'package:equatable/equatable.dart';

abstract class IntroEvent extends Equatable {
  const IntroEvent();

  @override
  List<Object> get props => [];
}

class IntroYesSelected extends IntroEvent {}

class IntroNoSelected extends IntroEvent {}
