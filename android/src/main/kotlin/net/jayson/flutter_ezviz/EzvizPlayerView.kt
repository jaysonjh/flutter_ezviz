package net.jayson.flutter_ezviz

import android.content.Context
import android.util.Log
import android.view.SurfaceHolder
import android.widget.FrameLayout
import com.videogo.openapi.EZOpenSDK
import com.videogo.openapi.EZPlayer
import org.jetbrains.anko.doAsync
import java.util.*
import java.util.concurrent.atomic.AtomicBoolean
import android.os.Handler
import android.os.Looper
import android.os.Message
import com.videogo.openapi.EZConstants
import com.videogo.errorlayer.ErrorInfo
import kotlinx.serialization.UnstableDefault
import kotlinx.serialization.json.Json
import kotlinx.serialization.stringify

/**
 * 播放状态
 *
 * Idle: 空闲状态，默认状态
 * Init: 初始化状态
 * Start: 播放状态
 * Pause: 暂停状态(回放才有暂停状态)
 * Stop: 停止状态
 * Error: 错误状态
 *
 * @property status
 */
enum class EzvizPlayerStatus(val value: Int) {
    Idle(0),
    Init(1),
    Start(2),
    Pause(3),
    Stop(4),
    Error(5),
}

interface EzvizPlayerEventHandler {
    fun onDispatchStatus(event: EzvizEventResult)
}

class EzvizPlayerView(context: Context) : FrameLayout(context), SurfaceHolder.Callback {
    private val TAG = "EZvizPlayerView"
    private var player: EZPlayer? = null
    private var url: String? = null
    private var deviceSerial: String? = null
    private var cameraNo: Int = 0
    private lateinit var surfaceLayout: EzvizPlayerLayout
    /**
     * surface是否创建好
     */
    private val isInitSurface = AtomicBoolean(false)
    /**
     * resume时是否恢复播放
     */
    private val isResumePlay = AtomicBoolean(true)
    private var playStatus: EzvizPlayerStatus

    /// 数据发送回调
    var eventHandler : EzvizPlayerEventHandler? = null

    // 创建一个Handler
    private val mHandler: Handler = object : Handler(Looper.getMainLooper()) {
        override fun handleMessage(msg: Message?) {
            super.handleMessage(msg)
            Log.e(TAG,"ID:"+msg?.what)
            when (msg?.what) {
                EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_START -> {
                    dispatchStatus(EzvizPlayerStatus.Start,null)
                }

                EZConstants.EZRealPlayConstants.MSG_REALPLAY_STOP_SUCCESS -> {
                    dispatchStatus(EzvizPlayerStatus.Stop,null)
                }

                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_START -> {
                    dispatchStatus(EzvizPlayerStatus.Start,null)
                }

                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_STOP_SUCCESS -> {
                    dispatchStatus(EzvizPlayerStatus.Stop,null)
                }

                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_CONNECTION_EXCEPTION,
                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_ENCRYPT_PASSWORD_ERROR,
                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PASSWORD_ERROR,
                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_SEARCH_FILE_FAIL,
                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_SEARCH_NO_FILE,
                EZConstants.EZRealPlayConstants.MSG_REALPLAY_ENCRYPT_PASSWORD_ERROR,
                EZConstants.EZRealPlayConstants.MSG_REALPLAY_PASSWORD_ERROR,
                EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL,
                EZConstants.EZPlaybackConstants.MSG_REMOTEPLAYBACK_PLAY_FAIL-> {
                    val errorInfo = msg.obj as? ErrorInfo
                    dispatchStatus(EzvizPlayerStatus.Error,errorInfo?.description)
                }
            }
        }
    }
    init {
        initSurfaceLayout()
        playStatus = EzvizPlayerStatus.Idle
    }

