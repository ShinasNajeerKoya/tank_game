import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:forge2d/forge2d.dart';
import 'package:tank_game/components/power_bar.dart';
import 'package:tank_game/shared/extension/misc_extensions.dart';
import '../game/tank_game.dart';
import 'destructible_ground.dart';
import 'heart_ui.dart';

class Tank extends PositionComponent with HasGameRef<TankGame> {
  late SpriteComponent body;
  late SpriteComponent turret;
  late PowerBar powerBar;
  late HeartUI heartUI;

  final double spriteRotationOffset = -math.pi / 2;

  double verticalSpeed = 0; // gravity falling speed
  final double gravity = 600; // stronger for snappy falling

  final Vector2 turretOffset = Vector2(0, 40); // move down by 80 pixels

  int lives = 3;

  @override
  Future<void> onLoad() async {
    body =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/body.png')
          ..size = Vector2(60, 60)
          ..anchor = Anchor.bottomCenter
          ..position = Vector2(0, 40);

    turret =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/turret.png')
          ..size = Vector2(5, 40)
          ..anchor = Anchor.bottomCenter;

    add(turret);
    add(body);

    powerBar = PowerBar()..position = Vector2(0, -body.size.y + 100);
    // add(powerBar);

    position = Vector2(80, 0);

    add(powerBar);

    heartUI = HeartUI()..position = Vector2(-20, -80); // Above tank
    add(heartUI);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _applyGroundBinding(dt);
    _updateTurret();
  }

  void _updateTurret() {
    turret.angle = gameRef.turretAngle + spriteRotationOffset;

    turret.position = Vector2(-body.size.x * 0.1, -body.size.y * 0.7) + turretOffset;
  }

  /// Ground-following with slope-alignment.
  void _applyGroundBinding(double dt) {
    final ground = gameRef.firstChild<DestructibleGround>();
    if (ground == null) return;

    final leftX = position.x + width * 0.25;
    final rightX = position.x + width * 0.75;

    final leftY = ground.getGroundHeightAt(leftX);
    final rightY = ground.getGroundHeightAt(rightX);

    if (leftY == null || rightY == null) {
      /// No ground → fall
      verticalSpeed += gravity * dt;
      position.y += verticalSpeed * dt;
      return;
    }

    // Ground exists → snap or slide to it
    final midY = (leftY + rightY) * 0.5;

    // Smooth snap to ground
    position.y = lerpDouble(position.y, midY - body.size.y * 0.5, 0.2)!;

    // Reset fall speed
    verticalSpeed = 0;

    // Slope angle
    final slopeAngle = math.atan2(rightY - leftY, width);
    angle = slopeAngle * 0.4; // smooth, little tilt
  }

  double get barrelAngle => gameRef.turretAngle;

  Vector2 get firePoint {
    final world = turret.absoluteCenter;
    final tip = Vector2(-20, 0)..rotate(gameRef.turretAngle);
    return world + tip;
  }

  void loseLife() {
    lives -= 1;

    // Update UI
    heartUI.updateHearts(lives);

    // Flash effect
    body.add(
      SequenceEffect([
        OpacityEffect.to(0.2, EffectController(duration: 0.08)),
        OpacityEffect.to(1.0, EffectController(duration: 0.08)),
      ]),
    );

    // Camera shake
    gameRef.camera.shake(intensity: 5, duration: 0.2);

    if (lives <= 0) {
      _die();
    }
  }

  void _die() {
    removeFromParent();

    // Respawn after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      gameRef.spawnTank();
    });
  }





}
