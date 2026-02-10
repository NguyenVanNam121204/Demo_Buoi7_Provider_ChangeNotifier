import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ApiService - Gọi HTTP đến Demo_Backend
//
// Kết nối với json-server chạy tại localhost:3000
// Sử dụng cho demo ProxyProvider

class ApiService {
  // Base URL của backend
  // CHÚ Ý: Với Android emulator, dùng 10.0.2.2 thay vì localhost
  // Với Web/Windows/iOS simulator, dùng localhost
  static const String baseUrl = 'http://localhost:3000';

  // ============================================
  // AUTH APIs
  // ============================================

  // Lấy danh sách users (để demo chọn user nhanh)
  // GET /auth/users
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      debugPrint('API: GET /auth/users');

      final response = await http.get(Uri.parse('$baseUrl/auth/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Loaded ${data.length} users');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('API Error: $e');
      return [];
    }
  }

  // ============================================
  // CART APIs
  // ============================================

  // Lấy giỏ hàng của user
  // GET /carts/user/:userId
  static Future<Map<String, dynamic>?> getCartByUserId(String userId) async {
    try {
      debugPrint('🌐 API: GET /carts/user/$userId');

      final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'Loaded ${data['itemCount']} items, total: ${data['totalPrice']}',
        );
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('API Error: $e');
      return null;
    }
  }

  // Lấy giỏ hàng (dạng list items)
  // GET /carts?userId=xxx
  static Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      debugPrint('API: GET /carts?userId=$userId');

      final response = await http.get(
        Uri.parse('$baseUrl/carts?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Loaded ${data.length} cart items');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('API Error: $e');
      return [];
    }
  }

  // Thêm item vào giỏ hàng
  // POST /carts
  static Future<Map<String, dynamic>?> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required String imageUrl,
  }) async {
    try {
      debugPrint('API: POST /carts');
      debugPrint('userId: $userId, product: $productName');

      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'productName': productName,
          'price': price,
          'quantity': quantity,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        debugPrint('Added to cart: ${data['id']}');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('API Error: $e');
      return null;
    }
  }

  // Cập nhật số lượng
  // PATCH /carts/:id
  static Future<bool> updateCartItem(String cartItemId, int quantity) async {
    try {
      debugPrint('API: PATCH /carts/$cartItemId');
      debugPrint('quantity: $quantity');

      final response = await http.patch(
        Uri.parse('$baseUrl/carts/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        debugPrint('Updated');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('API Error: $e');
      return false;
    }
  }

  // Xóa item khỏi giỏ
  // DELETE /carts/:id
  static Future<bool> deleteCartItem(String cartItemId) async {
    try {
      debugPrint('API: DELETE /carts/$cartItemId');

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartItemId'),
      );

      if (response.statusCode == 200) {
        debugPrint('Deleted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('API Error: $e');
      return false;
    }
  }

  // Xóa toàn bộ giỏ hàng của user
  // DELETE /carts/user/:userId
  static Future<bool> clearCart(String userId) async {
    try {
      debugPrint('API: DELETE /carts/user/$userId');

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/user/$userId'),
      );

      if (response.statusCode == 200) {
        debugPrint('Cart cleared');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('API Error: $e');
      return false;
    }
  }

  // ============================================
  // PRODUCTS APIs
  // ============================================

  // Lấy danh sách sản phẩm
  // GET /products
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      debugPrint('API: GET /products');

      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('Loaded ${data.length} products');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('API Error: $e');
      return [];
    }
  }
}
