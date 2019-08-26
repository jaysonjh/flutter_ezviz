//
//  EzvizManager.swift
//  flutter_ezviz
//
//  Created by 江鴻 on 2019/8/24.
//
import Foundation
import EZOpenSDKFramework


class EzvizManager {
    /// 获取SDK版本号
    static func sdkVersion(result: @escaping FlutterResult) {
        result(EZOpenSDK.getVersion())
    }
    
    /// 初始化SDK
    static func initSDK(_ arguments: Any?,result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let appkey = map["appkey"] as? String ?? AppKey
            let accessToken = map["accessToken"] as? String ?? AccessToken
            let enableLog = map["enableLog"] as? Bool ?? false
            let enableP2P = map["enableP2P"] as? Bool ?? false
            let ret = EZOpenSDK.initLib(withAppKey: appkey)
            EZOpenSDK.setAccessToken(accessToken)
            EZOpenSDK.setDebugLogEnable(enableLog)
            EZOpenSDK.enableP2P(enableP2P)
            EZHCNetDeviceSDK.initSDK()
            result(ret)
        }else {
            result(false)
        }
    }
    
    /// 是否开启日志
    static func enableLog(_ arguments: Any?) {
        if let map = arguments as? Dictionary<String, Any> {
            if let debug = map["enableLog"] as? Bool {
                EZOpenSDK.setDebugLogEnable(debug)
            }
        }
    }
    
    /// 是否开启P2P
    static func enableP2P(_ arguments: Any?) {
        if let map = arguments as? Dictionary<String, Any> {
            if let enableP2P = map["enableP2P"] as? Bool {
                EZOpenSDK.enableP2P(enableP2P)
            }
        }
    }
    
    /// 设置Token
    static func setAccessToken(_ arguments: Any?) {
        if let map = arguments as? Dictionary<String, Any> {
            if let accessToken = map["accessToken"] as? String {
                EZOpenSDK.setAccessToken(accessToken)
            }
        }
    }
    
    /// 获取设备信息
    static func getDeviceInfo(_ arguments: Any?, result: @escaping FlutterResult){
        if let map = arguments as? Dictionary<String, Any> {
            if let deviceSerial = map["deviceSerial"] as? String {
                EZOpenSDK.getDeviceInfo(deviceSerial) { (device, error) in
                    if let dev = device {
                        result(dev.toJSON())
                    }else {
                        ezvizLog(msg: error?.localizedDescription ?? "")
                        result(nil)
                    }
                }
            }
        }else {
            result(nil)
        }
    }
    
    /// 获取设备信息列表
    static func getDeviceInfoList(result: @escaping FlutterResult) {
        EZOpenSDK.getDeviceList(0, pageSize: 100) { (devices, count, error) in
            if let devList = devices {
                var devArr : [[String: Any]] = []
                devList.forEach({ (item) in
                    if let dev = item as? EZDeviceInfo {
                        devArr.append(dev.toJSON())
                    }
                })
                result(devList)
            }else {
                ezvizLog(msg: error?.localizedDescription ?? "")
                result(nil)
            }
        }
    }
    
    /// 设置视频通道分辨率
    static func setVideoLevel(_ arguments: Any?, result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let deviceSerial = map["deviceSerial"] as? String ?? ""
            let cameraId = map["cameraId"] as? Int ?? 0
            let videoLevel = map["videoLevel"] as? Int ?? 0
            let ezvizVideoLevel = EZVideoLevelType.init(rawValue: videoLevel) ?? EZVideoLevelType.low
            
            EZOpenSDK.setVideoLevel(deviceSerial, cameraNo: cameraId, videoLevel: ezvizVideoLevel) { (error) in
                if let err = error {
                    ezvizLog(msg: err.localizedDescription)
                    result(false)
                }else {
                    result(true)
                }
            }
        
        }
    }
    
    /// 云台控制
    static func controlPTZ(_ arguments: Any?, result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let deviceSerial = map["deviceSerial"] as? String ?? ""
            let cameraId = map["cameraId"] as? Int ?? 0
            let command = map["command"] as? String ?? ""
            let action = map["action"] as? String ?? ""
            let speed = map["speed"] as? Int ?? 0
            
            if let cmd = PTZKeys[command] as? EZPTZCommand{
                if let act = PTZKeys[action] as? EZPTZAction {
                    EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraId, command: cmd, action: act, speed: speed) { (error) in
                        if let err = error {
                            ezvizLog(msg: err.localizedDescription)
                            result(false)
                        }else {
                            result(true)
                        }
                    }
                    
                }else {
                    ezvizLog(msg: "action字符串不合法")
                    result(false)
                }
            }else {
                ezvizLog(msg: "command字符串不合法")
                result(false)
            }
        }
    }
}


// MARK: - 网络设备相关操作
extension EzvizManager {
    
    /// 登录网络设备
    static func loginNetDevice(_ arguments: Any?, result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let userId = map["userId"] as? String ?? ""
            let pwd = map["pwd"] as? String ?? ""
            let ipAddr = map["ipAddr"] as? String ?? ""
            let port = map["port"] as? Int ?? 0
            
            DispatchQueue.global().async {
                let deviceInfo = EZHCNetDeviceSDK.loginDevice(withUerName: userId, pwd: pwd, ipAddr: ipAddr, port: port)
                
                DispatchQueue.main.async {
                    if let dev = deviceInfo {
                        result(dev.toJSON())
                    }else {
                        ezvizLog(msg: "无法登陆设备")
                        result(nil)
                    }
                }
            }
        }
    }
    
    /// 登出网络设备
    static func logoutNetDevice(_ arguments: Any?, result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let userId = map["userId"] as? Int ?? 0
            result(EZHCNetDeviceSDK.logoutDevice(withUserId: userId))
        }
    }
    
    /// 网络设备云台控制
    static func netControlPTZ(_ arguments: Any?, result: @escaping FlutterResult) {
        if let map = arguments as? Dictionary<String, Any> {
            let userId = map["userId"] as? Int ?? 0
            let channelNo = map["channelNo"] as? Int ?? 0
            let command = map["command"] as? String ?? ""
            let action = map["action"] as? String ?? ""
            
            if let cmd = netPTZKeys[command] as? EZPTZCommandType{
                if let act = netPTZKeys[action] as? EZPTZActionType {
                    DispatchQueue.global().async {
                        let ret = EZHCNetDeviceSDK.ptzControl(withUserId: userId, channelNo: channelNo, command: cmd, action: act)
                        DispatchQueue.main.async {
                            result(ret)
                        }
                    }
                    
                }else {
                    ezvizLog(msg: "action字符串不合法")
                    result(false)
                }
            }else {
                ezvizLog(msg: "command字符串不合法")
                result(false)
            }
        }
    }
    
}
