import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/domain/entities/cart/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/app_router.dart';

class CartItemCard extends StatelessWidget {
  final CartItem? cartItem;
  final Function? onFavoriteToggle;
  final Function? onClick;
  final Function()? onLongClick;
  final bool isSelected;
  const CartItemCard({
    super.key,
    this.cartItem,
    this.onFavoriteToggle,
    this.onClick,
    this.onLongClick,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: cartItem == null
          ? Shimmer.fromColors(
              highlightColor: Colors.white,
              baseColor: Colors.grey.shade100,
              child: buildBody(context),
            )
          : buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    // Debug logging
    if (cartItem != null) {
      print('🖼️ [CART_CARD] Building cart item: ${cartItem!.product.name}');
      print('🖼️ [CART_CARD] Images count: ${cartItem!.product.images.length}');
      if (cartItem!.product.images.isNotEmpty) {
        print('🖼️ [CART_CARD] First image: ${cartItem!.product.images.first}');
      }
    }
    
    return GestureDetector(
      onTap: () {
        if (cartItem != null) {
          Navigator.of(context).pushNamed(AppRouter.productDetails,
              arguments: cartItem!.product);
        }
      },
      onLongPress: onLongClick,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // if (isSelected)
              //   Container(
              //     width: 20,
              //     alignment: Alignment.center,
              //     child: Container(
              //       width: 25,
              //       height: 25,
              //       decoration: BoxDecoration(
              //           color: Colors.black87,
              //           shape: BoxShape.circle
              //       ),
              //     ),
              //   ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: cartItem == null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.grey.shade300,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: cartItem!.product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: cartItem!.product.images.first,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print('🖼️ [DEBUG] Image load error: $error');
                                      print('🖼️ [DEBUG] Image URL: $url');
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                        child: cartItem == null
                            ? Container(
                                width: double.infinity,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            : Text(
                                cartItem!.product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                      child: cartItem == null
                          ? Container(
                              width: 80,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : Text(
                              r'$' + cartItem!.priceTag.price.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    ],
                  ),
                ),
              )
            ],
          ),
          // Positioned(
          //   top: 10,
          //   right: 0,
          //   child: FavoriteClothButton(
          //     cloth: cloth,
          //   ),
          // ),
        ],
      ),
    );
  }
}
