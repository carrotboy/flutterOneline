import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class EdgeRepeatButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  EdgeRepeatButton(this.game,Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-edge-repeat.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    game.mode = LangawGame.MODE_EDGE_REPEAT;
  }
}
