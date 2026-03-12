import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_engine/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_engine/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Vector4;

/// Configuration pour chaque modèle 3D disponible en AR
class _ARModelConfig {
  const _ARModelConfig({
    required this.assetPath,
    required this.localFileName,
    required this.label,
    required this.icon,
    this.scale = 0.4,
  });
  final String assetPath;
  final String localFileName;
  final String label;
  final IconData icon;
  final double scale;
}

class ArViewScreen extends StatefulWidget {
  const ArViewScreen({super.key});

  @override
  State<ArViewScreen> createState() => _ArViewScreenState();
}

class _ArViewScreenState extends State<ArViewScreen> {
  ARSessionManager? _arSessionManager;
  ARObjectManager? _arObjectManager;
  ARAnchorManager? _arAnchorManager;

  bool _isPlaneDetected = false;
  bool _isPlacingObject = false;
  bool _isModelPrepared = false;
  int _selectedModelIndex = 0;

  /// Dernier nœud et anchor placés (un seul modèle affiché à la fois)
  ARNode? _lastPlacedNode;
  ARPlaneAnchor? _lastPlacedAnchor;
  double _currentModelScale = 0.4;
  double _scaleOnPinchStart = 0.4;
  static const double _minScale = 0.15;
  static const double _maxScale = 1.5;

  static const List<_ARModelConfig> _arModels = [
    _ARModelConfig(
      assetPath: 'images/hover_bike_-_the_rocket.glb',
      localFileName: 'hover_bike_rocket.glb',
      label: 'Hover Bike',
      icon: Icons.two_wheeler,
      scale: 0.4,
    ),
    _ARModelConfig(
      assetPath: 'images/fpv-dron_nonstop.glb',
      localFileName: 'fpv_dron_nonstop.glb',
      label: 'FPV Drone',
      icon: Icons.flight,
      scale: 0.4,
    ),
  ];

  @override
  void dispose() {
    _arSessionManager?.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleOnPinchStart = _currentModelScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_lastPlacedNode == null) return;
    final newScale = (_scaleOnPinchStart * details.scale).clamp(_minScale, _maxScale);
    _currentModelScale = newScale;
    _lastPlacedNode!.scale = Vector3(newScale, newScale, newScale);
  }

  /// Supprime le modèle actuellement affiché (un seul modèle à la fois).
  Future<void> _removeCurrentModel() async {
    if (_lastPlacedAnchor == null) return;
    try {
      await _arAnchorManager?.removeAnchor(_lastPlacedAnchor!);
    } catch (e) {
      debugPrint('Erreur suppression modèle AR: $e');
    }
    _lastPlacedNode = null;
    _lastPlacedAnchor = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Stack(
          children: [
            ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
            ),

          // Top bar with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _arModels[_selectedModelIndex].icon,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _arModels[_selectedModelIndex].label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable model selector (smaller icons, above instruction)
          Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _arModels.length,
                  itemBuilder: (context, index) {
                    final model = _arModels[index];
                    final isSelected = index == _selectedModelIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () async {
                          if (index == _selectedModelIndex) return;
                          await _removeCurrentModel();
                          if (mounted) {
                            setState(() {
                              _selectedModelIndex = index;
                            });
                          }
                        },
                        child: Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF6093D).withOpacity(0.9)
                                : Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                model.icon,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                model.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Instruction overlay
          Positioned(
            left: 12,
            right: 12,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        !_isPlaneDetected
                            ? 'Bouge ton téléphone pour détecter les surfaces'
                            : _isPlacingObject
                                ? 'Placement du modèle...'
                                : _lastPlacedNode != null
                                    ? 'Pince avec deux doigts pour zoomer sur le modèle'
                                    : 'Tape sur une surface pour placer le modèle 3D',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) async {
    _arSessionManager = arSessionManager;
    _arObjectManager = arObjectManager;
    _arAnchorManager = arAnchorManager;

    // Préparer le modèle GLB dans le dossier documents de l'app
    await _prepareLocalModelFile();

    await _arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: null,
      showWorldOrigin: false,
      handleTaps: true,
    );

    await _arObjectManager?.onInitialize();

    _arSessionManager?.onPlaneOrPointTap = _onPlaneOrPointTapped;
  }

  /// Copie les modèles GLB du dossier assets vers le dossier Documents de l'application
  /// pour pouvoir les utiliser avec NodeType.fileSystemAppFolderGLB.
  Future<void> _prepareLocalModelFile() async {
    if (_isModelPrepared) return;

    try {
      final documentsDir = await getApplicationDocumentsDirectory();

      for (final model in _arModels) {
        final targetFile =
            File('${documentsDir.path}/${model.localFileName}');
        if (!await targetFile.exists()) {
          final byteData = await rootBundle.load(model.assetPath);
          await targetFile.writeAsBytes(
            byteData.buffer.asUint8List(),
            flush: true,
          );
        }
      }

      _isModelPrepared = true;
    } catch (e) {
      debugPrint('Erreur préparation modèles GLB locaux: $e');
    }
  }

  Future<void> _onPlaneOrPointTapped(List<ARHitTestResult> hits) async {
    if (hits.isEmpty || _isPlacingObject) return;

    await _removeCurrentModel();

    final hit = hits.firstWhere(
      (result) => result.type == ARHitTestResultType.plane,
      orElse: () => hits.first,
    );

    setState(() {
      _isPlaneDetected = true;
      _isPlacingObject = true;
    });

    try {
      final anchor = ARPlaneAnchor(transformation: hit.worldTransform);

      final didAddAnchor = await _arAnchorManager?.addAnchor(anchor) ?? false;
      if (!didAddAnchor) {
        throw Exception('Impossible d’ajouter un anchor AR');
      }

      final model = _arModels[_selectedModelIndex];
      _currentModelScale = model.scale;
      final node = ARNode(
        type: NodeType.fileSystemAppFolderGLB,
        uri: model.localFileName,
        scale: Vector3(model.scale, model.scale, model.scale),
        position: Vector3(0.0, 0.0, 0.0),
        rotation: Vector4(1.0, 0.0, 0.0, 0.0),
      );

      final didAddNode = await _arObjectManager?.addNode(
            node,
            planeAnchor: anchor,
          ) ??
          false;

      if (!didAddNode) {
        throw Exception('Impossible d’ajouter le modèle 3D');
      }
      _lastPlacedNode = node;
      _lastPlacedAnchor = anchor;
    } catch (e) {
      debugPrint('Error placing AR object: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du placement du modèle: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingObject = false;
        });
      }
    }
  }
}

