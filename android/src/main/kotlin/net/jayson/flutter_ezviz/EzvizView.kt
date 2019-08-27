package net.jayson.flutter_ezviz

import android.content.Context
import android.view.View
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.Json
import java.text.SimpleDateFormat
import java.util.*

class EzvizFlutterPlayerView(context:Context, registrar: PluginRegistry.Registrar, id: Int) : PlatformView, MethodChannel.MethodCallHandler,EventChannel.StreamHandler,EzvizPlayerEventHandler {

    private val player: EzvizPlayerView
    private val methodChannel: MethodChannel
    private val eventChannel: EventChannel
    /// Native to flutter event
    private var eventSink: EventChannel.EventSink? = null

    init {
        player = EzvizPlayerView(context)
        player.eventHandler = this
        val methodChannelName = EzvizPlayerChannelMethods.methodChannelName + "_${id}"
        val eventChannelName = EzvizPlayerChannelEvents.eventChannelName + "_${id}"
        methodChannel = MethodChannel( registrar.messenger(),methodChannelName)
        eventChannel = EventChannel(registrar.messenger(),eventChannelName)
        eventChannel.setStreamHandler(this)
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return player
    }

    override fun dispose() {
        player.playRelease()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            EzvizPlayerChannelMethods.initPlayerByDevice -> {
                val map = call.arguments as? Map<*, *>
                map?.let {
                    val deviceSerial = map["deviceSerial"] as? String ?: ""
                    val cameraNo = map["cameraNo"] as? Int ?: 0
                    player.initPlayer(deviceSerial,cameraNo)
                }
            }

            EzvizPlayerChannelMethods.initPlayerByUser -> {
                val map = call.arguments as? Map<*, *>
                map?.let {
                    val userId = map["userId"] as? Int ?: 0
                    val cameraNo = map["cameraNo"] as? Int ?: 0
                    val streamType = map["streamType"] as? Int ?: 0
                    player.initPlayer(userId, cameraNo, streamType)
                }
            }

            EzvizPlayerChannelMethods.initPlayerUrl -> {
                val map = call.arguments as? Map<*, *>
                map?.let {
                    val url = map["url"] as? String ?: ""
                    player.initPlayer(url)
                }
            }

            EzvizPlayerChannelMethods.playerRelease -> {
                player.playRelease()
            }

            EzvizPlayerChannelMethods.setPlayVerifyCode -> {
                val map = call.arguments as? Map<*, *>
                map?.let {
                    val verifyCode = map["verifyCode"] as? String ?: ""
                    player.setPlayVerifyCode(verifyCode)
                }
            }

            EzvizPlayerChannelMethods.startRealPlay -> {
                player.startRealPlay()
            }

            EzvizPlayerChannelMethods.stopRealPlay -> {
                player.stopRealPlay()
            }

            EzvizPlayerChannelMethods.startReplay -> {
                val map = call.arguments as? Map<*, *>
                map?.let {
                    val startTime = map["startTime"] as? String ?: ""
                    val endTime = map["endTime"] as? String ?: ""
                    val localDateFormat = SimpleDateFormat("yyyyMMddHHmmss", Locale.getDefault())
                    val startDate = localDateFormat.parse(startTime) ?: Date()
                    val endDate = localDateFormat.parse(endTime) ?: Date()
                    val startCalendar = Calendar.getInstance()
                    startCalendar.time = startDate
                    val endCalendar = Calendar.getInstance()
                    endCalendar.time = endDate
                    player.startPlayback(startCalendar,endCalendar)
                }
            }
            EzvizPlayerChannelMethods.stopReplay -> {
                player.stopPlayBack()
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        this.eventSink = p1
    }

    override fun onCancel(p0: Any?) {
        this.eventSink = null
    }

    @UnstableDefault
    override fun onDispatchStatus(event: EzvizEventResult) {
        this.eventSink?.success(Json.stringify(EzvizEventResult.serializer(),event))
    }
}