import 'package:eshop/core/error/failures.dart';
import 'package:http/http.dart' as http;

import '../../../core/constant/strings.dart';
import '../../models/category/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final http.Client client;
  CategoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CategoryModel>> getCategories() =>
      _getCategoryFromUrl('$baseUrl/categories');

  Future<List<CategoryModel>> _getCategoryFromUrl(String url) async {
    print('🔍 [DEBUG] Fetching categories from: $url');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    print('📡 [DEBUG] Category response status: ${response.statusCode}');
    print('📦 [DEBUG] Category response body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final result = categoryModelListFromRemoteJson(response.body);
        print('✅ [DEBUG] Successfully parsed ${result.length} categories');
        return result;
      } catch (e, stackTrace) {
        print('❌ [DEBUG] Error parsing categories: $e');
        print('📋 [DEBUG] Stack trace: $stackTrace');
        rethrow;
      }
    } else {
      print('❌ [DEBUG] Server error: ${response.statusCode}');
      throw ServerFailure();
    }
  }
}
