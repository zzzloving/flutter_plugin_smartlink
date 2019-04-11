import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_smartlink/flutter_plugin_smartlink.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

var ssidController = TextEditingController(text: "XZ_WIFI");
var pwdController = TextEditingController(text: "123456789");

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    FlutterPluginSmartlink.initMessageHandler();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max, //有效，外层Colum高度为整个屏幕
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: ssidController,
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: "SSID",
                            hintText: "SSID",
                            prefixIcon: Icon(Icons.wifi_lock)),
                      ),
                      TextField(
                        controller: pwdController,
                        decoration: InputDecoration(
                            labelText: "Pwd",
                            hintText: "pwd",
                            prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                StatelessWidgetTest(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyOnSmartLinkListener extends OnSmartLinkListener {
  @override
  void onCompleted() {
    if (dialogState != null)
      dialogState.setState(() {
        dialogState.btnOffstage = false;
        dialogState.text = dialogState.text + "\n已完成";
      });
  }

  @override
  void onLinked(Mac, Ip, Id, Mid, ModuleIP) {
    if (dialogState != null)
      dialogState.setState(() {
        dialogState.btnOffstage = false;
        dialogState.text =
            "Mac = $Mac\n Ip = $Ip\n Id = $Id \n Mid = $Mid \n ModuleIP = $ModuleIP \n ";
      });
  }

  @override
  void onTimeOut() {
    if (dialogState != null)
      dialogState.setState(() {
        dialogState.btnOffstage = false;
        dialogState.text = dialogState.text + "\n超时";
      });
  }
}

var dialogState;

class StatelessWidgetTest extends StatelessWidget {
  var listener = new MyOnSmartLinkListener();

  var dailog;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Start"),
      onPressed: () async {
        bool b = await FlutterPluginSmartlink.start(
            ssid: ssidController.text,
            pwd: pwdController.text,
            listener1: listener);
        if (b) {
          showDialog(
            context: context,
            builder: (_) => dailog = new MyDialog(),
          );
        } else {
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                      title: new Text("失败"),
                      content: new Text(ssidController.text),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text("确定"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ]));
        }
      },
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dialogState = new MyDialogState();
  }
}

class MyDialogState extends State<MyDialog> {
  var btnOffstage = true;
  String text = "发送中";

  @override
  Widget build(BuildContext context) {
    Duration insetAnimationDuration = const Duration(milliseconds: 100);
    Curve insetAnimationCurve = Curves.decelerate;

    RoundedRectangleBorder _defaultDialogShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)));

    return WillPopScope(
      onWillPop: () {
        return new Future.value(false);
      },
      child: AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Center(
            child: SizedBox(
              width: 220,
              height: 320,
              child: Material(
                elevation: 24.0,
                color: Theme.of(context).dialogBackgroundColor,
                type: MaterialType.card,
                //在这里修改成我们想要显示的widget就行了，外部的属性跟其他Dialog保持一致
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Offstage(
                        offstage: !btnOffstage,
                        child: new CircularProgressIndicator()),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: new Text(text),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Offstage(
                        offstage: btnOffstage,
                        child: RaisedButton(
                          child: Text("确定"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    )
                  ],
                ),
                shape: _defaultDialogShape,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
