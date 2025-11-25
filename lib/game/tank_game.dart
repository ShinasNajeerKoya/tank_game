import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

import '../components/bot_tank.dart';
import '../components/destructible_ground.dart';
import '../components/muzzle_flash.dart';
import '../components/projectile.dart';
import '../components/tank.dart';

class TankGame extends FlameGame with TapDetector {
  double power = 0;
  double maxPower = 450;
  bool isCharging = false;
  bool powerIncreasing = true;

  double turretAngle = 0;
  double turretSpeed = 4;
  bool angleIncreasing = true;

  // Gravity constant
  final double gravity = 300;

  bool isCoolingDown = false;
  double cooldownTime = 1.5;
  double cooldownTimer = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    add(DestructibleGround());

    final playerTank = Tank()..position = Vector2(200, 300);
    add(playerTank);

    // final bot = BotTank(target: playerTank, accuracy: 0.7, fireInterval: 2.5)
    //   ..position = Vector2(200, 900); // right side
    // add(bot);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (isCoolingDown) return; // cannot charge during cooldown
    isCharging = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    if (isCoolingDown) return; // cannot fire during cooldown

    isCharging = false;
    fireProjectile();

    // RESET POWER
    power = 0;
    powerIncreasing = true;

    // START COOLDOWN
    isCoolingDown = true;
    cooldownTimer = cooldownTime;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // --- COOLDOWN HANDLING ---
    if (isCoolingDown) {
      cooldownTimer -= dt;
      if (cooldownTimer <= 0) {
        cooldownTimer = 0;
        isCoolingDown = false;
      }
    }

    // --- POWER CHARGING (allowed only if not cooling) ---
    if (isCharging && !isCoolingDown) {
      power += 400 * dt * (powerIncreasing ? 1 : -1);

      if (power >= maxPower) {
        power = maxPower;
        powerIncreasing = false;
      } else if (power <= 0) {
        power = 0;
        powerIncreasing = true;
      }
    }

    // --- TURRET ROTATION ---
    if (!isCharging) {
      if (angleIncreasing) {
        turretAngle += turretSpeed * dt;
        if (turretAngle >= 3.14159) angleIncreasing = false;
      } else {
        turretAngle -= turretSpeed * dt;
        if (turretAngle <= 0) angleIncreasing = true;
      }
    }
  }

  void fireProjectile() {
    final tank = firstChild<Tank>();
    if (tank == null) return;

    final start = tank.firePoint;
    final angle = tank.barrelAngle;
    final double speed = power;

    // --- ADD MUZZLE FLASH ----
    final flash =
        MuzzleFlash()
          ..position = start.clone()
          ..angle = angle;
    add(flash);

    // ---- FIRE PROJECTILE ----
    final velocity = Vector2(-speed, 0)..rotate(angle);

    add(Projectile(rotationAngle: angle, initialVelocity: velocity, initialPos: start));
  }


  void spawnTank() {
    final tank = Tank()
      ..position = Vector2(80, 0);  // respawn position
    add(tank);
  }
}
