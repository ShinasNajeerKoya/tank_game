import 'package:flame/components.dart';

class HeartUI extends PositionComponent {
  final int maxHearts;
  int currentHearts;

  final double heartSize = 16;
  List<SpriteComponent> hearts = [];

  HeartUI({this.maxHearts = 3}) : currentHearts = maxHearts;

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < maxHearts; i++) {
      final heart = SpriteComponent()
        ..sprite = await Sprite.load('ui/heart.png')
        ..size = Vector2.all(heartSize)
        ..position = Vector2(i * (heartSize + 4), 0);

      hearts.add(heart);
      add(heart);
    }
  }

  void updateHearts(int count) {
    currentHearts = count;

    for (int i = 0; i < hearts.length; i++) {
      hearts[i].opacity = (i < currentHearts) ? 1.0 : 0.2;
    }
  }
}
