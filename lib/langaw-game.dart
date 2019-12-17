import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as prefix2;
import 'package:langaw/components/backyard.dart';
import 'package:langaw/components/edge-button.dart';
import 'package:langaw/components/edge-repeat-button.dart';
import 'package:langaw/components/edge-direction-button.dart';
import 'package:langaw/components/clean-button.dart';
import 'package:langaw/components/level_data_product.dart';
import 'package:langaw/components/move-button.dart';
import 'package:langaw/components/print-button.dart';
import 'package:langaw/components/vertex-button.dart';
import 'package:langaw/components/load-button.dart';
import 'package:langaw/components/undo-button.dart';
import 'package:langaw/edge.dart' as prefix1;
import 'package:langaw/file-util.dart';
import 'package:langaw/level-data-tune.dart';
import 'package:langaw/daily-challenge-level-data.dart';
import 'package:langaw/level_data_generate.dart';
import 'package:langaw/main.dart';
import 'package:langaw/oneline-basic.dart';
import 'package:langaw/symmetry.dart';
import 'package:langaw/translate-data.dart';
import 'package:langaw/translate-data.dart' as prefix0;
import 'package:langaw/view.dart';
import 'package:langaw/edge.dart';
import 'package:langaw/vertex.dart';
import 'package:langaw/level-data.dart';
import 'package:flame/sprite.dart';
import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'euler.dart';


class LangawGame extends Game {

  Size screenSize;

  Backyard background;

  VertexButton vertexButton;
  EdgeButton edgeButton;
  CleanButton cleanButton;
  PrintButton printButton;
  UndoButton undoButton;
  EdgeDirectionButton edgeDirectionButton;
  EdgeRepeatButton edgeRepeatButton;
  LoadButton loadButton;
  MoveButton moveButton;
  NextButton nextButton;
  PreButton preButton;
  SaveButton saveButton;


  View activeView = View.home;

  List<Offset> vertexList = [];
  List<Edge> edgeList = [];
  List<List<bool>> connect;

  Offset tempStartPoint;
  int tempStartPointIndex = -2;
  Offset tempCurrentPoint;
  Offset tempLastDragPoint;

  static const int MODE_VERTEX = 0;

  static const int MODE_EDGE = 1;

  static const int MODE_EDGE_LOCK = 2;

  static const int MODE_EDGE_REPEAT = 3;

  static const int MODE_MOVE = 4;

  int mode = MODE_VERTEX;

  static const double theButtomOpBarHeight = 70;
  static const double VERTEX_RADIUS = 10;
  static const double VERTEX_FONT_SIZE = 16;
  static const double LINE_CONNETED_EDGE = 6;
  static const double LINE_CONNETED_REPEATED_EDGE = 4;
  static const double DISTANCE_CHECK_THRESHHOLD = 30;

//  static const double X_MIN_LIMIT = 240;
//  static const double X_LIMIT = X_MIN_LIMIT + 540;
//  static const double Y_MIN_LIMIT = 240;
//  static const double Y_LIMIT = Y_MIN_LIMIT + 750;

  static const double X_MIN_LIMIT = 100;
  static const double X_LIMIT = X_MIN_LIMIT + 540;
  static const double Y_MIN_LIMIT = 100;
  static const double Y_LIMIT = Y_MIN_LIMIT + 750;


  static const double ICON_SIZE = 40;
  static const double ICON_TAP = 40;

  static const double MODE_FONT_SIZE = 50;
  static const double MODE_SPECIAL_FONT_SIZE = 55;

  static const double ICON_DIRECTION_SIZE = 10;

  static const double BACK_GRID_STEP = 30;

  static const double FINAL_HEIGHT = 924;
  static const double FINAL_WIDTH = 840;

  bool skipRender = false;

  Sprite directionSprite;

  String storagePath = '';
  String outPutPngFilePath = "";


