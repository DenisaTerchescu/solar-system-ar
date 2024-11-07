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

    // sun
    _addPlanet(
        arCoreController, 1, 'images/sun.jpg', vector.Vector3(-2, 0, -1.5));

    // mercury
    _addPlanet(
        arCoreController, 0.1, 'images/mercury.jpg', vector.Vector3(0, 0, -1.5));

    // venus
    _addPlanet(
        arCoreController, 0.12, 'images/venus.jpg', vector.Vector3(0.25, 0, -1.5));

    // earth
    _addPlanet(
        arCoreController, 0.14, 'images/earth.jpg', vector.Vector3(0.5, 0, -1.5));

    // mars
    _addPlanet(
        arCoreController, 0.16, 'images/mars.jpg', vector.Vector3(1, 0, -1.5));

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
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
