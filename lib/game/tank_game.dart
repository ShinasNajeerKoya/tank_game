// import 'package:flame/events.dart';
// import 'package:flame/extensions.dart';
// import 'package:flame/game.dart';
//
// import '../components/power_bar.dart';
// import '../components/projectile.dart';
// import '../components/tank.dart';
//
// class TankGame extends FlameGame with TapDetector {
//   double power = 0;
//   double maxPower = 400;
//   bool isCharging = false;
//   bool powerIncreasing = true; // <-- ADD THIS
//
//   double turretAngle = 0;
//   double turretSpeed = 1.5;
//   bool angleIncreasing = true;
//
//   @override
//   Color backgroundColor() => const Color(0xFF87CEEB);
//
//   @override
//   Future<void> onLoad() async {
//     add(Tank());
//     add(PowerBar());
//   }
//
//   @override
//   void onTapDown(TapDownInfo info) {
//     isCharging = true;
//   }
//
//   @override
//   void onTapUp(TapUpInfo info) {
//     isCharging = false;
//     fireProjectile();
//     power = 0;
//     powerIncreasing = true;
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//
//     // POWER CHARGING
//     if (isCharging) {
//       power += 200 * dt * (powerIncreasing ? 1 : -1);
//
//       if (power >= maxPower) {
//         power = maxPower;
//         powerIncreasing = false;
//       } else if (power <= 0) {
//         power = 0;
//         powerIncreasing = true;
//       }
//     }
//
//     // TURRET ROTATION
//     if (angleIncreasing) {
//       turretAngle += turretSpeed * dt;
//       if (turretAngle >= 3.14159) angleIncreasing = false;
//     } else {
//       turretAngle -= turretSpeed * dt;
//       if (turretAngle <= 0) angleIncreasing = true;
//     }
//   }
//
//   void fireProjectile() {
//     final tank = firstChild<Tank>();
//     if (tank == null) return;
//
//     final start = tank.firePoint;
//
//     // use the turret's actual visible angle (barrelAngle)
//     final double angle = tank.barrelAngle;
//
//     // compute velocity from power (you can scale power to taste)
//     final double speed = power; // or power * someFactor
//     final Vector2 velocity = Vector2(-speed, 0)..rotate(angle);
//
//     add(
//       Projectile(velocity, angle) // pass the rotation
//       ..position = start,
//     );
//   }
// }

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

import '../components/destructible_ground.dart';
import '../components/power_bar.dart';
import '../components/projectile.dart';
import '../components/tank.dart';
import '../components/ground.dart';

class TankGame extends FlameGame with TapDetector {
  double power = 0;
  double maxPower = 300;
  bool isCharging = false;
  bool powerIncreasing = true;

  double turretAngle = 0;
  double turretSpeed = 1.5;
  bool angleIncreasing = true;

  // Gravity constant
  final double gravity = 300; // pixels/s²

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  // @override
  // Future<void> onLoad() async {
  //   add(Tank());
  //   add(PowerBar());
  //   add(DestructibleGround());
  // }
  @override
  Future<void> onLoad() async {
    final tank = Tank();
    add(tank);
    add(DestructibleGround());
  }


  @override
  void onTapDown(TapDownInfo info) {
    isCharging = true;
  }

  @override
  void onTapUp(TapUpInfo info) {
    isCharging = false;
    fireProjectile();
    power = 0;
    powerIncreasing = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // POWER CHARGING
    if (isCharging) {
      power += 300 * dt * (powerIncreasing ? 1 : -1);

      if (power >= maxPower) {
        power = maxPower;
        powerIncreasing = false;
      } else if (power <= 0) {
        power = 0;
        powerIncreasing = true;
      }
    }

    // TURRET ROTATION
    if (angleIncreasing) {
      turretAngle += turretSpeed * dt;
      if (turretAngle >= 3.14159) angleIncreasing = false;
    } else {
      turretAngle -= turretSpeed * dt;
      if (turretAngle <= 0) angleIncreasing = true;
    }
  }

  void fireProjectile() {
    final tank = firstChild<Tank>();
    if (tank == null) return;

    final start = tank.firePoint;

    final double angle = tank.barrelAngle;

    final double speed = power;
    final Vector2 velocity = Vector2(-speed, 0)..rotate(angle);

    add(Projectile(rotationAngle: angle, initialVelocity: velocity, initialPos: start));
  }
}
