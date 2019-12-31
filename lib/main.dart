import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:langaw/components/new_widget.dart';
import 'package:langaw/langaw-game.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'file-util.dart';

Util flameUtil = Util();
LangawGame game = LangawGame();
Offstage offstage;
MyApp myApp;
VerticalDragGestureRecognizer verticalDragGestureRecognizer = VerticalDragGestureRecognizer();
BuildContext mContext;
List<FileStruct> levelList;
List<FileStruct> challengeList;

void main() async {
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);

  //runApp(game.widget);
  myApp = new MyApp();

  runApp(myApp);
  SimplePermissions
      .requestPermission(Permission.WriteExternalStorage)
      .then((value) {
    if (value == PermissionStatus.authorized) {

    } else {
      SimplePermissions.openSettings();
    }
  });

  levelList = await getLevelFiles(mContext);
  myApp.state.setState((){myApp.state.fileList = levelList;});
  challengeList = await getChallengeFiles(mContext);
  TapGestureRecognizer tapper = TapGestureRecognizer();
  tapper.onTapDown = game.onTapDown;
//  tapper.onTapUp = game.onTapUp;
  flameUtil.addGestureRecognizer(tapper);


  VerticalDragGestureRecognizer verticalDragGestureRecognizer = VerticalDragGestureRecognizer();
  verticalDragGestureRecognizer.onStart = game.onVerticalDragStart;
  verticalDragGestureRecognizer.onUpdate = game.onVerticalDragUpdate;
  verticalDragGestureRecognizer.onEnd = game.onVerticalDragEnd;

  flameUtil.addGestureRecognizer(verticalDragGestureRecognizer);


}

class MyApp extends StatefulWidget {
  _MyAppState state = new _MyAppState();
  @override
  _MyAppState createState() => state;
}

class _MyAppState extends State<MyApp> {
  bool visible = false;
  List<FileStruct> fileList = new List();
  int selectPos = -1;
  @override
  void setState(fn) {
    super.setState(fn);
  }
  @override
  Widget build(BuildContext context) {
    mContext = context;
    return new MaterialApp(
      home:
          new Scaffold(
            body: new Container(
              constraints: new BoxConstraints.expand(),
              color: Colors.tealAccent,
              child: new Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.red,
                    child: game.widget,
                  ),
                  offstage = Offstage(
                    offstage: visible,
                    child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white,
                        child: new Row(
                          children: <Widget>[
                            SizedBox(
                              height: 120,width: 120,
                              child:  new RadioGroup()
                            ),
                            SizedBox(
                              height: 800,
                              width: 280,
                              child: listViewLayoutBuilder(fileList),
                            )
                          ],
                        )

                    ),
                  ),
                ],
              ),
            ),
          )

    );
  }
}
