import '../datasources/api_service.dart';
import '../models/product_model.dart';

// ProductRepository - Repository Pattern
//
// Repository đóng vai trò trung gian giữa Data Source và Domain Layer
// Giúp tách biệt logic lấy dữ liệu với business logic
class ProductRepository {
  // Lấy tất cả sản phẩm từ API
  Future<List<ProductModel>> getAllProducts() async {
    final productsJson = await ApiService.getProducts();

    return productsJson
        .map(
          (json) => ProductModel(
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            description: json['description'] ?? '',
            price: (json['price'] ?? 0).toDouble(),
            category: json['category'] ?? '',
            imageUrl: json['imageUrl'] ?? '',
          ),
        )
        .toList();
  }
}
