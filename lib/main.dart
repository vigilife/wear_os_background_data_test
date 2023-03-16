import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wear/wear.dart';
import 'package:workout/workout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification_icon');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var count = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() => count++),
    );

    await startForegroundService();
    await startWorkout();

    // Comment these out to see Health Services behave normally
    listenToAccelerometer();
    listenToNoise();
  }

  Future<void> startForegroundService() => FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .startForegroundService(
        123,
        'Test',
        'Test',
        notificationDetails: const AndroidNotificationDetails('Test', 'Test'),
        foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeMicrophone,
        },
      );

  Future<void> startWorkout() async {
    final workout = Workout();

    workout.stream
        .listen((e) => debugPrint('WORKOUT: ${e.feature} - ${e.value}'));

    await workout.start(
      exerciseType: ExerciseType.walking,
      features: WorkoutFeature.values,
    );
  }

  void listenToAccelerometer() => accelerometerEvents
      .throttle((_) => TimerStream(true, const Duration(seconds: 1)))
      .listen((event) => debugPrint('ACCELEROMETER: $event'));

  void listenToNoise() =>
      NoiseMeter().noiseStream.listen((noise) => debugPrint('NOISE: $noise'));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AmbientMode(
        builder: (context, mode, child) => Scaffold(
          backgroundColor: mode == WearMode.active ? Colors.green : Colors.red,
          body: child!,
        ),
        child: Center(
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 120,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
