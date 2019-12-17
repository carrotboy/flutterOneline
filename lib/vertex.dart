
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:langaw/oneline-basic.dart';

class Vertex extends OneLineBasic
{
    double x =0;
    double y =0;

    int index = -1;

     Vertex(Map<String, dynamic> jsonData)
    {
      if(jsonData != null) {

        int xValue = jsonData['x'];
        x = xValue.toDouble();

        int yValue = jsonData['y'];
        y = yValue.toDouble();
        index = getVertexIndex(jsonData['id'].toString());

      }

    }


    Map<String, dynamic> toJson()
    {

      Map<String, dynamic> map = new Map();
      map['id'] =  getVectexId(index);
      map['x'] = x.toInt();
      map['y'] = y.toInt();

      return map;

    }


}

Map<String, dynamic> newJson(double x, double y) {
  Map<String, dynamic> map = new Map();
  map['id'] =  '0';
  map['x'] = x.toInt();
  map['y'] = y.toInt();

  return map;
}

Vertex newVertex(Vertex vertex) {
  return Vertex(vertex.toJson());
}

double calculateDis(Vertex start, Vertex end) {
  return sqrt((start.y-end.y)*(start.y-end.y) + (start.x-end.x)*(start.x-end.x));
}

Offset getCorrectPoint(Offset offset, double distance) {
  double height = (offset.dy+5)~/10 * distance;
  double width = (offset.dx+5)~/10 * distance;
  return Offset(width, height);
}