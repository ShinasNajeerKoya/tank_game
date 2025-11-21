import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Ground extends RectangleComponent {
  Ground() : super(
    position: Vector2(0, 340),
    size: Vector2(800, 200),
    paint: Paint()..color = Colors.brown,
  );
}
