// 插件方法名称定义
class EzvizChannelMethods {
  /// 插件入口名称
  static const String methodChannelName = "flutter_ezviz";

  /// 获取系统版本号 测试使用
  static const String platformVersion = "getPlatformVersion";

  /// 初始化SDK
  static const String initSDK = "initSDK";

  /// 获取SDK版本号
  static const String sdkVersion = "getSdkVersion";

  /// 是否开启日志
  static const String enableLog = "enableLog";

  /// 是否开启P2P
  static const String enableP2P = "enableP2P";

  /// 设置accessToken
  static const String setAccessToken = "setAccessToken";

  /// 获取设备信息
  static const String deviceInfo = "getDeviceInfo";

  /// 获取设备信息列表
  static const String deviceInfoList = "getDeviceInfoList";

  /// 设置视频通道清晰度
  static const String setVideoLevel = "setVideoLevel";

  /// 云台控制
  static const String controlPTZ = "controlPTZ";

  /// 登录网络设备
  static const String loginNetDevice = "loginNetDevice";

  /// 登出网络设备
  static const String logoutNetDevice = "logoutNetDevice";

  /// NetDevice 云台控制
  static const String netControlPTZ = "netControlPTZ";
}

// 插件事件名称定义
class EzvizChannelEvents {
  /// 插件event入口名称
  static const String eventChannelName = "flutter_ezviz_event";

  /// 播放器状态事件
  static const String playerStatusChange = "playerStatusChange";
}

class EzvizPlayerChannelMethods {
  /// 插件播放器入口名称
  static const String methodChannelName = "flutter_ezviz_player";

  /// 初始化播放器设备(设备信息)
  static const String initPlayerByDevice = "initPlayerByDevice";

  /// 初始化播放器设备(Url)
  static const String initPlayerUrl = "initPlayerUrl";

  /// 初始化播放器设备(用户信息)
  static const String initPlayerByUser = "initPlayerByUser";

  /// 开始直播
  static const String startRealPlay = "startRealPlay";

  /// 结束直播
  static const String stopRealPlay = "stopRealPlay";

  /// 开始回播
  static const String startReplay = "startReplay";

  /// 结束回播
  static const String stopReplay = "stopReplay";

  /// 释放播放器
  static const String playerRelease = "playerRelease";

  /// 设置播放密码
  static const String setPlayVerifyCode = "setPlayVerifyCode";
}

// 插件播放器事件名称定义
class EzvizPlayerChannelEvents {
  /// 插件event入口名称
  static const String eventChannelName = "flutter_ezviz_player_event";
  /// 播放器状态事件
  static const String playerStatusChange = "playerStatusChange";
}
