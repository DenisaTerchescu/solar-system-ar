import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

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

    // Sun
    _addPlanet(
        arCoreController, 0.5, 'images/sun.jpg', vector.Vector3(-2, 0, -1.5));

    // Mercury
    _addPlanet(
        arCoreController, 0.1, 'images/mercury.jpg', vector.Vector3(-1.5, 0, -1.5));

    // Venus
    _addPlanet(
        arCoreController, 0.11, 'images/venus.jpg', vector.Vector3(-1, 0, -1.5));

    // Earth
    _addPlanet(
        arCoreController, 0.12, 'images/terra.jpg', vector.Vector3(-0.5, 0, -1.5));

    // Mars
    _addPlanet(
        arCoreController, 0.13, 'images/mars.jpg', vector.Vector3(0, 0, -1.5));

    // Jupiter
    _addPlanet(
        arCoreController, 0.27, 'images/jupiter.jpg', vector.Vector3(0.5, 0, -1.5));

    // Saturn
    _addPlanet(
        arCoreController, 0.29, 'images/saturn.jpg', vector.Vector3(1.5, 0, -1.5));

    // Uranus
    _addPlanet(
        arCoreController, 0.15, 'images/uranus.png', vector.Vector3(2.0, 0, -1.5));

    // Neptune
    _addPlanet(
        arCoreController, 0.15, 'images/neptune.jpg', vector.Vector3(2.5, 0, -1.5));
  }

  Future<void> _addPlanet(ArCoreController controller, double radius,
      String texture, vector.Vector3 position) async {
    final material = ArCoreMaterial(
        color: Colors.red, textureBytes: await _loadTexture(texture));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: radius,
    );

    final node = ArCoreNode(
      shape: sphere,
      position: position,
    );
    controller.addArCoreNode(node);
  }

  @override
  void dispose() {
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
