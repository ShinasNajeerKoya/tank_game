import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/tank_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- LOCK ORIENTATION TO LANDSCAPE ONLY ----
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(GameWidget(game: TankGame()));
}
