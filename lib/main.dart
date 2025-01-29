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
  late double rotationSpeed;

  final List<Map<String, dynamic>> planets = [
    {
      'size': 0.1,
      'image': 'images/mercury.jpg',
      'position': vector.Vector3(-1.5, 0, -1.5),
      'name': 'Mercury',
      'description': 'Mercury is the smallest planet and closest to the Sun.'
    },
    {
      'size': 0.11,
      'image': 'images/venus.jpg',
      'position': vector.Vector3(-1, 0, -1.5),
      'name': 'Venus',
      'description': 'Venus is the hottest planet with a thick toxic atmosphere.'
    },
    {
      'size': 0.12,
      'image': 'images/terra.jpg',
      'position': vector.Vector3(-0.5, 0, -1.5),
      'name': 'Earth',
      'description': 'Earth is the only planet known to support life.'
    },
    {
      'size': 0.05,
      'image': 'images/moon.jpg',
      'position': vector.Vector3(-0.2, 0, -1.8),
      'name': 'Moon',
      'description': 'The Moon is Earth’s only natural satellite.'
    },
    {
      'size': 0.13,
      'image': 'images/mars.jpg',
      'position': vector.Vector3(0, 0, -1.5),
      'name': 'Mars',
      'description': 'Mars is known as the Red Planet and may have had water.'
    },
    {
      'size': 0.27,
      'image': 'images/jupiter.jpg',
      'position': vector.Vector3(0.5, 0, -1.5),
      'name': 'Jupiter',
      'description': 'Jupiter is the largest planet with a massive storm.'
    },
    {
      'size': 0.29,
      'image': 'images/saturn.jpg',
      'position': vector.Vector3(1.25, 0, -1.5),
      'name': 'Saturn',
      'description': 'Saturn is famous for its stunning rings.'
    },
    {
      'size': 0.15,
      'image': 'images/uranus.png',
      'position': vector.Vector3(2.0, 0, -1.5),
      'name': 'Uranus',
      'description': 'Uranus is an ice giant that rotates on its side.'
    },
    {
      'size': 0.15,
      'image': 'images/neptune.jpg',
      'position': vector.Vector3(2.75, 0, -1.5),
      'name': 'Neptune',
      'description': 'Neptune is the windiest planet in the solar system.'
    },
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
      'name': 'Moon',
      'node': ArCoreNode(name: 'Moon'),
      'distance': 0.3,
      'speed': 0.5,
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
  final vector.Vector3 sunPosition = vector.Vector3(0, 0, -3);

  @override
  void initState() {
    super.initState();
    rotationSpeed = 100.0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _rotatePlanets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar System AR'),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Stack(
        children: [
          // 🟢 ARCore View
          Positioned.fill(
            child: ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
              enableUpdateListener: true,
            ),
          ),

          Positioned(
            left: 10,
            top: 100,
            bottom: 100,
            child: RotatedBox(
              quarterTurns: -1, // Rotate the slider vertically
              child: Slider(
                value: rotationSpeed,
                min: 5.0,
                max: 100.0,
                divisions: 19,
                activeColor: Colors.pink,
                inactiveColor: Colors.pinkAccent,
                onChanged: (value) {
                  setState(() {
                    rotationSpeed = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showQuizDialog(context);
            },
            backgroundColor: Colors.pink,
            child: const Icon(Icons.quiz, color: Colors.white),
            heroTag: "quizButton", // Avoids Hero animation conflicts
          ),
          const SizedBox(height: 10), // Space between buttons
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizPage(),
              ));
            },
            backgroundColor: Colors.blue, // Different color for distinction
            child: const Icon(Icons.face, color: Colors.white),
            heroTag: "faceButton", // Unique hero tag
          ),
        ],
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
      "Sun",
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

    controller.onNodeTap = (nodeName) {

      if (nodeName == "Sun"){
        _showToast("The Sun is the star of our solar system.");
      } else {
        var tappedPlanet = planets.firstWhere(
              (planet) => planet['name'] == nodeName,
          orElse: () => {'description': 'Unknown celestial object'},
        );

        _showToast(tappedPlanet['description']);
      }
    };
  }

  void _rotatePlanets() {
    final earthNode = _planetNodes.firstWhere((planet) => planet['name'] == 'Earth');
    double speedFactor = rotationSpeed / 100.0;

    final earthPosition = (earthNode['node'] as ArCoreNode).position?.value ?? vector.Vector3(-0.2, 0, -1.8);

    for (var planet in _planetNodes) {

      if (planet['name'] != "Moon") {
         planet['angle'] += planet['speed'] *  speedFactor;;

         final double x = sunPosition.x + planet['distance'] * cos(planet['angle']);
         final double z = sunPosition.z + planet['distance'] * sin(planet['angle']);

         final updatedPosition = vector.Vector3(x, 0, z);

         planet['node'].position?.value = updatedPosition;
       } else {
         planet['angle'] += planet['speed'] * speedFactor;

         final double x = earthPosition.x + planet['distance'] * cos(planet['angle']);
         final double z = earthPosition.z + planet['distance'] * sin(planet['angle']);

         final updatedPosition = vector.Vector3(x, 0, z);

         planet['node'].position?.value = updatedPosition;
       }
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
