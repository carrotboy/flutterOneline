import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/euler.dart';
import 'package:langaw/langaw-game.dart';
import 'package:langaw/main.dart' as prefix0;

import '../main.dart';

class MoveButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  MoveButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/import.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    game.mode = LangawGame.MODE_MOVE;
//    game.loadCrazyGameData();
//    prefix0.myApp.state.visible =false;
    myApp.state.setState((){prefix0.myApp.state.visible = false;});

  }
}


class NextButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  NextButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/next.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    if (game.mode != LangawGame.MODE_MOVE) return;
    game.mode = LangawGame.MODE_MOVE;
    if (prefix0.myApp.state.selectPos < prefix0.myApp.state.fileList.length-1) {
      initEuler(prefix0.myApp.state.fileList[++prefix0.myApp.state.selectPos].path);
    }

  }
}


class PreButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  PreButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/pre.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    if (game.mode != LangawGame.MODE_MOVE) return;
    game.mode = LangawGame.MODE_MOVE;
    if (prefix0.myApp.state.selectPos > 0) {
      initEuler(prefix0.myApp.state.fileList[--prefix0.myApp.state.selectPos].path);
    }
  }
}

class SaveButton {
  final LangawGame game;
  Rect rect;
  Sprite sprite;

  SaveButton(this.game, Rect rect) {
    this.rect = rect;
    sprite = Sprite('ui/save.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void onTapDown() {
    game.saveJson();
  }
}