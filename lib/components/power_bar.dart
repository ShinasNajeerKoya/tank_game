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

    // If in cooldown → show reverse timer bar
    if (game.isCoolingDown) {
      double progress = game.cooldownTimer / game.cooldownTime; // 1 → 0
      final cooldownPaint = Paint()..color = Colors.white;

      final cooldownRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x * progress, size.y),
        const Radius.circular(5),
      );

      canvas.drawRRect(cooldownRect, cooldownPaint);
      return; // do NOT draw power bar during cooldown
    }

    // Normal power bar
    double filledWidth = (game.power / game.maxPower) * size.x;
    final fill = Paint()..color = Colors.red;

    final fillRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, filledWidth, size.y), const Radius.circular(5));

    canvas.drawRRect(fillRect, fill);
  }
}
