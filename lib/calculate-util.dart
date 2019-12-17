import 'dart:collection';

import 'edge.dart';

class BFS {
  List<bool> visited;
  List<List<bool>> connect;
  int points;
  BFS(List<Edge> edgeList, int points) {
    this.points = points;
    visited = List.generate(points, (int index) {return false;});
    connect = List.generate(points, (int index) {
      return List.generate(points, (int dex) {return false;});
    });
    edgeList.forEach((it)=>union(it));
  }

  void union(Edge edge) {
    connect[edge.startIndex][edge.endIndex] = true;
    connect[edge.endIndex][edge.startIndex] = true;
  }

  bool bfs() {
    int count = 0;
    Queue Q = Queue();
    Q.add(0);
    while(Q.isNotEmpty) {
      int s = Q.removeFirst();
      visited[s] = true;
      count++;
      for(int j=0; j< points; j++) {
        if(connect[s][j]==true && visited[j]==false) {
          visited[j] = true;
          Q.add(j);
        }
      }
    }
    if (count == points) {
      return true;
    }
    return false;
  }
}