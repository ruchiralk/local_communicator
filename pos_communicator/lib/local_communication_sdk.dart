import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'dart:developer' as developer;
import 'local_communication_server.dart';

import 'local_network_discovery.dart';

class LocalCommunicationSDK {
  final LocalNetworkDiscovery discovery = LocalNetworkDiscovery();
  final LocalCommunicationServer server = LocalCommunicationServer();

  Future initialize(
      {required String deviceId,
      required LocalCommunicationDelegate delegate}) async {
    await discovery.register(deviceId: deviceId);
    await server.start(discovery.port);
  }

  Future<List<LocalCommunicationResponse>> get(String path) async {
    final devices = await discovery.refresh();
    final futures = devices.map((device) => _get(path, device));
    return await Future.wait(futures);
  }

  Future<List<LocalCommunicationResponse>> post(String path, String data) async {
    final devices = await discovery.refresh();
    final futures = devices.map((device) => _post(path, device, data));
    return await Future.wait(futures);
  }

  Future<LocalCommunicationResponse> _get(
      String path, LocalNetworkDevice device) async {
    final dio = _dio();
    final url = _createUrl(path, device);
    final response = await dio.get(url);
    return LocalCommunicationResponse(
        path, response.data, response.statusCode, device);
  }

  Future<LocalCommunicationResponse> _post(
      String path, LocalNetworkDevice device, String data) async {
    final dio = _dio();
    final url = _createUrl(path, device);
    final response = await dio.post(url, data: data);
    return LocalCommunicationResponse(
        path, response.data, response.statusCode, device);
  }

  Dio _dio() {
    final dio = Dio();
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: _log, // specify log function
      retries: 3, // retry count
      retryDelays: const [
        Duration(milliseconds: 300), // wait 1 sec before first retry
        Duration(milliseconds: 800), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
      ],
    ));
    return dio;
  }

  void _log(String message) {
    developer.log(message);
  }

  String _createUrl(String path, LocalNetworkDevice device) {
    return 'http://${device.hostName}:${device.port}/$path';
  }
}

class LocalCommunicationResponse {
  final String path;
  final String data;
  final int? statusCode;
  final LocalNetworkDevice device;

  LocalCommunicationResponse(
      this.path, this.data, this.statusCode, this.device);
}
