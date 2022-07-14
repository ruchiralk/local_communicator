
import 'dart:async';
import 'dart:io';
import 'package:nsd/nsd.dart' as nsd;
import 'package:platform_device_id/platform_device_id.dart';

class LocalNetworkDiscovery {

  late int _port;
  int get port => _port;

  nsd.Discovery? _discovery;
  nsd.Registration? _registration;
  late String _deviceId;

  List<LocalNetworkDevice> get results {
    final services = _discovery?.services;
    if(services?.isNotEmpty == true) {
      return services!.where((element) => element.name?.contains(_deviceId) == false).map((e) =>
          LocalNetworkDevice(e.name, e.type, e.host, e.port)
      ).toList();
    }
    return List.empty();
  }

  static const String serviceType = '_grubpos._tcp';

  Future<int> _getUnusedPort() {
    return ServerSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      var port = socket.port;
      socket.close();
      return port;
    });
  }


  Future register({required String deviceId}) async {
    _port = await _getUnusedPort();
    _deviceId = deviceId;
    _registration = await _registerNSDService(_port);
    await refresh();
  }

  Future unRegister() async {
    if(_registration != null) {
      await nsd.unregister(_registration!);
    }
  }

  Future<nsd.Registration> _registerNSDService(int port)  {
    return nsd.register(nsd.Service(name: _deviceId, type:  serviceType, port: port));
  }

  Future<List<LocalNetworkDevice>> refresh() async {
    final completer = Completer<List<LocalNetworkDevice>>();
    // ignore: prefer_function_declarations_over_variables
    final listener = () => completer.complete(results);
    _stopDiscovery(listener);
    _discovery = await nsd.startDiscovery(serviceType, ipLookupType: nsd.IpLookupType.any);
    _discovery?.addListener(listener);
    return completer.future;
  }

  void _stopDiscovery(void Function() listener) async {
    if(_discovery != null) {
      _discovery?.removeListener(listener);
      await nsd.stopDiscovery(_discovery!);
    }
  }
}

class LocalNetworkDevice {
  final String? name;
  final String? type;
  final String? hostName;
  final int? port;

  LocalNetworkDevice(this.name, this.type, this.hostName, this.port);

  @override
  String toString() {
    return '[name: $name, type: $type, hostName: $hostName, port: $port]';
  }
}