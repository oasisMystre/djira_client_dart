import 'package:djira_client/djira_client.dart';

void main() async {
  final client = Request(url: "http://127.0.0.1:8000", options: {});

  /// Advice you use then, this can block ui
  /// Since this is a websocket response can take long to be received
  final response = await client.request(
    namespace: "users",
    action: "list",
    method: Method.get,
  );

  print(response.data);
}
