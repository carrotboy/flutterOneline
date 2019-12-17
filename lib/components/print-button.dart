import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class PrintButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  PrintButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/icon-print.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {

//    game.activeView = View.help;

    print('cleanbutton down');
    game.doPrint();


  }
}
