import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class VertexButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  VertexButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-vertex.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {

    game.mode = LangawGame.MODE_VERTEX;
    game.doEdgeModeClean();
  }
}
