import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonEnum()
enum Method {
  @JsonValue("GET")
  get,
  @JsonValue("POST")
  post,
  @JsonValue("PUT")
  put,
  @JsonValue("PATCH")
  patch,
  @JsonValue("SUBSCRIPTION")
  subscription,
}

@JsonEnum()
enum Type {
  @JsonValue("added")
  created,
  @JsonValue("modified")
  updated,
  @JsonValue("removed")
  removed,
}

@JsonSerializable()
class Response {
  @JsonKey(required: true)
  final int status;

  @JsonKey(required: true)
  final String requestId;

  @JsonKey(required: true)
  final Method method;

  @JsonKey()
  final Type? type;

  @JsonKey(required: true)
  final dynamic data;

  const Response({
    required this.status,
    required this.requestId,
    required this.method,
    required this.type,
    required this.data,
  });

  factory Response.fromJson(Map<String, dynamic> json) => _$ResponseFromJson(json);
}
