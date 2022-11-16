import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final workout = Workout();
  await workout.start(
    exerciseType: ExerciseType.walking,
    features: WorkoutFeature.values,
  );

  workout.stream.listen((e) => debugPrint('${e.feature}: ${e.value}'));

  accelerometerEvents
      .throttle((_) => TimerStream(true, const Duration(seconds: 1)))
      .listen(((event) => debugPrint(event.toString())));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AmbientMode(
        builder: (context, mode, child) => child!,
        child: const Scaffold(body: Center(child: Text('Hello, world!'))),
      ),
    );
  }
}
