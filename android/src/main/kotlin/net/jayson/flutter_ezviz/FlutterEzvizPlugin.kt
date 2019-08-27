package net.jayson.flutter_ezviz

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterEzvizPlugin: MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_ezviz")
      channel.setMethodCallHandler(FlutterEzvizPlugin())
      registrar.platformViewRegistry().registerViewFactory(EzvizPlayerChannelMethods.methodChannelName,EzvizPlayerFactory(registrar))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when(call.method) {
      EzvizChannelMethods.platformVersion -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      EzvizChannelMethods.sdkVersion -> {
        EzvizManager.sdkVersion(result)
      }

      EzvizChannelMethods.initSDK -> {
        EzvizManager.initSDK(call.arguments,result)
      }

      EzvizChannelMethods.enableLog -> {
        EzvizManager.enableLog(call.arguments)
      }

      EzvizChannelMethods.enableP2P -> {
        EzvizManager.enableP2P(call.arguments)
      }

      EzvizChannelMethods.setAccessToken -> {
        EzvizManager.setAccessToken(call.arguments)
      }

      EzvizChannelMethods.setVideoLevel -> {
        EzvizManager.setVideoLevel(call.arguments,result)
      }

      EzvizChannelMethods.deviceInfo -> {
        EzvizManager.getDeviceInfo(call.arguments,result)
      }

      EzvizChannelMethods.deviceInfoList -> {
        EzvizManager.getDeviceList(result)
      }

      EzvizChannelMethods.controlPTZ -> {
        EzvizManager.controlPTZ(call.arguments,result)
      }

      EzvizChannelMethods.loginNetDevice -> {
        EzvizManager.loginNetDevice(call.arguments,result)
      }

      EzvizChannelMethods.logoutNetDevice -> {
        EzvizManager.logoutNetDevice(call.arguments,result)
      }

      EzvizChannelMethods.netControlPTZ -> {
        EzvizManager.netControlPTZ(call.arguments,result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }
}
