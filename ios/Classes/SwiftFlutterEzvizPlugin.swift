import Flutter
import UIKit
import EZOpenSDKFramework

func ezvizLog(msg: String) {
    print("EZviz Log: \(msg)")
}

public class SwiftFlutterEzvizPlugin: NSObject, FlutterPlugin {
    
    private var isInit = false
    private let eventChannel: FlutterEventChannel
    /// Native to flutter event
    private var eventSink: FlutterEventSink?
    
    init(eventChannel: FlutterEventChannel) {
        self.eventChannel = eventChannel
        super.init()
        self.eventChannel.setStreamHandler(self)
    }
    
    deinit {
        if isInit {
            EZOpenSDK.destoryLib()
        }
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: EzvizChannelMethods.methodChannelName, binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: EzvizChannelEvents.eventChannelName, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterEzvizPlugin(eventChannel: eventChannel)
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

extension SwiftFlutterEzvizPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        ezvizLog(msg: "onListen \(eventSink.debugDescription)")
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        ezvizLog(msg: "onCancel \(eventSink.debugDescription)")
        self.eventSink = nil
        return nil
    }
}
