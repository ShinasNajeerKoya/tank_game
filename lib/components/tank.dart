import 'dart:math' as math;

import 'package:flame/components.dart';

import '../game/tank_game.dart';

class Tank extends PositionComponent with HasGameRef<TankGame> {
  late SpriteComponent body;
  late SpriteComponent turret;

  final double spriteRotationOffset = -math.pi / 2;

  @override
  Future<void> onLoad() async {
    body =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/body.png')
          ..size = Vector2(80, 40)
          ..anchor = Anchor.bottomCenter;

    turret =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/turret.png')
          ..size = Vector2(15, 50)
          ..anchor = Anchor.bottomCenter;
    ;

    add(body);
    add(turret);

    position = Vector2(80, 300);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // rotate UPWARD instead of downward
    turret.angle = gameRef.turretAngle + spriteRotationOffset;
    turret.position = Vector2(-body.size.x * 0.1, -body.size.y * 0.8);
  }

  // double get barrelAngle => turret.angle + math.pi / 2;
  // double get barrelAngle => turret.angle;
  double get barrelAngle => gameRef.turretAngle;

  Vector2 get firePoint {
    final world = turret.absoluteCenter;
    // final tip = Vector2(25, 0)..rotate(turret.angle);
    final tip = Vector2(-20, 0)..rotate(gameRef.turretAngle);

    return world + tip;
  }

  Vector2 get firePoint2 {
    // muzzle position in turret's local coordinates
    final offset = Vector2(-100, turret.size.y);

    // rotate that local offset by *game angle*, not sprite angle
    final rotated = offset.clone()..rotate(gameRef.turretAngle);

    // convert from local -> world coordinates
    return turret.absolutePosition + rotated;
  }
}