  LangawGame() {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    background = Backyard(this);


    double rectX = X_LIMIT + ICON_SIZE;

    Rect rect = Rect.fromLTWH(rectX, Y_MIN_LIMIT, ICON_SIZE, ICON_SIZE);
    vertexButton = VertexButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + ICON_SIZE + ICON_TAP, ICON_SIZE, ICON_SIZE);
    edgeButton = EdgeButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 2, ICON_SIZE, ICON_SIZE);
    edgeRepeatButton = EdgeRepeatButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 3, ICON_SIZE, ICON_SIZE);
    edgeDirectionButton = EdgeDirectionButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 4, ICON_SIZE, ICON_SIZE);
    undoButton = UndoButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 5, ICON_SIZE, ICON_SIZE);
    printButton = PrintButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 6, ICON_SIZE, ICON_SIZE);
    cleanButton = CleanButton(this, rect);

    rect = Rect.fromLTWH(
        rectX, Y_MIN_LIMIT + (ICON_SIZE + ICON_TAP) * 7, ICON_SIZE, ICON_SIZE);
    moveButton = MoveButton(this, rect);

    rect = Rect.fromLTWH(
        50, 50, ICON_SIZE, ICON_SIZE); // hardcode to show in at left corner

    loadButton = LoadButton(this, rect);

    rect = Rect.fromLTWH(
        150, 50, ICON_SIZE, ICON_SIZE); // hardcode to show in at left corner

    moveButton = MoveButton(this, rect);

    rect = Rect.fromLTWH(
        250, 50, ICON_SIZE, ICON_SIZE); // hardcode to show in at left corner

    preButton = PreButton(this, rect);

    rect = Rect.fromLTWH(
        350, 50, ICON_SIZE, ICON_SIZE); // hardcode to show in at left corner

    nextButton = NextButton(this, rect);

    rect = Rect.fromLTWH(
        450, 50, ICON_SIZE, ICON_SIZE); // hardcode to show in at left corner

    saveButton = SaveButton(this, rect);

    directionSprite = Sprite('ui/icon-direction.png');

    //for output a bunch of png
    final directory = await getExternalStorageDirectory();
    storagePath = directory.path;
  }


  //out put the edge and vertex to json
  void outputVetexAndEdgeInformation() {
    if (doVertexCheckValid()) {
      Map<String, dynamic> map = new Map();

      List<Edge> edges = new List(edgeList.length);

      for (int i = 0; i < edgeList.length; i ++) // draw edge
          {
        Edge edge = edgeList.elementAt(i);
        edge.inArrayIndex = i;
        edges[i] = edge;
      }

      map['edges'] = edges;

      List<Vertex> vertexs = new List(vertexList.length);
      for (int i = 0; i < vertexList.length; i ++) {
        Offset offset = vertexList.elementAt(i);

        Vertex vertex = new Vertex(null);
        vertex.x = offset.dx - X_MIN_LIMIT;
        vertex.y = offset.dy - Y_MIN_LIMIT;

//        vertex.x = offset.dx ;
//        vertex.y = offset.dy ;

        vertex.index = i;

        String json = jsonEncode(vertex);
        vertexs[i] = vertex;
      }

      map['vertices'] = vertexs;


      map['graph'] = {"height": 750, "width": 540};

      String finalJson = jsonEncode(map);

      printLog(finalJson);
    }
    else {
      print('奇数边的点不是两个，请检查边是否有问题！！');
    }
  }


  //check before ouput
  bool doVertexCheckValid() {
    bool isValid = true;

    List<int> vertexConnectedEdgeCounts = new List(vertexList.length);

    for (int i = 0; i < vertexConnectedEdgeCounts.length; i ++) {
      vertexConnectedEdgeCounts[i] = 0;
    }

    for (int i = 0; i < edgeList.length; i ++) // draw edge
        {
      Edge edge = edgeList.elementAt(i);


      vertexConnectedEdgeCounts[edge.startIndex] =
          vertexConnectedEdgeCounts[edge.startIndex] + 1;

      vertexConnectedEdgeCounts[edge.endIndex] =
          vertexConnectedEdgeCounts[edge.endIndex] + 1;
    }


    int oddCount = 0;
    for (int i = 0; i < vertexConnectedEdgeCounts.length; i ++) {
      int edgeCountForEachVertex = vertexConnectedEdgeCounts[i];

      if (edgeCountForEachVertex == 0) {
        isValid = false;

        print('!!有顶点没有连边');

        return isValid;
      }

      if (edgeCountForEachVertex % 2 == 1) {
        oddCount = oddCount + 1;
      }
    }


    if (oddCount == 0 || oddCount == 2) {

    }
    else {
      isValid = false;
    }

    return isValid;
  }

  void printLog(String msg) {
//    if ( msg == null || msg.length == 0)
//      return;
//
//    int segmentSize = 3 * 1024;
//    int length = msg.length;
//    if (length <= segmentSize ) {// 长度小于等于限制直接打印
//      print(msg);
//    }else {
//      while (msg.length > segmentSize ) {// 循环分段打印日志
//        String logContent = msg.substring(0, segmentSize );
//
//        msg = msg.replaceAll(logContent, "");
//        print(logContent);
//      }
//      print(msg);// 打印剩余日志
//    }


    int maxLogSize = 1000;
    for (int i = 0; i <= msg.length / maxLogSize; i++) {
      int start = i * maxLogSize;
      int end = (i + 1) * maxLogSize;
      end = end > msg.length ? msg.length : end;
      print(msg.substring(start, end));
    }
  }


  //根据点击的位置找到已经在顶点列表中最接近的顶点，需要满足最小距离在 DISTANCE_CHECK_SIZE 之内
  int findCandidatePoint(double dx, double dy) {
    int index = -1;

    double minDisance = 10000;

    for (int i = 0; i < vertexList.length; i ++) {
      Offset offset = vertexList.elementAt(i);

      double distance = LevelDataTune.calculateDis(
          dx, dy, offset.dx, offset.dy);

      if (distance < minDisance && distance <= DISTANCE_CHECK_THRESHHOLD) {
        minDisance = distance;
        index = i;
      }
    }

    return index;
  }


  void onVerticalDragStart(DragStartDetails details) {
    switch (mode) {
      case MODE_VERTEX:
        return;
      case MODE_EDGE:
        break;
      case MODE_EDGE_LOCK:
        break;
      case MODE_EDGE_REPEAT:
        break;
      case MODE_MOVE:
        break;
      default:
      // code block
    }

    //find the candidate start point
    if (vertexList != null) {
      int indexFromList = findCandidatePoint(
          details.globalPosition.dx, details.globalPosition.dy);

      if (indexFromList >= 0 && indexFromList <= vertexList.length - 1) {
        tempStartPoint = vertexList.elementAt(indexFromList);
        tempStartPointIndex = indexFromList;
      } else {
        tempStartPoint = null;
      }
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    tempCurrentPoint =
        Offset(details.globalPosition.dx, details.globalPosition.dy);

    switch (mode) {
      case MODE_EDGE:
      case MODE_EDGE_REPEAT:
      case MODE_EDGE_LOCK:
        handleDragEndFindEndingPoint(tempCurrentPoint);
        break;
      case MODE_MOVE:
        if (tempStartPoint != null) {
          vertexList.removeAt(tempStartPointIndex);
          vertexList.insert(tempStartPointIndex, tempCurrentPoint);
          tempStartPoint = vertexList.elementAt(tempStartPointIndex);
        }
        break;

      default:
        ;
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    switch (mode) {
      case MODE_EDGE:
      case MODE_EDGE_REPEAT:
      case MODE_EDGE_LOCK:
        break;
      case MODE_MOVE:
        if (tempStartPoint != null) {
          vertexList.removeAt(tempStartPointIndex);
          vertexList.insert(
              tempStartPointIndex, getCorrectPoint(tempStartPoint, 10.0));
          tempStartPoint = vertexList.elementAt(tempStartPointIndex);
        }
        break;

      default:
        ;
    }
  }


  void drawModeText(Canvas canvas) {
    TextStyle style = TextStyle(fontSize: MODE_FONT_SIZE, color: Colors.black);

    String modeString = '';

    switch (mode) {
      case MODE_VERTEX:
        modeString = '打点模式';
        break;
      case MODE_EDGE:
        modeString = '连边模式';
        break;
      case MODE_EDGE_LOCK:
        modeString = '连方向边模式';
        style = TextStyle(fontSize: MODE_SPECIAL_FONT_SIZE, color: Colors.red);
        break;
      case MODE_EDGE_REPEAT:
        modeString = '连重复边模式';
        style = TextStyle(fontSize: MODE_SPECIAL_FONT_SIZE, color: Colors.red);
        break;
      case MODE_MOVE:
        modeString = '原图拉伸';
        if (myApp.state.fileList != null && myApp.state.selectPos > -1) {
          FileStruct file = myApp.state.fileList[myApp.state.selectPos];
          modeString = 'Level' + file.level.toString() + " Stage" +
              file.stage.toString();
        }
        break;
      default:
      // code block
    }


    TextSpan span = new TextSpan(text: modeString, style: style);
    TextPainter tp = new TextPainter(text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(X_LIMIT / 2 - 50, Y_LIMIT + 0));
  }

  void render(Canvas canvas) {
    background.render(canvas);

    drawModeText(canvas);


    //draw the buttons
    vertexButton.render(canvas);
    edgeButton.render(canvas);
    cleanButton.render(canvas);
    printButton.render(canvas);
    undoButton.render(canvas);

    edgeDirectionButton.render(canvas);
    edgeRepeatButton.render(canvas);
    cleanButton.render(canvas);
    moveButton.render(canvas);
    preButton.render(canvas);
    nextButton.render(canvas);
    saveButton.render(canvas);
    loadButton.render(canvas); //for bunch of png

    List<int> degreeList = List.generate(vertexList.length, (int index){return 0;});

    if (!skipRender) {
      List<int> listOfRepeatEdgeIndexs = new List();
      for (int i = 0; i < edgeList.length; i ++) { // draw edge
        Edge edge = edgeList.elementAt(i);
        Offset offsetStartPoint = vertexList.elementAt(edge.startIndex);
        Offset offsetEndPoint =
        vertexList.elementAt(edge.endIndex);
        degreeList[edge.startIndex]++;
        degreeList[edge.endIndex]++;


        if (edge.repeat == 2) {
          listOfRepeatEdgeIndexs.add(i);
        }

        else if (edge.lock == true) {
          Paint linePaint = Paint();
          linePaint.color = Color(0xffaaddbb);
          linePaint.strokeWidth = LINE_CONNETED_EDGE;
          canvas.drawLine(offsetStartPoint, offsetEndPoint, linePaint);

          drawEdgeDirectionLabel(canvas, offsetStartPoint, offsetEndPoint);
        }
        else {
          Paint linePaint = Paint();
          linePaint.color = Color(0xffaaddbb);
          linePaint.strokeWidth = LINE_CONNETED_EDGE;
          canvas.drawLine(offsetStartPoint, offsetEndPoint, linePaint);
        }
      }


      //draw repeated edge
      drawRepeatedEdge(canvas, listOfRepeatEdgeIndexs, edgeList, vertexList, 0);


      //draw all the vertex
      Paint radiusPaint = Paint();
      radiusPaint.color = Color(0xffff00ff);
      for (int i = 0; i < vertexList.length; i ++) {
        Offset offset = vertexList.elementAt(i);
        if (degreeList[i] == 0) {
          radiusPaint.color = Color(0xff0000ff);
        } else if (degreeList[i]%2 == 1) {
          radiusPaint.color = Colors.black;
        } else {
          radiusPaint.color = Color(0xffff00ff);
        }
        canvas.drawCircle(offset, VERTEX_RADIUS, radiusPaint);


        Vertex vertex = new Vertex(null);
        String id = vertex.getVectexId(i);


        Offset idTextOffset = Offset(
            offset.dx - VERTEX_RADIUS / 2, offset.dy - VERTEX_RADIUS / 2 - 3);

        TextSpan span = new TextSpan(text: id,
            style: TextStyle(fontSize: VERTEX_FONT_SIZE, color: Colors.white));
        TextPainter tp = new TextPainter(text: span,
            textAlign: TextAlign.justify,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, idTextOffset);
      }


      if (tempStartPoint != null && tempCurrentPoint != null) {
        Paint linePaint = Paint();
        linePaint.color = Color(0xff00ffff);

        Offset offset2 = Offset(0, 0);
        canvas.drawLine(tempStartPoint, tempCurrentPoint, linePaint);
      }
    }
  }


  void drawRepeatedEdge(Canvas canvas, List indexList,
      List<Edge> edgeListToDraw, List<Offset> vertexListToDraw,
      double canvasXShift) {
    for (int i = 0; i < indexList.length; i ++) {
      int indexInEdgeList = indexList[i];

      Edge edge = edgeListToDraw.elementAt(indexInEdgeList);
      Offset offsetStartPoint = vertexListToDraw.elementAt(edge.startIndex);
      Offset offsetEndPoint = vertexListToDraw.elementAt(edge.endIndex);

      Paint linePaint = Paint();
      linePaint.color = Color(0xffaa00bb);
      linePaint.strokeWidth = LINE_CONNETED_REPEATED_EDGE;

      Offset offsetStartPointRepeatEdge = Offset(
          offsetStartPoint.dx + canvasXShift,
          offsetStartPoint.dy + 2); //shift 2 along y axis
      Offset offsetEndPointRepeatEdge = Offset(offsetEndPoint.dx + canvasXShift,
          offsetEndPoint.dy + 2); //shift 2 along y axis
      canvas.drawLine(
          offsetStartPointRepeatEdge, offsetEndPointRepeatEdge, linePaint);


      drawEdgeRepeatNumber(
          canvas, offsetStartPoint, offsetEndPoint, canvasXShift);
    }
  }

  void drawEdgeRepeatNumber(Canvas canvas, Offset offsetStartPoint,
      Offset offsetEndPoint, double canvasXShift) {
    Offset middlePoint = Offset(
        (offsetStartPoint.dx + offsetEndPoint.dx) / 2 + canvasXShift -
            VERTEX_RADIUS / 2,
        (offsetStartPoint.dy + offsetEndPoint.dy) / 2 - VERTEX_RADIUS / 2 - 2);

    TextSpan span = new TextSpan(text: '2',
        style: TextStyle(fontSize: VERTEX_FONT_SIZE, color: Colors.black));
    TextPainter tp = new TextPainter(text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, middlePoint);
  }

  double calculateAngle(Offset offsetStartPoint, Offset offsetEndPoint) {
    double dx = offsetEndPoint.dx - offsetStartPoint.dx;
    double dy = offsetEndPoint.dy - offsetStartPoint.dy;

    double inRads = atan2(dy, dx) + pi / 2;

    return inRads;
  }


  void drawEdgeDirectionLabel(Canvas canvas, Offset offsetStartPoint,
      Offset offsetEndPoint) {
    canvas.save();

    final player = SpriteComponent.fromSprite(
        ICON_DIRECTION_SIZE, ICON_DIRECTION_SIZE,
        directionSprite); // width, height, sprite

    // screen coordinates
    player.x = (offsetStartPoint.dx + offsetEndPoint.dx) / 2;
    player.y = (offsetStartPoint.dy + offsetEndPoint.dy) / 2; // 0 by default

    player.anchor = Anchor.center;

    player.angle =
        calculateAngle(offsetStartPoint, offsetEndPoint); // 0 by default

    player.render(canvas);

    canvas.restore();
  }

  void update(double t) {

  }

  void resize(Size size) {
    screenSize = size;
  }


  //clean the canvas, reset to original state
  void doClean() {
    vertexList.clear();
    edgeList.clear();
    doEdgeModeClean();
    mode = MODE_VERTEX;
  }


  void doEdgeModeClean() {
    tempCurrentPoint = null;
    tempStartPoint = null;
    tempStartPointIndex = -1;
  }

  void doConnectClean() {
    if (connect != null) {
      for (int i = 0; i < connect.length; i++) {
        connect[i].clear();
      }
    }
  }


  void doPrint() {
    saveJson();
    //outputVetexAndEdgeInformation(); //test
  }


  //add points to the list
  void addVertexToList(TapDownDetails d) {
    var dx = d.globalPosition.dx;
    var dy = d.globalPosition.dy;

    double tempYLimit = screenSize.height - theButtomOpBarHeight;

    if (tempYLimit > Y_LIMIT) {
      tempYLimit = Y_LIMIT;
    }


    if (dx >= X_MIN_LIMIT - 4 && dx <= X_LIMIT + 4 && dy >= Y_MIN_LIMIT - 4 &&
        dy <= tempYLimit + 4) { // do not affect the bottom bar
      if (vertexList.length >= 30) {
        print('too many vertexs');
        return;
      }

      if (checkIfAGoodPoint(Offset(dx, dy))) {
        addTensVertex(Offset(dx, dy));
      }
    }
  }


  //add points in tens coordinate
  void addTensVertex(Offset offset) {
    double xyThreshhold = 5;

    double dx = offset.dx;
    double dy = offset.dy;


    for (int i = 0; i < vertexList.length; i ++) {
      Offset offsetInList = vertexList.elementAt(i);

      if ((dx - offsetInList.dx).abs() <= xyThreshhold) {
        dx = offsetInList.dx;
      }

      if ((dy - offsetInList.dy).abs() <= xyThreshhold) {
        dy = offsetInList.dy;
      }
    }

    int tempDxInt = dx.toInt();
    if (tempDxInt % 10 >= 5) {
      tempDxInt = tempDxInt + 5;
    }


    int tempDyInt = dy.toInt();
    if (tempDyInt % 10 >= 5) {
      tempDyInt = tempDyInt + 5;
    }

    int intDx = (tempDxInt / 10).toInt() * 10;
    int intDy = (tempDyInt / 10).toInt() * 10;

    vertexList.add(Offset(intDx.toDouble(), intDy.toDouble()));
  }

  bool checkIfAGoodPoint(Offset offset) {
    for (int i = 0; i < vertexList.length; i ++) {
      Offset offsetInList = vertexList.elementAt(i);
      double dis = LevelDataTune.calculateDis(
          offset.dx, offset.dy, offsetInList.dx, offsetInList.dy);
      if (dis <= 20) {
        print("!!!!!YOU too close");
        return false;
      }
    }

    return true;
  }


  void handleDragEndFindEndingPoint(Offset offset) {
    if (offset != null && offset.dy > theButtomOpBarHeight &&
        offset.dy < screenSize.height - theButtomOpBarHeight) {
      int index = findCandidatePoint(offset.dx, offset.dy);

      if (index >= 0 && index <= vertexList.length - 1 &&
          tempStartPointIndex >= 0 &&
          index != tempStartPointIndex) //not same as start point
          {
        if (checkIfDuplicateEdge(tempStartPointIndex, index) == false) {
          // this is an  valid edge

          Edge edge = Edge(null);

          edge.startIndex = tempStartPointIndex;
          edge.endIndex = index;


          if (mode == MODE_EDGE_LOCK) {
            edge.lock = true;
          }

          if (mode == MODE_EDGE_REPEAT) {
            edge.repeat = 2;
          }

          edge.inArrayIndex = edgeList.length;
          edgeList.add(edge);

          int size = edgeList.length;

          print(' edgeList size = $size');

          doEdgeModeClean();
        }
      }
    }
  }

  bool checkIfDuplicateEdge(int tempStartPointIndex, int endPointIndex) {
    for (int i = 0; i < edgeList.length; i ++) // do normal edge check first
        {
      Edge edge = edgeList[i];

      if (edge.repeat == 0) // normal edge
          {
        if ((edge.startIndex == tempStartPointIndex &&
            edge.endIndex == endPointIndex) ||
            (edge.startIndex == endPointIndex &&
                edge.endIndex == tempStartPointIndex)) {
          return true;
        }
      }
    }


    for (int i = 0; i < edgeList.length; i ++) {
      Edge edge = edgeList[i];

      if (edge.repeat == 2) // repeat edge
          {
        if (edge.startIndex == tempStartPointIndex &&
            edge.endIndex == endPointIndex) {
          return true;
        }

        if (edge.startIndex == endPointIndex &&
            edge.endIndex == tempStartPointIndex) {
          return false; // allow one more time
        }
      }
    }

    return false;
  }


  void onTapDown(TapDownDetails d) {
    switch (mode) {
      case MODE_VERTEX:
        addVertexToList(d);
        break;

      default:
        ;
    }


    // buttons action
    if (vertexButton.rect.contains(d.globalPosition)) {
      vertexButton.onTapDown();
    }

    if (cleanButton.rect.contains(d.globalPosition)) {
      cleanButton.onTapDown();
    }

    if (edgeButton.rect.contains(d.globalPosition)) {
      edgeButton.onTapDown();
    }


    if (printButton.rect.contains(d.globalPosition)) {
      printButton.onTapDown();
    }

    if (moveButton.rect.contains(d.globalPosition)) {
      moveButton.onTapDown();
    }

    if (preButton.rect.contains(d.globalPosition)) {
      preButton.onTapDown();
    }

    if (nextButton.rect.contains(d.globalPosition)) {
      nextButton.onTapDown();
    }

    if (saveButton.rect.contains(d.globalPosition)) {
      saveButton.onTapDown();
    }


    if (undoButton.rect.contains(d.globalPosition)) {
      undoButton.onTapDown();
    }


    if (edgeRepeatButton.rect.contains(d.globalPosition)) {
      edgeRepeatButton.onTapDown();
    }


    if (edgeDirectionButton.rect.contains(d.globalPosition)) {
      edgeDirectionButton.onTapDown();
    }

    if (loadButton.rect.contains(d.globalPosition)) {
      loadButton.onTapDown();
    }

    //temp put it here
//    takeScreenshot();


  }


  void unDo() {
    switch (mode) {
      case MODE_VERTEX:
        if (vertexList.length > 0)
          vertexList.removeLast();
        break;
      case MODE_EDGE:
      case MODE_EDGE_REPEAT:
      case MODE_EDGE_LOCK:
        if (edgeList.length > 0)
          edgeList.removeLast();
        break;
      default:
        ;
    }
  }


  void loadCandidateLevelData() async
  {
//    if (true) {
//      generateJsons();
//      return;
//    }
    //    LevelData.LEVEL_DATA.length
    Set<String> set = new Set();
    List<String> hasList = [];
    hasList.addAll(DataOrigin.DATA_SWAP_UP_LEVEL);
    hasList.addAll(DataOrigin.DATA_SWAP_ADD_LEVEL);
    hasList.addAll(DataOrigin.DATA_SWAP_DOWN_LEVEL);
//    for (int i = 0; i < hasList.length; i++) {
//      set.add(hasList[i]);
//    }
    List<String> levelDatas = LevelDataProduct.RES;
    //levelDatas = DataOrigin.DATA_SWAP_ADD_LEVEL;
    int length = levelDatas.length;
    for (int i = 0; i < length; i ++) {
//        doClean(); // clean everything first
//        print(LevelData.LEVEL_DATA[i]);
      String levelData = await rootBundle.loadString(levelDatas[i]);

      var parsedJson = json.decode(levelData);
      var edges = parsedJson['edges'];
      var vertices = parsedJson['vertices'];


      List<Edge> edgeListToImage = [];
      List<Offset> vertexListToImage = [];
      List<Vertex> vertexList = [];

      List<int> edgeIndexListRepeatOne = [];
      List<int> edgeIndexListRepeatTwice = [];

      List<Offset> tunedVertexListToImage = [];

      for (int i = 0; i < edges.length; i ++) {
        Edge edge = Edge(edges[i]);
        edgeListToImage.add(edge);
        if (edge.repeat == 1) {
          edgeIndexListRepeatOne.add(i);
        } else if (edge.repeat == 2) {
          edgeIndexListRepeatTwice.add(i);
        }
      }

      for (int i = 0; i < vertices.length; i ++) {
        Vertex vertex = Vertex(vertices[i]);
        vertexList.add(vertex);
      }

      tunedVertexListToImage = LevelDataTune.tuneVertices(vertices);
      EulerInfo euler = getEulerInfo(vertexList, edgeListToImage, 1, 1);
      //euler = getEulerInfo(vertexList, edgeListToImage, 550/euler.height, 500/euler.width);

      EulerInfo eulerDouble = copyEuler(euler);
      EulerInfo eulerAddTri = copyEuler(euler);
      EulerInfo eulerAddTriBottom = copyEuler(euler);
      EulerInfo eulerSwap = copyEuler(euler);
      EulerInfo eulerSwapOffset = copyEuler(euler);
      EulerInfo eulerSwapTwoPairs = copyEuler(euler);
      EulerInfo eulerSwapTwoPairsDown = copyEuler(euler);
      EulerInfo eulerTopY = copyEuler(euler);
      EulerInfo eulerBottomY = copyEuler(euler);

      Vertex center = euler.center;
      List<Vertex> vList = getMinDistancePointsNotConnect(eulerDouble);
      if (vList.isNotEmpty) {
        eulerDouble.edgeList = addDoubleDirectEdge(eulerDouble.edgeList, vList);
      }
      bool hasUglyEdge = false;
      bool has = false;
      for (int j = 6; j < 7; j++) {
        String tail = "res";
        List<Vertex> tempList = [];
        if (j == 9) {
          eulerDouble.vertexList =
              translateX180(eulerDouble.vertexList, center);
          tempList = eulerDouble.vertexList;
          edgeListToImage = eulerDouble.edgeList;
        } else if (j == 9) {
          eulerAddTri.vertexList =
              translateX180(eulerAddTri.vertexList, center);
          addTopTri(eulerAddTri);
          tempList = eulerAddTri.vertexList;
          edgeListToImage = eulerAddTri.edgeList;
        } else if (j == 9) {
          eulerAddTriBottom.vertexList =
              translateX180(eulerAddTriBottom.vertexList, center);
          addBottomTri(eulerAddTriBottom);
          tempList = eulerAddTriBottom.vertexList;
          edgeListToImage = eulerAddTriBottom.edgeList;
        } else if (j == 9) {
          eulerSwap.vertexList = translateX180(eulerSwap.vertexList, center);
          if (vList.isNotEmpty) {
            swapVertex(eulerSwap, vList[0], vList[1], false);
          }
          tempList = eulerSwap.vertexList;
          edgeListToImage = eulerSwap.edgeList;
        } else if (j == 9) {
          eulerSwapOffset.vertexList =
              translateX180(eulerSwapOffset.vertexList, center);
          if (vList.isNotEmpty) {
            swapVertex(eulerSwapOffset, vList[0], vList[1], true);
          }
          tempList = eulerSwapOffset.vertexList;
          edgeListToImage = eulerSwapOffset.edgeList;
        } else if (j == 9) {
          eulerSwapTwoPairs.vertexList =
              translateX180(eulerSwapOffset.vertexList, center);
          List<Vertex> leftList = findLeftUpConnerPoints(eulerSwapTwoPairs);
          List<Vertex> rightList = findRightUpConnerPoints(eulerSwapTwoPairs);
          if (leftList.isNotEmpty) {
            swapVertex(eulerSwapTwoPairs, leftList[0], leftList[1], false);
          }
          if (rightList.isNotEmpty) {
            swapVertex(eulerSwapTwoPairs, rightList[0], rightList[1], false);
          }
          tempList = eulerSwapTwoPairs.vertexList;
          edgeListToImage = eulerSwapTwoPairs.edgeList;
        } else if (j == 0) {
          tail = "swap";
          eulerSwapTwoPairs.vertexList =
              translateX180(eulerSwapOffset.vertexList, center);
          List<Vertex> leftList = findLeftUpConnerPoints(eulerSwapTwoPairs);
          List<Vertex> rightList = findRightUpConnerPoints(eulerSwapTwoPairs);
          List<Vertex> swapList = [];
          if (leftList.isNotEmpty) {
            swapVertex(eulerSwapTwoPairs, leftList[0], leftList[1], false);
            swapList.add(leftList[0]);
            swapList.add(leftList[1]);
          }
          if (rightList.isNotEmpty) {
            swapVertex(eulerSwapTwoPairs, rightList[0], rightList[1], false);
            swapList.add(rightList[0]);
            swapList.add(rightList[1]);
          }
          List<Edge> swapEdgeList = getSwapEdgeList(
              swapList, eulerSwapTwoPairs.edgeList);
          hasUglyEdge =
              prefix1.hasUglyEdge(eulerSwapTwoPairs.vertexList, swapEdgeList);
          if (hasUglyEdge) {
            print('has ugly edgeUP = $i');

            continue;
          }
          tempList = eulerSwapTwoPairs.vertexList;
          edgeListToImage = eulerSwapTwoPairs.edgeList;
        } else if (j == 1) {
          if (hasUglyEdge) continue;
          tail = "swap-add-2";
          addTopTri(eulerSwapTwoPairs);
          tempList = eulerSwapTwoPairs.vertexList;
          edgeListToImage = eulerSwapTwoPairs.edgeList;
        } else if (j == 6) {
          euler = getEulerInfo(
              euler.vertexList, euler.edgeList, 550 / euler.height,
              500 / euler.width);
          if (hasUglyEdge || has) {
            continue;
          }
          tempList = euler.vertexList;
          edgeListToImage = euler.edgeList;
        } else if (j == 2) {
          tail = "swap-down";
//            if (set.contains(levelDatas[i])) {
//              has = true;
//              break;
//            }
          eulerSwapTwoPairsDown.vertexList =
              translateX180(eulerSwapTwoPairsDown.vertexList, center);
          List<Vertex> leftList = findLeftDownConnerPoints(
              eulerSwapTwoPairsDown);
          List<Vertex> rightList = findRightDownConnerPoints(
              eulerSwapTwoPairsDown);
          List<Vertex> swapList = [];
          if (leftList.isNotEmpty) {
            swapVertex(eulerSwapTwoPairsDown, leftList[0], leftList[1], false);
            swapList.add(leftList[0]);
            swapList.add(leftList[1]);
          }
          if (rightList.isNotEmpty) {
            swapVertex(
                eulerSwapTwoPairsDown, rightList[0], rightList[1], false);
            swapList.add(rightList[0]);
            swapList.add(rightList[1]);
          }
          List<Edge> swapEdgeList = getSwapEdgeList(
              swapList, eulerSwapTwoPairsDown.edgeList);
          hasUglyEdge = prefix1.hasUglyEdge(
              eulerSwapTwoPairsDown.vertexList, swapEdgeList);
          if (hasUglyEdge) {
            print('has ugly edge = $i');

            break;
          }
          tempList = eulerSwapTwoPairsDown.vertexList;
          edgeListToImage = eulerSwapTwoPairsDown.edgeList;
        } else if (j == 4) {
          tail = "y-top";
          if (set.contains(levelDatas[i])) {
            has = true;
            continue;
          }
          List<Vertex> vertexList = getYCenterVertexList(eulerTopY, TYPE_TOP);
          if (vertexList == null || vertexList.length < 2) {
            print("no center top " + i.toString());
            has = true;
            continue;
          }
          print("hhhhhh13");
          swapVertex(eulerTopY, vertexList[0], vertexList[1], false);
          List<Vertex> swapList = [vertexList[0], vertexList[1]];
          List<Edge> swapEdgeList = getSwapEdgeList(
              swapList, eulerTopY.edgeList);

          print("hhhhhh12");


          hasUglyEdge = prefix1.hasUglyEdge(eulerTopY.vertexList, swapEdgeList);
          print("hhhhhh1");

          if (hasUglyEdge) {
            print('has ugly edge Top Y = $i');
            break;
          }
          print("hhhhhh");
          tempList = eulerTopY.vertexList;
          edgeListToImage = eulerTopY.edgeList;
        } else if (j == 5) {
          tail = "y-bottom";
          if (set.contains(levelDatas[i])) {
            has = true;
            continue;
          }
          List<Vertex> vertexList = getYCenterVertexList(
              eulerBottomY, TYPE_BOTTOM);
          if (vertexList == null || vertexList.length < 2) {
            print("no center top " + i.toString());
            has = true;
            continue;
          }
          swapVertex(eulerBottomY, vertexList[0], vertexList[1], false);
          List<Vertex> swapList = [vertexList[0], vertexList[1]];
          List<Edge> swapEdgeList = getSwapEdgeList(
              swapList, eulerBottomY.edgeList);
          hasUglyEdge =
              prefix1.hasUglyEdge(eulerBottomY.vertexList, swapEdgeList);
          if (hasUglyEdge) {
            print('has ugly edge Top Y = $i');
            continue;
          }
          tempList = eulerBottomY.vertexList;
          edgeListToImage = eulerBottomY.edgeList;
        }
        vertexListToImage.clear();
        for (int k = 0; k < tempList.length; k++) {
          Vertex vertex = tempList[k];
          vertexListToImage.add(Offset(vertex.x, vertex.y));
        }
        var path = "onelineln/" + levelDatas[i].replaceAll("assets/", "")
            .replaceAll("/", "-")
            .replaceAll(".txt", "");
//          for (int i = 1000; i < 1024; i++) {
//            String folder = "level/"+"lp" + i.toString();
//            var directory = new Directory((await getExternalStorageDirectory()).path +"/"+ folder);
//            if (!directory.existsSync()) {
//              directory.createSync();
//            }
//          }
        if (true) {
          //directory.createSync();
          outPutPngFilePath = path + "-" + tail + ".png";
          drawLevelDataToPng(
              outPutPngFilePath, edgeListToImage, vertexListToImage, null);
        } else {
          outPutPngFilePath = path + "-" + tail + ".png";


//        drawLevelDataToPng(outPutPngFilePath, edgeListToImage, vertexListToImage, tunedVertexListToImage);

          drawLevelDataToPng(
              outPutPngFilePath, edgeListToImage, vertexListToImage, null);
        }
        var jsonPath = levelDatas[i].replaceAll("assets/", "")
            .replaceAll("/", "-")
            .replaceAll(".txt", "");
        List<String> paths = levelDatas[i].split('/');
        tempList = compressFinal(
            tempList, eulerSwapTwoPairs, FINAL_HEIGHT, FINAL_WIDTH);
        String name = paths[paths.length - 1];
        String //outJsonPath = (await getExternalStorageDirectory()).path +"level/" + paths[paths.length-2] + "/" + name.substring(2);
        outJsonPath = (await getExternalStorageDirectory()).path + "/level/" +
            jsonPath;

        outputVertexAndEdgeJson(tempList, edgeListToImage, outJsonPath);
      }

      print('level datad count = $i');
    }
  }


  void loadCrazyGameData() async
  {
    String allLevelData = await rootBundle.loadString('assets/crazygame/data1');


    var objs = json.decode(allLevelData);

    var levels = objs['levels'];

    for (int i = 0; i < levels.length; i ++) {
      print(levels[i]);
      if (levels[i] != null) {
        var vertices = levels[i]['vertices'];
        var edges = levels[i]['links'];

        List<Edge> edgeListToImage = [];
        List<Offset> vertexListToImage = [];

        print(edges.length);

        for (int edgeIndex = 0; edgeIndex < edges.length; edgeIndex ++) {
          Edge edge = Edge(null);
          edge.startIndex = edges[edgeIndex][0];
          edge.endIndex = edges[edgeIndex][1];
          edge.repeat = edges[edgeIndex][2];
          edgeListToImage.add(edge);
        }


        print(vertices.length);
        for (int vertexIndex = 0; vertexIndex <
            vertices.length; vertexIndex ++) {
          Vertex vertex = Vertex(null);
          int x = vertices[vertexIndex][0];
          vertex.x = x.toDouble();

          int y = vertices[vertexIndex][1];
          vertex.y = y.toDouble();
          vertex.index = vertexIndex;
          vertexListToImage.add(Offset(vertex.x, vertex.y));
        }


        outPutPngFilePath = "crazygame/data$i.png";


        print(edgeListToImage.length);
        print(vertexListToImage.length);

        drawLevelDataToPng(
            outPutPngFilePath, edgeListToImage, vertexListToImage, null);

        print(outPutPngFilePath);
      }
    }
  }


  void drawLevelDataToPng(String outPutPngFilePath, List<Edge> edgeListToImage,
      List<Offset> vertexListToImage,
      List<Offset> tunedVertexListToImage) async {
    var pictureRecorder = new PictureRecorder();
    Canvas canvas = new Canvas(pictureRecorder);

    commonRenderPart(
        canvas, outPutPngFilePath, edgeListToImage, vertexListToImage,
        tunedVertexListToImage);

    int imageWidth = X_LIMIT.toInt();

    if (tunedVertexListToImage != null) {
      imageWidth = X_LIMIT.toInt() * 2;
    }

    ui.Image image = await pictureRecorder.endRecording().toImage(
        imageWidth, (Y_LIMIT + 100).toInt());
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    writeImage(pngBytes, outPutPngFilePath);
  }


  void commonRenderPartDrawEdge(Canvas canvas, List<Edge> edgeListToImage,
      List<Offset> vertexListToImage, double canvasXShift) {
    List<int> listOfRepeatEdgeIndexs = new List();

    for (int i = 0; i < edgeListToImage.length; i ++) // draw edge
        {
      Edge edge = edgeListToImage.elementAt(i);


      if (edge.startIndex < 0 || edge.endIndex < 0 ||
          edge.endIndex >= vertexListToImage.length) {
        print('!!!!!!!error!!!$outPutPngFilePath edge.startIndex=${edge
            .startIndex}  edge.endIndex=${edge.endIndex}');
      }


      Offset offsetStartPoint = Offset(vertexListToImage
          .elementAt(edge.startIndex)
          .dx + canvasXShift, vertexListToImage
          .elementAt(edge.startIndex)
          .dy);

      Offset offsetEndPoint = Offset(vertexListToImage
          .elementAt(edge.endIndex)
          .dx + canvasXShift, vertexListToImage
          .elementAt(edge.endIndex)
          .dy);


      if (edge.repeat == 2) {
        listOfRepeatEdgeIndexs.add(i);
      }

      else if (edge.lock == true) {
        Paint linePaint = Paint();
        linePaint.color = Color(0xffaaddbb);
        linePaint.strokeWidth = LINE_CONNETED_EDGE;
        canvas.drawLine(offsetStartPoint, offsetEndPoint, linePaint);
        drawEdgeDirectionLabel(canvas, offsetStartPoint, offsetEndPoint);
      }
      else {
        Paint linePaint = Paint();
        linePaint.color = Color(0xffaaddbb);
        linePaint.strokeWidth = LINE_CONNETED_EDGE;
        canvas.drawLine(offsetStartPoint, offsetEndPoint, linePaint);
      }
    }


    //draw repeated edge
    drawRepeatedEdge(
        canvas, listOfRepeatEdgeIndexs, edgeListToImage, vertexListToImage,
        canvasXShift);
  }

  void commonRenderPartDrawVerices(Canvas canvas,
      List<Offset> vertexListToImage, double canvasXShift) {
    double radius = 20;
    //draw all the vertex
    Paint radiusPaint = Paint();
    radiusPaint.color = Color(0xffff00ff);
    for (int i = 0; i < vertexListToImage.length; i ++) {
      Offset offset = Offset(vertexListToImage
          .elementAt(i)
          .dx + canvasXShift, vertexListToImage
          .elementAt(i)
          .dy);

      canvas.drawCircle(offset, radius, radiusPaint);


      Vertex vertex = new Vertex(null);
      String id = vertex.getVectexId(i);


      Offset idTextOffset = Offset(
          offset.dx - radius / 2 + 1.4, offset.dy - radius / 2 - 3);

      TextSpan span = new TextSpan(text: id,
          style: TextStyle(
              fontSize: VERTEX_FONT_SIZE + 8, color: Colors.white));
      TextPainter tp = new TextPainter(text: span,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, idTextOffset);
    }
  }

  void commonRenderPart(Canvas canvas, String outPutPngFilePath,
      List<Edge> edgeListToImage, List<Offset> vertexListToImage,
      List<Offset> tunedVertexListToImage) {
    int ratio = 1;
    if (tunedVertexListToImage != null)
      ratio = 2;

    Rect bgRect = Rect.fromLTWH(0, 0, X_LIMIT * ratio, Y_LIMIT + 100);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xffffffff);
    canvas.drawRect(bgRect, bgPaint);

    commonRenderPartDrawEdge(canvas, edgeListToImage, vertexListToImage, 40);


    if (tunedVertexListToImage != null) {
      commonRenderPartDrawEdge(
          canvas, edgeListToImage, tunedVertexListToImage, X_LIMIT);
    }


    commonRenderPartDrawVerices(canvas, vertexListToImage, 40);

    if (tunedVertexListToImage != null) {
      commonRenderPartDrawVerices(canvas, tunedVertexListToImage, X_LIMIT - 50);
    }

    //draw answer path
    String answer = "";
    for (int i = 0; i < edgeListToImage.length; i++) {
      prefix1.Edge edge = edgeListToImage[i];
      answer += (edge.getVectexId(edge.startIndex) + "->");
      if (i % 10 == 0 && i > 0) {
        answer += '\n';
      }
    }
    prefix1.Edge lastEdge = edgeListToImage[edgeListToImage.length - 1];
    answer += lastEdge.getVectexId(lastEdge.endIndex);
    TextSpan answerSpan = new TextSpan(text: answer,
        style: TextStyle(fontSize: VERTEX_FONT_SIZE * 2, color: Colors.black));
    TextPainter answerTp = new TextPainter(text: answerSpan,
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr);
    answerTp.layout();
    answerTp.paint(canvas, Offset(50, Y_LIMIT - 100));

    //draw file name
//    TextSpan span = new TextSpan(text: outPutPngFilePath.substring(12),
//          style: TextStyle(fontSize: VERTEX_FONT_SIZE * 2, color: Colors.black));
//    TextPainter tp = new TextPainter(text: span,
//          textAlign: TextAlign.justify,
//          textDirection: TextDirection.ltr);
//    tp.layout();
//    tp.paint(canvas, Offset(50,  Y_LIMIT + 50));


  }


  Future<File> _localFile(String outPutPngFilePath) async {
    if (outPutPngFilePath.contains("15"))
      print('$storagePath/$outPutPngFilePath');
    return File('$storagePath/$outPutPngFilePath');
  }

  Future<File> writeImage(Uint8List pngBytes, String outPutPngFilePath) async {
    File file = await _localFile(outPutPngFilePath);

    // Write the file
    return file.writeAsBytes(pngBytes);
  }

  void outputVertexAndEdgeJson(List<Vertex> vertexList, List<Edge> edgeList,
      String fileName) async
  {
    if (true) {
      Map<String, dynamic> map = new Map();

      List<Edge> edges = new List(edgeList.length);

      for (int i = 0; i < edgeList.length; i ++) // draw edge
          {
        Edge edge = edgeList.elementAt(i);
        edges[i] = edge;
        edges[i].inArrayIndex = i;
      }

      map['edges'] = edges;

      List<Vertex> vertexs = new List(vertexList.length);
      for (int i = 0; i < vertexList.length; i ++) {
        Offset offset = new Offset(vertexList[i].x, vertexList[i].y);
        Vertex vertex = new Vertex(null);
        vertex.x = offset.dx;
        vertex.y = offset.dy;

//        vertex.x = offset.dx ;
//        vertex.y = offset.dy ;

        vertex.index = i;

        //String json = jsonEncode(vertex);
        vertexs[i] = vertex;
      }

      map['vertices'] = vertexs;


      map['graph'] = {"height": 924, "width": 840};

      String finalJson = jsonEncode(map);

      File file = new File(fileName);
      Directory directory = new Directory("/storage/emulated/0/level/");
      if (!directory.existsSync()) directory.createSync();
      if (file.existsSync()) {
        file.deleteSync();
        file = new File(fileName);
        file.createSync();
      } else {
        file.createSync();
      }
      await file.writeAsString(finalJson);
      //printLog(finalJson);
    }
    else {
      print('奇数边的点不是两个，请检查边是否有问题！！');
    }
  }


  void generateJsons() async
  {
    for (int k = 3; k < 4; k++) {
      List<String> levelDatas = LevelDataProduct.RES;
      if (k == 0) {
        levelDatas = LevelDataProduct.SWAP_UP;
      } else if (k == 1) {
        levelDatas = LevelDataProduct.SWAP_ADD;
      } else if (k == 2) {
        levelDatas = LevelDataProduct.SWAP_DOWN;
      } else if (k == 3) {
        levelDatas = LevelDataProduct.RES;
      } else if (k == 4) {
        levelDatas = LevelDataProduct.SWAP_TOP;
      } else {
        levelDatas = LevelDataProduct.SWAP_BOTTOM;
      }
      int length = levelDatas.length;
      for (int i = 0; i < length; i ++) {
        String levelData = await rootBundle.loadString(levelDatas[i]);
        var parsedJson = json.decode(levelData);
        var edges = parsedJson['edges'];
        var vertices = parsedJson['vertices'];

        List<Edge> edgeListToImage = [];
        List<Offset> vertexListToImage = [];
        List<Vertex> vertexList = [];

        List<int> edgeIndexListRepeatOne = [];
        List<int> edgeIndexListRepeatTwice = [];
        for (int i = 0; i < edges.length; i ++) {
          Edge edge = Edge(edges[i]);
          edgeListToImage.add(edge);
          if (edge.repeat == 1) {
            edgeIndexListRepeatOne.add(i);
          } else if (edge.repeat == 2) {
            edgeIndexListRepeatTwice.add(i);
          }
        }

        for (int i = 0; i < vertices.length; i ++) {
          Vertex vertex = Vertex(vertices[i]);
          vertexList.add(vertex);
        }

        EulerInfo euler = getEulerInfo(vertexList, edgeListToImage, 1, 1);
        EulerInfo eulerDouble = copyEuler(euler);
        EulerInfo eulerAddTri = copyEuler(euler);
        EulerInfo eulerAddTriBottom = copyEuler(euler);
        EulerInfo eulerSwap = copyEuler(euler);
        EulerInfo eulerSwapOffset = copyEuler(euler);
        EulerInfo eulerSwapTwoPairs = copyEuler(euler);
        EulerInfo eulerSwapTwoPairsDown = copyEuler(euler);
        EulerInfo eulerTopY = copyEuler(euler);
        EulerInfo eulerBottomY = copyEuler(euler);
        Vertex center = euler.center;
        List<Vertex> vList = getMinDistancePointsNotConnect(eulerDouble);
        if (vList.isNotEmpty) {
          eulerDouble.edgeList =
              addDoubleDirectEdge(eulerDouble.edgeList, vList);
        }
        bool hasUglyEdge = false;
        bool has = false;
        for (int j = k; j < k + 1; j++) {
          String tail = "res";
          List<Vertex> tempList = [];
          if (j == 0) {
            tail = "swap";
            eulerSwapTwoPairs.vertexList =
                translateX180(eulerSwapOffset.vertexList, center);
            List<Vertex> leftList = findLeftUpConnerPoints(eulerSwapTwoPairs);
            List<Vertex> rightList = findRightUpConnerPoints(eulerSwapTwoPairs);
            List<Vertex> swapList = [];
            if (leftList.isNotEmpty) {
              swapVertex(eulerSwapTwoPairs, leftList[0], leftList[1], false);
              swapList.add(leftList[0]);
              swapList.add(leftList[1]);
            }
            if (rightList.isNotEmpty) {
              swapVertex(eulerSwapTwoPairs, rightList[0], rightList[1], false);
              swapList.add(rightList[0]);
              swapList.add(rightList[1]);
            }
            List<Edge> swapEdgeList = getSwapEdgeList(
                swapList, eulerSwapTwoPairs.edgeList);
            hasUglyEdge =
                prefix1.hasUglyEdge(eulerSwapTwoPairs.vertexList, swapEdgeList);
            if (hasUglyEdge) {
              print('has ugly edgeUP = $i');
              continue;
            }
            tempList = eulerSwapTwoPairs.vertexList;
            edgeListToImage = eulerSwapTwoPairs.edgeList;
          } else if (j == 1) {
            tail = "swap-add-2";

            eulerSwapTwoPairs.vertexList =
                translateX180(eulerSwapOffset.vertexList, center);
            List<Vertex> leftList = findLeftUpConnerPoints(eulerSwapTwoPairs);
            List<Vertex> rightList = findRightUpConnerPoints(eulerSwapTwoPairs);
            List<Vertex> swapList = [];
            if (leftList.isNotEmpty) {
              swapVertex(eulerSwapTwoPairs, leftList[0], leftList[1], false);
              swapList.add(leftList[0]);
              swapList.add(leftList[1]);
            }
            if (rightList.isNotEmpty) {
              swapVertex(eulerSwapTwoPairs, rightList[0], rightList[1], false);
              swapList.add(rightList[0]);
              swapList.add(rightList[1]);
            }
            List<Edge> swapEdgeList = getSwapEdgeList(
                swapList, eulerSwapTwoPairs.edgeList);
            hasUglyEdge =
                prefix1.hasUglyEdge(eulerSwapTwoPairs.vertexList, swapEdgeList);
            if (hasUglyEdge) continue;
            addTopTri(eulerSwapTwoPairs);
            tempList = eulerSwapTwoPairs.vertexList;
            edgeListToImage = eulerSwapTwoPairs.edgeList;
          } else if (j == 3) {
//            euler = getEulerInfo(
//                euler.vertexList, euler.edgeList, 550 / euler.height,
//                500 / euler.width);
            if (hasUglyEdge || has) {
              continue;
            }
            tempList = euler.vertexList;
            edgeListToImage = euler.edgeList;
          } else if (j == 2) {
            tail = "swap-down";
            eulerSwapTwoPairsDown.vertexList =
                translateX180(eulerSwapTwoPairsDown.vertexList, center);
            List<Vertex> leftList = findLeftDownConnerPoints(
                eulerSwapTwoPairsDown);
            List<Vertex> rightList = findRightDownConnerPoints(
                eulerSwapTwoPairsDown);
            List<Vertex> swapList = [];
            if (leftList.isNotEmpty) {
              swapVertex(
                  eulerSwapTwoPairsDown, leftList[0], leftList[1], false);
              swapList.add(leftList[0]);
              swapList.add(leftList[1]);
            }
            if (rightList.isNotEmpty) {
              swapVertex(
                  eulerSwapTwoPairsDown, rightList[0], rightList[1], false);
              swapList.add(rightList[0]);
              swapList.add(rightList[1]);
            }
            List<Edge> swapEdgeList = getSwapEdgeList(
                swapList, eulerSwapTwoPairsDown.edgeList);
            hasUglyEdge = prefix1.hasUglyEdge(
                eulerSwapTwoPairsDown.vertexList, swapEdgeList);
            if (hasUglyEdge) {
              print('has ugly edge = $i');
              break;
            }
            tempList = eulerSwapTwoPairsDown.vertexList;
            edgeListToImage = eulerSwapTwoPairsDown.edgeList;
          } else if (j == 4) {
            tail = "y-top";
            List<Vertex> vertexList = getYCenterVertexList(eulerTopY, TYPE_TOP);
            if (vertexList == null || vertexList.length < 2) {
              print("no center top " + i.toString());
              has = true;
              continue;
            }
            swapVertex(eulerTopY, vertexList[0], vertexList[1], false);
            List<Vertex> swapList = [vertexList[0], vertexList[1]];
            List<Edge> swapEdgeList = getSwapEdgeList(
                swapList, eulerTopY.edgeList);

            hasUglyEdge =
                prefix1.hasUglyEdge(eulerTopY.vertexList, swapEdgeList);
            if (hasUglyEdge) {
              print('has ugly edge Top Y = $i');
              break;
            }
            tempList = eulerTopY.vertexList;
            edgeListToImage = eulerTopY.edgeList;
          } else if (j == 5) {
            tail = "y-bottom";
            List<Vertex> vertexList = getYCenterVertexList(
                eulerBottomY, TYPE_BOTTOM);
            if (vertexList == null || vertexList.length < 2) {
              print("no center top " + i.toString());
              has = true;
              continue;
            }
            swapVertex(eulerBottomY, vertexList[0], vertexList[1], false);
            List<Vertex> swapList = [vertexList[0], vertexList[1]];
            List<Edge> swapEdgeList = getSwapEdgeList(
                swapList, eulerBottomY.edgeList);
            hasUglyEdge =
                prefix1.hasUglyEdge(eulerBottomY.vertexList, swapEdgeList);
            if (hasUglyEdge) {
              print('has ugly edge Top Y = $i');
              continue;
            }
            tempList = eulerBottomY.vertexList;
            edgeListToImage = eulerBottomY.edgeList;
          }
          vertexListToImage.clear();
          for (int k = 0; k < tempList.length; k++) {
            Vertex vertex = tempList[k];
            vertexListToImage.add(Offset(vertex.x, vertex.y));
          }
          var path = "onelineln/" + levelDatas[i].replaceAll("assets/", "")
              .replaceAll("/", "-")
              .replaceAll(".txt", "");
          var jsonPath = levelDatas[i].replaceAll("assets/", "")
              .replaceAll("/", "-")
              .replaceAll(".txt", "") + ".txt";
          List<String> paths = levelDatas[i].split('/');
          tempList = compressFinal(
              tempList, euler, FINAL_HEIGHT, FINAL_WIDTH);
          String name = paths[paths.length - 1];
          String //outJsonPath = (await getExternalStorageDirectory()).path +"level/" + paths[paths.length-2] + "/" + name.substring(2);
          outJsonPath = (await getExternalStorageDirectory()).path + "/level/" +
              jsonPath;
          outputVertexAndEdgeJson(tempList, edgeListToImage, outJsonPath);
        }
        print('level datad count = $i');
      }
    }
  }

  //out put the edge and vertex to json
  void saveJson() async
  {
    List<FileStruct> fileList = myApp.state.fileList;
    int selectPos = myApp.state.selectPos;
    if (fileList == null || selectPos < 0 || selectPos > fileList.length - 1) {
      return;
    }
    FileStruct struct = fileList[selectPos];
    String ancestor = "/level/";
    if (struct.level > 999) ancestor = "/challenge/";
    String stage = "/l";
    if (struct.level > 999) stage = "/lvl";
    String fileName1 = (await getExternalStorageDirectory()).path + ancestor;
    String fileName2 = fileName1 + "lp" + struct.level.toString() + "/";
    String fileName = (await getExternalStorageDirectory()).path + ancestor +
        "lp"
        + struct.level.toString() + stage + struct.stage.toString();

    if (doVertexCheckValid()) {
      Map<String, dynamic> map = new Map();

      List<Edge> edges = copyEdgeList(edgeList);

      for (int i = 0; i < edgeList.length; i ++) // draw edge
          {
        Edge edge = edgeList.elementAt(i);
        edge.inArrayIndex = i;
        edges[i] = edge;
      }

      map['edges'] = edges;

      List<Vertex> vertexes = new List(vertexList.length);
      for (int i = 0; i < vertexList.length; i ++) {
        Offset offset = vertexList.elementAt(i);

        Vertex vertex = new Vertex(null);
        vertex.x = offset.dx - X_MIN_LIMIT;
        vertex.y = offset.dy - Y_MIN_LIMIT;

//        vertex.x = offset.dx ;
//        vertex.y = offset.dy ;

        vertex.index = i;
        vertexes[i] = vertex;
      }
      RectShape shape = getRect(vertexes);
      int adapterX = 840;
      int adapterY = 924;
      adapterEditScreen(vertexes, shape, adapterY, adapterX);

      map['vertices'] = vertexes;


      map['graph'] = {"height": 924, "width": 840};

      String finalJson = jsonEncode(map);

      printLog(finalJson);
      File file = new File(fileName);
      Directory directory1 = new Directory(fileName1);
      Directory directory2 = new Directory(fileName2);
      if (!directory1.existsSync()) {
        directory1.createSync();
      }
      if (!directory2.existsSync()) {
        directory2.createSync();
      }

      if (file.existsSync()) {
        file.deleteSync();
        file = new File(fileName);
        file.createSync();
      } else {
        file.createSync();
      }
      await file.writeAsString(finalJson);
      Directory directory = new Directory(fileName2);
      directory.listSync().length;
      //Toast.show("保存完成", mContext);
      prefix2.Fluttertoast.showToast(msg: "已编辑完" +  directory.listSync().length.toString()+"个");
    }
    else {
      print('奇数边的点不是两个，请检查边是否有问题！！');
    }
  }

  void generateAllAnswers() async {
    List<FileStruct> allFileList = [];
    allFileList.addAll(levelList);
    //allFileList.addAll(challengeList.sublist(270));
    for (int i = 0; i < allFileList.length; i ++) {
      FileStruct file = allFileList[i];
      String levelData = await rootBundle.loadString(file.path);

      var parsedJson = json.decode(levelData);
      var edges = parsedJson['edges'];
      var vertices = parsedJson['vertices'];

      List<Edge> edgeListToImage = [];
      List<Offset> vertexListToImage = [];
      List<Vertex> vertexList = [];

      for (int i = 0; i < edges.length; i ++) {
        Edge edge = Edge(edges[i]);
        edgeListToImage.add(edge);
      }

      for (int i = 0; i < vertices.length; i ++) {
        Vertex vertex = Vertex(vertices[i]);
        vertexList.add(vertex);
      }

      RectShape shape = getRect(vertexList);
      int adapterX = 450;
      int adapterY = 495;
      adapterEditScreen(vertexList, shape, adapterY, adapterX);
      translateCenter(vertexList, adapterY, adapterX, 280, 376);

      for (int k = 0; k < vertexList.length; k++) {
        Vertex vertex = vertexList[k];
        vertexListToImage.add(Offset(vertex.x, vertex.y));
      }
      var path = "onelineln/";
      if (file.level < 999) {
        outPutPngFilePath =
            path + "level/level" + (file.level).toString() + "/" +
                "level" + (file.level).toString() + "-stage" +
                (file.stage).toString() + ".png";
        String directoryPath1 = (await getExternalStorageDirectory()).path +
            "/" + path + "level/";
        Directory directory1 = Directory(directoryPath1);
        if (!directory1.existsSync()) directory1.createSync();
        String directoryPath2 = directoryPath1 + "level" +
            (file.level).toString() + "/";
        Directory directory2 = Directory(directoryPath2);
        if (!directory2.existsSync()) directory2.createSync();
        drawLevelDataToPng(
            outPutPngFilePath, edgeListToImage, vertexListToImage, null);
        //printLog(outPutPngFilePath + "\n");
      } else {
        outPutPngFilePath =
            path + "challenge/level" + (file.level).toString() + "/" +
                "level" + (file.level).toString() + "-stage" +
                (file.stage).toString() + ".png";
        String directoryPath1 = (await getExternalStorageDirectory()).path +
            "/" + path + "challenge/";
        Directory directory1 = Directory(directoryPath1);
        if (!directory1.existsSync()) directory1.createSync();
        String directoryPath2 = directoryPath1 + "level" +
            (file.level).toString() + "/";
        Directory directory2 = Directory(directoryPath2);
        if (!directory2.existsSync()) directory2.createSync();
        drawLevelDataToPng(
            outPutPngFilePath, edgeListToImage, vertexListToImage, null);
      }
    }
  }

  void saveAllJson() async
  {
    List<FileStruct> fileList = challengeList;
    int selectPos = myApp.state.selectPos;
//    if (fileList == null || selectPos < 0 || selectPos > fileList.length - 1) {
//      return;
//    }
    for (int selectPos = 0; selectPos < fileList.length; selectPos++) {
      FileStruct struct = fileList[selectPos];
      String ancestor = "/level/";
      if (struct.level > 999) ancestor = "/challenge/";
      String stage = "/l";
      if (struct.level > 999) stage = "/lvl";
      String fileName1 = (await getExternalStorageDirectory()).path + ancestor;
      String fileName2 = fileName1 + "lp" + struct.level.toString() + "/";
      String fileName = (await getExternalStorageDirectory()).path + ancestor +
          "lp"
          + struct.level.toString() + stage + struct.stage.toString();
      String levelData = await rootBundle.loadString(struct.path);

      var parsedJson = json.decode(levelData);
      var edges = parsedJson['edges'];
      var vertices = parsedJson['vertices'];

      edgeList.clear();
      vertexList.clear();
      List<Vertex> vertexListToImage = [];

      for (int i = 0; i < edges.length; i ++) {
        Edge edge = Edge(edges[i]);
        edgeList.add(edge);
      }

      for (int i = 0; i < vertices.length; i ++) {
        Vertex vertex = Vertex(vertices[i]);
        vertexListToImage.add(vertex);
        vertexList.add(new Offset(vertex.x, vertex.y));
      }
      if (doVertexCheckValid()) {
        Map<String, dynamic> map = new Map();

        List<Edge> edges = copyEdgeList(edgeList);

        for (int i = 0; i < edgeList.length; i ++) // draw edge
            {
          Edge edge = edgeList.elementAt(i);
          edge.inArrayIndex = i;
          edges[i] = edge;
        }

        map['edges'] = edges;

        List<Vertex> vertexes = new List(vertexList.length);
        for (int i = 0; i < vertexList.length; i ++) {
          Offset offset = vertexList.elementAt(i);

          Vertex vertex = new Vertex(null);
          vertex.x = offset.dx - X_MIN_LIMIT;
          vertex.y = offset.dy - Y_MIN_LIMIT;

//        vertex.x = offset.dx ;
//        vertex.y = offset.dy ;

          vertex.index = i;
          vertexes[i] = vertex;
        }
        RectShape shape = getRect(vertexes);
        int adapterX = 840;
        int adapterY = 924;
        adapterEditScreen(vertexes, shape, adapterY, adapterX);

        map['vertices'] = vertexes;


        map['graph'] = {"height": 924, "width": 840};

        String finalJson = jsonEncode(map);

        printLog(finalJson);
        File file = new File(fileName);
        Directory directory1 = new Directory(fileName1);
        Directory directory2 = new Directory(fileName2);
        if (!directory1.existsSync()) {
          directory1.createSync();
        }
        if (!directory2.existsSync()) {
          directory2.createSync();
        }

        if (file.existsSync()) {
          file.deleteSync();
          file = new File(fileName);
          file.createSync();
        } else {
          file.createSync();
        }
        await file.writeAsString(finalJson);
      }
      else {
        print('奇数边的点不是两个，请检查边是否有问题！！');
      }
    }
  }

  void saveAllJson730() async
  {
    List<FileStruct> fileList = challengeList;
    int selectPos = myApp.state.selectPos;
//    if (fileList == null || selectPos < 0 || selectPos > fileList.length - 1) {
//      return;
//    }
    for (int selectPos = 0; selectPos < fileList.length; selectPos++) {
      FileStruct struct = fileList[selectPos];
      String ancestor = "/level/";
      if (struct.level > 999) ancestor = "/challenge/";
      String stage = "/l";
      if (struct.level > 999) stage = "/lvl";
      String fileName1 = (await getExternalStorageDirectory()).path + ancestor;
      String fileName2 = fileName1 + "lp" + struct.level.toString() + "/";
      String fileName = (await getExternalStorageDirectory()).path + ancestor +
          "lp"
          + struct.level.toString() + stage + struct.stage.toString();
      String levelData = await rootBundle.loadString(struct.path);

      var parsedJson = json.decode(levelData);
      var edges = parsedJson['edges'];
      var vertices = parsedJson['vertices'];

      edgeList.clear();
      vertexList.clear();
      List<Vertex> vertexListToImage = [];

      for (int i = 0; i < edges.length; i ++) {
        Edge edge = Edge(edges[i]);
        edgeList.add(edge);
      }

      for (int i = 0; i < vertices.length; i ++) {
        Vertex vertex = Vertex(vertices[i]);
        vertexListToImage.add(vertex);
        vertexList.add(new Offset(vertex.x, vertex.y));
      }
      if (doVertexCheckValid()) {
        Map<String, dynamic> map = new Map();

        List<Edge> edges = copyEdgeList(edgeList);

        for (int i = 0; i < edgeList.length; i ++) // draw edge
            {
          Edge edge = edgeList.elementAt(i);
          edge.inArrayIndex = i;
          edges[i] = edge;
        }

        map['edges'] = edges;

        List<Vertex> vertexes = new List(vertexList.length);
        for (int i = 0; i < vertexList.length; i ++) {
          Offset offset = vertexList.elementAt(i);

          Vertex vertex = new Vertex(null);
          vertex.x = offset.dx - X_MIN_LIMIT;
          vertex.y = offset.dy - Y_MIN_LIMIT;

//        vertex.x = offset.dx ;
//        vertex.y = offset.dy ;

          vertex.index = i;
          vertexes[i] = vertex;
        }
        RectShape shape = getRect(vertexes);
        int adapterX = 730;
        int adapterY = 803;
        adapterEditScreenTxCenter(
            vertexes, shape, adapterY, adapterX, 924, 840);

        map['vertices'] = vertexes;


        map['graph'] = {"height": 924, "width": 840};
        map['graph'] = {"height": 803, "width": 730};


        String finalJson = jsonEncode(map);

        printLog(finalJson);
        File file = new File(fileName);
        Directory directory1 = new Directory(fileName1);
        Directory directory2 = new Directory(fileName2);
        if (!directory1.existsSync()) {
          directory1.createSync();
        }
        if (!directory2.existsSync()) {
          directory2.createSync();
        }

        if (file.existsSync()) {
          file.deleteSync();
          file = new File(fileName);
          file.createSync();
        } else {
          file.createSync();
        }
        await file.writeAsString(finalJson);
      }
      else {
        print('奇数边的点不是两个，请检查边是否有问题！！');
      }
    }
  }

}
