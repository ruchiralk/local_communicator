package com.gt.pos_communicator

import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PosCommunicatorPlugin */
class PosCommunicatorPlugin: FlutterPlugin, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private var methodCallHandler : MethodCallHandlerImpl? = null

  private var randomNumberEventHandler: RandomNumberStreamHandler? = null

  // FlutterPlugin ========================================================
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodCallHandler = MethodCallHandlerImpl()
    methodCallHandler?.startListening(flutterPluginBinding.binaryMessenger)

    randomNumberEventHandler = RandomNumberStreamHandler()
    randomNumberEventHandler?.startListening(flutterPluginBinding.binaryMessenger);
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (methodCallHandler != null) {
      methodCallHandler?.stopListening()
      methodCallHandler = null
    }

    if (randomNumberEventHandler != null) {
      randomNumberEventHandler?.stopListening()
      randomNumberEventHandler = null
    }
  }
  // End

  // ============================ ActivityAware =============================
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(TAG, "onAttachedToActivity")
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(TAG, "onReattachedToActivityForConfigChanges")
  }

  override fun onDetachedFromActivity() {
   Log.d(TAG, "onDetachedFromActivity")
  }

  //

  companion object {
    const val TAG = "PosCommunicatorPlugin"
  }
}