

import 'package:langaw/vertex.dart';
import 'dart:ui';
import 'dart:math';


class LevelDataTune{


  static const double X_MIDDLE = 540/2;
  static const double X_MIN_LEFT = 540/6;
  static const double X_MAX_RIGHT = 540 - 540/6;
  static const double X_SHIFT = 80;

  static const double DISTANCE_TOO_CLOSE_THRESHHOLD = 60;

  static List<Offset> tuneVertices(var vertices)
  {

      List<Offset> vertexList = new List(vertices.length);



      List<bool> isOutputDone =  new List(vertices.length);

      for(int i = 0 ; i < vertices.length; i ++ )
        {
          isOutputDone[i] = false;
        }

      for(int i = 0 ; i < vertices.length; i ++  )
      {

        if(isOutputDone[i] == false) {
            Vertex vertex = Vertex(vertices[i]);

            int xSymmetryInex = findXSymmetryIndex(
                vertex.x, vertex.y, vertices, i + 1);

            if (xSymmetryInex == -1) { // no symmetry points, don't do any adjustment
                vertexList[i] = (Offset(vertex.x, vertex.y));
            }
            else
              {

                double shift = findXShift(vertex.x);
                if(ifApartEnough(vertexList,vertex.x + shift, vertex.y,i) == false) {
                   shift = 0;
                }


                vertexList[i] = Offset(vertex.x + shift, vertex.y);

                Vertex symmetryVertex = Vertex(vertices[xSymmetryInex]);
                vertexList[xSymmetryInex] = Offset(symmetryVertex.x - shift, symmetryVertex.y);

                isOutputDone[i] = true;
                isOutputDone[xSymmetryInex] = true;

              }
        }


      }



      return vertexList;



  }


  //计算两点之间的距离，屏幕坐标
  static double calculateDis(double dx1, double dy1, double dx2, double dy2)
  {
    double distance  = sqrt((dy1 -  dy2) * (dy1 -  dy2)  + (dx1- dx2) * (dx1- dx2)  );

    return distance;
  }

  static bool ifApartEnough(List<Offset> vertexList, double dx, double dy, intEndIndex)
  {
    for(int i =0 ; i < intEndIndex ; i ++ )
      {
          Offset offset = vertexList[i];

          if(calculateDis(offset.dx,offset.dy, dx, dy) < DISTANCE_TOO_CLOSE_THRESHHOLD )
            {

              return false;
            }
      }

    return true;

  }

  static double findXShift(double dx)
  {
     if(dx <= X_MIN_LEFT  )
       {
         return X_SHIFT;
       }
     else if(dx > X_MIN_LEFT && dx <= X_MIDDLE )
       {
         return  -X_SHIFT;
       }
     else if(dx > X_MIDDLE  && dx <= X_MAX_RIGHT )
       {
         return X_SHIFT;
       }
     else
       {
         return -X_SHIFT;
       }

  }



  static int findXSymmetryIndex( double dx, double dy, var vertices, int startIndex)
  {
     int index = -1;
     for(int i = startIndex ; i < vertices.length; i ++  )
     {
       Vertex vertex = Vertex(vertices[i]);

       if(dy == vertex.y &&  dx - X_MIDDLE  == X_MIDDLE - vertex.x )
         {
           return i;
         }

     }


     return index;
  }





  static Offset getTunedOffset()
  {



  }


}