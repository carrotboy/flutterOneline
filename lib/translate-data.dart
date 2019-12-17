import 'package:langaw/oneline-basic.dart';
import 'package:langaw/vertex.dart';
import 'package:langaw/vertex.dart' as prefix0;
import 'dart:math';

import 'edge.dart';

double det = 0.05;
const int leftUp = 1;
const int rightUp = 2;
const int leftDown = 3;
const int rightDown = 4;
const int TYPE_TOP = 1;
const int TYPE_BOTTOM = 2;


class EulerInfo {
  Vertex center;
  double height = 0;
  double width = 0;
  int singleDirectCount = 0;
  int doubleDirectCount = 0;
  List<Vertex> vertexList = [];
  List<Edge> edgeList = [];
  List<List<bool>> connect = [];
  List<int> pointDegree = [];//每个点出入度f
}

EulerInfo copyEuler(EulerInfo euler) {
  EulerInfo copy = new EulerInfo();
  copy.center = euler.center;
  copy.height = euler.height;
  copy.width = euler.width;
  copy.singleDirectCount = euler.singleDirectCount;
  copy.doubleDirectCount = euler.doubleDirectCount;
  copy.vertexList = copyVertexList(euler.vertexList);
  copy.edgeList = copyEdgeList(euler.edgeList);
  copy.connect = euler.connect;
  copy.pointDegree = euler.pointDegree;
  return copy;
}

Vertex getCenter(List<Vertex> vertexs) {
  double minWidth = 0;
  double maxWidth = 0;
  double minHeight = 0;
  double maxHeight = 0;
  for(int i = 0; i < vertexs.length; i++) {
    minHeight = min(vertexs[i].y, minHeight);
    minWidth = min(vertexs[i].x, minWidth);
    maxHeight = max(vertexs[i].y, maxHeight);
    maxWidth = max(vertexs[i].x, maxWidth);
  }
  return new Vertex(newJson((minWidth+maxWidth)/2, (minHeight+maxHeight)/2));
}

EulerInfo getEulerInfo(List<Vertex> vertexList, List<Edge> edgeList, double compressY, double compressX) {
  EulerInfo euler = new EulerInfo();
  double minWidth = double.maxFinite;
  double maxWidth = 0;
  double minHeight = double.maxFinite;
  double maxHeight = 0;
  euler.connect = new List(vertexList.length);
  for (int i = 0; i < vertexList.length; i++) {
    euler.connect[i] = new List(vertexList.length);
    for (int j = 0; j < vertexList.length; j++) {
      euler.connect[i][j] = false;
    }
    euler.connect[i][i] = true;
  }
  for(int i = 0; i < vertexList.length; i++) {
    euler.pointDegree.add(0);
    minHeight = min(vertexList[i].y, minHeight);
    minWidth = min(vertexList[i].x, minWidth);
    maxHeight = max(vertexList[i].y, maxHeight);
    maxWidth = max(vertexList[i].x, maxWidth);
  }
  euler.center = new Vertex(newJson((minWidth+maxWidth)/2, (minHeight+maxHeight)/2));
  euler.height = (maxHeight - minHeight) * compressY;
  euler.width = (maxWidth - minWidth) * compressX;
  euler.vertexList = translateCompress(vertexList, euler.center, compressY, compressX);
  double detX = euler.center.x - 270;
  double dexY = euler.center.y - 375;
  for (int i = 0; i < euler.vertexList.length; i++) {
    euler.vertexList[i].x -= detX;
    euler.vertexList[i].y -= dexY;
  }
  euler.center.x = 270;
  euler.center.y = 375;
  euler.edgeList = copyEdgeList(edgeList);
  for (int i = 0; i < edgeList.length; i++) {
    Edge edge = edgeList[i];
    euler.pointDegree[edge.startIndex]++;
    if (edge.lock) {
      euler.singleDirectCount++;
    } else if (edge.repeat == 2) {
      euler.doubleDirectCount++;
    }
    euler.connect[edge.startIndex][edge.endIndex] = true;
    euler.connect[edge.endIndex][edge.startIndex] = true;
  }
  return euler;

}

