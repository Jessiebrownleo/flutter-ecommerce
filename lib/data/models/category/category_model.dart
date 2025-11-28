import 'dart:convert';

import '../../../domain/entities/category/category.dart';

List<CategoryModel> categoryModelListFromRemoteJson(String str) =>
    List<CategoryModel>.from(
        json.decode(str)['data'].map((x) => CategoryModel.fromJson(x)));

List<CategoryModel> categoryModelListFromLocalJson(String str) =>
    List<CategoryModel>.from(
        json.decode(str).map((x) => CategoryModel.fromJson(x)));

String categoryModelListToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    print('🏷️ [DEBUG] Parsing category: ${json.toString()}');
    
    const String baseImageUrl = 'https://soben.store';
    String imageUrl = json["img"] ?? json["image"] ?? "";
    
    // Convert relative URLs to absolute URLs
    if (imageUrl.isNotEmpty && imageUrl.startsWith('/')) {
      imageUrl = '$baseImageUrl$imageUrl';
    }
    
    return CategoryModel(
      id: json["_id"] ?? json["id"] ?? "",
      name: json["title"] ?? json["name"] ?? "Unknown",
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": name,
        "img": image,
      };

  factory CategoryModel.fromEntity(Category entity) => CategoryModel(
        id: entity.id,
        name: entity.name,
        image: entity.image,
      );
}
