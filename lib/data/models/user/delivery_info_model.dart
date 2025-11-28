import 'dart:convert';

import '../../../domain/entities/user/delivery_info.dart';

DeliveryInfoModel deliveryInfoModelFromRemoteJson(String str) {
  final jsonData = json.decode(str);
  // Handle both direct response and wrapped response
  final data = jsonData['data'] ?? jsonData;
  return DeliveryInfoModel.fromJson(data);
}

DeliveryInfoModel deliveryInfoModelFromLocalJson(String str) =>
    DeliveryInfoModel.fromJson(json.decode(str));

List<DeliveryInfoModel> deliveryInfoModelListFromRemoteJson(String str) {
  final jsonData = json.decode(str);
  // Handle both direct array and wrapped response
  final dataArray = jsonData['data'] ?? jsonData;
  return List<DeliveryInfoModel>.from(
      dataArray.map((x) => DeliveryInfoModel.fromJson(x)));
}

List<DeliveryInfoModel> deliveryInfoModelListFromLocalJson(String str) =>
    List<DeliveryInfoModel>.from(
        json.decode(str).map((x) => DeliveryInfoModel.fromJson(x)));

String deliveryInfoModelToJson(DeliveryInfoModel data) =>
    json.encode(data.toJson());

String deliveryInfoModelListToJson(List<DeliveryInfoModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryInfoModel extends DeliveryInfo {
  const DeliveryInfoModel({
    required super.id,
    required super.customerName,
    required super.customerEmail,
    required super.customerPhone,
    required super.shippingAddress,
  });

  factory DeliveryInfoModel.fromJson(Map<String, dynamic> json) =>
      DeliveryInfoModel(
        id: json["_id"] ?? json["id"] ?? "",
        customerName: json["customerName"] ?? "",
        customerEmail: json["customerEmail"] ?? "",
        customerPhone: json["customerPhone"] ?? "",
        shippingAddress: json["shippingAddress"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "customerName": customerName,
        "customerEmail": customerEmail,
        "customerPhone": customerPhone,
        "shippingAddress": shippingAddress,
      };

  factory DeliveryInfoModel.fromEntity(DeliveryInfo entity) =>
      DeliveryInfoModel(
        id: entity.id,
        customerName: entity.customerName,
        customerEmail: entity.customerEmail,
        customerPhone: entity.customerPhone,
        shippingAddress: entity.shippingAddress,
      );
}
