package net.jayson.flutter_ezviz

import android.content.Context
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec

class EzvizPlayerFactory(private val registrar: Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(p0: Context?, p1: Int, p2: Any?): PlatformView {
       return EzvizFlutterPlayerView(p0!!,registrar,p1)
    }

}