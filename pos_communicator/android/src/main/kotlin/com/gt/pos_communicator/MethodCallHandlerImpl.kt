package com.gt.pos_communicator

import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodCallHandlerImpl : MethodChannel.MethodCallHandler {

    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success(PlatformInfo.platformVersion())
        }
    }

    /**
     * Register this instance as a method call handler on the given {@code messenger}
     *
     *<p> Stops any previously started and unstopped calls
     */
    fun startListening(messenger: BinaryMessenger) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed")
            stopListening()
        }
        channel = MethodChannel(messenger, "plugins.gt.io/pos_communicator_handler")
        channel?.setMethodCallHandler(this);
    }

    fun stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized")
            return
        }
        channel?.setMethodCallHandler(null)
        channel = null
    }

    companion object {
        const val TAG = "MethodCallHandlerImpl"
    }
}