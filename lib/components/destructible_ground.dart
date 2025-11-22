import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/tank_game.dart';

class DestructibleGround extends SpriteComponent with HasGameRef<TankGame> {
  ui.Image? _image;

  /// RGBA pixel buffer (updated each time a hole is made)
  late Uint8List pixelData;

  /// Cached height map: for every x → first solid y
  late List<int> heightMap;

  DestructibleGround() : super(size: Vector2(800, 200), position: Vector2(0, 340), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    _image = await gameRef.images.load('tanks/ground.png');

    sprite = Sprite(_image!);

    await _updatePixelAndHeightMaps();
  }

  Future<void> _updatePixelAndHeightMaps() async {
    if (_image == null) return;

    final byteData = await _image!.toByteData(format: ui.ImageByteFormat.rawRgba);
    pixelData = byteData!.buffer.asUint8List();

    final width = _image!.width;
    final height = _image!.height;

    heightMap = List.filled(width, height);

    // Build heightMap
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final index = (y * width + x) * 4;
        final alpha = pixelData[index + 3];
        if (alpha > 10) {
          heightMap[x] = y;
          break;
        }
      }
    }
  }

  /// Get the world-ground height at a given X.
  double? getGroundHeightAt(double worldX) {
    if (_image == null) return null;

    final localX = (worldX - position.x).round();
    if (localX < 0 || localX >= heightMap.length) return null;

    final h = heightMap[localX];

    return (h >= _image!.height) ? null : position.y + h.toDouble();
  }

  /// Create circular hole and regenerate pixel + height maps.
  Future<void> makeHole(Vector2 worldPos, double radius) async {
    if (_image == null) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(_image!, Offset.zero, Paint());

    final erasePaint = Paint()..blendMode = BlendMode.clear;

    final local = worldPos - position;

    canvas.drawCircle(Offset(local.x, local.y), radius, erasePaint);

    final picture = recorder.endRecording();

    final newImage = await picture.toImage(size.x.toInt(), size.y.toInt());

    _image = newImage;
    sprite = Sprite(newImage);

    // Extend ground to required depth

    await _updatePixelAndHeightMaps(); // fast & optimized
  }
}
