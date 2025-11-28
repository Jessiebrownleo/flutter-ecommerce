import '../../../domain/entities/order/order_item.dart';
import '../product/price_tag_model.dart';
import '../product/product_model.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required ProductModel super.product,
    required PriceTagModel super.priceTag,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
      id: json["_id"],
      product: ProductModel.fromJson(json["product"]),
      priceTag: PriceTagModel.fromJson(json["priceTag"]),
      price: json["price"],
      quantity: json["quantity"]);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "product": (product as ProductModel).toJson(),
        "priceTag": (priceTag as PriceTagModel).toJson(),
        "price": price,
        "quantity": quantity,
      };

  Map<String, dynamic> toJsonBody() => {
        "_id": id,
        "product": product.id,
        "priceTag": priceTag.id,
        "price": price,
        "quantity": quantity,
      };

  factory OrderItemModel.fromEntity(OrderItem entity) => OrderItemModel(
        id: entity.id,
        product: ProductModel.fromEntity(entity.product),
        priceTag: PriceTagModel.fromEntity(entity.priceTag),
        price: entity.price,
        quantity: entity.quantity,
      );

  // Parse from order response where order and product are separate objects
  factory OrderItemModel.fromOrderResponse(
      Map<String, dynamic> order, Map<String, dynamic> productJson) {
    final product = ProductModel.fromJson(productJson);
    
    // Create price tag from order data
    final priceTag = PriceTagModel(
      id: '',
      name: 'Order Price',
      price: (order['totalAmount'] as num).toDouble(),
    );
    
    return OrderItemModel(
      id: order['id'] ?? '',
      product: product,
      priceTag: priceTag,
      price: (order['totalAmount'] as num).toDouble(),
      quantity: order['quantity'] ?? 1,
    );
  }
}
