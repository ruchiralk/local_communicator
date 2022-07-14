import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:developer' as developer;

class LocalCommunicationServer {
  LocalCommunicationDelegate? delegate;

  Future<bool> start(int port) async {
    Future<Response> _responseHandler(Request request) async {
      final data = await request.readAsString();
      final method = request.method;
      final path = request.url.path;
      final headers = request.headers;
      final response = await delegate?.requestReceived(
          CommunicationDelegateRequest(data, method, path, headers));
      return response?.successful == true
          ? Response.ok(response?.data ?? '')
          : Response.notFound(response?.data);
    }

    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(_responseHandler);

    var server = await shelf_io.serve(handler, '0.0.0.0', port);
    developer.log(
        'LocalCommunicationServer serving at http://${server.address.host}:${server.port}');
    return true;
  }
}

mixin LocalCommunicationDelegate {
  Future<CommunicationDelegateResponse> requestReceived(
      CommunicationDelegateRequest request);
}

class CommunicationDelegateRequest {
  final String? data;
  final String method;
  final String path;
  final Map<String, String> headers;

  CommunicationDelegateRequest(this.data, this.method, this.path, this.headers);
}

class CommunicationDelegateResponse {
  final bool successful;
  final String data;

  CommunicationDelegateResponse(this.successful, this.data);
}
