import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class UndoButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  UndoButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-undo.png');

  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);

  }

  void onTapDown() {

    game.unDo();

  }
}
