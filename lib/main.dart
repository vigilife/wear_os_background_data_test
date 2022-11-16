import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:workout/workout.dart';

void main() async {
  final workout = Workout();

  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .startForegroundService(123, 'test', 'test');

  await workout.start(
    exerciseType: ExerciseType.walking,
    features: WorkoutFeature.values,
  );

  NoiseMeter().noiseStream.listen((noise) {
    debugPrint(noise.toString());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Center(child: Text('Hello, world!')),
    );
  }
}
