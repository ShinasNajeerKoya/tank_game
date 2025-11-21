import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tank_game/game/tank_game.dart';

class DestructibleGround extends SpriteComponent with HasGameRef<TankGame> {
  ui.Image? _image;

  DestructibleGround()
      : super(
    size: Vector2(800, 200),
    position: Vector2(0, 340),
    anchor: Anchor.topLeft,
  );

  @override
  Future<void> onLoad() async {
    // load your ground.png from assets
    _image = await gameRef.images.load('tanks/ground.png');
    sprite = Sprite(_image!);
  }

  /// Creates a circular hole at the impact point.
  Future<void> makeHole(Vector2 worldPos, double radius) async {
    if (_image == null) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // draw existing terrain
    canvas.drawImage(_image!, Offset.zero, Paint());

    // eraser circle
    final erasePaint = Paint()
      ..blendMode = BlendMode.clear;

    // convert world coords → local coords
    final local = worldPos - position;

    canvas.drawCircle(
      Offset(local.x, local.y),
      radius,
      erasePaint,
    );

    final picture = recorder.endRecording();

    final newImage =
    await picture.toImage(size.x.toInt(), size.y.toInt());

    _image = newImage;
    sprite = Sprite(newImage);
  }
}