List<Vertex> translateX180(List<Vertex> vertexes, Vertex center) {
  List<Vertex> newList = [];
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = new Vertex(vertexes[i].toJson());
    vertex.x = center.x * 2 - vertex.x;
    newList.add(newVertex(vertex));
  }
  return newList;
}

List<Vertex> translateY180(List<Vertex> vertexes, Vertex center) {
  List<Vertex> newList = [];
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = new Vertex(vertexes[i].toJson());
    vertex.y = center.y * 2 - vertex.y;
    newList.add(newVertex(vertex));
  }
  return newList;
}

List<Vertex> translateXY180(List<Vertex> vertexes, Vertex center) {
  List<Vertex> newList = [];
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = new Vertex(vertexes[i].toJson());
    vertex.y = center.y * 2 - vertex.y;
    vertex.x = center.x * 2 - vertex.x;
    newList.add(newVertex(vertex));
  }
  return newList;
}

List<Vertex> translateCompressY20(List<Vertex> vertexes, Vertex center) {
  List<Vertex> newList = [];
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = new Vertex(vertexes[i].toJson());
    vertex.y = center.y * 0.2 + vertex.y * 0.8;
    vertex.x = center.x * 0.05 + vertex.x * 0.95;
    newList.add(newVertex(vertex));
  }
  return newList;
}

List<Vertex> translateCompress(List<Vertex> vertexes, Vertex center, double compressY, double compressX) {
  List<Vertex> newList = [];
  for (int i = 0; i < vertexes.length; i++) {
    Vertex vertex = new Vertex(vertexes[i].toJson());
    vertex.y = center.y * (1-compressY) + vertex.y * compressY;
    vertex.x = center.x * (1-compressX) + vertex.x * compressX;
    newList.add(newVertex(vertex));
  }
  return newList;
}

List<Edge> copyEdgeList(List<Edge> edgeList) {
  List<Edge> list = [];
  for (int i = 0; i< edgeList.length; i++) {
    list.add(Edge(edgeList[i].toJson()));
  }
  return list;
}

List<Vertex> copyVertexList(List<Vertex> vertexList) {
  List<Vertex> list = [];
  for (int i = 0; i < vertexList.length; i++) {
    list.add(Vertex(vertexList[i].toJson()));
  }
  return list;
}

List<Vertex> getMinDistancePointsNotConnect(EulerInfo euler) {
  List<Vertex> points = new List(2);
  double minDis = double.maxFinite;
  List<Vertex> vertexList = euler.vertexList;
  for (int i = 0; i < vertexList.length; i++) {
    for (int j = i+1; j < vertexList.length; j++) {
      double distance = calculateDis(vertexList[i], vertexList[j]);
      if (!euler.connect[i][j] && distance < minDis) {
        points[0] = newVertex(vertexList[i]);
        points[1] = newVertex(vertexList[j]);
        minDis = distance;
      }
    }
  }
  if (points[0] == null) {
    points = new List(0);
  }
  return points;
}





//List<Vertex> getMinDistancePointsNotConnect(EulerInfo euler) {
//  List<Vertex> points = new List(2);
//  Vertex startV = euler.vertexList[euler.edgeList[0].startIndex];
//  double minDis = double.maxFinite;
//  List<Vertex> vertexList = euler.vertexList;
//  points[0] = startV;
//  for (int i = 0; i < vertexList.length; i++) {
//    if (vertexList[i].index != startV.index && !euler.connect[startV.index][vertexList[i].index]) {
//      if (calculateDis(startV, vertexList[i]) < minDis) {
//        points[1] = vertexList[i];
//      }
//
//    }
//  }
//  return points;
//}

bool isEuler(EulerInfo euler) {
  List<int> degree = euler.pointDegree;
  for (int i = 0; i < degree.length; i++) {
    if (degree[i]%2 == 1) {
      return false;
    }
  }
  return true;
}

