import '../../../domain/entities/product/product.dart';
import '../category/category_model.dart';
import 'price_tag_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required List<PriceTagModel> super.priceTags,
    required List<CategoryModel> super.categories,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    const String baseImageUrl = 'https://soben.store';
    
    // Map imgs.previews to images, fallback to images field or empty list
    List<String> imageList = [];
    
    // Check for new API format with imgs.previews
    if (json["imgs"] != null && json["imgs"]["previews"] != null) {
      imageList = List<String>.from(json["imgs"]["previews"].map((x) {
        // Convert relative URLs to absolute URLs
        String imageUrl = x.toString();
        if (imageUrl.startsWith('/')) {
          return '$baseImageUrl$imageUrl';
        }
        return imageUrl;
      }));
    } 
    // Fallback to old API format with direct images array
    else if (json["images"] != null) {
      imageList = List<String>.from(json["images"].map((x) => x.toString()));
    }

    // Create a single PriceTag from price and discountedPrice
    List<PriceTagModel> priceTags = [];
    if (json["price"] != null) {
      priceTags.add(PriceTagModel(
        id: "default",
        name: "Default",
        price: json["discountedPrice"] ?? json["price"],
      ));
    }

    // Handle categories - could be a list of IDs or objects
    List<CategoryModel> categoryList = [];
    if (json["categoryId"] != null) {
      // If it's just an ID, create a minimal category
      categoryList.add(CategoryModel(
        id: json["categoryId"],
        name: "Category",
        image: "",
      ));
    } else if (json["categories"] != null) {
      categoryList = List<CategoryModel>.from(
          json["categories"].map((x) => CategoryModel.fromJson(x)));
    }

    return ProductModel(
      id: json["_id"] ?? json["id"] ?? "",
      name: json["title"] ?? json["name"] ?? "",
      description: json["description"] ?? "",
      priceTags: priceTags,
      categories: categoryList,
      images: imageList,
      createdAt: json["createdAt"] != null 
          ? DateTime.parse(json["createdAt"]) 
          : DateTime.now(),
      updatedAt: json["updatedAt"] != null 
          ? DateTime.parse(json["updatedAt"]) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "priceTags": List<dynamic>.from(
            (priceTags as List<PriceTagModel>).map((x) => x.toJson())),
        "categories": List<dynamic>.from(
            (categories as List<CategoryModel>).map((x) => x.toJson())),
        "images": List<dynamic>.from(images.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };

  factory ProductModel.fromEntity(Product entity) => ProductModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        priceTags: entity.priceTags
            .map((priceTag) => PriceTagModel.fromEntity(priceTag))
            .toList(),
        categories: entity.categories
            .map((category) => CategoryModel.fromEntity(category))
            .toList(),
        images: entity.images,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
