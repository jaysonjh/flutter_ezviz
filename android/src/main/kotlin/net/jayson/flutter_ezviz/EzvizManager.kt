package net.jayson.flutter_ezviz

import com.videogo.exception.BaseException
import com.videogo.openapi.EZConstants
import com.videogo.openapi.EZHCNetDeviceSDK
import com.videogo.openapi.EZOpenSDK
import io.flutter.plugin.common.MethodChannel.Result
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

/**
 * 萤石云SDK管理类
 */
object EzvizManager {

    val ptzKeys = mapOf(
            Pair(Action_START,EZConstants.EZPTZAction.EZPTZActionSTART.name),
            Pair(Action_STOP,EZConstants.EZPTZAction.EZPTZActionSTOP.name),
            Pair(Command_Left,EZConstants.EZPTZCommand.EZPTZCommandLeft.name),
            Pair(Command_Right,EZConstants.EZPTZCommand.EZPTZCommandRight.name),
            Pair(Command_Up,EZConstants.EZPTZCommand.EZPTZCommandUp.name),
            Pair(Command_Down,EZConstants.EZPTZCommand.EZPTZCommandDown.name),
            Pair(Command_ZoomIn,EZConstants.EZPTZCommand.EZPTZCommandZoomIn.name),
            Pair(Command_ZoomOut,EZConstants.EZPTZCommand.EZPTZCommandZoomOut.name)
    )

    /// 获取SDK版本号
    fun sdkVersion(result: Result) {
        result.success(EZOpenSDK.getVersion())
    }

    /// 初始化SDK
    fun initSDK(arguments: Any?, result: Result) {
        val map = arguments as? Map<*, *>
        map?.let {
            val appKey = map["appKey"] as? String ?: AppKey
            val accessToken = map["accessToken"] as? String ?: AccessToken
            val enableLog = map["enableLog"] as? Boolean ?: false
            val enableP2P = map["enableP2P"] as? Boolean ?: false
            val application = ApplicationUtils.application
            application?.let {
                val ret = EZOpenSDK.initLib(it, appKey)
                EZOpenSDK.enableP2P(enableP2P)
                EZOpenSDK.showSDKLog(enableLog)
                EZOpenSDK.getInstance().setAccessToken(accessToken)
                EZHCNetDeviceSDK.getInstance()
                result.success(ret)
            }
        }
    }

    /// 是否开启Log
    fun enableLog(arguments: Any?) {
        val map = arguments as? Map<*, *>
        map?.let {
            val debug = map["enableLog"] as? Boolean ?: false
            EZOpenSDK.showSDKLog(debug)
        }
    }

    /// 是否开启P2P
    fun enableP2P(arguments: Any?) {
        val map = arguments as? Map<*, *>
        map?.let {
            val debug = map["enableP2P"] as? Boolean ?: false
            EZOpenSDK.enableP2P(debug)
        }
    }

    /// 设置Token
    fun setAccessToken(arguments: Any?) {
        val map = arguments as? Map<*, *>
        map?.let {
            val accessToken = map["accessToken"] as? String ?: ""
            EZOpenSDK.getInstance().setAccessToken(accessToken)
        }
    }

    /// 获取设备信息
    fun getDeviceInfo(arguments: Any?, result: Result) {
        doAsync {
            val map = arguments as? Map<*, *>
            map?.let {
                try {
                    val deviceSerial = map["deviceSerial"] as? String ?: ""
                    val deviceInfo = EZOpenSDK.getInstance().getDeviceInfo(deviceSerial)
                    if (deviceInfo == null) {
                        uiThread {
                            result.success(null)
                        }
                    } else {
                        val device = mapOf<String, Any>(
                                Pair("deviceSerial", deviceInfo.deviceSerial),
                                Pair("deviceName", deviceInfo.deviceName),
                                Pair("isSupportPTZ", deviceInfo.isSupportPTZ),
                                Pair("cameraNum", deviceInfo.cameraNum)
                        )
                        uiThread {
                            result.success(device)
                        }
                    }
                } catch (e: BaseException) {
                    result.error("获取设备异常", e.localizedMessage, null)
                }
            }
        }
    }

