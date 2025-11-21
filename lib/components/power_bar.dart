import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/tank_game.dart';

class PowerBar extends PositionComponent {
  @override
  Future<void> onLoad() async {
    size = Vector2(20, 150);  // width, height
    position = Vector2(20, 20); // top-left corner
  }

  @override
  void render(Canvas canvas) {
    final game = findGame() as TankGame;

    // background bar
    final bg = Paint()..color = Colors.white.withOpacity(0.4);
    canvas.drawRect(size.toRect(), bg);

    // filled power portion
    double filledHeight = (game.power / game.maxPower) * size.y;
    final fill = Paint()..color = Colors.red;

    canvas.drawRect(
      Rect.fromLTWH(0, size.y - filledHeight, size.x, filledHeight),
      fill,
    );
  }
}