List<Edge> addDoubleDirectEdge(List<Edge> edgelist, List<Vertex> vertexList) {
  List<Edge> list = [];
  Vertex start = vertexList[0];
  Vertex end = vertexList[1];
  Edge edge1 = new Edge(null);
  Edge edge2 = new Edge(null);
  Vertex first;
  Vertex second;
  int pos = 0;
  for (int i = 0; i < edgelist.length; i++) {
    Edge edge = edgelist[i];
    if (edge.endIndex == start.index) {
      first = start;
      second = end;
      pos = i + 1;
      break;
    } else if (edge.endIndex == end.index) {
      first = end;
      second = start;
      pos = i + 1;
      break;
    }
  }
  edge1.startIndex = first.index;
  edge1.endIndex = second.index;
  edge1.repeat = 2;
  edge2.startIndex = second.index;
  edge2.endIndex = second.index;
  list.add(edge1);
  list.add(edge2);
  edgelist.insertAll(pos, list);
  return edgelist;
}


List<Vertex> _findTopTriVertexes(EulerInfo euler, int level) {
  List<Vertex> list = [];
  double max = euler.center.y + euler.height * 0.5;
  double max2 = 0;

  List<Vertex> vertexList = euler.vertexList;
  if (level != 1) {
    for (int i = 0; i < vertexList.length; i++) {
      Vertex vertex = vertexList[i];
      if (vertex.y > max2 && !isSameY(max, vertex.y)) {
        max2 = vertex.y;
      }
    }
    max = max2;
  }
//  if (max < euler.center.y) {
//    return [];
//  }
  for (int i = 0; i < vertexList.length; i++) {
    Vertex vertex = vertexList[i];
    if(isSameY(max, vertex.y)) {
      list.add(vertex);
    }
  }
  list.sort((left,right)=>left.x.toInt()-right.x.toInt());
  if (list.length < 2) {
    return new List();
  } else {
    List<Vertex> topList = new List();
    topList.add(list[0]);
    topList.add(list[list.length-1]);
    return topList;
  }
}

List<Vertex> _findTopTriVs(EulerInfo euler) {
  List<Vertex> vertexList = _findTopTriVertexes(euler, 1);
  if (vertexList.length < 2) {
    vertexList = _findTopTriVertexes(euler, 2);
  }
  if (vertexList.length < 2) {
    return new List();
  }
  return vertexList;
}

void addTopTri(EulerInfo euler) {
  if (euler.vertexList.length > 25) return;
  List<Vertex> vertexList = _findTopTriVs(euler);
  OneLineBasic basic = new OneLineBasic();
  if (vertexList.length < 2) return;
  double minX = euler.center.x - euler.width * 0.5;
  double maxX = euler.center.x + euler.width * 0.5;
  double detX  = double.maxFinite;
  Vertex v1 = vertexList[0];
  Vertex v2 = vertexList[vertexList.length-1];
  detX = min(v1.x-0, detX);
  detX = min(540-v2.x, detX);
  detX = min(detX, 35);
  Vertex topV1 = new Vertex(null);
  topV1.x = v1.x - detX;
  topV1.y = v1.y + 100;
  topV1.index = euler.vertexList.length;
  euler.vertexList.add(topV1);
  Vertex topV2 = new Vertex(null);
  topV2.x = topV1.x + 70;
  topV2.y = topV1.y;
  topV2.index = euler.vertexList.length;
  euler.vertexList.add(topV2);
  _addTriEdge(v1, topV1, topV2, euler);
  Vertex topV3 = new Vertex(null);
  topV3.x = v2.x + detX;
  topV3.y = v2.y + 100;
  topV3.index = euler.vertexList.length;
  euler.vertexList.add(topV3);
  Vertex topV4 = new Vertex(null);
  topV4.x = topV3.x - 70;
  topV4.y = topV3.y;
  topV4.index = euler.vertexList.length;
  euler.vertexList.add(topV4);
  _addTriEdge(v2, topV3, topV4, euler);
}

