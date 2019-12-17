import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class CleanButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  CleanButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-clear.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {

    print('cleanbutton down');
    game.doClean();


  }
}
