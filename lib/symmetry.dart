import 'package:langaw/vertex.dart';

import 'translate-data.dart';
class SymmetryY {
  List<Vertex> leftList = [];
  List<Vertex> rightList = [];
  Map<Vertex, Vertex> map = new Map();
  Vertex center;
  bool isSymmetry = false;
}

SymmetryY getSymmetry(EulerInfo euler) {
  SymmetryY symmetryY = new SymmetryY();
  symmetryY.center = euler.center;
  List<Vertex> vertexList = euler.vertexList;
  Vertex center = symmetryY.center;
  for (int i = 0; i < vertexList.length; i++) {
    Vertex vertex = vertexList[i];
    if (vertex.x < center.x && !_sameYAxis(vertex, center)) {
      symmetryY.leftList.add(vertex);
    } else if (vertex.x > center.x && !_sameYAxis(vertex, center)) {
      symmetryY.rightList.add(vertex);
    }
  }
  if (symmetryY.leftList.length != symmetryY.rightList.length) {
    return symmetryY;
  }

}

bool _sameYAxis(Vertex des, Vertex res) {
  if ((des.x-res.x).abs() < 10) {
    return true;
  }
  return false;
}

bool _isSymmetryYAxis(Vertex v1, Vertex v2, SymmetryY symmetryY) {
  if ((v1.y-v2.y).abs() < 10 && (v1.x+v2.x - symmetryY.center.x * 2).abs() < 10) {
    return true;
  }
}

bool _isSymmetryY(SymmetryY symmetryY) {
  List<Vertex> leftList = symmetryY.leftList;
  List<Vertex> rightList = symmetryY.rightList;
  for (int i = 0; i < leftList.length; i++) {
    bool hasSymmetryPoint = false;
    for (int j = 0; j < rightList.length; j++) {

    }
  }
}

List<Vertex> findLeftUpConnerPoints(EulerInfo euler) {
  List<Vertex> list = copyVertexList(euler.vertexList);
  list.sort((left, right)=> ((left.x + left.y - right.x - right.y)*100).toInt());
  List<Vertex> desList = [];
  for (int i = 0; i < list.length; i++) {
    Vertex vertex = list[i];
    if (vertex.x < euler.center.x - 15) {
      desList.add(vertex);
    }
    if (desList.length == 2) {
      return desList;
    }
  }
  return [];
}

List<Vertex> findRightUpConnerPoints(EulerInfo euler) {
  List<Vertex> list = translateX180(copyVertexList(euler.vertexList), euler.center);
  list.sort((left, right)=> ((left.x + left.y - right.x - right.y)*100).toInt());
  List<Vertex> desList = [];
  for (int i = 0; i < list.length; i++) {
    Vertex vertex = list[i];
    if (vertex.x < euler.center.x - 15) {
      desList.add(vertex);
    }
    if (desList.length == 2) {
      return desList;
    }
  }
  return [];
}

List<Vertex> findRightDownConnerPoints(EulerInfo euler) {
  List<Vertex> list = translateXY180(copyVertexList(euler.vertexList), euler.center);
  list.sort((left, right)=> ((left.x + left.y - right.x - right.y)*100).toInt());
  List<Vertex> desList = [];
  for (int i = 0; i < list.length; i++) {
    Vertex vertex = list[i];
    if (vertex.x < euler.center.x - 15) {
      desList.add(vertex);
    }
    if (desList.length == 2) {
      return desList;
    }
  }
  return [];
}

List<Vertex> findLeftDownConnerPoints(EulerInfo euler) {
  List<Vertex> list = translateY180(copyVertexList(euler.vertexList), euler.center);
  list.sort((left, right)=> ((left.x + left.y - right.x - right.y)*100).toInt());
  List<Vertex> desList = [];
  for (int i = 0; i < list.length; i++) {
    Vertex vertex = list[i];
    if (vertex.x < euler.center.x - 15) {
      desList.add(vertex);
    }
    if (desList.length == 2) {
      return desList;
    }
  }
  return [];
}