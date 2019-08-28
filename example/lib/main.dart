import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_ezviz/flutter_ezviz.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initSDK();
  }

  Future<bool> initSDK() async {
    bool result;
    EzvizInitOptions options = EzvizInitOptions(
        appKey: 'ab658cff26434f5085d276c23370273e',
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
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  EzvizPlayerController playerController;
  final String _deviceSerial = "D35923454";
  final int _cameraNo = 1;
  final String _verifyCode = "RXPZFF";
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _videoName = '0-流畅';
  int _videoLevel = 0;
  // 0-流畅，1-均衡，2-高清，3-超清
  final List<String> _videoLevels = ['0-流畅', '1-均衡', '2-高清', '3-超清'];
  bool isShowPTZ = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (this.isShowPTZ) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _playerView(),
            _initPlayer(context),
            _controllerPad(context),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _playerView(),
            _initPlayer(context),
            _realPlayer(),
            _replayer(context),
          ],
        ),
      );
    }
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

  Widget _initPlayer(BuildContext context) {
    return Container(
        width: 750,
        height: 120,
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              onPressed: () async {
                // await playerController.initPlayerByDevice(_deviceSerial, _cameraNo);
                await Future.wait([
                  playerController.initPlayerByDevice(_deviceSerial, _cameraNo),
                  playerController.setPlayVerifyCode(_verifyCode)
                ]);
              },
              child: Text('初始化播放器'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  isShowPTZ = !isShowPTZ;
                });
              },
              child: Text(isShowPTZ ? '关闭云台' : '开启云台'),
            )
          ],
        ));
  }

  Widget _realPlayer() {
    return Container(
        width: 750,
        height: 120,
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black12)),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('视频清晰度'),
              trailing: DropdownButton(
                value: _videoName,
                items: _videoLevels.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) async {
                  await this.onVideoLevel(context, val);
                },
              ),
            ),
            Row(
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
            )
          ],
        ));
  }

  Widget _replayer(BuildContext context) {
    return Container(
      width: 750,
      margin: EdgeInsets.all(5.0),
      decoration:
          BoxDecoration(border: Border.all(width: 0.5, color: Colors.black12)),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              '开始时间: ${_start.toString()}',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            trailing: FlatButton(
              onPressed: () {
                onShowTime(context, _start, true);
              },
              child: Text(
                '更改时间',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ),
          ListTile(
            title: Text(
              '结束时间: ${_end.toString()}',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            trailing: FlatButton(
              onPressed: () {
                onShowTime(context, _end, false);
              },
              child: Text(
                '更改时间',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
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
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _controllerItem(context, 4, Icons.zoom_in),
              _controllerItem(context, 5, Icons.zoom_out),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _controllerItem(context, 0, Icons.arrow_drop_up),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _controllerItem(context, 1, Icons.arrow_left),
              SizedBox(width: 44,height: 44,),
              _controllerItem(context, 3, Icons.arrow_right),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _controllerItem(context, 2, Icons.arrow_drop_down),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controllerItem(BuildContext context, int cmd, IconData iconData) {
    return Container(
      margin: EdgeInsets.all(3.0),
      padding: EdgeInsets.all(3.0),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(5.0))
          ),
      child: GestureDetector(
        onTapDown: (detail) async {
          await this.onControllerPad(cmd, false);
        },
        onTapUp: (detail) async {
          await this.onControllerPad(cmd, true);
        },
        onTapCancel: () async {
          await this.onControllerPad(cmd, false);
        },
        child: Icon(
          iconData,
          size: 36,
        ),
      ),
    );
  }

  void onPlayerCreated(EzvizPlayerController ezvizPlayerController) {
    this.playerController = ezvizPlayerController;
    this.playerController.setPlayerEventHandler(onPlayerEvent, onPlayerError);
  }

  void onPlayerEvent(EzvizEvent event) {
    EzvizPlayerStatus playerStatus = event.data is EzvizPlayerStatus
        ? (event.data as EzvizPlayerStatus)
        : null;
    print(
        'onPlayerEvent : ${event.eventType} ${playerStatus.status} ${playerStatus.message ?? ""}');
  }

  void onPlayerError(error) {
    print('onPlayerError : ${error.toString()}');
  }

  Future onShowTime(BuildContext context, DateTime time, bool isStart) async {
    var currentTime = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: time.subtract(Duration(days: 15)),
        lastDate: time.add(Duration(days: 15)));
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

  Future<bool> onControllerPad(int cmd, bool isStop) async {
    String command;
    switch (cmd) {
      case 0:
        command = EzvizPtzCommands.Up;
        break;
      case 1:
        command = EzvizPtzCommands.Left;
        break;
      case 2:
        command = EzvizPtzCommands.Down;
        break;
      case 3:
        command = EzvizPtzCommands.Right;
        break;
      case 4:
        command = EzvizPtzCommands.ZoomIn;
        break;
      case 5:
        command = EzvizPtzCommands.ZoomOut;
        break;
      default:
    }
    String action = isStop ? EzvizPtzActions.Stop : EzvizPtzActions.Start;
    return await EzvizManager.shared().controlPTZ(this._deviceSerial,
        this._cameraNo, command, action, EzvizPtzSpeeds.Normal);
  }

  Future<bool> onVideoLevel(BuildContext context, String name) async {
    int level = 0;
    if (name == '0-流畅') {
      level = 0;
    } else if (name == '1-均衡') {
      level = 1;
    } else if (name == '2-高清') {
      level = 2;
    } else if (name == '3-超清') {
      level = 3;
    }
    setState(() {
      _videoLevel = level;
      _videoName = name;
    });
    bool result = await EzvizManager.shared()
        .setVideoLevel(this._deviceSerial, this._cameraNo, this._videoLevel);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('变更视频清晰度需重新开始直播!'),
            actions: <Widget>[
              FlatButton(
                child: Text('关闭'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    return result;
  }
}
