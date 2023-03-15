import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noise_meter/noise_meter.dart';
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

    await startForegroundService();
    await startWorkout();

    // Comment this out to see Health Services behave normally
    listenToAccelerometer();

    // Comment this out to see Health Services behave normally
    listenToNoise();
  }

  Future<void> startForegroundService() => FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .startForegroundService(123, 'test', 'test');

  Future<void> startWorkout() async {
    final workout = Workout();

    workout.stream.listen((e) {
      debugPrint('${e.feature}: ${e.value}');

      if (e.feature == WorkoutFeature.heartRate) {
        setState(() => heartRate = e.value);
      }
    });

    await workout.start(
      exerciseType: ExerciseType.walking,
      features: WorkoutFeature.values,
    );
  }

  void listenToAccelerometer() => accelerometerEvents
      .throttle((_) => TimerStream(true, const Duration(seconds: 1)))
      .listen((event) => debugPrint(event.toString()));

  void listenToNoise() => NoiseMeter().noiseStream.listen((noise) {
        debugPrint(noise.toString());
      });

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
