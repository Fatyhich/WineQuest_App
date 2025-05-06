import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/api_repository.dart';
import 'logic/bloc/job_bloc/job_bloc.dart';
import 'presentation/screens/main_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get available cameras
  final cameras = await availableCameras();

  runApp(WineQuestApp(cameras: cameras));
}

class WineQuestApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const WineQuestApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JobBloc>(
          create: (context) => JobBloc(apiRepository: ApiRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'WineQuest App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        home: MainScreen(cameras: cameras),
      ),
    );
  }
}
