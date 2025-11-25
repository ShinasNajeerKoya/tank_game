import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import '../game/tank_game.dart';
import 'projectile.dart';
import 'muzzle_flash.dart';
import 'destructible_ground.dart';
import 'power_bar.dart';

class BotTank extends PositionComponent with HasGameRef<TankGame> {
  late SpriteComponent body;
  late SpriteComponent turret;
  late PowerBar powerBar;

  final Vector2 turretOffset = Vector2(0, 40);
  final double spriteRotationOffset = -math.pi / 2;

  double verticalSpeed = 0;
  final double gravity = 600;

  // Bot AI properties
  final double accuracy; // 0 = bad, 1 = perfect
  final double fireInterval; // seconds between shots
  double fireTimer = 0;
  final math.Random random = math.Random();

  // Current turret angle
  double turretAngle = 0;

  // Turret rotation limits (in radians)
  final double minTurretAngle = -math.pi / 2; // left-most
  final double maxTurretAngle = math.pi / 2; // right-most

  // Power charging
  double power = 0;
  double maxPower = 450;
  bool isCharging = false;
  bool powerIncreasing = true;
  double chargeSpeed = 400;

  // Target player
  final PositionComponent target;

  BotTank({required this.target, this.accuracy = 0.7, this.fireInterval = 2.5});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Body sprite
    body =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/body.png')
          ..size = Vector2(60, 60)
          ..anchor = Anchor.bottomCenter
          ..position = Vector2(0, 40);

    // Turret sprite
    turret =
        SpriteComponent()
          ..sprite = await Sprite.load('tanks/turret.png')
          ..size = Vector2(5, 40)
          ..anchor = Anchor.bottomCenter;

    add(turret);
    add(body);

    // Power bar
    powerBar = PowerBar()..position = Vector2(0, -body.size.y + 100);
    // add(powerBar);

    position = Vector2(500, 0); // start on right side
  }

  @override
  void update(double dt) {
    super.update(dt);

    _applyGroundBinding(dt);
    _updateTurretRotation(dt);
    _chargePower(dt);
    _fireTimerUpdate(dt);
    _updateTurretPosition();
    // _updatePowerBar();
  }

  /// Ground following
  void _applyGroundBinding(double dt) {
    final ground = gameRef.firstChild<DestructibleGround>();
    if (ground == null) return;

    final leftX = position.x + 15;
    final rightX = position.x + 45;

    final leftY = ground.getGroundHeightAt(leftX);
    final rightY = ground.getGroundHeightAt(rightX);

    if (leftY == null || rightY == null) {
      verticalSpeed += gravity * dt;
      position.y += verticalSpeed * dt;
      return;
    }

    final midY = (leftY + rightY) * 0.5;
    position.y = lerpDouble(position.y, midY - body.size.y * 0.5, 0.2)!;
    verticalSpeed = 0;

    final slopeAngle = math.atan2(rightY - leftY, body.size.x);
    angle = slopeAngle * 0.4;
  }

  /// Smooth turret rotation with 180° limit
  void _updateTurretRotation(double dt) {
    // 1. Target direction
    final dx = target.position.x - position.x;
    final dy = target.position.y - position.y;

    // IMPORTANT: The player's turret uses only 0 → PI
    double targetAngle = math.atan2(dy, dx);

    // Convert angle from (-PI..PI) → (0..PI)
    if (targetAngle < 0) targetAngle += math.pi;

    // 2. Add inaccuracy
    final maxOffset = (1 - accuracy) * math.pi / 12; // ±15°
    targetAngle += (random.nextDouble() * 2 - 1) * maxOffset;

    // 3. Clamp to same limits as the player turret
    targetAngle = targetAngle.clamp(0, math.pi);

    // 4. Smooth rotation
    const double rotateSpeed = 2.5;
    final diff = targetAngle - turretAngle;
    turretAngle += diff.clamp(-rotateSpeed * dt, rotateSpeed * dt);
  }

  /// Clamp an angle to min/max within -π..π
  double _clampAngle(double angle, double min, double max) {
    while (angle < -math.pi) angle += 2 * math.pi;
    while (angle > math.pi) angle -= 2 * math.pi;
    return angle.clamp(min, max);
  }

  void _updateTurretPosition() {
    turret.angle = turretAngle + spriteRotationOffset;
    turret.position = Vector2(-body.size.x * 0.1, -body.size.y * 0.7) + turretOffset;
  }

  /// Power charging
  void _chargePower(double dt) {
    isCharging = true; // bot always charges
    if (isCharging) {
      power += chargeSpeed * dt * (powerIncreasing ? 1 : -1);
      if (power >= maxPower) {
        power = maxPower;
        powerIncreasing = false;
      } else if (power <= 0) {
        power = 0;
        powerIncreasing = true;
      }
    }
  }

  // void _updatePowerBar() {
  //   powerBar.currentPower = power / maxPower;
  // }

  /// Firing projectiles
  void _fireTimerUpdate(double dt) {
    fireTimer -= dt;
    if (fireTimer <= 0) {
      _fireProjectile();
      fireTimer = fireInterval + random.nextDouble();
      power = 0; // reset power after shot
      powerIncreasing = true;
    }
  }

  Vector2 get firePoint {
    final world = turret.absoluteCenter;
    final tip = Vector2(-20, 0)..rotate(turretAngle);
    return world + tip;
  }

  void _fireProjectile() {
    final start = firePoint;
    final velocity = Vector2(-power, 0)..rotate(turretAngle);

    final flash =
        MuzzleFlash()
          ..position = start.clone()
          ..angle = turretAngle;
    gameRef.add(flash);

    gameRef.add(Projectile(rotationAngle: turretAngle, initialVelocity: velocity, initialPos: start));
  }
}
