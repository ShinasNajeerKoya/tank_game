import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/tank_game.dart';

class PowerBar extends PositionComponent {
  @override
  double width = 50;
  @override
  double height = 10;

  @override
  Future<void> onLoad() async {
    size = Vector2(width, height);
    anchor = Anchor.topCenter;
  }

  @override
  void render(Canvas canvas) {
    final game = findGame() as TankGame;

    // background
    final bg = Paint()..color = Colors.white.withOpacity(0.4);
    final rRect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5));
    canvas.drawRRect(rRect, bg);

    // fill
    double filledWidth = (game.power / game.maxPower) * size.x;

    final fill = Paint()..color = Colors.red;

    final fillRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledWidth, size.y), const Radius.circular(5));
    canvas.drawRRect(fillRect, fill);
  }
}
