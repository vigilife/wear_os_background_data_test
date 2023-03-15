import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var heartRate = 0.0;

  @override
  void initState() async {
    super.initState();

    final workout = Workout();
    await workout.start(
      exerciseType: ExerciseType.walking,
      features: WorkoutFeature.values,
    );

    workout.stream.listen((e) {
      debugPrint('${e.feature}: ${e.value}');

      if (e.feature == WorkoutFeature.heartRate) {
        setState(() => heartRate = e.value);
      }
    });

    // Comment this out to see Health Services behave normally
    accelerometerEvents
        .throttle((_) => TimerStream(true, const Duration(seconds: 1)))
        .listen((event) => debugPrint(event.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AmbientMode(
        builder: (context, mode, child) => child!,
        child: Scaffold(
          body: Center(
            child: Text('Heart rate: $heartRate'),
          ),
        ),
      ),
    );
  }
}
