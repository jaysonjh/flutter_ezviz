//
//  EzvizView.swift
//  flutter_ezviz
//
//  Created by 江鴻 on 2019/8/25.
//

import Foundation

class EzvizView : NSObject,FlutterPlatformView{
    
    private let player: EzvizPlayer
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    /// Native to flutter event
    private var eventSink: FlutterEventSink?
    
    init(messenger: FlutterBinaryMessenger, viewId: Int64, frame: CGRect) {
        player = EzvizPlayer()
        let methodChannelName = EzvizPlayerChannelMethods.methodChannelName + "_\(viewId)"
        let eventChannelName = EzvizPlayerChannelEvents.eventChannelName + "_\(viewId)"
        methodChannel = FlutterMethodChannel.init(name: methodChannelName, binaryMessenger: messenger)
        eventChannel = FlutterEventChannel.init(name: eventChannelName, binaryMessenger: messenger)
        super.init()
        methodChannel.setMethodCallHandler { [weak self](call, result) in
            self?.onHandle(call, result: result)
        }
        eventChannel.setStreamHandler(self)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStatusChanged(notification:)), name: .EzvizPlayStatusChanged, object: nil)
    }
    
    deinit {
        player.playerRelease()
        eventChannel.setStreamHandler(nil)
        methodChannel.setMethodCallHandler(nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    func view() -> UIView {
        return player
    }
    
    func onHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case EzvizPlayerChannelMethods.initPlayerByDevice:
            if let map = call.arguments as? Dictionary<String, Any> {
                let deviceSerial = map["deviceSerial"] as? String ?? ""
                let cameraNo = map["cameraNo"] as? Int ?? 0
                DispatchQueue.main.async {
                    self.player.initPlayer(deviceSerial: deviceSerial, cameraNo: cameraNo)
                }
            }
        case EzvizPlayerChannelMethods.initPlayerUrl:
            if let map = call.arguments as? Dictionary<String, Any> {
                let url = map["url"] as? String ?? ""
                DispatchQueue.main.async {
                    self.player.initPlayer(url: url)
                }
            }
        case EzvizPlayerChannelMethods.initPlayerByUser:
            if let map = call.arguments as? Dictionary<String, Any> {
                let userId = map["userId"] as? Int ?? 0
                let cameraNo = map["cameraNo"] as? Int ?? 0
                let streamType = map["streamType"] as? Int ?? 0
                DispatchQueue.main.async {
                    self.player.initPlayer(userId: userId, cameraNo: cameraNo, streamType: streamType)
                }
            }
        case EzvizPlayerChannelMethods.playerRelease:
            DispatchQueue.main.async {
                self.player.playerRelease()
            }
        case EzvizPlayerChannelMethods.setPlayVerifyCode:
            if let map = call.arguments as? Dictionary<String, Any> {
                let verifyCode = map["verifyCode"] as? String ?? ""
                DispatchQueue.main.async {
                    self.player.setPlayVerifyCode(verifyCode)
                }
            }
        case EzvizPlayerChannelMethods.startRealPlay:
            DispatchQueue.main.async {
                result(self.player.startRealPlay())
            }
        case EzvizPlayerChannelMethods.stopRealPlay:
            DispatchQueue.main.async {
                result(self.player.stopRealPlay())
            }
        case EzvizPlayerChannelMethods.startReplay:
            if let map = call.arguments as? Dictionary<String, Any> {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss"
                let startTime = map["startTime"] as? String ?? ""
                let endTime = map["endTime"] as? String ?? ""
                let startDate = formatter.date(from: startTime) ?? Date()
                let endDate = formatter.date(from: endTime) ?? Date()
                DispatchQueue.main.async {
                    result(self.player.startReplay(startTime: startDate, endTime: endDate))
                }
            }
        case EzvizPlayerChannelMethods.stopReplay:
            DispatchQueue.main.async {
                result(self.player.stopReplay())
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    @objc func playerStatusChanged( notification: Notification) {
        if let data = notification.userInfo as? [String: Any] {
            do {
                let playerResult = try EzvizPlayerResult(status: data["status"] as? UInt ?? 0, message: data["message"] as? String ?? "")
                let event = EzvizPlayerEventResult(eventType: EzvizPlayerChannelEvents.playerStatusChange, msg: "Player Status Changed", data: objToJSONString(obj: playerResult))
                self.eventSink?(objToJSONString(obj: event))
            }catch{}
        }
    }
}


// MARK: - FlutterStreamHandler
extension EzvizView : FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        ezvizLog(msg: "onListen \(eventSink.debugDescription)")
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        ezvizLog(msg: "onCancel \(eventSink.debugDescription)")
        self.eventSink = nil
        return nil
    }
}