List<Vertex> _findBottomTriVertexes(EulerInfo euler, int level) {
  List<Vertex> list = [];
  double min = euler.center.y - euler.height * 0.5;
  double min2 = double.maxFinite;

  List<Vertex> vertexList = euler.vertexList;
  if (level != 1) {
    for (int i = 0; i < vertexList.length; i++) {
      Vertex vertex = vertexList[i];
      if (vertex.y < min2 && !isSameY(min, vertex.y)) {
        min2 = vertex.y;
      }
    }
    min = min2;
  }
//  if (min > euler.center.y) {
//    return [];
//  }
  for (int i = 0; i < vertexList.length; i++) {
    Vertex vertex = vertexList[i];
    if(isSameY(min, vertex.y)) {
      list.add(vertex);
    }
  }
  list.sort((left,right)=>left.x.toInt()-right.x.toInt());
  if (list.length < 2) {
    return new List();
  } else {
    List<Vertex> topList = new List();
    topList.add(list[0]);
    topList.add(list[list.length-1]);
    return topList;
  }
}

List<Vertex> _findBottomTriVs(EulerInfo euler) {
  List<Vertex> vertexList = _findBottomTriVertexes(euler, 1);
  if (vertexList.length < 2) {
    vertexList = _findBottomTriVertexes(euler, 2);
  }
  if (vertexList.length < 2) {
    return new List();
  }
  return vertexList;
}

void addBottomTri(EulerInfo euler) {
  if (euler.vertexList.length > 25) return;
  List<Vertex> vertexList = _findBottomTriVs(euler);
  if (vertexList.length < 2) return;
  double detX  = double.maxFinite;
  Vertex v1 = vertexList[0];
  Vertex v2 = vertexList[vertexList.length-1];
  detX = min(v1.x-0, detX);
  detX = min(540-v2.x, detX);
  detX = min(detX, 35);
  Vertex topV1 = new Vertex(null);
  topV1.x = v1.x - detX;
  topV1.y = v1.y - 100;
  topV1.index = euler.vertexList.length;
  euler.vertexList.add(topV1);
  Vertex topV2 = new Vertex(null);
  topV2.x = topV1.x + 70;
  topV2.y = topV1.y;
  topV2.index = euler.vertexList.length;
  euler.vertexList.add(topV2);
  _addTriEdge(v1, topV1, topV2, euler);
  Vertex topV3 = new Vertex(null);
  topV3.x = v2.x + detX;
  topV3.y = v2.y - 100;
  topV3.index = euler.vertexList.length;
  euler.vertexList.add(topV3);
  Vertex topV4 = new Vertex(null);
  topV4.x = topV3.x - 70;
  topV4.y = topV3.y;
  topV4.index = euler.vertexList.length;
  euler.vertexList.add(topV4);
  _addTriEdge(v2, topV3, topV4, euler);
}

void _addTriEdge(Vertex v1, Vertex v2, Vertex v3, EulerInfo euler){
  Edge edge1 = new Edge(null);
  edge1.startIndex = v1.index;
  edge1.endIndex = v2.index;
  Edge edge2 = new Edge(null);
  edge2.startIndex = v2.index;
  edge2.endIndex = v3.index;
  Edge edge3 = new Edge(null);
  edge3.startIndex = v3.index;
  edge3.endIndex = v1.index;
  List<Edge> edgeList = [edge1, edge2, edge3];
  for (int i = 0; i < euler.edgeList.length; i++) {
    if (euler.edgeList[i].startIndex == v1.index) {
      euler.edgeList.insertAll(i, edgeList);
      break;
    }
  }
}


bool isSameY(double h1, double h2) {
  if ((h1-h2).abs() < 10) {
    return true;
  }
  return false;
}

