import Flutter
import UIKit
import EZOpenSDKFramework

func ezvizLog(msg: String) {
    print("EZviz Log: \(msg)")
}

public class SwiftFlutterEzvizPlugin: NSObject, FlutterPlugin {
    
    private var isInit = false
    
    deinit {
        if isInit {
            EZOpenSDK.destoryLib()
        }
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: EzvizChannelMethods.methodChannelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterEzvizPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch call.method {
    case EzvizChannelMethods.platformVersion:
        result("iOS " + UIDevice.current.systemVersion)
    case EzvizChannelMethods.sdkVersion:
        EzvizManager.sdkVersion(result: result)
    case EzvizChannelMethods.initSDK:
        isInit = true
        EzvizManager.initSDK(call.arguments,result: result)
    case EzvizChannelMethods.enableLog:
        EzvizManager.enableLog(call.arguments)
    case EzvizChannelMethods.enableP2P:
        EzvizManager.enableP2P(call.arguments)
    case EzvizChannelMethods.setAccessToken:
        EzvizManager.setAccessToken(call.arguments)
    case EzvizChannelMethods.deviceInfo:
        EzvizManager.getDeviceInfo(call.arguments, result: result)
    case EzvizChannelMethods.deviceInfoList:
        EzvizManager.getDeviceInfoList(result: result)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
