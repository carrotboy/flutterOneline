import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class LoadButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  LoadButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-load.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
//    game.loadCandidateLevelData();
//    game.loadCrazyGameData();
  game.generateAllAnswers();
   // game.saveAllJson();

  }
}
