// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['status', 'requestId', 'method', 'data'],
  );
  return Response(
    status: json['status'] as int,
    requestId: json['requestId'] as String,
    method: $enumDecode(_$MethodEnumMap, json['method']),
    type: $enumDecodeNullable(_$TypeEnumMap, json['type']),
    data: json['data'],
  );
}

const _$MethodEnumMap = {
  Method.get: 'GET',
  Method.post: 'POST',
  Method.put: 'PUT',
  Method.patch: 'PATCH',
  Method.delete: 'DELETE',
  Method.subscription: 'SUBSCRIPTION',
};

const _$TypeEnumMap = {
  Type.created: 'added',
  Type.updated: 'modified',
  Type.removed: 'removed',
};