    /// 获取设备信息List
    fun getDeviceList(result: Result) {
        doAsync {
            try {
                val deviceInfoList = EZOpenSDK.getInstance().getDeviceList(0, 100)
                if (deviceInfoList == null || deviceInfoList.isEmpty()) {
                    uiThread {
                        result.success(null)
                    }
                } else {
                    val array = arrayListOf<Map<String, Any>>()
                    for (deviceInfo in deviceInfoList) {
                        val device = mapOf<String, Any>(
                                Pair("deviceSerial", deviceInfo.deviceSerial),
                                Pair("deviceName", deviceInfo.deviceName),
                                Pair("isSupportPTZ", deviceInfo.isSupportPTZ),
                                Pair("cameraNum", deviceInfo.cameraNum)
                        )
                        array.add(device)
                    }
                    uiThread {
                        result.success(array)
                    }
                }
            } catch (e: BaseException) {
                result.error("获取设备异常", e.localizedMessage, null)
            }

        }
    }

    /// 设置视频通道分辨率
    fun setVideoLevel(arguments: Any?, result: Result) {
        val map = arguments as? Map<*, *>
        map?.let {
            val deviceSerial = map["deviceSerial"] as? String ?: ""
            val cameraId = map["cameraId"] as? Int ?: 0
            val videoLevel = map["videoLevel"] as? Int ?: 0

            doAsync {
                val ret = EZOpenSDK.getInstance().setVideoLevel(deviceSerial, cameraId, videoLevel)
                uiThread {
                    result.success(ret)
                }
            }
        }
    }

    /// 云台控制
    fun controlPTZ(arguments: Any?, result: Result) {
        val map = arguments as? Map<*, *>
        map?.let {
            try {
                val deviceSerial = map["deviceSerial"] as? String ?: ""
                val cameraId = map["cameraId"] as? Int ?: 0
                val command = map["command"] as? String ?: ""
                val action = map["action"] as? String ?: ""
                val speed = map["speed"] as? Int ?: 0
                doAsync {
                    val ret = EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraId, EZConstants.EZPTZCommand.valueOf(ptzKeys[command] ?: "") , EZConstants.EZPTZAction.valueOf(ptzKeys[action] ?: ""), speed)
                    uiThread {
                        result.success(ret)
                    }
                }
            } catch (e: BaseException) {
                result.error("云台控制异常", e.localizedMessage, null)
            }
        }
    }

    /// 登录网络设备
    fun loginNetDevice(arguments: Any?, result: Result) {
        val map = arguments as? Map<*, *>
        map?.let {
            try {
                val userId = map["userId"] as? String ?: ""
                val pwd = map["pwd"] as? String ?: ""
                val ipAddr = map["ipAddr"] as? String ?: ""
                var port = map["port"] as? Int ?: 0

                doAsync {
                    val netDevice = EZHCNetDeviceSDK.getInstance().loginDeviceWithUerName(userId, pwd, ipAddr, port)
                    if (netDevice == null) {
                        uiThread {
                            result.success(null)
                        }
                    } else {
                        val deviceInfo = mapOf<String, Any>(
                                Pair("userId", netDevice.loginId),
                                Pair("channelCount", netDevice.byChanNum),
                                Pair("startChannelNo", netDevice.byStartChan),
                                Pair("dStartChannelNo", netDevice.byStartDChan),
                                Pair("dChannelCount", netDevice.byIPChanNum),
                                Pair("byDVRType", netDevice.byDVRType)
                        )
                        uiThread {
                            result.success(deviceInfo)
                        }
                    }
                }
            } catch (e: BaseException) {
                result.error("登录网络设备异常", e.localizedMessage, null)
            }

        }
    }

    /// 登出网络设备
    fun logoutNetDevice(arguments: Any?, result: Result) {
        val map = arguments as? Map<*, *>
        map?.let {
            val userId = map["userId"] as? Int ?: 0
            doAsync {
                val ret = EZHCNetDeviceSDK.getInstance().logoutDeviceWithUserId(userId)
                uiThread {
                    result.success(ret)
                }
            }
        }
    }

    /// 网络设备控制
    fun netControlPTZ(arguments: Any?, result: Result) {
        result.error("Android不支持此方法",null,null)
    }

}