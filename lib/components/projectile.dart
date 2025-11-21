import 'dart:math' as math;

import 'package:flame/components.dart';

import '../game/tank_game.dart';

class Projectile extends SpriteComponent with HasGameRef<TankGame> {
  final Vector2 velocity;
  final double rotationAngle;

  Projectile(this.velocity, this.rotationAngle);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('tanks/bullet.png');
    size = Vector2(16, 16); // adjust based on your image
    anchor = Anchor.bottomCenter;

    angle = rotationAngle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }
}
