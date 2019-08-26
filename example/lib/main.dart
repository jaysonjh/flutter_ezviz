import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_ezviz/ezviz.dart';
import 'package:flutter_ezviz/ezviz_player.dart';
import 'package:flutter_ezviz/ezviz_definition.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  EzvizPlayerController playerController;
  String _deviceSerial = "D35923454";
  int _cameraNo = 1;
  String _verifyCode = "RXPZFF";

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  Future<bool> initSDK() async {
    bool result;
    EzvizInitOptions options = EzvizInitOptions(appkey: 'ab658cff26434f5085d276c23370273e', accessToken: 'at.9vckb7393o78sumy2zu9jy3l5x5jqsn4-58fal9s2fb-02a0u1f-kyiiztys1', enableLog: true,enableP2P: false);
    try {
      result = await EzvizManager.shared().initSDK(options);
    } on PlatformException {
      result = false;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                width: 750,
                height: 360,
                padding: EdgeInsets.all(5.0),
                child: EzvizPlayer(
                  onCreated: onPlayerCreated,
                ),
              ),
              RaisedButton(
                onPressed: () async{
                  // await playerController.initPlayerByDevice(_deviceSerial, _cameraNo);
                  await Future.wait([playerController.initPlayerByDevice(_deviceSerial, _cameraNo),playerController.setPlayVerifyCode(_verifyCode)]);
                },
                child: Text('初始化播放器'),
              ),
              RaisedButton(
                onPressed: () async{
                  await playerController.startRealPlay();
                },
                child: Text('开启直播'),
              ),
              RaisedButton(
                onPressed: () async{
                  await playerController.stopRealPlay();
                },
                child: Text('结束直播'),
              ),
            ],
          ),
          // child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  void onPlayerCreated(EzvizPlayerController ezvizPlayerController) {
    this.playerController = ezvizPlayerController;
    this.playerController.setPlayerEventHandler(onPlayerEvent, onPlayerError);
  }

  void onPlayerEvent(EzvizEvent event){
    print('onPlayerEvent : ${event.eventType} ${event.data}');
  }

  void onPlayerError(error) {
    print('onPlayerError : ${error.toString()}');
  }
}