void swapVertex(EulerInfo euler, Vertex v1, Vertex v2, bool isOffset) {
  v1.x = euler.vertexList[v1.index].x;
  v1.y = euler.vertexList[v1.index].y;
  v2.x = euler.vertexList[v2.index].x;
  v2.y = euler.vertexList[v2.index].y;
  if (isOffset) {
     _offset(v1, v2);
  }
  euler.vertexList[v1.index].x = v2.x;
  euler.vertexList[v1.index].y = v2.y;
  euler.vertexList[v2.index].x = v1.x;
  euler.vertexList[v2.index].y = v1.y;
}

void _offset(Vertex v1, Vertex v2) {
  int type = _offsetType(v1, v2);
  double detX = 0;
  double detY = 0;
  switch (type) {
    case leftDown:
      detX = 40;
      detY = 40;
      break;
    case leftUp:
      detX = 40;
      detY = -40;
      break;
    case rightUp:
      detX = -40;
      detY = -40;
      break;
    case rightDown:
      detX = -40;
      detY = 40;
      break;
  }
  v1.x += detX;
  v2.x += detX;
  v1.y += detY;
  v2.y += detY;
}

int _offsetType(Vertex v, Vertex w) {
  if (v.x < 230 && v.y < 710 && w.x < 230 && w.y < 710) {
    return leftDown;
  } else if (v.x < 230 && v.y > 40 && w.x < 230 && w.y > 40) {
    return leftUp;
  } else if (v.x > 40 && v.y < 710 && w.x > 40 && w.y < 710) {
    return rightDown;
  }
  return rightUp;
}

//按长finalY 宽finalX 进行填满区域拉伸缩放
List<Vertex> compressFinal(List<Vertex> vertexList, EulerInfo euler, double finalY, double finalX) {
  Vertex center = euler.center;
  double compressY = finalY/euler.height;
  double compressX = finalX/euler.width;
  double detY = center.y - finalY * 0.5;
  double detX = center.x - finalX * 0.5;
  center.x = finalX * 0.5;
  center.y = finalY * 0.5;
  for (int i = 0; i < vertexList.length; i++) {
    Vertex vertex = vertexList[i];
    vertex.x -= detX;
    vertex.y -= detY;
    vertex.x = center.x * (1-compressX) + vertex.x * compressX;
    vertex.y = center.y * (1-compressY) + vertex.y * compressY;
  }
  return vertexList;
}

List<Vertex> _getVertexListYCenter(EulerInfo euler) {
  List<Vertex> vertexList = new List<Vertex>();
  for (int i = 0; i < euler.vertexList.length; i++) {
    Vertex vertex = euler.vertexList[i];
    if ((vertex.x-euler.center.x).abs() < 10) {
      vertexList.add(Vertex(vertex.toJson()));
    }
  }
  return vertexList;
}

List<Vertex> getYCenterVertexList(EulerInfo eulerInfo, int sortType) {
  List<Vertex> vertexList = _getVertexListYCenter(eulerInfo);
  List<Edge> edgeList = eulerInfo.edgeList;
  if (vertexList.length < 2) {
    return new List<Vertex>();
  }
  if (sortType == TYPE_BOTTOM) {
    vertexList.sort((left, right) => (left.y - right.y).toInt());
  } else {
    vertexList.sort((left, right) => (right.y - left.y).toInt());
  }
  Set<int> set = new Set();
  for (int i = 2; i < vertexList.length; i++) {
    set.add(vertexList[i].index);
  }
  Vertex v1 = vertexList[0];
  Vertex v2 = vertexList[1];
  for (int i = 0; i < edgeList.length; i++) {
    int start = edgeList[i].startIndex;
    int end = edgeList[i].endIndex;
    if ((v1.index == start && set.contains(end))|| (v1.index == end && set.contains(start)) ||
        (v2.index == start && set.contains(end))|| (v2.index == end && set.contains(start))) {
      return new List<Vertex>();
    }
  }
  List<Vertex> list = new List<Vertex>();
  list.add(v1);
  list.add(v2);
  return list;
}