    private fun initSurfaceLayout() {
        surfaceLayout = EzvizPlayerLayout(context)
        val layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT)
        surfaceLayout.setSurfaceHolderCallback(this)
        addView(surfaceLayout, 0, layoutParams)
    }

    fun initPlayer(deviceSerial: String, cameraNo: Int) {
        player?.release()
        this.url = null
        player = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo)
        this.deviceSerial = deviceSerial
        this.cameraNo = cameraNo
        player?.setSurfaceHold(surfaceLayout.getSurfaceView()?.holder)
        player?.setHandler(this.mHandler)
        dispatchStatus(EzvizPlayerStatus.Init,null)
    }

    fun initPlayer(url: String) {
        player?.release()
        this.deviceSerial = null
        this.cameraNo = 0
        player = EZOpenSDK.getInstance().createPlayerWithUrl(url)
        this.url = url
        player?.setSurfaceHold(surfaceLayout.getSurfaceView()?.holder)
        player?.setHandler(this.mHandler)
        dispatchStatus(EzvizPlayerStatus.Init,null)
    }

    fun initPlayer(userId: Int, cameraNo: Int, streamType: Int) {
        player?.release()
        this.deviceSerial = null
        this.cameraNo = 0
        this.url = null
        player = EZOpenSDK.getInstance().createPlayerWithUserId(userId, cameraNo, streamType)
        player?.setSurfaceHold(surfaceLayout.getSurfaceView()?.holder)
        player?.setHandler(this.mHandler)
        dispatchStatus(EzvizPlayerStatus.Init,null)
    }

    fun startRealPlay(): Boolean {
        if (player != null) {
            dispatchStatus(EzvizPlayerStatus.Start, null)
            return player!!.startRealPlay()
        }
        return false
    }

    fun stopRealPlay(): Boolean {
        if (player != null) {
            return player!!.stopRealPlay()
        }
        return false
    }

    fun startPlayback(startDate: Calendar, endDate: Calendar): Boolean {
        if (player != null) {

            var result = false
            doAsync {
                val list = EZOpenSDK.getInstance().searchRecordFileFromDevice(deviceSerial, cameraNo, startDate, endDate)
                if (list.first() != null) {
                    result = player!!.startPlayback(list.first())
                } else {
                    result = false
                    dispatchStatus(EzvizPlayerStatus.Error, "播放列表为空")
                }
            }
            return result
        }
        return false
    }

    fun stopPlayBack(): Boolean {
        if (player != null) {
            return player!!.stopPlayback()
        }
        return false
    }

    fun playRelease() {
        player?.stopPlayback()
        player?.stopRealPlay()
        player?.release()
        player = null
        dispatchStatus(EzvizPlayerStatus.Idle, null)
    }

    fun setPlayVerifyCode(verifyCode: String) {
        player?.setPlayVerifyCode(verifyCode)
    }

    fun setVideoSizeChange(width: Int, height: Int) {
        surfaceLayout.setSurfaceSize(width, height)
    }

    /**
     * 向Flutter发生状态信息
     *
     * @param status
     * @param message
     */
    @UnstableDefault
    private fun dispatchStatus(status: EzvizPlayerStatus, message: String?) {
        val playerResult = EzvizPlayerResult(status.ordinal,message)

        val eventResult = EzvizEventResult(EzvizPlayerChannelEvents.playerStatusChange,"Player Status Changed", Json.stringify(EzvizPlayerResult.serializer(),playerResult))
        eventHandler?.onDispatchStatus(eventResult)
    }

    override fun surfaceChanged(holder: SurfaceHolder?, format: Int, width: Int, height: Int) {

    }

    override fun surfaceCreated(holder: SurfaceHolder?) {
        Log.i(TAG, "surfaceCreated")
        player?.setSurfaceHold(holder)
        if (isInitSurface.compareAndSet(false, true) && isResumePlay.get()) {
            isResumePlay.set(false)
        }
    }

    override fun surfaceDestroyed(holder: SurfaceHolder?) {
        Log.i(TAG, "surfaceDestroyed")
        isInitSurface.set(false)
    }
}

