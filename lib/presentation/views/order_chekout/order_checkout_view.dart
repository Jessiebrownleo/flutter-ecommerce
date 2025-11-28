import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop/presentation/blocs/cart/cart_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../core/services/services_locator.dart' as di;
import '../../../core/router/app_router.dart';
import '../../../domain/entities/cart/cart_item.dart';
import '../../../domain/entities/order/order_details.dart';
import '../../../domain/entities/order/order_item.dart';
import '../../../domain/entities/user/delivery_info.dart';
import '../../blocs/order/order_add/order_add_cubit.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/outline_label_card.dart';

class OrderCheckoutView extends StatefulWidget {
  final List<CartItem> items;
  const OrderCheckoutView({super.key, required this.items});

  @override
  State<OrderCheckoutView> createState() => _OrderCheckoutViewState();
}

class _OrderCheckoutViewState extends State<OrderCheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<OrderAddCubit>(),
      child: BlocListener<OrderAddCubit, OrderAddState>(
        listener: (context, state) {
          EasyLoading.dismiss();
          if (state is OrderAddLoading) {
            EasyLoading.show(status: 'Loading...');
          } else if (state is OrderAddSuccess) {
            // Clear cart
            context.read<CartBloc>().add(const ClearCart());
            
            // Navigate to payment QR screen with order details
            Navigator.of(context).pushReplacementNamed(
              AppRouter.paymentQR,
              arguments: state.order,
            );
          } else if (state is OrderAddFail) {
            EasyLoading.showError("Error");
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Order Checkout'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(
                  height: 12,
                ),
                OutlineLabelCard(
                  title: 'Delivery Details',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Shipping Address',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your shipping address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                OutlineLabelCard(
                  title: 'Selected Products',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 8),
                    child: Column(
                      children: widget.items
                          .map((product) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 75,
                                      child: AspectRatio(
                                        aspectRatio: 0.88,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: product.product.images.isNotEmpty
                                                  ? CachedNetworkImage(
                                                      imageUrl: product
                                                          .product.images.first,
                                                      fit: BoxFit.contain,
                                                      placeholder: (context, url) => const Center(
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                      errorWidget: (context, url, error) =>
                                                          const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.image_not_supported,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                            )),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.product.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge,
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                              '\$${product.priceTag.price.toStringAsFixed(2)}')
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                OutlineLabelCard(
                  title: 'Order Summery',
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Number of Items"),
                            Text("x${widget.items.length}")
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Price"),
                            Text(
                                "\$${widget.items.fold(0.0, (previousValue, element) => (element.priceTag.price + previousValue))}")
                          ],
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Delivery Charge"), Text("\$4.99")],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total"),
                            Text(
                                "\$${(widget.items.fold(0.0, (previousValue, element) => (element.priceTag.price + previousValue)) + 4.99)}")
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Builder(builder: (context) {
                return InputFormButton(
                  color: Colors.black87,
                  onClick: () {
                    if (_formKey.currentState!.validate()) {
                      // Create delivery info from form data
                      final deliveryInfo = DeliveryInfo(
                        id: '',
                        customerName: _nameController.text,
                        customerEmail: _emailController.text,
                        customerPhone: _phoneController.text,
                        shippingAddress: _addressController.text,
                      );

                      // Place order with delivery info
                      context.read<OrderAddCubit>().addOrder(OrderDetails(
                          id: '',
                          orderItems: widget.items
                              .map((item) => OrderItem(
                                    id: '',
                                    product: item.product,
                                    priceTag: item.priceTag,
                                    price: item.priceTag.price,
                                    quantity: 1,
                                  ))
                              .toList(),
                          deliveryInfo: deliveryInfo,
                          discount: 0));
                    }
                  },
                  titleText: 'Confirm',
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
