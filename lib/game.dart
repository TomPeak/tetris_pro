import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tetris/core/tetris_main.dart';
import 'package:tetris/core/tetris.dart';
import 'utility/direction.dart';
import 'utility/config.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:ui';

class MainGame extends FlameGame
    with KeyboardEvents, HasGameRef, TapCallbacks, DragCallbacks {
  final TetrisMain _tetris = TetrisMain();
  Score points = Score();
  final List<RectangleComponent> _wallComponentList = [];
  final List<RectangleComponent> _rectComponentList = [];
  final List<RectangleComponent> _nextMinoComponentList = [];
  bool drop = false;
  // @override
  // Color backgroundColor() => const Color.fromRGBO(89, 106, 108, 1.0);
  TextBoxComponent scoreText =
      TextBoxComponent(text: "0", position: Vector2(260.0, 320.0));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    await draw();
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('audio/tetris.ogg', volume: 1.0);
    _tetris.setRenderCallback(renderCallback);
    _tetris.setChangeMinoCallback(minoBottomHitCallback);

    var leftButton = SpriteButtonComponent(
        onPressed: () {
          _tetris.keyInput(Direction.left.name);
        },
        button: await loadSprite("left.png"),
        buttonDown: await loadSprite("left.png"),
        position: Vector2(20, 600),
        size: Vector2(60, 60));
    var rightButton = SpriteButtonComponent(
        onPressed: () {
          _tetris.keyInput(Direction.right.name);
        },
        button: await loadSprite("right.png"),
        buttonDown: await loadSprite("right.png"),
        position: Vector2(260, 600),
        size: Vector2(60, 60));
    var rotateButton = SpriteButtonComponent(
        onPressed: () {
          _tetris.keyInput(Direction.rotate.name);
        },
        button: await loadSprite("rotate.png"),
        buttonDown: await loadSprite("rotate.png"),
        position: Vector2(100, 600),
        size: Vector2(60, 60));
    var dropButton = SpriteButtonComponent(
        onPressed: () {
          do {
            _tetris.keyInput(Direction.down.name);
            // Solange runter bis angekommen.
          } while (!_tetris.getIsMinoBottomHit);
        },
        button: await loadSprite("drop.png"),
        buttonDown: await loadSprite("drop.png"),
        position: Vector2(180, 600),
        size: Vector2(60, 60));
    add(leftButton);
    add(rightButton);
    add(rotateButton);
    add(dropButton);
  }

  Future<void> draw() async {
    for (var y = 0; y < _tetris.displayBuffer.length; y++) {
      final row = _tetris.displayBuffer[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] == 1) {
          _wallComponentList
              .add(createBlock(x + 1, y + 1, getBlockPaint(row[x])));
        } else if (row[x] > 1) {
          _rectComponentList
              .add(createBlock(x + 1, y + 1, getBlockPaint(row[x])));
        }
      }
    }

    for (var wall in _wallComponentList) {
      add(wall);
    }
    for (var rect in _rectComponentList) {
      add(rect);
    }

    createNextMino();
    for (var nextMino in _nextMinoComponentList) {
      add(nextMino);
    }

    add(getRenderText('NEXT', 260.0, 30.0));
    add(getRenderText('LEVEL', 260.0, 180.0));
    add(getRenderText('1', 260.0, 220.0));
    add(getRenderText('SCORE', 260.0, 280.0));

    add(scoreText);

    // camera.followVector2(Vector2(pushGame.state.width * oneBlockSize / 2, pushGame.state.height * oneBlockSize / 2));
  }

  renderCallback() {
    resetRenderMino();
    renderMino();
  }

  // Hier kommt der Stein am Boden an Call back Wizard23
  minoBottomHitCallback() {
    resetRenderMino();
    renderMino();

    resetRenderNextMino();
    createNextMino();
    for (var nextMino in _nextMinoComponentList) {
      add(nextMino);
    }
    if (_tetris.isGameOver) {
      final regular = TextPaint(
          style: TextStyle(
          fontSize: 48.0,
          color: Color(0xFF990000 ),
      )
      );
      add(TextComponent(
          text: 'GAME OVER',
          position: Vector2(30, 280),
          textRenderer: regular));
      FlameAudio.bgm.stop();
    }
  }

  createNextMino() {
    for (var y = 0; y < _tetris.nextMinoShapeArray.length; y++) {
      final row = _tetris.nextMinoShapeArray[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] > 1) {
          _nextMinoComponentList
              .add(createBlock(x + 1, y + 1, getBlockPaint(row[x])));
        }
      }
    }
    for (var nextMino in _nextMinoComponentList) {
      nextMino.position.x = nextMino.position.x + 240;
      nextMino.position.y = nextMino.position.y + 40;
    }
  }

  createBlock(int x, int y, Paint paint) {
    return RectangleComponent(
      position: Vector2(oneBlockSize * x, oneBlockSize * y),
      size: Vector2.all(oneBlockSize),
      paint: paint,
    );
  }

  getBlockPaint(int no) {
    if (no == 1) {
      return paintMap['wall'];
    }
    final List<String> minoStringList = ['I', 'O', 'S', 'Z', 'J', 'L', 'T'];
    return paintMap['mino${minoStringList[no - 2]}'];
  }

  void resetRenderMino() {
    for (var rect in _rectComponentList) {
      remove(rect);
    }
    _rectComponentList.clear();
  }

  void renderMino() {
    for (var y = 0; y < _tetris.displayBuffer.length; y++) {
      final row = _tetris.displayBuffer[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] > 1) {
          _rectComponentList
              .add(createBlock(x + 1, y + 1, getBlockPaint(row[x])));
        }
      }
    }
    for (var rect in _rectComponentList) {
      add(rect);
    }
  }

  void resetRenderNextMino() {
    for (var nextMino in _nextMinoComponentList) {
      remove(nextMino);
    }
    _nextMinoComponentList.clear();
  }

  void renderNextMino() {
    createNextMino();
    for (var nextMino in _nextMinoComponentList) {
      add(nextMino);
    }
  }

  TextComponent getRenderText(String text, double x, double y) {
    const style = TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
    final regular = TextPaint(style: style);

    return TextComponent(text: text, textRenderer: regular)
      // ..anchor = Anchor.topCenter
      ..x = x
      ..y = y;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_tetris.isGameOver && !drop) {
      var mino = _rectComponentList[0];
      if ((mino.position.x > event.devicePosition.x - 60 &&
              mino.position.x < event.devicePosition.x) &&
          mino.position.y > event.devicePosition.y - 60 &&
          mino.position.y < event.devicePosition.y) {
        _tetris.keyInput(Direction.rotate.name);
      } else {
        if (event.devicePosition.x > mino.position.x) {
          _tetris.keyInput(Direction.right.name);
        } else {
          _tetris.keyInput(Direction.left.name);
        }
        debugPrint("${mino.position.x}mino");
        debugPrint("${event.devicePosition.x}Device");
      }
    }
  }

  //TODO Wizard23 Hier die Swipegesture down
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (event.localDelta.y > 0) {
      drop = true;
      do {
        _tetris.keyInput(Direction.down.name);
        // Solange runter bis angekommen.
      } while (!_tetris.getIsMinoBottomHit);
    }
    drop = false;
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    Direction keyDirection = Direction.none;

    if (!isKeyDown) {
      return super.onKeyEvent(event, keysPressed);
    }

    keyDirection = getKeyDirection(event);
    if (keyDirection != Direction.none && !_tetris.isGameOver) {
      _tetris.keyInput(keyDirection.name);
      return super.onKeyEvent(event, keysPressed);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  Direction getKeyDirection(KeyEvent event) {
    Direction keyDirection = Direction.none;
    if (event.logicalKey == LogicalKeyboardKey.keyA ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      keyDirection = Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.keyD ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      keyDirection = Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.keyW ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      keyDirection = Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.keyS ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      keyDirection = Direction.down;
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      keyDirection = Direction.rotate;
    }
    return keyDirection;
  }
}
