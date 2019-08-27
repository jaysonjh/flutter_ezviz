/// 插件事件处理
typedef void EzvizOnEvent(EzvizEvent event);

/// 插件事件异常
typedef void EzvizOnError(error);


/// 初始化SDK参数对象
class EzvizInitOptions {
  String appKey = "";
  String accessToken = "";
  bool enableLog = false;
  bool enableP2P = false;
  EzvizInitOptions(
      {this.appKey, this.accessToken, this.enableLog, this.enableP2P});
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appKey'] = this.appKey;
    data['accessToken'] = this.accessToken;
    data['enableLog'] = this.enableLog;
    data['enableP2P'] = this.enableP2P;
    return data;
  }
}

/// 网络摄像机设备信息
class EzvizNetDeviceInfo {
  // userID,建立播放器时需要
  String userId = "";
  // 数字通道数
  int dChannelCount = 0;
  // 起始数字通道号，0为无效果
  int dStartChannelNo = 0;
  // 模拟通道数
  int channelCount = 0;
  // 起始模拟通道号，0为无效果
  int startChannelNo = 0;
  // 设备类型
  int byDVRType = 0;

  EzvizNetDeviceInfo(
      {this.userId,
      this.dChannelCount,
      this.dStartChannelNo,
      this.channelCount,
      this.startChannelNo,
      this.byDVRType});

  EzvizNetDeviceInfo.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    dChannelCount = json['dChannelCount'];
    dStartChannelNo = json['dStartChannelNo'];
    channelCount = json['channelCount'];
    startChannelNo = json['startChannelNo'];
    byDVRType = json['byDVRType'];
  }
}

/// 设备信息
class EzvizDeviceInfo {
  /// 设备串号
  String deviceSerial = "";

  /// 设备名称
  String deviceName = "";

  /// 是否支持云台控制
  bool isSupportPTZ = false;

  /// 摄像机通道号
  int cameraNum = 0;

  EzvizDeviceInfo(
      {this.deviceSerial, this.deviceName, this.isSupportPTZ, this.cameraNum});

  EzvizDeviceInfo.fronJson(Map<String, dynamic> json) {
    deviceSerial = json['deviceSerial'];
    deviceName = json['deviceName'];
    isSupportPTZ = json['isSupportPTZ'];
    cameraNum = json['cameraNum'];
  }
}

/// Event的对象
class EzvizEvent {
  /// event类型 (见EzvizEventNames)
  String eventType;
  /// 信息
  String msg;
  /// 成功后的数据
  dynamic data;

  EzvizEvent(this.eventType,this.msg);

  factory EzvizEvent.init(Map<String, dynamic> data) {

    if (data['eventType'] == null)
      return null;

    return new EzvizEvent(
      data['eventType'] as String,
      data['msg'] as String,
    );
  }
}