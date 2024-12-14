import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:fluttertoast/fluttertoast.dart';

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

    final List<Map<String, dynamic>> planets = [
      {'size': 0.5, 'image': 'images/sun.jpg', 'position': vector.Vector3(-2, 0, -1.5)},
      {'size': 0.1, 'image': 'images/mercury.jpg', 'position': vector.Vector3(-1.5, 0, -1.5)},
      {'size': 0.11, 'image': 'images/venus.jpg', 'position': vector.Vector3(-1, 0, -1.5)},
      {'size': 0.12, 'image': 'images/terra.jpg', 'position': vector.Vector3(-0.5, 0, -1.5)},
      {'size': 0.13, 'image': 'images/mars.jpg', 'position': vector.Vector3(0, 0, -1.5)},
      {'size': 0.27, 'image': 'images/jupiter.jpg', 'position': vector.Vector3(0.5, 0, -1.5)},
      {'size': 0.29, 'image': 'images/saturn.jpg', 'position': vector.Vector3(1.25, 0, -1.5)},
      {'size': 0.15, 'image': 'images/uranus.png', 'position': vector.Vector3(2.0, 0, -1.5)},
      {'size': 0.15, 'image': 'images/neptune.jpg', 'position': vector.Vector3(3.0, 0, -1.5)},
    ];

    for (var planet in planets) {
      _addPlanet(
        arCoreController,
        planet['size'],
        planet['image'],
        planet['position'],
      );
    }
  }

  Future<void> _addPlanet(ArCoreController controller, double radius,
      String texture, vector.Vector3 position) async {
    final material = ArCoreMaterial(
        color: Colors.red, textureBytes: await _loadTexture(texture));
    final sphere = ArCoreSphere(
      materials: [material],
      radius: radius,
    );

    var planetName = extractPlanetName(texture);

    final node = ArCoreNode(
      shape: sphere,
      position: position,
      name: planetName
    );
    controller.addArCoreNode(node);

    controller.onNodeTap = (nodes) {
      // if (nodes.contains(planetName)) {
        _showToast("You clicked on $nodes!");
      // }
    };
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
