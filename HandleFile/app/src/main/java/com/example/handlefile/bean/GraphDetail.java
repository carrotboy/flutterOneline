package com.example.handlefile.bean;

import java.util.List;

public class GraphDetail {
    public List<Edge> edges;
    public List<Vertex> vertices;
    public Graph graph;
    public double edgeCount = 0;
    public int vertexCount = 0;
    public boolean used = false;
    public boolean inserted = false;
    public String fileName = "";
    public void calculate() {
        vertexCount = vertices.size();
        for (int i = 0; i < edges.size(); i++) {
            if (edges.get(i).lock) {
                edgeCount += 1.5;
            } else {
                edgeCount += 1;
            }
        }
    }
}
