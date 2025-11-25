import 'dart:math' as math;
import 'package:flame/camera.dart';
import 'package:flame/components.dart';

extension CameraShake on CameraComponent {
  void shake({double intensity = 8, double duration = 0.2}) {
    final original = viewfinder.position.clone();
    double timer = 0;

    add(
      TimerComponent(
        period: 0.016,
        repeat: true,
        onTick: () {
          timer += 0.016;

          if (timer >= duration) {
            viewfinder.position = original;
            return;
          }

          final dx = (math.Random().nextDouble() - 0.5) * intensity;
          final dy = (math.Random().nextDouble() - 0.5) * intensity;

          viewfinder.position = original + Vector2(dx, dy);
        },
      ),
    );
  }
}
