import 'dart:async';

import 'package:flutter/services.dart';

class PosCommunicator {
  static const MethodChannel _channel = MethodChannel('plugins.gt.io/pos_communicator_handler');

  static const EventChannel _randomNumberEventChannel = const EventChannel("plugins.gt.io/random_number_stream_handler");

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Stream<int> get getRandomNumberStream {
    return _randomNumberEventChannel.receiveBroadcastStream().cast();
  }
}
