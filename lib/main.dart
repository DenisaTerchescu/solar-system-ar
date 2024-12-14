import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    home: SolarSystemApp(),
  ));
}

class SolarSystemApp extends StatefulWidget {
  @override
  _SolarSystemAppState createState() => _SolarSystemAppState();
}

class _SolarSystemAppState extends State<SolarSystemApp> {
  late ArCoreController arCoreController;

  final List<Map<String, dynamic>> planets = [
    {'size': 0.5, 'image': 'images/sun.jpg', 'distance': 0.0}, // Sun at center
    {'size': 0.1, 'image': 'images/mercury.jpg', 'distance': 0.5}, // Mercury
    {'size': 0.11, 'image': 'images/venus.jpg', 'distance': 1.0}, // Venus
    {'size': 0.12, 'image': 'images/terra.jpg', 'distance': 1.5}, // Earth
    {'size': 0.13, 'image': 'images/mars.jpg', 'distance': 2.0}, // Mars
    {'size': 0.27, 'image': 'images/jupiter.jpg', 'distance': 2.5}, // Jupiter
    {'size': 0.29, 'image': 'images/saturn.jpg', 'distance': 3.0}, // Saturn
    {'size': 0.15, 'image': 'images/uranus.png', 'distance': 3.5}, // Uranus
    {'size': 0.15, 'image': 'images/neptune.jpg', 'distance': 4.0}, // Neptune
  ];

  final Map<String, ArCoreNode> _planetNodes = {};
  late Timer _timer;
  final vector.Vector3 sunPosition = vector.Vector3(-2, 0, -1.5);

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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showQuizDialog(context);
            },
            backgroundColor: Colors.pink,
            child: const Icon(Icons.quiz_outlined),
          )),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    for (var planet in planets) {
      _addPlanet(
        arCoreController,
        planet['size'],
        planet['image'],
        planet['distance'],
      );
    }

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      // _updatePlanetPositions();
    });
  }

  Future<void> _addPlanet(ArCoreController controller, double radius,
      String texture, double distance) async {
    final material = ArCoreMaterial(
        color: Colors.red, textureBytes: await _loadTexture(texture));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: radius,
    );

    var planetName = extractPlanetName(texture);

    final position = sunPosition +
        vector.Vector3(distance, 0, 0);

    final node = ArCoreNode(
      shape: sphere,
      position: position,
      name: planetName
    );
    controller.addArCoreNode(node);

    _planetNodes[planetName] = node;

    controller.onNodeTap = (nodes) {
        _showToast("You clicked on $nodes!");
    };
  }

  void _updatePlanetPositions() {
    final double time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (int i = 1; i < planets.length; i++) {
      final planet = planets[i];
      final distance = planet['distance'];
      final speed = 0.5 / distance;

      final double angle = time * speed * 2 * pi;
      final double x = distance * cos(angle);
      final double z = distance * sin(angle);

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

String extractPlanetName(String filePath) {
  final RegExp regex = RegExp(r'\/([^\/]+)\.');
  final match = regex.firstMatch(filePath);
  return match != null ? match.group(1) ?? '' : '';
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
        ],
      );
    },
  );
}
