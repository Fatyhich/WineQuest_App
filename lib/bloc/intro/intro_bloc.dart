import 'package:flutter_bloc/flutter_bloc.dart';
import 'intro_event.dart';
import 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  IntroBloc() : super(IntroInitial()) {
    on<IntroYesSelected>(_onYesSelected);
    on<IntroNoSelected>(_onNoSelected);
  }

  void _onYesSelected(IntroYesSelected event, Emitter<IntroState> emit) {
    emit(IntroNavigateToRecording());
  }

  void _onNoSelected(IntroNoSelected event, Emitter<IntroState> emit) {
    emit(IntroNavigateToQuestionnaire());
  }
}
