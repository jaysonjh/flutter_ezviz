/// 初始化SDK参数对象
class EzvizInitOptions {
  String appkey = "";
  String accessToken = "";
  bool enableLog = false;
  bool enableP2P = false;
  EzvizInitOptions(
      {this.appkey, this.accessToken, this.enableLog, this.enableP2P});
  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appkey'] = this.appkey;
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

/// 播放状态对象
class EzvizPlayerStatus {

  /// 状态
  ///   * 0 Idle: 空闲状态，默认状态
  ///   * 1 Init: 初始化状态
  ///   * 2 Start: 播放状态
  ///   * 3 Pause: 暂停状态(回放才有暂停状态)
  ///   * 4 Stop: 停止状态
  ///   * 9 Error: 错误状态
  int status = 0;
  /// 错误信息，只有在Error状态才不为空
  String message = "";

  EzvizPlayerStatus({this.status,this.message});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}

/// 通道清晰度
/// 0-流畅，1-均衡，2-高清，3-超清
class EzvizVideoLevels {
  static const Low = 0;
  static const Middle = 1;
  static const High = 2;
  static const SuperHigh = 3;

  static bool isVideolLevel(int level) {
    if (level >= Low && level <=SuperHigh){
      return true;
    }
    return false;
  }
}

/// 云台控制-指令类型
class EzvizPtzCommands {
  static const Left = "EZPTZCommand_Left";
  static const Right = "EZPTZCommand_Right";
  static const Up = "EZPTZCommand_Up";
  static const Down = "EZPTZCommand_Down";
  static const ZoomIn = "EZPTZCommand_ZoomIn";
  static const ZoomOut = "EZPTZCommand_ZoomOut";

  static const commands = [
    Left,Right,Up,Down,ZoomIn,ZoomOut
  ];

  static bool isPtzCommand(String command) {
    return commands.contains(command);
  }
}

/// 云台控制-动作类型
class EzvizPtzActions {
  static const Start = "EZPTZAction_START";
  static const Stop = "EZPTZAction_STOP";

  static const actions = [Start,Stop];

  static bool isPtzAction(String action) {
    return actions.contains(action);
  }
}

/// 云台控制-速度类型
/// 0-慢，1-适中，2-快
class EzvizPtzSpeeds {
  static const Slow = 0;
  static const Normal = 1;
  static const Fast = 2;

  static const speeds = [Slow,Normal,Fast];

  static bool isPtzSpeed(int speed){
    if (speed >= Slow && speed <=Fast){
      return true;
    }
    return false;
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