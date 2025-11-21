import 'dart:math' as math;

import 'package:flame/components.dart';

import '../game/tank_game.dart';
import 'Ground.dart';
import 'destructible_ground.dart';

class Projectile extends SpriteComponent with HasGameRef<TankGame> {
  final Vector2 initialVelocity;
  final Vector2 initialPos;

  final double rotationAngle;

  late Vector2 velocity;

  Projectile({required this.rotationAngle, required this.initialVelocity, required this.initialPos});

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('tanks/bullet.png');
    size = Vector2(16, 16); // adjust based on your image
    anchor = Anchor.bottomCenter;

    position = initialPos.clone(); // set starting location
    velocity = initialVelocity.clone();

    angle = rotationAngle;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // APPLY GRAVITY
    velocity.y += gameRef.gravity * dt;

    // MOVE PROJECTILE
    position += velocity * dt;

    // STOP WHEN HITTING GROUND
    final ground = gameRef.firstChild<DestructibleGround>();
    if (ground != null) {
      if (position.y >= ground.position.y) {
        const explosionRadius = 30.0;

        ground.makeHole(position.clone(), explosionRadius);

        removeFromParent(); // bullet removed
      }
    }
  }
}
