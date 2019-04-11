import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPluginSmartlink {
  static const MethodChannel _channel =
      const MethodChannel('flutter_plugin_smartlink');

  static const BasicMessageChannel<dynamic> runTimer =
      const BasicMessageChannel(
          "flutter_plugin_smartlink_2_dart", StandardMessageCodec());
  static OnSmartLinkListener listener;

  static void initMessageHandler() {
    runTimer.setMessageHandler((map) {
      // 接收到的时间
      var type = map["type"];
      var data = map["data"];
      if (type == 1) {
        if (listener != null) {
          listener.onLinked(data["Mac"], data["Ip"], data["Id"], data["Mid"],
              data["ModuleIP"]);
        }
      } else if (type == 2) {
        if (data == 1) {
          if (listener != null) listener.onCompleted();
        } else if (data == 2) {
          if (listener != null) listener.onTimeOut();
        } else {
          print("========无data=========");
        }
      }else{
        print("========无type=========$type");
      }

    });
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> start(
      {String ssid,
      String pwd,
      String others,
      OnSmartLinkListener listener1}) async {
    listener = listener1;
    try {
      return await _channel
          .invokeMethod("start", {"ssid": ssid, "pwd": pwd, "others": others});
    } catch (e) {
      print(e);
      return false;
    }
  }
}

abstract class OnSmartLinkListener {
  void onLinked(Mac, Ip, Id, Mid, ModuleIP) ;

  void onCompleted();

  void onTimeOut() ;
}
