import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';

class Score extends TextBoxComponent with ChangeNotifier {
  int _score = 0;

  int get value => _score;

  void addScore(int points) {
    _score += points;
    notifyListeners();
  }

  void reset() {
    _score = 0;
    notifyListeners();
  }

  @override
  String get text => _score.toString();
}