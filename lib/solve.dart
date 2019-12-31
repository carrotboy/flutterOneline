import 'dart:math';

import 'package:langaw/edge.dart';
import 'package:langaw/main.dart';

class SolveEdge{
  int startIndex;
  int endIndex;
  String startDesc;
  String endDesc;
  bool isDirect = false;
  bool isDirectReverse = false;
  int edgeCount = 0;
}

class SolveVertex {
  int index;
  bool isDirect = false;
  bool isDirectReverse = false;
  bool isDoubleEdge = false;
}

void getSolveEdgeList() {
  List<Edge> edgeList = game.edgeList;
  int length = game.vertexList.length;
  List<List<SolveEdge>> solveEdgeList  = List.generate(length, (int index) {
    return List.generate(length, (int dex) {return new SolveEdge();});
  });
  for (int i = 0; i < edgeList.length; i++) {
    int startIndex = edgeList[i].startIndex;
    int endIndex = edgeList[i].endIndex;
    solveEdgeList[startIndex][endIndex].edgeCount++;
    solveEdgeList[endIndex][startIndex].edgeCount++;
    solveEdgeList[startIndex][endIndex].isDirectReverse = false;
    solveEdgeList[endIndex][startIndex].isDirectReverse = true;
    solveEdgeList[startIndex][endIndex].isDirect = edgeList[i].lock;
    solveEdgeList[endIndex][startIndex].isDirect = edgeList[i].lock;
  }
  game.solveEdgeConnects = solveEdgeList;
  initSolveVertex();
  game.temp = game.edgeList.length+1;
}

void initSolveVertex(){
  game.solveVertexList = List.generate(game.edgeList.length+1, (int index) {return new SolveVertex();});
}

void solveDfs(int u, int edgeCount, bool isDirect, bool isDirectReverse) {
  for (int v = 0; v < game.vertexList.length; v++) {
    if (game.solveEdgeConnects[u][v].edgeCount > 0) {
      game.solveEdgeConnects[u][v].edgeCount--;
      game.solveEdgeConnects[v][u].edgeCount--;
      solveDfs(v, game.solveEdgeConnects[v][u].edgeCount, game.solveEdgeConnects[u][v].isDirect, game.solveEdgeConnects[u][v].isDirectReverse);
    }
  }
  int index = --game.temp;
  game.solveVertexList[index].index = u;
  if (edgeCount > 0) {
    game.solveVertexList[index].isDoubleEdge = true;
  }
  game.solveVertexList[index].isDirect = isDirect;
  game.solveVertexList[index].isDirectReverse = isDirectReverse;
}

int getSolveStartIndex() {
  int index = 0;
  int max = 0;
  if (isDegreeJishu()) {
    for (int i = 0; i < game.degreeList.length; i++) {
      int current = game.degreeList[i];
      if (current%2 == 1) {
        if (max < current) {
          max = current;
          index = i;
        }
      }
    }
  } else {
    for (int i = 0; i < game.degreeList.length; i++) {
      int current = game.degreeList[i];
      if (max < current) {
        max = current;
        index = i;
      }
    }
  }
  return index;
}

bool isDegreeJishu() {
  for (int i = 0; i < game.degreeList.length; i++) {
    if (game.degreeList[i]%2 == 1) {
      return true;
    }
  }
  return false;
}

