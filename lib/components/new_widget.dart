import 'package:flutter/material.dart';
import 'package:langaw/euler.dart';
import 'package:langaw/main.dart';

import '../file-util.dart';

class RadioGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RadioGroup();
  }
}

class _RadioGroup extends State<RadioGroup> {
  String _newValue = '关卡';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RadioListTile<String>(

              value: '关卡',
              title: Text('关卡'),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                  myApp.state.fileList = levelList;
                  myApp.state.setState((){});
                });
              },
            ),
            RadioListTile<String>(
              value: '挑战',
              title: Text('挑战'),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                  myApp.state.fileList = challengeList;
                  myApp.state.setState((){});
                });
              },
            ),
          ],
    );
  }
}

///listView builder 构建
Widget listViewLayoutBuilder(List<FileStruct> list) {
  return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(10.0),
      itemCount: list.length,
cacheExtent: 300,
//        controller ,
      itemBuilder: (context, pos) => new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Text(
              "level${list[pos].level+1}",
              style: new TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            new Text(
              "stage${list[pos].stage+1}",
              style: new TextStyle(fontSize: 18.0, color: Colors.green),
            ),
            new FlatButton(
                onPressed: (){
                  myApp.state.setState((){
                    myApp.state.visible = true;
                    myApp.state.selectPos = pos;
                  });
                  initEuler(list[pos].path);
                },
                child: new Text(
                  "选择",
                  style: new TextStyle(fontSize: 18.0, color: Colors.blue),
                ),
            ),

          ],
        ),
      ));
}






