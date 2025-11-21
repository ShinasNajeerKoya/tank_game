import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class MuzzleFlash extends SpriteComponent {
  MuzzleFlash() : super(size: Vector2(50, 50), anchor: Anchor.centerRight);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('effects/muzzle_flash.png');

    // tiny flash effect
    add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.08), // very quick fade
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
