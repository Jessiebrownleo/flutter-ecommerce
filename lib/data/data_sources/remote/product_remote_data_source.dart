
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../core/constant/strings.dart';
import '../../../domain/usecases/product/get_product_usecase.dart';
import '../../models/product/product_response_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductResponseModel> getProducts(FilterProductParams params);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<ProductResponseModel> getProducts(params) {
    // Build URL based on whether category filter is applied
    String url;
    
    // API expects page numbers starting from 1, not 0
    final pageNumber = (params.limit ?? 0) + 1;
    
    if (params.categories.isNotEmpty) {
      // Use category-specific endpoint
      final categoryId = params.categories.first.id;
      url = '$baseUrl/products/category/$categoryId?page=$pageNumber&pageSize=${params.pageSize}';
      
      // Add search query if provided
      if (params.keyword != null && params.keyword!.isNotEmpty) {
        url += '&searchQuery=${params.keyword}';
      }
    } else {
      // Use general products endpoint
      url = '$baseUrl/products?searchQuery=${params.keyword}&pageSize=${params.pageSize}&page=$pageNumber';
    }
    
    return _getProductFromUrl(url);
  }

  Future<ProductResponseModel> _getProductFromUrl(String url) async {
    print('🔍 [DEBUG] Fetching products from: $url');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('📡 [DEBUG] Response status: ${response.statusCode}');
    print('📦 [DEBUG] Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final result = productResponseModelFromJson(response.body);
        print('✅ [DEBUG] Successfully parsed ${result.products.length} products');
        return result;
      } catch (e, stackTrace) {
        print('❌ [DEBUG] Error parsing response: $e');
        print('📋 [DEBUG] Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      print('❌ [DEBUG] Server error: ${response.statusCode} - ${response.body}');
      throw ServerException();
    }
  }
}
