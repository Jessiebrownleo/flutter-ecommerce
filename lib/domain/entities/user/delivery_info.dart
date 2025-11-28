import 'package:equatable/equatable.dart';

class DeliveryInfo extends Equatable {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;

  const DeliveryInfo({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
  });

  @override
  List<Object> get props => [
    id,
    customerName,
    customerEmail,
    customerPhone,
    shippingAddress,
  ];
}
