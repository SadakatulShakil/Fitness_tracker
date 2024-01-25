import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'daily_step_count.dart';


class MyHomePage1 extends StatefulWidget {
  const MyHomePage1({super.key});

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'N/A';
  String _steps = 'N/A';
  List<DailyStepCount> dailyStepCounts = [];

  @override
  void initState() {
    super.initState();
    requestActivityRecognitionPermission();
  }

  Future<void> requestActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      // Request the permission
      status = await Permission.activityRecognition.request();
    }

    if (status.isGranted) {
      initPlatformState();
      // Permission granted, proceed with your code
    } else {
      // Permission denied
    }
  }

  void onStepCount(StepCount event) {
    print('eventsCount: ' + event.steps.toString());
    setState(() {
      _steps = event.steps.toString();
      _updateDailyStepCount(event.steps);
    });
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print('events: ' + event.status);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'not available';
    });
    print(_status);
  }

  void initPlatformState() {
    print('Initializing platform state');
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void _updateDailyStepCount(int steps) {
    DateTime today = DateTime.now();
    DateTime dateKey = DateTime(today.year, today.month, today.day);

    setState(() {
      DailyStepCount? todayStepCount = dailyStepCounts.firstWhere(
            (count) => count.date == dateKey,
        orElse: () => DailyStepCount(dateKey, 0), // Default to a new entry with 0 steps
      );

      if (todayStepCount != null) {
        // Update existing entry
        todayStepCount.steps = steps;
      } else {
        // Add a new entry
        dailyStepCounts.add(DailyStepCount(dateKey, steps));
      }
    });
  }

  int get _getTodayStepCount {
    DateTime today = DateTime.now();
    DateTime dateKey = DateTime(today.year, today.month, today.day);

    DailyStepCount? todayStepCount = dailyStepCounts.firstWhere(
          (count) => count.date == dateKey,
      orElse: () => DailyStepCount(dateKey, 0), // Default to a new entry with 0 steps
    );

    return todayStepCount.steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step Count Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Step Count: $_steps'),
            SizedBox(height: 20),
            Text('Today\'s Step Count: $_getTodayStepCount'),
          ],
        ),
      ),
    );
  }
}
