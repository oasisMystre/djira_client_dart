import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' show Socket, io;
import 'package:uuid/uuid.dart' show Uuid;

import 'serializers/response.dart';

class Request {
  final Socket socket;
  final Map<Method, Map<String, List<Function(Response)>>> listeners = {
    Method.get: {},
    Method.post: {},
    Method.put: {},
    Method.patch: {},
    Method.delete: {},
    Method.subscription: {},
  };

  Request({
    required String url,
    required Map<String, dynamic> options,
  }) : socket = io(url, options);

  _addListener({
    required Method method,
    required String requestId,
    required List<Function(Response)> listener,
  }) {
    listeners[method]!.putIfAbsent(requestId, () {
      return listener;
    });
  }

  /// Remove a listener from listeners
  /// requestId is returned for every request sent
  removeListener({
    required Method method,
    required String requestId,
  }) {
    listeners[method]?.remove(requestId);
  }

  /// Send request packet to server
  _sendRequest({
    String? id,
    required String namespace,
    required String action,
    required Method method,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    required Function(Response) onError,
    required Function(Response) onSuccess,
  }) {
    final requestId = id ?? const Uuid().v4().toString();

    _addListener(
      method: method,
      requestId: requestId,
      listener: [onError, onSuccess],
    );

    // Register listener for namespace if not exist
    if (!socket.hasListeners(namespace)) {
      socket.on(namespace, (data) {
        log("Liistener on", error: data);
        try {
          final response = Response.fromJson(data);
          // Check if response has registered listeners
          if (listeners.containsKey(response.method) &&
              (listeners[response.method] as Map)
                  .containsKey(response.requestId)) {
            [onError, onSuccess] =
            (listeners[response.method] as Map)[response.requestId];

            // emit response to listener
            (((response.status / 100).round() == 2)
                ? onSuccess
                : onError)(response);
          } else {
log("No fucking reciever");
          }
        } catch(e, s){ log("Error lol", error: e, stackTrace: s);}
      });
    }

    socket.emit(namespace, {
      "method": method.name.toUpperCase(),
      "action": action,
      "requestId": requestId,
      "data": data,
      "query": query,
    });
  }

  // Convert _sendRequest to future using completer
  /// Send request to a server then listen to a future response
  Future<Response> request({
    String? requestId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    required String namespace,
    required String action,
    required Method method,
  }) {
    Completer<Response> completer = Completer();

    _sendRequest(
      id: requestId,
      namespace: namespace,
      action: action,
      method: method,
      data: data,
      query: query,
      onError: (response) => completer.completeError(response),
      onSuccess: (response) => completer.complete(response),
    );

    return completer.future;
  }

  /// Listen to database update from djira server
  /// Subscribe to database update with a listener
  /// [onSuccess] dispatch when success response is received
  /// [onError] dispatch when error response is received
  Future<Function({String action})> subscribe({
    required String namespace,
    String action = "subscribe",
    Method method = Method.post,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    required Function(Response) onError,
    required Function(Response) onSuccess,
  }) {
    return request(
      namespace: namespace,
      action: action,
      method: method,
      data: data,
      query: query,
    ).then((final response) {
      _addListener(
        method: Method.subscription,
        requestId: response.requestId,
        listener: [onError, onSuccess],
      );

      /// Todo Allow send custom payload when unsubscribing
      /// Works fine for my project, If you need to fork or send pull request
      return ({final String action = "unsubscribe"}) async {
        return request(
          data: data,
          query: query,
          action: action,
          method: Method.delete,
          namespace: namespace,
          requestId: response.requestId,
        ).then((unsubscribeResponse) {
          removeListener(
            method: Method.subscription,
            requestId: response.requestId,
          );

          return unsubscribeResponse;
        });
      };
    });
  }
}
