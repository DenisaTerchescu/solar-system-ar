import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:math';

import 'Quiz.dart';

void main() {
  runApp(const MaterialApp(
    home: SolarSystemApp(),
  ));
}

class SolarSystemApp extends StatefulWidget {
  const SolarSystemApp({super.key});

  @override
  _SolarSystemAppState createState() => _SolarSystemAppState();
}

class _SolarSystemAppState extends State<SolarSystemApp> {
  late ArCoreController arCoreController;

  final List<Map<String, dynamic>> planets = [
    {'size': 0.1, 'image': 'images/mercury.jpg', 'position': vector.Vector3(-1.5, 0, -1.5), 'name': 'Mercury'},
    {'size': 0.11, 'image': 'images/venus.jpg', 'position': vector.Vector3(-1, 0, -1.5), 'name': 'Venus'},
    {'size': 0.12, 'image': 'images/terra.jpg', 'position': vector.Vector3(-0.5, 0, -1.5), 'name': 'Earth'},
    {'size': 0.13, 'image': 'images/mars.jpg', 'position': vector.Vector3(0, 0, -1.5), 'name': 'Mars'},
    {'size': 0.27, 'image': 'images/jupiter.jpg', 'position': vector.Vector3(0.5, 0, -1.5), 'name': 'Jupiter'},
    {'size': 0.29, 'image': 'images/saturn.jpg', 'position': vector.Vector3(1.25, 0, -1.5), 'name': 'Saturn'},
    {'size': 0.15, 'image': 'images/uranus.png', 'position': vector.Vector3(2.0, 0, -1.5), 'name': 'Uranus'},
    {'size': 0.15, 'image': 'images/neptune.jpg', 'position': vector.Vector3(2.75, 0, -1.5), 'name': 'Neptune'},
  ];

  late final List<Map<String, dynamic>> _planetNodes = [
    {
      'name': 'Mercury',
      'node': ArCoreNode(name: 'Mercury'),
      'distance': 1.0,
      'speed': 0.2,
      'angle': 0.0
    },
    {
      'name': 'Venus',
      'node': ArCoreNode(name: 'Venus'),
      'distance': 1.5,
      'speed': 0.15,
      'angle': 0.0
    },
    {
      'name': 'Earth',
      'node': ArCoreNode(name: 'Earth'),
      'distance': 2.0,
      'speed': 0.1,
      'angle': 0.0
    },
    {
      'name': 'Mars',
      'node': ArCoreNode(name: 'Mars'),
      'distance': 2.5,
      'speed': 0.09,
      'angle': 0.0
    },
    {
      'name': 'Jupiter',
      'node': ArCoreNode(name: 'Jupiter'),
      'distance': 3.0,
      'speed': 0.07,
      'angle': 0.0
    },
    {
      'name': 'Saturn',
      'node': ArCoreNode(name: 'Saturn'),
      'distance': 3.5,
      'speed': 0.05,
      'angle': 0.0
    },
    {
      'name': 'Uranus',
      'node': ArCoreNode(name: 'Uranus'),
      'distance': 4.0,
      'speed': 0.03,
      'angle': 0.0
    },
    {
      'name': 'Neptune',
      'node': ArCoreNode(name: 'Neptune'),
      'distance': 4.5,
      'speed': 0.02,
      'angle': 0.0
    },
  ];


  late Timer _timer;
  final vector.Vector3 sunPosition = vector.Vector3(-2.0, 0, -1.5);

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _rotatePlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Solar System AR',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.pink,
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
          enableUpdateListener: true,
          debug: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showQuizDialog(context);
          },
          backgroundColor: Colors.pink,
          child: const Icon(Icons.quiz_outlined),
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    _addSun(
      arCoreController,
      0.5,
      'images/sun.jpg',
      sunPosition,
      "the Sun",
    );

    for (var planet in planets) {
      _addPlanet(
        arCoreController,
        planet['size'],
        planet['image'],
        planet['position'],
        planet['name'],
      );
    }
  }

  Future<void> _addSun(ArCoreController controller, double radius,
      String texture, vector.Vector3 position, String name) async {

    final material = ArCoreMaterial(
      color: Colors.red,
      textureBytes: await _loadTexture(texture),
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: radius,
    );

    final node = ArCoreRotatingNode(
      shape: sphere,
      position: position,
      name: name,
      degreesPerSecond: 30.0,
      rotation: vector.Vector4(0, 1, 0, 10),
    );

    controller.addArCoreNode(node);

    controller.onNodeTap = (nodes) {
      _showToast("You tapped on $nodes!");
    };
  }

  Future<void> _addPlanet(ArCoreController controller, double radius,
      String texture, vector.Vector3 position, String name) async {

    final material = ArCoreMaterial(
      color: Colors.red,
      textureBytes: await _loadTexture(texture),
    );

    final sphere = ArCoreSphere(
      materials: [material],
      radius: radius,
    );

    for (var planet in _planetNodes) {
      if (planet['name'] == name) {
          planet['node'] = ArCoreRotatingNode(
            shape: sphere,
            position: position,
            name: name,
            degreesPerSecond: 30.0,
            rotation: vector.Vector4(0, 1, 0, 10),
          );
          controller.addArCoreNode(planet['node']);
          break;
        }
      }

    controller.onNodeTap = (nodes) {
      _showToast("You tapped on $nodes!");
    };
  }

  void _rotatePlanets() {
    for (var planet in _planetNodes) {

        planet['angle'] += planet['speed'];

        final double x = sunPosition.x + planet['distance'] * cos(planet['angle']);
        final double z = sunPosition.z + planet['distance'] * sin(planet['angle']);

        final updatedPosition = vector.Vector3(x, 0, z);

        planet['node'].position?.value = updatedPosition;

      }

    }



  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.pinkAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    arCoreController.dispose();
    super.dispose();
  }

  Future<Uint8List> _loadTexture(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}

void _showQuizDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Time for a quiz!'),
        content: const Text(
            'Are you ready to test your knowledge about the solar system?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizPage()),
              );
            },
            child: const Text('Okay'),
          ),
        ],
      );
    },
  );
}
