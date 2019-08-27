import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_ezviz/ezviz.dart';
import 'package:flutter_ezviz/ezviz_player.dart';
import 'package:flutter_ezviz/ezviz_definition.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  Future<bool> initSDK() async {
    bool result;
    EzvizInitOptions options = EzvizInitOptions(
        appkey: 'ab658cff26434f5085d276c23370273e',
        accessToken:
            'at.9vckb7393o78sumy2zu9jy3l5x5jqsn4-58fal9s2fb-02a0u1f-kyiiztys1',
        enableLog: true,
        enableP2P: false);
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _playerView(),
              _initPlayer(),
              _realPlayer(),
              _replayer(),
            ],
          ),
          // child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  Widget _playerView() {
    return Container(
      width: 750,
      height: 360,
      padding: EdgeInsets.all(5.0),
      child: EzvizPlayer(
        onCreated: onPlayerCreated,
      ),
    );
  }

  Widget _initPlayer() {
    return Container(
      width: 350,
      height: 44,
      padding: EdgeInsets.all(5.0),
      child: RaisedButton(
        onPressed: () async {
          // await playerController.initPlayerByDevice(_deviceSerial, _cameraNo);
          await Future.wait([
            playerController.initPlayerByDevice(_deviceSerial, _cameraNo),
            playerController.setPlayVerifyCode(_verifyCode)
          ]);
        },
        child: Text('初始化播放器'),
      ),
    );
  }

  Widget _realPlayer() {
    return Container(
        width: 750,
        height: 44,
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                await playerController.startRealPlay();
              },
              child: Text('开启直播'),
            ),
            RaisedButton(
              onPressed: () async {
                await playerController.stopRealPlay();
              },
              child: Text('结束直播'),
            ),
          ],
        ));
  }

  Widget _replayer() {
    return Container(
      width: 750,
      margin: EdgeInsets.all(5.0),
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.black12)),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  onShowTime(context, _start, true);
                },
                child: Text('回播开始时间'),
              ),
              RaisedButton(
                onPressed: () {
                  onShowTime(context, _end, false);
                },
                child: Text('回播结束时间'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                onPressed: () async {
                  await playerController.startReplay(_start, _end);
                },
                child: Text('回播开始'),
              ),
              RaisedButton(
                onPressed: () async {
                  await playerController.stopReplay();
                },
                child: Text('回播结束'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controllerPad(BuildContext context) {
    return Container(
      width: 750,
      height: 200,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                onTap: () {},
              )
            ],
          )
        ],
      ),
    );
  }

  void onPlayerCreated(EzvizPlayerController ezvizPlayerController) {
    this.playerController = ezvizPlayerController;
    this.playerController.setPlayerEventHandler(onPlayerEvent, onPlayerError);
  }

  void onPlayerEvent(EzvizEvent event) {
    print('onPlayerEvent : ${event.eventType} ${event.data}');
  }

  void onPlayerError(error) {
    print('onPlayerError : ${error.toString()}');
  }

  Future onShowTime(BuildContext context, DateTime time, bool isStart) async {
    var currentTime = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: time.subtract(Duration(days: 15)),
        lastDate: _start.add(Duration(days: 15)));
    if (currentTime != null) {
      setState(() {
        if (isStart) {
          _start = currentTime;
        } else {
          _end = currentTime;
        }
      });
    }
  }

  void onControllerPad(int command) async {}
}
