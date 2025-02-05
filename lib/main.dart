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
      'description': 'Mercury is the smallest planet and closest to the Sun. It is about 57.9 million kilometers away from the Sun on average.'
    },
    {
      'size': 0.11,
      'image': 'images/venus.jpg',
      'position': vector.Vector3(-1, 0, -1.5),
      'name': 'Venus',
      'description': 'Venus is the second planet from the Sun and the hottest planet in the solar system. It is about 108.2 million kilometers away from the Sun. Venus has a thick, toxic atmosphere made mostly of carbon dioxide, with clouds of sulfuric acid that trap heat, creating an extreme greenhouse effect.'
    },
    {
      'size': 0.12,
      'image': 'images/terra.jpg',
      'position': vector.Vector3(-0.5, 0, -1.5),
      'name': 'Earth',
      'description': '"Earth is the third planet from the Sun and the only planet known to support life. It is about 149.6 million kilometers away from the Sun. Earth has a unique atmosphere composed mainly of nitrogen and oxygen, which helps regulate temperature and protect life from harmful solar radiation.'
    },
    {
      'size': 0.05,
      'image': 'images/moon.jpg',
      'position': vector.Vector3(-0.2, 0, -1.8),
      'name': 'Moon',
      'description': '"The Moon is Earth’s only natural satellite and the fifth largest moon in the solar system. It has a rocky, cratered surface shaped by billions of years of asteroid impacts.'
    },
    {
      'size': 0.13,
      'image': 'images/mars.jpg',
      'position': vector.Vector3(0, 0, -1.5),
      'name': 'Mars',
      'description': 'Mars is the fourth planet from the Sun, located about 227.9 million kilometers away. It is often called the Red Planet because of its reddish appearance, caused by iron oxide (rust) on its surface. Mars has the largest volcano in the solar system, Olympus Mons, and a massive canyon system, Valles Marineris.'
    },
    {
      'size': 0.27,
      'image': 'images/jupiter.jpg',
      'position': vector.Vector3(0.5, 0, -1.5),
      'name': 'Jupiter',
      'description': 'Jupiter is the fifth planet from the Sun and the largest planet in the solar system. It is about 778.5 million kilometers away from the Sun. Its most famous feature is the Great Red Spot, a massive storm that has been raging for centuries and is larger than Earth'
    },
    {
      'size': 0.29,
      'image': 'images/saturn.jpg',
      'position': vector.Vector3(1.25, 0, -1.5),
      'name': 'Saturn',
      'description': 'Saturn is the sixth planet from the Sun, located about 1.4 billion kilometers away. It is a gas giant best known for its stunning ring system, which is made of ice, rock, and dust.'
    },
    {
      'size': 0.15,
      'image': 'images/uranus.png',
      'position': vector.Vector3(2.0, 0, -1.5),
      'name': 'Uranus',
      'description': 'Uranus is the seventh planet from the Sun, located about 2.9 billion kilometers away. What makes Uranus unique is its extreme tilt—it rotates on its side, with its axis tilted at an angle of about 98 degrees'
    },
    {
      'size': 0.15,
      'image': 'images/neptune.jpg',
      'position': vector.Vector3(2.75, 0, -1.5),
      'name': 'Neptune',
      'description': 'Neptune is the eighth and farthest planet from the Sun, located about 4.5 billion kilometers away. It is an ice giant, similar to Uranus, and is known for having the strongest winds in the solar system, reaching speeds of over 2,000 kilometers per hour.'
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
    arCoreController.onPlaneTap = _handleOnPlaneTap;

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

    controller.onNodeTap = (nodeName) {

      if (nodeName == "Sun") {
        _showToast(context, "The Sun is a massive, glowing ball of hot gases at the center of our solar system. It is a star made mostly of hydrogen and helium, and its immense gravity holds the planets in orbit.");
      }
      else  if (nodeName == "Alien"){
        onTapHandler(nodeName);
      } else {
        var tappedPlanet = planets.firstWhere(
              (planet) => planet['name'] == nodeName,
          orElse: () => {'description': 'Unknown celestial object'},
        );

        _showToast(context, tappedPlanet['description']);
      }
    };
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



  void _showToast(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Get to know more!'),
          content: Text(
             message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _spawnAlien(ArCoreHitTestResult plane) {
    final alienNode = ArCoreReferenceNode(
        name: "Alien",
        // https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF/Box.gltf
        objectUrl: "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/CesiumMan/glTF/CesiumMan.gltf",
        position: plane.pose.translation,
        scale: vector.Vector3(0.8, 0.8, 0.8),
        rotation: plane.pose.rotation);

    arCoreController.addArCoreNodeWithAnchor(alienNode);
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _spawnAlien(hit);
  }

  void onTapHandler(String name) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: <Widget>[
            Text('Remove $name?'),
            IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () {
                  arCoreController.removeNode(nodeName: name);
                  Navigator.pop(context);
                })
          ],
        ),
      ),
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
