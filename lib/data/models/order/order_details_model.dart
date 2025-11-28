import 'dart:convert';

import '../../../domain/entities/order/order_details.dart';
import '../user/delivery_info_model.dart';
import 'order_item_model.dart';

List<OrderDetailsModel> orderDetailsModelListFromJson(String str) {
  final jsonData = json.decode(str);
  // Handle both direct array and wrapped response
  final dataArray = jsonData['data'] ?? jsonData;
  return List<OrderDetailsModel>.from(
      dataArray.map((x) => OrderDetailsModel.fromJson(x)));
}

List<OrderDetailsModel> orderDetailsModelListFromLocalJson(String str) =>
    List<OrderDetailsModel>.from(
        json.decode(str).map((x) => OrderDetailsModel.fromJson(x)));

OrderDetailsModel orderDetailsModelFromJson(String str) {
  print('📦 [DEBUG] Parsing order response...');
  final jsonData = json.decode(str);
  print('📦 [DEBUG] JSON data keys: ${jsonData.keys}');
  
  // Handle the actual API response structure
  if (jsonData['success'] == true && jsonData['data'] != null) {
    final data = jsonData['data'];
    print('📦 [DEBUG] Data keys: ${data.keys}');
    
    // The API returns orders array and products array
    final orders = data['orders'] as List;
    final products = data['products'] as List;
    
    print('📦 [DEBUG] Orders count: ${orders.length}');
    print('📦 [DEBUG] Products count: ${products.length}');
    
    // Build order items from orders and products
    final orderItems = <OrderItemModel>[];
    for (var order in orders) {
      // Find matching product
      final product = products.firstWhere(
        (p) => p['id'] == order['productId'],
        orElse: () => null,
      );
      
      if (product != null) {
        orderItems.add(OrderItemModel.fromOrderResponse(order, product));
      }
    }
    
    // Extract delivery info from first order
    final firstOrder = orders.first;
    final deliveryInfo = DeliveryInfoModel(
      id: '',
      customerName: firstOrder['customerName'] ?? '',
      customerEmail: firstOrder['customerEmail'] ?? '',
      customerPhone: firstOrder['customerPhone'] ?? '',
      shippingAddress: firstOrder['shippingAddress'] ?? '',
    );
    
    print('✅ [DEBUG] Successfully parsed order with ${orderItems.length} items');
    
    // Extract Bakong QR code and MD5
    String? qrCode;
    String? md5;
    double? totalAmount;
    if (data['bakong'] != null && 
        data['bakong']['data'] != null) {
      if (data['bakong']['data']['qr'] != null) {
        qrCode = data['bakong']['data']['qr'];
        print('✅ [DEBUG] Extracted QR code: ${qrCode!.substring(0, 50)}...');
      }
      if (data['bakong']['data']['md5'] != null) {
        md5 = data['bakong']['data']['md5'];
        print('✅ [DEBUG] Extracted MD5: $md5');
      }
    }
    
    if (data['totalAmount'] != null) {
      totalAmount = (data['totalAmount'] as num).toDouble();
      print('✅ [DEBUG] Total amount: \$${totalAmount}');
    }
    
    return OrderDetailsModel(
      id: firstOrder['id'] ?? '',
      orderItems: orderItems,
      deliveryInfo: deliveryInfo,
      discount: 0,
      qrCode: qrCode,
      md5: md5,
      totalAmount: totalAmount,
    );
  }
  
  // Fallback to old structure
  print('⚠️ [DEBUG] Using fallback parsing');
  final data = jsonData['data'] ?? jsonData;
  return OrderDetailsModel(
    id: data["_id"] ?? data["id"] ?? '',
    orderItems: List<OrderItemModel>.from(
        (data["orderItems"] ?? []).map((x) => OrderItemModel.fromJson(x))),
    deliveryInfo: DeliveryInfoModel.fromJson(data["deliveryInfo"] ?? {}),
    discount: data["discount"] ?? 0,
  );
}

String orderModelListToJsonBody(List<OrderDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJsonBody())));

String orderModelListToJson(List<OrderDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJsonBody());

class OrderDetailsModel extends OrderDetails {
  const OrderDetailsModel({
    required super.id,
    required List<OrderItemModel> super.orderItems,
    required DeliveryInfoModel super.deliveryInfo,
    required super.discount,
    super.qrCode,
    super.md5,
    super.totalAmount,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
        id: json["_id"],
        orderItems: List<OrderItemModel>.from(
            json["orderItems"].map((x) => OrderItemModel.fromJson(x))),
        deliveryInfo: DeliveryInfoModel.fromJson(json["deliveryInfo"]),
        discount: json["discount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "orderItems": List<dynamic>.from(
            (orderItems as List<OrderItemModel>).map((x) => x.toJson())),
        "deliveryInfo": (deliveryInfo as DeliveryInfoModel).toJson(),
        "discount": discount,
      };

  Map<String, dynamic> toJsonBody() => {
        "items": List<dynamic>.from(
            (orderItems as List<OrderItemModel>).map((x) => {
              "productId": x.product.id,
              "quantity": x.quantity,
            })),
        "customerName": deliveryInfo.customerName,
        "customerEmail": deliveryInfo.customerEmail,
        "customerPhone": deliveryInfo.customerPhone,
        "shippingAddress": deliveryInfo.shippingAddress,
      };

  factory OrderDetailsModel.fromEntity(OrderDetails entity) =>
      OrderDetailsModel(
        id: entity.id,
        orderItems: entity.orderItems
            .map((orderItem) => OrderItemModel.fromEntity(orderItem))
            .toList(),
        deliveryInfo: DeliveryInfoModel.fromEntity(entity.deliveryInfo),
        discount: entity.discount,
        qrCode: entity.qrCode,
        md5: entity.md5,
        totalAmount: entity.totalAmount,
      );
}
