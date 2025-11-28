import 'package:eshop/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> saveCart(List<CartItemModel> cart);
  Future<void> saveCartItem(CartItemModel cartItem);
  Future<bool> deleteCartItem(CartItemModel cartItem);
  Future<bool> deleteCart();
}

const cachedCart = 'CACHED_CART';

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveCart(List<CartItemModel> cart) {
    return sharedPreferences.setString(
      cachedCart,
      cartItemModelToJson(cart),
    );
  }

  @override
  Future<void> saveCartItem(CartItemModel cartItem) {
    print('🛒 [DEBUG] Saving cart item: ${cartItem.product.name}');
    final jsonString = sharedPreferences.getString(cachedCart);
    final List<CartItemModel> cart = [];
    if (jsonString != null) {
      cart.addAll(cartItemModelListFromLocalJson(jsonString));
      print('🛒 [DEBUG] Existing cart has ${cart.length} items');
    }
    if (!cart.any((element) =>
        element.product.id == cartItem.product.id &&
        element.priceTag.id == cartItem.priceTag.id)) {
      cart.add(cartItem);
      print('🛒 [DEBUG] Added item to cart. New cart size: ${cart.length}');
    } else {
      print('🛒 [DEBUG] Item already in cart, not adding duplicate');
    }
    return sharedPreferences.setString(
      cachedCart,
      cartItemModelToJson(cart),
    );
  }

  @override
  Future<List<CartItemModel>> getCart() {
    print('🛒 [DEBUG] Getting cart from local storage');
    final jsonString = sharedPreferences.getString(cachedCart);
    if (jsonString != null) {
      final cart = cartItemModelListFromLocalJson(jsonString);
      print('🛒 [DEBUG] Retrieved ${cart.length} items from cart');
      return Future.value(cart);
    } else {
      print('🛒 [DEBUG] No cart found in local storage');
      throw CacheFailure();
    }
  }

  @override
  Future<bool> deleteCart() async {
    return sharedPreferences.remove(cachedCart);
  }

  @override
  Future<bool> deleteCartItem(CartItemModel cartItem) async {
    final jsonString = sharedPreferences.getString(cachedCart);
    if (jsonString != null) {
      final List<CartItemModel> cart =
          cartItemModelListFromLocalJson(jsonString);
      cart.removeWhere((element) =>
          element.product.id == cartItem.product.id &&
          element.priceTag.id == cartItem.priceTag.id);
      return sharedPreferences.setString(
        cachedCart,
        cartItemModelToJson(cart),
      );
    } else {
      throw CacheFailure();
    }
  }
}
