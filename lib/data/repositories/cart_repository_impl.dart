import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cart/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/local/cart_local_data_source.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/cart_remote_data_source.dart';
import '../models/cart/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CartItem>>> getLocalCartItems() async {
    try {
      final localProducts = await localDataSource.getCart();
      return Right(localProducts);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getRemoteCartItems() async {
    // No remote cart API - just return local cart items
    print('🛒 [DEBUG] No remote cart API - returning local cart items');
    return getLocalCartItems();
  }

  @override
  Future<Either<Failure, CartItem>> addCartItem(CartItem params) async {
    try {
      print('🛒 [DEBUG] CartRepository.addCartItem called');
      print('🛒 [DEBUG] Product: ${params.product.name}');
      
      // Cart is local-only - no API endpoint exists for cart management
      // Cart items are sent directly to the order endpoint on checkout
      print('🛒 [DEBUG] Saving locally (cart is local-only)');
      
      try {
        final cartItemModel = CartItemModel.fromParent(params);
        await localDataSource.saveCartItem(cartItemModel);
        print('✅ [DEBUG] Successfully saved cart item locally');
        return Right(params);
      } catch (e, stackTrace) {
        print('❌ [DEBUG] Error saving cart item: $e');
        print('📋 [DEBUG] Stack trace: $stackTrace');
        return Left(CacheFailure());
      }
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Exception in addCartItem: $e');
      print('📋 [DEBUG] Stack trace: $stackTrace');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CartItemModel>> deleteCartItem(CartItem params) async {
    try {
      print('🛒 [DEBUG] Deleting cart item locally');
      final cartItem = CartItemModel.fromParent(params);
      await localDataSource.deleteCartItem(cartItem);
      print('✅ [DEBUG] Cart item deleted');
      return Right(cartItem);
    } catch (e) {
      print('❌ [DEBUG] Error deleting cart item: $e');
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> deleteCart() async {
    try {
      print('🛒 [DEBUG] Clearing cart locally');
      await localDataSource.deleteCart();
      print('✅ [DEBUG] Cart cleared');
      return Right(NoParams());
    } catch (e) {
      print('❌ [DEBUG] Error clearing cart: $e');
      return Left(CacheFailure());
    }
  }
}
