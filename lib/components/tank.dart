import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:tank_game/components/power_bar.dart';

import '../game/tank_game.dart';

class Tank extends PositionComponent with HasGameRef<TankGame> {
  late SpriteComponent body;
  late SpriteComponent turret;
  late PowerBar powerBar;

  final double spriteRotationOffset = -math.pi / 2;

  @override
  Future<void> onLoad() async {
    body =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/body.png')
          ..size = Vector2(60, 60)
          ..anchor = Anchor.bottomCenter;

    turret =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/turret.png')
          ..size = Vector2(5, 40)
          ..anchor = Anchor.bottomCenter;

    add(turret);
    add(body);

    // Add power bar UNDER the tank
    powerBar = PowerBar()..position = Vector2(0, -body.size.y + 65); // 5px below the tank
    add(powerBar);

    position = Vector2(80, 300);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // rotate UPWARD instead of downward
    turret.angle = gameRef.turretAngle + spriteRotationOffset;
    turret.position = Vector2(-body.size.x * 0.1, -body.size.y * 0.7);
  }

  double get barrelAngle => gameRef.turretAngle;

  Vector2 get firePoint {
    final world = turret.absoluteCenter;
    final tip = Vector2(-20, 0)..rotate(gameRef.turretAngle);

    return world + tip;
  }
}
