import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ezviz/ezviz_methods.dart';

typedef void EzvizPlayerCreatedCallback(EzvizPlayerController controller);

///用与和原生代码关联 播放器管理类
class EzvizPlayerController {
  MethodChannel _channel;

  EzvizPlayerController.init(int id) {
    _channel =
        new MethodChannel(EzvizPlayerChannelMethods.methodChannelName + "_$id");
  }
}

/// 萤石云播放器
class EzvizPlayer extends StatefulWidget {
  final EzvizPlayerCreatedCallback onCreated;
  final x;
  final y;
  final width;
  final height;

  EzvizPlayer(
      {Key key, 
      @required this.onCreated, 
      @required this.x, 
      @required this.y, 
      @required this.width, 
      @required this.height})
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
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }else {
      return UiKitView(
        viewType: EzvizPlayerChannelMethods.methodChannelName,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
      }
    widget.onCreated(new EzvizPlayerController.init(id));
  }
}
