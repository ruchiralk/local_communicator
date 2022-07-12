package com.gt.pos_communicator

import android.os.Handler
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Runnable
import java.util.*

class RandomNumberStreamHandler: EventChannel.StreamHandler {

    private var eventChannel: EventChannel? = null
    private var sink: EventChannel.EventSink? = null;
    private var handler: Handler? = null
    private val runnable = Runnable {
        sendNewRandomNumber()
    }

    private fun sendNewRandomNumber() {
        val randomNumber = Random().nextInt(9)
        sink?.success(randomNumber)
        handler?.postDelayed(runnable, 1000)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        handler = Handler()
        handler?.post(runnable)
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        handler?.removeCallbacks(runnable)
    }

    fun startListening(messenger: BinaryMessenger) {
        if (eventChannel != null) {
            Log.wtf(TAG, "Setting event channel handler before the last was disposed")
            stopListening()
        }
        eventChannel = EventChannel(messenger, "plugins.gt.io/random_number_stream_handler")
        eventChannel?.setStreamHandler(this);
    }

    fun stopListening() {
        if (eventChannel == null) {
            Log.d(TAG, "Trying to stop when no event channel had been initialized")
            return
        }
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    companion object {
        private const val TAG = "EventChannelHandlerImpl"
    }
}