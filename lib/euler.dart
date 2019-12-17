import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:langaw/langaw-game.dart';
import 'package:langaw/main.dart';
import 'package:langaw/translate-data.dart';
import 'package:langaw/vertex.dart';

import 'edge.dart';

void initEuler(String path) async{
  List<Vertex> list = List();
  String levelData = await rootBundle.loadString(path);
  var parsedJson = json.decode(levelData);
  var edges = parsedJson['edges'];
  var vertices = parsedJson['vertices'];
  game.doClean();
  game.mode = LangawGame.MODE_MOVE;
  //game.vertexList = vertices;
  game.connect = new List(vertices.length);
  for (int i = 0; i < vertices.length; i++) {
    game.connect[i] = new List(vertices.length);
    for (int j = 0; j < vertices.length; j++) {
      game.connect[i][j] = false;
    }
    game.connect[i][i] = true;
  }
  for(int edgeIndex = 0 ; edgeIndex < edges.length; edgeIndex ++  )
  {
    Edge edge = Edge(edges[edgeIndex]);
    game.edgeList.add(edge);
  }
  for(int vertexIndex = 0 ; vertexIndex < vertices.length; vertexIndex ++  ) {
    list.add(Vertex(vertices[vertexIndex]));
  }
  RectShape shape = getRect(list);
  int adapterX = 450;
  int adapterY = 495;
  adapterEditScreen(list, shape, adapterY, adapterX);
  translateCenter(list, adapterY, adapterX, 370, 476);
  adapterTenTenPoints(list);
  for(int i = 0 ; i < list.length; i++  )
  {
    game.vertexList.add(Offset(list[i].x, list[i].y));
  }
  for (int i = 0; i < game.edgeList.length; i++) {
    Edge edge = game.edgeList[i];
    game.connect[edge.startIndex][edge.endIndex] = true;
  }
}

class RectShape{
  int left = 1000000;
  int right = -1000000;
  int bottom = 1000000;
  int top = -1000000;
}

RectShape getRect(List<Vertex> vertexs) {
  RectShape shape = new RectShape();
  for(int i = 0; i < vertexs.length; i++) {
    shape.bottom = min(vertexs[i].y.toInt(), shape.bottom);
    shape.left = min(vertexs[i].x.toInt(), shape.left);
    shape.top = max(vertexs[i].y.toInt(), shape.top);
    shape.right = max(vertexs[i].x.toInt(), shape.right);
  }
  return shape;
}

void adapterEditScreen(List<Vertex> vertexes, RectShape shape, int h, int w) {
  double height = (shape.top - shape.bottom).toDouble();
  double width = (shape.right - shape.left).toDouble();
  double comPressX = w/width;
  double comPressY = h/height;
  //以（0，0）为基准
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = vertexes[i];
    vertex.x -= shape.left;
    vertex.y -= shape.bottom;
    vertex.x *= comPressX;
    vertex.y *= comPressY;
  }
}

void adapterEditScreenTxCenter(List<Vertex> vertexes, RectShape shape, int h, int w, int hNew, int wNew) {
  double height = (shape.top - shape.bottom).toDouble();
  double width = (shape.right - shape.left).toDouble();
  double comPressX = w/width;
  double comPressY = h/height;
  //以（0，0）为基准
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = vertexes[i];
    vertex.x -= shape.left;
    vertex.y -= shape.bottom;
    vertex.x *= comPressX;
    vertex.y *= comPressY;
    vertex.x -= (w-wNew)/2;
    vertex.y -= (h-hNew)/2;
  }
}

void translateCenter(List<Vertex> vertexes, int h, int w, int cx, int cy) {
  double x = w/2.0;
  double y = h/2.0;
  double detX = x - cx;
  double detY = y - cy;
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = vertexes[i];
    vertex.x -= detX;
    vertex.y -= detY;
  }
}

void adapterTenTenPoints(List<Vertex> vertexes){
  for (int i = 0; i < vertexes.length; i++) {
    adapterTenTenPoint(vertexes[i]);
  }
}

void adapterTenTenPoint(Vertex vertex) {
  vertex.x = ((vertex.x+5).toInt() - (vertex.x+5).toInt()%10).toDouble();
  vertex.y = ((vertex.y+5).toInt() - (vertex.y+5).toInt()%10).toDouble();

}

