import 'package:flutter/material.dart';
import 'main_game_page.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
  FlameAudio.bgm.initialize();
  FlameAudio.bgm.play('audio/tetris.ogg', volume: 1.0);
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tetris',
      home: MainGamePage(),
    );
  }
}
