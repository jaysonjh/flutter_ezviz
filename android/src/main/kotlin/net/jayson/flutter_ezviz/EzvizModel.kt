package net.jayson.flutter_ezviz

import com.videogo.openapi.EZConstants
import kotlinx.serialization.*
const val AppKey: String = "888b1f2a00d14aee910d1a7437669a2a"
const val AccessToken: String = "at.1zvz23zq4ahu89r1cf1fmlv41s0h8g22-6t4r5o4vql-1hvx6ud-h0myuu18u"

const val Action_START = "EZPTZAction_START"
const val Action_STOP  = "EZPTZAction_STOP"
const val Command_Left = "EZPTZCommand_Left"
const val Command_Right = "EZPTZCommand_Right"
const val Command_Up = "EZPTZCommand_Up"
const val Command_Down = "EZPTZCommand_Down"
const val Command_ZoomIn = "EZPTZCommand_ZoomIn"
const val Command_ZoomOut = "EZPTZCommand_ZoomOut"
/// 数据返回
@Serializable
data class EzvizEventResult(
        val eventType: String,
        val msg: String,
        val data: String?
)

/// 播放状态
@Serializable
data class EzvizPlayerResult(
        val status: Int,
        val message: String?
)
