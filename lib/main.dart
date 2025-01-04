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
    {'size': 0.5, 'image': 'images/sun.jpg', 'position': vector.Vector3(-2, 0, -1.5), 'name': 'the Sun'},
    {'size': 0.1, 'image': 'images/mercury.jpg', 'position': vector.Vector3(-1.5, 0, -1.5), 'name': 'Mercury'},
/*    {'size': 0.11, 'image': 'images/venus.jpg', 'position': vector.Vector3(-1, 0, -1.5), 'name': 'Venus'},
    {'size': 0.12, 'image': 'images/terra.jpg', 'position': vector.Vector3(-0.5, 0, -1.5), 'name': 'Earth'},
    {'size': 0.13, 'image': 'images/mars.jpg', 'position': vector.Vector3(0, 0, -1.5), 'name': 'Mars'},
    {'size': 0.27, 'image': 'images/jupiter.jpg', 'position': vector.Vector3(0.5, 0, -1.5), 'name': 'Jupiter'},
    {'size': 0.29, 'image': 'images/saturn.jpg', 'position': vector.Vector3(1.25, 0, -1.5), 'name': 'Saturn'},
    {'size': 0.15, 'image': 'images/uranus.png', 'position': vector.Vector3(2.0, 0, -1.5), 'name': 'Uranus'},
    {'size': 0.15, 'image': 'images/neptune.jpg', 'position': vector.Vector3(2.75, 0, -1.5), 'name': 'Neptune'},*/
  ];

  final Map<String, ArCoreNode> _planetNodes = {};
  late Timer _timer;
  final vector.Vector3 sunPosition = vector.Vector3(-1.5, 0, -1.5);
  double offset = 0.0;
  double angle = 0.0; // Current angle of rotation for Mercury
  final double mercuryDistance = 1; // Distance of Mercury from the Sun
  final double mercurySpeed = 0.5; // Speed of Mercury's rotation

  @override
  void initState() {
    super.initState();

    // Start a timer to double the size of the planets every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _scalePlanets();
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
    arCoreController.onPlaneTap = _onPlaneTap;

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

    final node = ArCoreNode(
      shape: sphere,
      position: position,
      name: name,
      // degreesPerSecond: 30.0,
      rotation: vector.Vector4(0, 1, 0, 10),
    );


    controller.addArCoreNode(node);

    _planetNodes[name] = node;

    controller.onNodeTap = (nodes) {
      _showToast("You tapped on $nodes!");
    };
  }

  void _scalePlanets() async{
    setState(() async {
      // Remove the existing Mercury node
      await arCoreController.removeNode(nodeName: 'Mercury');

      // Increment the angle for Mercury's rotation
      angle += mercurySpeed;

      // Calculate the new position of Mercury based on its orbit
      final double x = sunPosition.x + mercuryDistance * cos(angle);
      final double z = sunPosition.z + mercuryDistance * sin(angle);

      final updatedPosition = vector.Vector3(x, 0, z);

      // Add Mercury again at the updated position
      _addPlanet(
        arCoreController,
        0.2, // Mercury's size
        'images/mercury.jpg',
        updatedPosition,
        'Mercury',
      );

      // Log the updated position for debugging
      print("Updated Mercury Position: $updatedPosition");
    });
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

  Future<void> _onPlaneTap(List<ArCoreHitTestResult> hits) async {
   print("Plane tapped!");
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
        ],
      );
    },
  );
}


