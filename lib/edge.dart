

import 'dart:math';

import 'package:langaw/oneline-basic.dart';
import 'package:langaw/vertex.dart';

class Edge extends OneLineBasic
{
   int startIndex;
   int endIndex;
   int repeat = 1 ;
   bool lock = false ;
   int inArrayIndex = -1;

   Edge(Map<String, dynamic> jsonData) {


      if(jsonData != null) {
         startIndex = getVertexIndex(jsonData['start'].toString());
         endIndex = getVertexIndex(jsonData['end'].toString());

         var repeatInJson = jsonData['repeat'];
         if (repeatInJson != null) {
            repeat = repeatInJson;
         }

         var lockInJson = jsonData['lock'];
         if (lockInJson != null) {
            lock = lockInJson;
         }
      }
   }

   Map<String, dynamic> toJson()
       {
          Map<String, dynamic> map = new Map();
          map['start'] =  getVectexId(startIndex);
          map['end'] = getVectexId(endIndex);
          map['id'] = inArrayIndex;

          if(lock == true) {
             map['lock'] = lock;
          }

          if(repeat > 1) {
             map['repeat'] = repeat;
          }

          return map;

       }

}

//点到线段的距离
double calculateDistance(Vertex v, Edge edge, List<Vertex> list) {
   double x = v.x;
   double y = v.y;
   Vertex v1 = list[edge.startIndex];
   Vertex v2 = list[edge.endIndex];
   double x1 = v1.x;
   double y1 = v1.y;
   double x2 = v2.x;
   double y2 = v2.y;
   double cross = (x2 - x1) * (x - x1) + (y2 - y1) * (y - y1);
   if (cross <= 0) {
      return sqrt((x - x1) * (x - x1) + (y - y1) * (y - y1));
   }
   double d2 = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
   if (cross >= d2) {
      return sqrt((x - x2) * (x - x2) + (y - y2) * (y - y2));
   }
   double r = cross / d2;
   double px = x1 + (x2 - x1) * r;
   double py = y1 + (y2 - y1) * r;
   return sqrt((x - px) * (x - px) + (y - py) * (y - py));
}

//点是否在矩形内，做了8个像素的外延
bool inRectangle(Vertex v,Edge edge, List<Vertex> list) {
   double det = 5;
   Vertex v1 = list[edge.startIndex];
   Vertex v2 = list[edge.endIndex];
   double maxX = max(v1.x, v2.x);
   double minX = min(v1.x, v2.x);
   double maxY = max(v1.y, v2.y);
   double minY = min(v1.y, v2.y);
   if (v.x < minX - det) {
      return false;
   }
   if (v.x > maxX + det) {
      return false;
   }
   if (v.y < minY - det) {
      return false;
   }
   if (v.y > maxY + det) {
      return false;
   }
   return true;
}

//获取交换点影响到的边
List<Edge> getSwapEdgeList(List<Vertex> swapList, List<Edge> edgeList) {
   List<Edge> list = [];
   Set<int> set = new Set();
   for (int i = 0; i < swapList.length; i++) {
      set.add(swapList[i].index);
   }
   for (int i = 0; i < edgeList.length; i++) {
      Edge edge = edgeList[i];
      if (set.contains(edge.startIndex) || set.contains(edge.endIndex)) {
         list.add(edge);
      }
   }
   return list;
}

//交换产生的边是否覆盖其他已有点，排除该类混淆图形
bool hasUglyEdge(List<Vertex> vertexList, List<Edge> swapList) {
   for (int i =0 ; i < swapList.length; i++) {
      Edge edge = swapList[i];
      for (int j = 0; j < vertexList.length; j++) {
         Vertex v = vertexList[j];
         if (v.index != edge.startIndex && v.index != edge.endIndex) {
            if (calculateDistance(v, edge, vertexList) < 10) {
               return true;
            }
         }
      }
   }
   return false;
}