import 'dart:async';

import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_3d_flutter/step_tracking.dart';

import 'daily_step_count.dart';
import 'inverted_circle_clipper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UI 3D flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  O3DController o3dController = O3DController();
  PageController mainPageController = PageController();
  PageController textsPageController = PageController();
  int page = 0;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'N/A';
  String _steps = 'N/A';
  List<DailyStepCount> dailyStepCounts = [];

  @override
  void initState() {
    super.initState();
    // Initialize Pedometer streams in initState
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
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
      //_updateDailyStepCount(event.steps);
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

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Not Counting';
    });
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

    DailyStepCount? todayStepCount = dailyStepCounts.firstWhere(
          (count) => count.date == dateKey,
      orElse: () => DailyStepCount(dateKey, 0), // Default to a new entry with 0 steps,
    );

    if (todayStepCount != null) {
      // Update existing entry
      todayStepCount.steps = steps;
    } else {
      // Add a new entry
      dailyStepCounts.add(DailyStepCount(dateKey, steps));
    }
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

    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: Stack(
          children: [
            O3D(
              src: 'assets/men_walking.glb',
              controller: o3dController,
              ar: false,
              autoPlay: true,
              autoRotate: false,
              cameraControls: false,
              cameraTarget: CameraTarget(-.18, 0.8, 0.6),
              cameraOrbit: CameraOrbit(0, 90, 1),
            ),
            PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: mainPageController,
              children: [
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(12, height * 0.8, 12, 100),
                  itemCount: 100,
                  itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/image1.jpg',
                          fit: BoxFit.cover,
                          width: 70,
                          height: 70,
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('A simple way to stay healthy',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Dr Babak',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),

                        const Icon(Icons.location_on,
                          color: Colors.red,
                        )

                      ],
                    ),
                  ),
                ),),
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(12, height * 0.8, 12, 100),
                  itemCount: 100,
                  itemBuilder: (context, index) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/image2.jpg',
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70,
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('10:24',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12
                                    ),
                                  ),
                                  Text('Morning walk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('2 km in 30min',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Icon(Icons.directions_walk_rounded,
                            color: Colors.red,
                          )

                        ],
                      ),
                    ),
                  ),),
                ClipPath(
                  clipper: InvertedCircleClipper(),
                  child: Container(
                    color: Colors.white,
                  ),
                )
              ],
            ),
            Container(
              width: 100,
              height: double.infinity,
              margin: const EdgeInsets.all(12),
              child: PageView(
                controller: textsPageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text("Daily goals"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            const Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text("87"),
                              ),
                            ),
                            Transform.translate(
                                offset: const Offset(0, 20),
                                child: const Text("%"))
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.local_fire_department_outlined,
                                color: Colors.red),
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("1,840"),
                              Text(
                                "calories",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ))
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.do_not_step, color: Colors.purple),
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_steps),
                              const Text(
                                "steps",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ))
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.hourglass_bottom,
                                color: Colors.lightBlueAccent),
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("3.5"),
                              Text(
                                "hours",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text("Today"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Transform.translate(
                                offset: const Offset(0, 20),
                                child: const Text("")),
                            const Expanded(
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text("25"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "January 2024",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.local_fire_department_outlined,
                                color: Colors.red),
                          ),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("1,840"),
                                  Text(
                                    "calories",
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.do_not_step, color: Colors.purple),
                          ),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("3,480"),
                                  Text(
                                    "steps",
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ))
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.hourglass_bottom,
                                color: Colors.lightBlueAccent),
                          ),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("3.5"),
                                  Text(
                                    "hours",
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text("Profile"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text("Shakil"),
                        ),
                      ),
                      Text(
                        "27 years old",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: page,
          onTap: (page) {
            mainPageController.animateToPage(page,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
            textsPageController.animateToPage(page,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);

            if (page == 0) {
              o3dController.cameraTarget(-.18, 0.8, 0.6);
              o3dController.cameraOrbit(0, 90, 1);
            } else if (page == 1) {
              o3dController.cameraTarget(-0.9, 0.8, 0);
              o3dController.cameraOrbit(-90, 90, 1);
            } else if (page == 2) {
              o3dController.cameraTarget(0, 1.5, -.1);
              o3dController.cameraOrbit(0, 90, .2);
            }

            setState(() {
              this.page = page;
            });
          },
          showUnselectedLabels: false,
          showSelectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined), label: 'timer'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'profile'),
          ]),
    );
  }
}
