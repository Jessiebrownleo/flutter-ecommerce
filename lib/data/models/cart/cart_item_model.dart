import 'dart:convert';

import '../../../domain/entities/cart/cart_item.dart';
import '../product/price_tag_model.dart';
import '../product/product_model.dart';

List<CartItemModel> cartItemModelListFromLocalJson(String str) =>
    List<CartItemModel>.from(
        json.decode(str).map((x) => CartItemModel.fromJson(x)));

List<CartItemModel> cartItemModelListFromRemoteJson(String str) =>
    List<CartItemModel>.from(
        json.decode(str)["data"].map((x) => CartItemModel.fromJson(x)));

List<CartItemModel> cartItemModelFromJson(String str) =>
    List<CartItemModel>.from(
        json.decode(str).map((x) => CartItemModel.fromJson(x)));

String cartItemModelToJson(List<CartItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartItemModel extends CartItem {
  const CartItemModel({
    super.id,
    required ProductModel super.product,
    required PriceTagModel super.priceTag,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    print('🛒 [DEBUG] Parsing CartItemModel from JSON');
    print('🛒 [DEBUG] Product data: ${json["product"]}');
    final cartItem = CartItemModel(
      id: json["_id"],
      product: ProductModel.fromJson(json["product"]),
      priceTag: PriceTagModel.fromJson(json["priceTag"]),
    );
    print('🛒 [DEBUG] Product images count: ${cartItem.product.images.length}');
    if (cartItem.product.images.isNotEmpty) {
      print('🛒 [DEBUG] First image URL: ${cartItem.product.images.first}');
    }
    return cartItem;
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "product": (product as ProductModel).toJson(),
        "priceTag": (priceTag as PriceTagModel).toJson(),
      };

  Map<String, dynamic> toBodyJson() => {
        "_id": id,
        "product": product.id,
        "priceTag": priceTag.id,
      };

  factory CartItemModel.fromParent(CartItem cartItem) {
    print('🛒 [DEBUG] Converting CartItem to CartItemModel');
    print('🛒 [DEBUG] Product type: ${cartItem.product.runtimeType}');
    print('🛒 [DEBUG] PriceTag type: ${cartItem.priceTag.runtimeType}');
    
    // Convert Product entity to ProductModel if needed
    ProductModel productModel;
    if (cartItem.product is ProductModel) {
      productModel = cartItem.product as ProductModel;
    } else {
      productModel = ProductModel.fromEntity(cartItem.product);
    }
    
    // Convert PriceTag entity to PriceTagModel if needed
    PriceTagModel priceTagModel;
    if (cartItem.priceTag is PriceTagModel) {
      priceTagModel = cartItem.priceTag as PriceTagModel;
    } else {
      priceTagModel = PriceTagModel.fromEntity(cartItem.priceTag);
    }
    
    return CartItemModel(
      id: cartItem.id,
      product: productModel,
      priceTag: priceTagModel,
    );
  }
}
