package com.example.handlefile;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Environment;
import android.telecom.Call;
import android.util.Log;
import android.util.Pair;

import com.alibaba.fastjson.JSON;
import com.example.handlefile.bean.Edge;
import com.example.handlefile.bean.Graph;
import com.example.handlefile.bean.GraphDetail;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class LevelDataUtil {
    private static LevelDataUtil levelDataUtil;
    Context mContext;
    public static LevelDataUtil getInstance(Context context) {
        if (levelDataUtil == null) {
            synchronized (LevelDataUtil.class) {
                levelDataUtil =  new LevelDataUtil();
                levelDataUtil.mContext = context;
                return levelDataUtil;
            }
        }
        return levelDataUtil;
    }
    private Map<String, GraphDetail> graphMap = new HashMap<>();
    private List<List<GraphDetail>> graphList = new ArrayList<>(32);
    private List<String> pngPaths = new ArrayList<>();
    private Map<String, String> pngMap = new HashMap<>();
    private List<GraphDetail> allGraphs = new ArrayList<>();

    private boolean isInit = false;
    public void initGraph(Context context) {
        if (isInit) return;
        isInit = true;
        graphMap.clear();
        graphList.clear();
        //pngPaths.clear();
        pngMap.clear();
        for (int i = 0;i < 32; i++) {
            graphList.add(new ArrayList<GraphDetail>());
        }
        AssetManager asserter = context.getAssets();
        String[] graphs = null;
        try {
            Long start = System.currentTimeMillis();
            graphs = asserter.list("level");
            pngPaths = Arrays.asList(asserter.list("folder1"));
            for (int i = 0; i < pngPaths.size(); i++) {
                String path = pngPaths.get(i);
                int subPos = path.indexOf('-', 12);
                pngMap.put(path.substring(0, subPos), "folder1/" + path);
            }
            for (String file: graphs) {
                String[] splits = file.split("-");
                int guanka = Integer.valueOf(splits[1].substring(2));
                if (guanka > 999 && guanka < 1024) continue;
                InputStream is =  asserter.open("level/" + file);
                InputStreamReader isReader = new InputStreamReader(is,"UTF-8");
                BufferedReader br = new BufferedReader(isReader);
                StringBuilder detail = new StringBuilder();
                String line = null;
                while((line = br.readLine()) != null){//读txt文件中内容
                    Log.d("txt中内容", line);
                    detail.append(line);
                }
                br.close();
                isReader.close();
                GraphDetail graphDetail = JSON.parseObject(detail.toString(), GraphDetail.class);
                graphDetail.calculate();
                graphDetail.fileName = file;
                graphMap.put(file, graphDetail);
                graphList.get(graphDetail.vertexCount).add(graphDetail);
            }
            int a = 8;
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            clearDirtyElement();
            sortGraphList();
            generateGuanKa();
            isInit = false;
        }
    }

    private void clearDirtyElement() {
        for(int i = 0; i < graphList.size(); i++) {
            List<GraphDetail> list = graphList.get(i);
            List<GraphDetail> dirtyList = new ArrayList<>();
            for (int j = 0; j < list.size(); j++) {
                GraphDetail detail = list.get(j);
                if (detail.used) {
                    dirtyList.add(detail);
                }
            }
            list.removeAll(dirtyList);
        }
        List<List<GraphDetail>> dirtyList = new ArrayList<>();
        for (int i = 0; i < graphList.size(); i++) {
            List<GraphDetail> list = graphList.get(i);
            if (list.isEmpty()) {
                dirtyList.add(list);
            }
        }
        graphList.removeAll(dirtyList);
    }

    private void sortGraphList() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            for (int i = 0; i < graphList.size(); i++) {
                graphList.get(i).sort(new Comparator<GraphDetail>() {
                    @Override
                    public int compare(GraphDetail o1, GraphDetail o2) {
                        return (int) ((o1.edgeCount - o2.edgeCount) * 100);
                    }
                });
            }
        }
    }

    private void generateGuanKa() {
        int levels = (graphMap.size() -30)/30;
        for (int i = 0; i < levels; i++) {
            List<GraphDetail> list = generateNextGuanka(i);
            generateGuankaJsonFile(list, i);
            clearDirtyElement();
        }
    }

    private void generateGuankaJsonFile(List<GraphDetail> list, int level) {
        String destDir = Environment.getExternalStorageDirectory().getPath()+"/level/"
                + "lp" + level +"/";
        String levelFile = Environment.getExternalStorageDirectory().getAbsolutePath();
        String[] s = Environment.getExternalStorageDirectory().list();
        File file = new File(destDir);
        boolean mk = false;
        if (!file.exists()) {
            if(!file.getParentFile().exists()) {
                mk = file.getParentFile().mkdirs();
            }
            mk = file.mkdirs();
        }
        for (int i = 0; i < list.size(); i++) {
            String destPath = destDir + "/" + "l" + i;
            File destFile = new File(destPath);
            try {
            if (destFile.exists()) {
                destFile.delete();
            }
            GraphDetail detail = list.get(i);
            AssetManager asserter = mContext.getAssets();
                InputStream input =  asserter.open("level/" + detail.fileName);
                if (!destFile.exists()) {
                    destFile.createNewFile();
                    copyFileUsingFileStreams(input, destFile);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void copyFileUsingFileStreams(InputStream input, File dest)
            throws IOException {
        OutputStream output = null;
        try {
            output = new FileOutputStream(dest);
            byte[] buf = new byte[1024];
            int bytesRead;
            while ((bytesRead = input.read(buf)) != -1) {
                output.write(buf, 0, bytesRead);
            }
        } finally {
            input.close();
            output.close();
        }
    }

    private List<GraphDetail> generateNextGuanka(int level) {
        int[] counts = new int[]{2, 6, 7, 8, 4, 3};
        int[] firsts = new int[]{1, 3, 4, 4, 2, 3};
        List<GraphDetail> guankaList = new ArrayList<>();
        List<List<GraphDetail>> listLists = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            List<GraphDetail> list = new ArrayList<>();
            int listSize = graphList.size();
            int index = i;
            if (listSize < 6){
                int t = i + (listSize - 6);
                if (t < 0) {
                    index = 0;
                }
            }
            int count = counts[i];
            while (list.size() < count){
                List<GraphDetail> old = graphList.get(index);
                for (int k = 0; k < old.size(); k++) {
                    if (list.size() >= count) {
                        break;
                    }
                    GraphDetail detail = old.get(k);
                    if (!detail.used) {
                        list.add(detail);
                        detail.used = true;
                    }
                }
                index++;
                if (index >= listSize) {
                    index = 0;
                }
            }
            listLists.add(list);
        }
        for (int i = 0; i < firsts.length; i++) {
            guankaList.addAll(listLists.get(i).subList(0, firsts[i]));
        }
        for (int i = 0; i < guankaList.size(); i++) {
            guankaList.get(i).inserted = true;
        }
        int size = guankaList.size();
        for (int i = 0; i < listLists.size(); i++) {
            List<GraphDetail> list = listLists.get(i);
            for (int j = 0; j < list.size(); j++) {
                GraphDetail detail = list.get(j);
                if (!detail.inserted) {
                    guankaList.add(size, detail);
                    detail.inserted = true;
                }
            }
        }
        for(int i = 0; i < guankaList.size(); i++) {
            //if (guankaList.get(i).fileName.contains("1024")) {
            if (true) {
                verify(level, i, guankaList.get(i));
            }
        }
        if (level == 0) {
            List<String> fileNames = new ArrayList<>();
            for (int i = 0; i < guankaList.size(); i++) {
                fileNames.add(guankaList.get(i).fileName);
            }
            generatePngs(fileNames);
        }
        return guankaList;
    }

    private void generatePngs(List<String> fileNames) {
        for (int i = 0; i < fileNames.size(); i++) {
            String destDir = Environment.getExternalStorageDirectory().getPath()+"/level/"
                    + "lp" + 0;
            String destPath = destDir + "/" + "lg" + i+".png";
            File destFile = new File(destPath);
            try {
                if (!destFile.exists()) {
                    destFile.createNewFile();
                }
                AssetManager asserter = mContext.getAssets();
                if (pngMap.get(fileNames.get(i)) != null) {
                    InputStream input = asserter.open(pngMap.get(fileNames.get(i)));
                    if (destFile.exists()) {
                        copyFileUsingFileStreams(input, destFile);
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void verify(int level, int guanka, GraphDetail detail) {
        verifyFinal(level, guanka, detail);
        //getErrorDoubleGraphs(level, guanka, detail);
    }

    private void getErrorDoubleGraphs(int level, int guanka, GraphDetail detail) {
        List<Edge> list = new ArrayList<>();
        for (int i = 0; i< detail.edges.size(); i++) {
            Edge edge = detail.edges.get(i);
            if (edge.repeat == 2) {
                list.add(edge);
            }
        }
        boolean hasError = false;
        for (int i = 0; i < list.size(); i++) {
            int count = 0;
            Edge dest = list.get(i);
            for (int j = 0; j < detail.edges.size(); j++) {
                Edge edge = detail.edges.get(j);
                if ((dest.start.equals(edge.start) && dest.end.equals(edge.end)) || (dest.end.equals(edge.start) && dest.start.equals(edge.end))) {
                    count++;
                }
            }
            if (count != 2) {
                Log.e("errorDoubleGuanka", "start: " + dest.start + " end: " + dest.end +" level "+ level + "  guanka " + guanka + "  "+ detail.fileName);
                hasError = true;
            }
        }
        if (hasError) {
            for (int i = 0; i < detail.edges.size(); i++) {
                Edge dest = detail.edges.get(i);
                int count = 0;
                for (int j = 0; j < detail.edges.size(); j++) {
                    Edge edge = detail.edges.get(j);
                    if ((dest.start.equals(edge.start) && dest.end.equals(edge.end)) || (dest.end.equals(edge.start) && dest.start.equals(edge.end))) {
                        count++;
                    }
                }
                if (count > 2) {
                    //Log.e("errorMultiEdge", "start: " + dest.start + " end: "+dest.end);
                }
                if (count == 2) {
                    //Log.d("error?No!", "start: " + dest.start + " end: " + dest.end);
                }
            }
        } else {
            for (int i = 0; i < detail.edges.size(); i++) {
                if (detail.edges.get(i).lock == true) {
                    Edge dest = detail.edges.get(i);
                    Log.e("errorBlock", "start: " + dest.start + " end: " + dest.end +" level "+ level + "  guanka " + guanka + "  "+ detail.fileName);
                    break;
                }
            }
        }
    }

    void verifyFinal(int level ,int guanka, GraphDetail detail) {
        boolean isSameDouble = isSameDoubleEdgeList(getDoubleEdges(detail), getActualDoubleEdges(detail));
        if (!isSameDouble) {
            Log.e("notSameDoubleEdges", " level "+ level + "  guanka " + guanka + "  "+ detail.fileName);

        }
        if (!isConnectGraph(detail)) {
            Log.e("notConnected", " level "+ level + "  guanka " + guanka + "  "+ detail.fileName);
        }
    }

    Comparator<Edge> comparator = new Comparator<Edge>() {
        @Override
        public int compare(Edge o1, Edge o2) {
            if (o1.start.equals(o2.start)) {
                return o1.end.compareTo(o1.end);
            }
            return o1.start.compareTo(o2.start);
        }
    };
    private List<Edge> getDoubleEdges(GraphDetail detail) {
        List<Edge> edges = new ArrayList<>();
        for (int i = 0; i< detail.edges.size(); i++) {
            Edge edge = detail.edges.get(i);
            if (edge.repeat == 2) {
                edges.add(new Edge(edge));
            }
        }
        Collections.sort(edges, comparator);
        return edges;
    }

    private List<Edge> getActualDoubleEdges(GraphDetail detail) {
        List<Edge> edges = new ArrayList<>();
        for (int i = 0; i < detail.edges.size(); i++) {
            Edge dest = detail.edges.get(i);
            int count = 0;
            if (isInDoubleEdges(dest, edges)) continue;
            for (int j = 0; j < detail.edges.size(); j++) {
                Edge edge = detail.edges.get(j);
                if ((dest.start.equals(edge.start) && dest.end.equals(edge.end)) || (dest.end.equals(edge.start) && dest.start.equals(edge.end))) {
                    count++;
                }
            }
            if (count > 2) {
                Log.e("errorMultiEdge", "start: " + dest.start + " end: "+dest.end);
            }
            if (count == 2) {
                edges.add(new Edge(dest));
            }
        }
        Collections.sort(edges, comparator);
        return edges;
    }

    private boolean isInDoubleEdges(Edge edge, List<Edge> list) {
        for (int j = 0; j < list.size(); j++) {
            Edge dest = list.get(j);
            if ((dest.start.equals(edge.start) && dest.end.equals(edge.end)) || (dest.end.equals(edge.start) && dest.start.equals(edge.end))) {
                return true;
            }
        }
        return false;
    }

    private boolean isSameDoubleEdgeList(List<Edge> edges1, List<Edge> edges2) {
        if (edges1.size() != edges2.size()) {
            return false;
        }
        if (edges1.size() == 0 && edges2.size() == 0) {
            return true;
        }
        for (int i = 0; i < edges1.size(); i++) {
            Edge edge1 = edges1.get(i);
            Edge edge2 = edges2.get(i);
            if(edge1.start.equals(edge2.start) && edge1.end.equals(edge2.end)) {

            } else {
                return false;
            }
        }
        return true;
    }

    private boolean isConnectGraph(GraphDetail detail) {
        List<Edge> list = detail.edges;
        for (int i = 0; i < list.size()-1; i++) {
            Edge edge1 = list.get(i);
            Edge edge2 = list.get(i+1);
            if (!edge1.end.equals(edge2.start)) {
                return false;
            }
        }
        return true;
    }

    public void verifyConnectAllFiles(Context context) {
        AssetManager asserter = context.getAssets();
        String[] graphs = null;
        try {
            Long start = System.currentTimeMillis();
            graphs = asserter.list("level");
            for (String graph: graphs) {
                String[] files = asserter.list("level/"+graph);
                for (String file: files) {
                    String fileName = "level/" + graph + "/"+file;
                    InputStream is = asserter.open("level/" + graph + "/"+file);
                    InputStreamReader isReader = new InputStreamReader(is, "UTF-8");
                    BufferedReader br = new BufferedReader(isReader);
                    StringBuilder detail = new StringBuilder();
                    String line = null;
                    while ((line = br.readLine()) != null) {//读txt文件中内容
                        //Log.d("txt中内容", line);
                        detail.append(line);
                    }
                    br.close();
                    isReader.close();
                    GraphDetail graphDetail = JSON.parseObject(detail.toString(), GraphDetail.class);
                    graphDetail.fileName = file;
                    if (!isConnectGraph(graphDetail)) {
                        Log.e("notConnect", graphDetail.fileName + "  " + fileName);
                    } else {
                        //Log.d("Connect", graphDetail.fileName);
                    }
                }
            }
            int a = 8;
            Pair<String, String> pair = new Pair<>("","");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
        }
    }
}
