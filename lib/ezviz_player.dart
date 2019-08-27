import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ezviz/ezviz_methods.dart';
import 'package:flutter_ezviz/ezviz_utils.dart';
import 'package:flutter_ezviz/ezviz_definition.dart';

typedef void EzvizPlayerCreatedCallback(EzvizPlayerController controller);

///用与和原生代码关联 播放器管理类
class EzvizPlayerController {
  MethodChannel _channel;

  EventChannel _eventChannel;
  /// 事件监听
  StreamSubscription _dataSubscription;

  EzvizPlayerController.init(int id) {
    _channel =
        new MethodChannel(EzvizPlayerChannelMethods.methodChannelName + "_$id");
    _eventChannel = new EventChannel(EzvizPlayerChannelEvents.eventChannelName + "_$id");
  }
    /// 设置EventHandler
  void setPlayerEventHandler(EzvizOnEvent event, EzvizOnError error) {
    /// 释放之前的handler
    removePlayerEventHandler();
    _dataSubscription = _eventChannel.receiveBroadcastStream().listen((data) {
      if (data is Map<String, dynamic> || data is String) {
        var jsonData = data is String ? json.decode(data) : data;
        ezvizLog("JSON => $jsonData");
        var ezvizEvent = EzvizEvent.init(jsonData);
        if (ezvizEvent != null) {
          if (ezvizEvent.eventType == EzvizChannelEvents.playerStatusChange) {
            var mapData = json.decode(jsonData['data']);
             ezvizEvent.data = EzvizPlayerStatus.fromJson(mapData);
          }
          if (event != null) {
            event(ezvizEvent);
          }
        }
      }
    }, onError: error);
  }

  /// 停止EventHandler
  void removePlayerEventHandler() {
    if (_dataSubscription != null) {
      _dataSubscription.cancel();
    }
  }

  /// 初始化播放器
  /// - Parameters:
  ///   - deviceSerial: 设备序列号
  ///   - cameraNo: 通道号
  Future<void> initPlayerByDevice(String deviceSerial, int cameraNo) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceSerial'] = deviceSerial;
    data['cameraNo'] = cameraNo;
    await _channel.invokeMethod(EzvizPlayerChannelMethods.initPlayerByDevice,data);
  }

  /// 初始化播放器
  /// - Parameters:
  ///   - url: 直播地址
  Future<void> initPlayerByUrl(String url) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = url;
    await _channel.invokeMethod(EzvizPlayerChannelMethods.initPlayerUrl,data);
  }

  /// 初始化局域网播放器
  /// - Parameters:
  ///   - userId: 用户ID
  ///   - cameraNo: 通道号
  ///   - streamType: 码流类型 1:主码流 2:子码流
  Future<void> initPlayerByUser(int userId, int cameraNo, int streamType) async {
    if( ! EzvizStreamTypes.isStreamType(streamType)) {
      ezvizLog('不合法的参数: streamType');
      return;
    }
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['cameraNo'] = cameraNo;
    data['streamType'] = streamType;
    await _channel.invokeMethod(EzvizPlayerChannelMethods.initPlayerByUser,data);
  }

  /// 开启直播
  Future<bool> startRealPlay() async {
    return await _channel.invokeMethod(EzvizPlayerChannelMethods.startRealPlay);
  }

  /// 结束直播
  Future<bool> stopRealPlay() async {
    return await _channel.invokeMethod(EzvizPlayerChannelMethods.stopRealPlay);
  }

  /// 开始回放
  Future<bool> startReplay(DateTime startTime, DateTime endTime) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTime'] = dateToStr(startTime);
    data['endTime'] = dateToStr(endTime);
    return await _channel.invokeMethod(EzvizPlayerChannelMethods.startReplay,data);
  } 

  /// 停止回放
  Future<bool> stopReplay() async {
    return await _channel.invokeMethod(EzvizPlayerChannelMethods.stopReplay);
  }

  /// 释放播放器
  Future<void> release() async {
    _channel.invokeMethod(EzvizPlayerChannelMethods.playerRelease);
  }

  /// 设置视频解码密码
  Future<void> setPlayVerifyCode(String verifyCode) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['verifyCode'] = verifyCode;
    await _channel.invokeMethod(EzvizPlayerChannelMethods.setPlayVerifyCode,data);
  }

}

/// 萤石云播放器
class EzvizPlayer extends StatefulWidget {
  final EzvizPlayerCreatedCallback onCreated;

  EzvizPlayer(
      {Key key, 
      @required this.onCreated})
      : super(key: key);

  _EzvizPlayerState createState() => _EzvizPlayerState();
}

class _EzvizPlayerState extends State<EzvizPlayer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: nativeView(),
    );
  }

  Widget nativeView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: EzvizPlayerChannelMethods.methodChannelName,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }else if (defaultTargetPlatform == TargetPlatform.iOS){
      return UiKitView(
        viewType: EzvizPlayerChannelMethods.methodChannelName,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }else {
      return new Text('$defaultTargetPlatform is not yet supported by this plugin');
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
      }
    widget.onCreated(new EzvizPlayerController.init(id));
  }
}
