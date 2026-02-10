import '../../data/models/product_model.dart';

// CartItem - Entity đại diện cho một item trong giỏ hàng
//
// Entity thuộc Domain Layer trong Clean Architecture
// Chứa business logic liên quan đến item trong giỏ
class CartItem {
  final ProductModel product;
  int quantity;

  // ID của cart item trên backend (để sync API)
  // null nếu chưa được sync hoặc user chưa đăng nhập
  String? cartItemId;

  CartItem({required this.product, this.quantity = 1, this.cartItemId});

  // Tính tổng tiền của item này
  double get totalPrice => product.price * quantity;

  // Tăng số lượng
  void increment() {
    quantity++;
  }

  // Giảm số lượng
  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // ============================================
  // JSON SERIALIZATION - Để lưu vào SharedPreferences
  // ============================================

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'cartItemId': cartItemId,
    };
  }

  // Factory constructor để tạo từ JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      cartItemId: json['cartItemId'] as String?,
    );
  }
}
