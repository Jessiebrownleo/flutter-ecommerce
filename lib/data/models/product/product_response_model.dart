import '../../../domain/entities/product/pagination_meta_data.dart';
import '../../../domain/entities/product/product.dart';
import '../../../domain/entities/product/product_response.dart';
import 'pagination_data_model.dart';
import 'product_model.dart';
import 'dart:convert';

ProductResponseModel productResponseModelFromJson(String str) =>
    ProductResponseModel.fromJson(json.decode(str));

String productResponseModelToJson(ProductResponseModel data) =>
    json.encode(data.toJson());

class ProductResponseModel extends ProductResponse {
  ProductResponseModel({
    required PaginationMetaData meta,
    required List<Product> data,
  }) : super(products: data, paginationMetaData: meta);

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
      print('🔧 [DEBUG] Parsing product response...');
      print('📊 [DEBUG] JSON keys: ${json.keys.toList()}');
      
      try {
        PaginationMetaDataModel meta;
        List<ProductModel> products;
        
        // Check if response has nested data structure (category endpoint)
        if (json["data"] is Map && json["data"]["items"] != null) {
          print('📦 [DEBUG] Detected category-filtered response format');
          
          // Category endpoint format: { data: { items: [...], totalItems, currentPage, ... } }
          final data = json["data"] as Map<String, dynamic>;
          
          meta = PaginationMetaDataModel(
            page: data["currentPage"] ?? 1,
            pageSize: data["pageSize"] ?? 10,
            total: data["totalItems"] ?? 0,
          );
          
          products = List<ProductModel>.from(
              data["items"].map((x) => ProductModel.fromJson(x)));
          
          print('✅ [DEBUG] Parsed ${products.length} products from category filter');
        } else if (json["data"] is List) {
          print('📦 [DEBUG] Detected general products response format');
          
          // General endpoint format: { data: [...] }
          final dataList = json["data"] as List;
          
          meta = PaginationMetaDataModel(
            page: 1,
            pageSize: dataList.length,
            total: dataList.length,
          );
          
          products = List<ProductModel>.from(
              dataList.map((x) => ProductModel.fromJson(x)));
          
          print('✅ [DEBUG] Parsed ${products.length} products from general endpoint');
        } else {
          throw Exception('Unknown response format');
        }
        
        return ProductResponseModel(
          meta: meta,
          data: products,
        );
      } catch (e, stackTrace) {
        print('❌ [DEBUG] Error in ProductResponseModel.fromJson: $e');
        print('📋 [DEBUG] Stack trace: $stackTrace');
        print('📄 [DEBUG] Raw JSON: $json');
        rethrow;
      }
   }

  Map<String, dynamic> toJson() => {
        "meta": (paginationMetaData as PaginationMetaDataModel).toJson(),
        "data": List<dynamic>.from((products as List<ProductModel>).map((x) => x.toJson())),
      };
}
