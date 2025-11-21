import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class CollisionFlash extends SpriteComponent {
  CollisionFlash()
      : super(
    size: Vector2(40, 40),     // adjust for your explosion size
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('effects/tank_explosion.png');

    // Fade out + remove automatically
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.15),  // quick flash
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
