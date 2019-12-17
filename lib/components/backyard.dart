import 'dart:ui';
import 'package:flame/sprite.dart';
import 'package:langaw/langaw-game.dart';

class Backyard {
  final LangawGame game;
  Sprite bgSprite;
  Rect bgRect;

  Backyard(this.game) {

    bgRect = Rect.fromLTWH(0, 0, game.screenSize.width, game.screenSize.height);

  }


  void render(Canvas c) {
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xffffffff);
    c.drawRect(bgRect, bgPaint);


    Paint linePaint = Paint();
    linePaint.color = Color(0xffff0000);

    double theButtomOpBarHeight = 70;


    double height = game.screenSize.height;
    double width = game.screenSize.width;

    Offset startPoint = Offset(0,  game.screenSize.height - theButtomOpBarHeight);
    Offset endPoint = Offset(game.screenSize.width,  game.screenSize.height - theButtomOpBarHeight);


    double yLimit =  game.screenSize.height;

    if(yLimit > LangawGame.Y_LIMIT)
      {
        yLimit = LangawGame.Y_LIMIT;
      }

    double xLimit = game.screenSize.width;
    if(xLimit > LangawGame.X_LIMIT)
      {
        xLimit = LangawGame.X_LIMIT;
      }

    // draw horizon
      int counter = 0;
      for(double baseLineY = LangawGame.Y_MIN_LIMIT;  baseLineY <=  yLimit ; baseLineY = baseLineY + LangawGame.BACK_GRID_STEP )
      {
        startPoint = Offset(LangawGame.X_MIN_LIMIT,  baseLineY);
        //endPoint = Offset(game.screenSize.width,  baseLineY);
        endPoint = Offset(xLimit,  baseLineY);
        Paint baselinePaint = Paint();
        baselinePaint.color = Color(0xff000000);
        baselinePaint.strokeWidth = 1;
        if(counter %  3 == 0) {
          baselinePaint.color = Color(0xffff0000);
          baselinePaint.strokeWidth = 2;
        }
        c.drawLine(startPoint, endPoint, baselinePaint);

        counter ++ ;
      }


      //draw vertical
    counter = 0;
    for(double baseLineX = LangawGame.X_MIN_LIMIT;  baseLineX <=  xLimit ; baseLineX = baseLineX + LangawGame.BACK_GRID_STEP )
    {
      startPoint = Offset(baseLineX,  LangawGame.Y_MIN_LIMIT);
      endPoint = Offset(baseLineX,  LangawGame.Y_LIMIT);


      Paint baselinePaint = Paint();
      baselinePaint.color = Color(0xff000000);
      baselinePaint.strokeWidth = 1;
      if(counter %  3 == 0) {
        baselinePaint.color = Color(0xffff0000);
        baselinePaint.strokeWidth = 2;
      }
      c.drawLine(startPoint, endPoint, baselinePaint);

      counter ++ ;
    }



  }

  void update(double t) {}
}
