import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
Future<List<FileStruct>> getLevelFiles(BuildContext context) async {
  // >> To get paths you need these 2 lines
  final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  // >> To get paths you need these 2 lines

  final imagePaths = manifestMap.keys
      .where((String key) => key.contains('lvls/lp'))
  .map((String key)=>FileStruct(key))
  .where((FileStruct file)=> file.level < 1000)
       .toList();
  imagePaths.sort((FileStruct left, FileStruct right)=> left.weight-right.weight);
  return imagePaths;
}

Future<List<FileStruct>> getChallengeFiles(BuildContext context) async {
  // >> To get paths you need these 2 lines
  final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  // >> To get paths you need these 2 lines

  final imagePaths = manifestMap.keys
      .where((String key) => key.contains('lvls/lp'))
      .map((String key)=>FileStruct(key))
      .where((FileStruct file)=> file.level > 999)
      .toList();
  imagePaths.sort((FileStruct left, FileStruct right)=> left.weight-right.weight);
  return imagePaths;
}

class FileStruct {
  String path;
  int weight = 0;
  int level;
  int stage;
  FileStruct(String filePath) {
    this.path = filePath;

    if (path.contains('lvls/lp')){
      List<String> list = path.split("/");
      level = int.parse(list[2].substring(2));
      list[3] = list[3].replaceAll(".json", "").replaceAll(".txt", "");
      if (list[3].contains("lvl")) {
        stage = int.parse(list[3].substring(3));
      } else {
        stage = int.parse(list[3].substring(1));
      }
      weight = level*1000 + stage;
    }
  }
}

