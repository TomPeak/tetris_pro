import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'game.dart';

class MainGamePage extends StatefulWidget {
  const MainGamePage({super.key});

  @override
  MainGamePageState createState() => MainGamePageState();
}

class MainGamePageState extends State<MainGamePage> {
  MainGame game = MainGame();

  @override
  Widget build(BuildContext context) {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('tetris.ogg', volume: 1.0);
    return Scaffold(
        body: Stack(
      children: [
        GameWidget(game: game),
      ],
    ));
  }
}
