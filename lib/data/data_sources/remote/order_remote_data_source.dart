import 'package:eshop/core/error/failures.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../core/constant/strings.dart';
import '../../models/order/order_details_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderDetailsModel> addOrder(OrderDetailsModel params, String token);
  Future<List<OrderDetailsModel>> getOrders(String token);
}

class OrderRemoteDataSourceSourceImpl implements OrderRemoteDataSource {
  final http.Client client;
  OrderRemoteDataSourceSourceImpl({required this.client});

  @override
  Future<OrderDetailsModel> addOrder(params, token) async {
    print('📦 [DEBUG] Creating order...');
    print('📦 [DEBUG] Order items: ${params.orderItems.length}');
    
    final body = orderDetailsModelToJson(params);
    print('📦 [DEBUG] Request body: $body');
    
    final response = await client.post(
      Uri.parse('$baseUrl/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    
    print('📦 [DEBUG] Response status: ${response.statusCode}');
    print('📦 [DEBUG] Response body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ [DEBUG] Order created successfully');
      return orderDetailsModelFromJson(response.body);
    } else {
      print('❌ [DEBUG] Order creation failed');
      throw ServerException();
    }
  }

  @override
  Future<List<OrderDetailsModel>> getOrders(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return orderDetailsModelListFromJson(response.body);
    } else {
      throw ServerFailure();
    }
  }
}
