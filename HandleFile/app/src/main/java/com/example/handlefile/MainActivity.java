package com.example.handlefile;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Bundle;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;

import android.util.Log;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;

import java.io.IOException;
import java.security.cert.Certificate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        verifyStoragePermissions(this);
        FloatingActionButton fab = findViewById(R.id.fab);
        FloatingActionButton fab2 = findViewById(R.id.fab_2);
        Button button = findViewById(R.id.btn_test);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final Thread thread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        //listFiles();
                        LevelDataUtil util = LevelDataUtil.getInstance(getApplicationContext());
                        util.initGraph(getApplicationContext());
                    }
                });
                thread.start();
            }
        });
        fab2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final Thread thread = new Thread(new Runnable() {
                    @Override
                    public void run() {
                        //listFiles();
                        LevelDataUtil util = LevelDataUtil.getInstance(getApplicationContext());
                        util.verifyConnectAllFiles(getApplicationContext());
                    }
                });
                thread.start();
            }
        });
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int[][] testDatas = new int[][] {{0,6,18,2,17,14,0,12,13,11,16,18,10,19,17,7,19,8,3,15,9,18,1,11,5,13,0,2,5,1,4,15,0},
                        {0,2,14,4,13,12,3,8,1,15,7,19,15,6,18,3,16,8,11,10,12,18,8,17,10,18,11,16,13,6,9,18,2,19,5,3,7,10,0},
                        {0,14,3,11,17,9,10,17,13,15,5,19,9,15,18,8,16,17,19,11,1,9,6,11,7,19,2,17,8,13,10,5,14,18,3,16,0,7,2,10,4,13,3,6,1,8,6,7,8,12,0},
                        {0,11,2,4,6,3,9,1,13,9,12,10,2,5,11,4,15,5,18,16,13,17,8,6,7,15,12,19,16,14,0}};
                for (int i = 0; i < testDatas.length; i++) {
                    CheckUtil.getInstance().isAllStepOne(CheckUtil.getInstance().getPointList(testDatas[i]));
                }
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    void listFiles() {
        AssetManager asserter = getAssets();
        String[] bookDirs = null;
        try {
            Long start = System.currentTimeMillis();
            List<String> res = new ArrayList<>();
            List<String> swapUp = new ArrayList<>();
            List<String> swapAdd = new ArrayList<>();
            List<String> swapDown = new ArrayList<>();
            List<String> swapTopY = new ArrayList<>();
            List<String> swapBottomY = new ArrayList<>();
            // 0,1等目录下必须要有文件，才能被list出来。
            bookDirs = asserter.list("folder1");
            for (String dir : bookDirs) {// 取到0,1等目录
                Log.d("book", dir);
                if (dir.contains("res")) {
                    res.add(dir);
                } else if (dir.contains("swap-down")) {
                    swapDown.add(dir);
                } else if (dir.contains("y-top")) {
                    swapTopY.add(dir);
                } else if (dir.contains("y-bottom")) {
                    swapBottomY.add(dir);
                } else if (dir.contains("add")) {
                    swapAdd.add(dir);
                } else {
                    swapUp.add(dir);
                }
            }
            Comparator<String> comparator = new Comparator<String>() {
                @Override
                public int compare(String o1, String o2) {
//                    try {
//                        String[] s1 = o1.split("-");
//                        String[] s2 = o2.split("-");
//                        int a1 = Integer.valueOf(s1[1].substring(2));
//                        int a2 = s1[2].startsWith("lvl") ? Integer.valueOf(s1[2].substring(3)) : Integer.valueOf(s1[2]);
//                        int b1 = Integer.valueOf(s2[1].substring(2));
//                        int b2 = s1[2].startsWith("lvl") ? Integer.valueOf(s2[2].substring(3));
//                        if (a1 == a2) {
//                            return b1 - b2;
//                        }
//                        return a1 - a2;
//
//                    } catch (Exception e) {
//
//                    }
                    return o1.compareTo(o2);
                }
            };
            if (!res.isEmpty())
                Collections.sort(res, comparator);
            if (!swapAdd.isEmpty())
                Collections.sort(swapAdd, comparator);
            if (!swapBottomY.isEmpty())
                Collections.sort(swapBottomY, comparator);
            if (!swapTopY.isEmpty())
                Collections.sort(swapTopY, comparator);
            if (!swapUp.isEmpty())
                Collections.sort(swapUp, comparator);
            if (!swapDown.isEmpty())
                Collections.sort(swapDown, comparator);
                //res.sort(comparator);
                //swapAdd.sort(comparator);
                //swapBottomY.sort(comparator);
                //swapTopY.sort(comparator);
                //swapUp.sort(comparator);
                //swapDown.sort(comparator);


            List<String> resPaths = generateFilePaths(res);
            List<String> swapUpPaths = generateFilePaths(swapUp);
            List<String> swapAddPaths = generateFilePaths(swapAdd);
            List<String> swapDownPaths = generateFilePaths(swapDown);
            List<String> swapTopYPaths = generateFilePaths(swapTopY);
            List<String> swapBottomYPaths = generateFilePaths(swapBottomY);
            String resArray = generateArrays(resPaths);
            String swapUpArray = generateArrays(swapUpPaths);
            String swapDownArray = generateArrays(swapDownPaths);
            String swapAddArray = generateArrays(swapAddPaths);
            String swapTopYArray = generateArrays(swapTopYPaths);
            String swapBottomYArray = generateArrays(swapBottomYPaths);
            Long end = System.currentTimeMillis();
            Log.d("allTime", (end-start) + "millionSecond");
            int a=4;
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    String generateFilePath(String file) {
        String[] strings = file.split("-");
        StringBuilder path = new StringBuilder();
        if (strings.length > 3) {
            if (!file.contains("1024")) {
                path.append("'assets/").append(strings[0]).append('/').append(strings[1]).append('/').append(strings[2]).append("'");
            } else {
                path.append("'assets/").append(strings[0]).append('/').append(strings[1]).append('/').append(strings[2]).append(".txt").append("'");
            }
        }
        return path.toString();
    }

    List<String> generateFilePaths(List<String> files) {
        List<String> paths = new ArrayList<>();
        for (int i = 0; i < files.size(); i++) {
            paths.add(generateFilePath(files.get(i)));
        }
        return paths;
    }

    String generateArrays(List<String> paths) {
        StringBuilder builder = new StringBuilder();
        builder.append('[');
        for (int i = 0; i < paths.size()-1; i++) {
            builder.append(paths.get(i)).append(',').append("\n ");
        }
        if (!paths.isEmpty()) {
            builder.append(paths.get(paths.size()-1));
        }
        builder.append(']');
        return builder.toString();
    }

    private static final int REQUEST_EXTERNAL_STORAGE = 1;
    private static String[] PERMISSIONS_STORAGE = {"android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE" };


    public void verifyStoragePermissions(Activity activity) {

         try {
         //检测是否有写的权限
         int permission = ActivityCompat.checkSelfPermission(activity,
        Manifest.permission.WRITE_EXTERNAL_STORAGE);
         if (permission != PackageManager.PERMISSION_GRANTED) {
             ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
             Log.e("requestFa1", "request");
         }
         } catch (Exception e) {
             Log.e("requestFa2", "request");

             e.printStackTrace();
         }
        }

}
