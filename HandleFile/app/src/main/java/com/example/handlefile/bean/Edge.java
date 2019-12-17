package com.example.handlefile.bean;

public class Edge {
    public String start;
    public String end;
    public int repeat = 1;
    public boolean lock = false;
    public int id = -1;
    public Edge(){}
    public Edge(Edge copySwap) {
        boolean swap = copySwap.start.compareTo(copySwap.end) > 0 ? true : false;
        if (swap) {
            this.start = copySwap.end;
            this.end = copySwap.start;
        } else {
            this.start = copySwap.start;
            this.end = copySwap.end;
        }
    }
}
