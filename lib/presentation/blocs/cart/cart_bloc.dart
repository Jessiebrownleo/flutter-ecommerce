import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/cart/cart_item.dart';
import '../../../domain/usecases/cart/add_cart_item_usecase.dart';
import '../../../domain/usecases/cart/delete_cart_usecase.dart';
import '../../../domain/usecases/cart/get_local_cart_items_usecase.dart';
import '../../../domain/usecases/cart/get_remote_cart_items_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetLocalCartItemsUseCase _getCachedCartUseCase;
  final AddCartUseCase _addCartUseCase;
  final GetRemoteCardItemsUseCase _syncCartUseCase;
  final DeleteCartUseCase _clearCartUseCase;
  CartBloc(
    this._getCachedCartUseCase,
    this._addCartUseCase,
    this._syncCartUseCase,
    this._clearCartUseCase,
  ) : super(const CartInitial(cart: [])) {
    on<GetCart>(_onGetCart);
    on<AddProduct>(_onAddToCart);
    on<ClearCart>(_onClearCart);
  }

  void _onGetCart(GetCart event, Emitter<CartState> emit) async {
    try {
      print('🛒 [DEBUG] Getting cart...');
      emit(CartLoading(cart: state.cart));
      final result = await _getCachedCartUseCase(NoParams());
      result.fold(
        (failure) {
          print('🛒 [DEBUG] Failed to get local cart: $failure');
          emit(CartError(cart: state.cart, failure: failure));
        },
        (cart) {
          print('🛒 [DEBUG] Loaded ${cart.length} items from local cart');
          emit(CartLoaded(cart: cart));
        },
      );
      
      // Try to sync with remote, but don't fail if it doesn't work
      // since we don't have a remote cart API
      try {
        print('🛒 [DEBUG] Attempting to sync cart with remote...');
        final syncResult = await _syncCartUseCase(NoParams());
        emit(CartLoading(cart: state.cart));
        syncResult.fold(
          (failure) {
            print('🛒 [DEBUG] Remote sync failed (expected): $failure');
            // Keep the local cart even if sync fails
            emit(CartLoaded(cart: state.cart));
          },
          (cart) {
            print('🛒 [DEBUG] Synced ${cart.length} items from remote');
            emit(CartLoaded(cart: cart));
          },
        );
      } catch (e) {
        print('🛒 [DEBUG] Remote sync error (expected): $e');
        // Keep the local cart even if sync fails
        emit(CartLoaded(cart: state.cart));
      }
    } catch (e) {
      print('🛒 [DEBUG] Cart error: $e');
      emit(CartError(failure: ExceptionFailure(), cart: state.cart));
    }
  }

  void _onAddToCart(AddProduct event, Emitter<CartState> emit) async {
    try {
      print('🛒 [DEBUG] _onAddToCart called');
      print('🛒 [DEBUG] Current cart size: ${state.cart.length}');
      print('🛒 [DEBUG] Adding product: ${event.cartItem.product.name}');
      
      emit(CartLoading(cart: state.cart));
      List<CartItem> cart = [];
      cart.addAll(state.cart);
      cart.add(event.cartItem);
      
      print('🛒 [DEBUG] New cart size (before save): ${cart.length}');
      print('🛒 [DEBUG] Calling addCartUseCase...');
      
      var result = await _addCartUseCase(event.cartItem);
      result.fold(
            (failure) {
          print('🛒 [DEBUG] addCartUseCase failed: $failure');
          emit(CartError(cart: state.cart, failure: failure));
        },
            (_) {
          print('🛒 [DEBUG] addCartUseCase succeeded!');
          print('🛒 [DEBUG] Emitting CartLoaded with ${cart.length} items');
          emit(CartLoaded(cart: cart));
        },
      );
    } catch (e) {
      print('🛒 [DEBUG] Exception in _onAddToCart: $e');
      emit(CartError(cart: state.cart, failure: ExceptionFailure()));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      print('🛒 [DEBUG] Clearing cart...');
      emit(const CartLoading(cart: []));
      await _clearCartUseCase(NoParams());
      print('✅ [DEBUG] Cart cleared successfully');
      emit(const CartLoaded(cart: []));
    } catch (e) {
      print('❌ [DEBUG] Error clearing cart: $e');
      emit(CartError(cart: const [], failure: ExceptionFailure()));
    }
  }
}
