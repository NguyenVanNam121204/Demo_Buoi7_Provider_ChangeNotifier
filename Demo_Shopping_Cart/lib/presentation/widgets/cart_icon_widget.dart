import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

// CartIconWidget - Sử dụng CONSUMER để hiển thị số lượng
//
// CONSUMER:
// - Lắng nghe MỌI thay đổi từ CartProvider
// - Rebuild TOÀN BỘ widget bên trong builder mỗi khi notifyListeners() được gọi
// - Phù hợp khi widget cần nhiều thông tin từ Provider
//
// Trong ví dụ này:
// - Consumer rebuild mỗi khi giỏ hàng thay đổi (thêm/xóa/cập nhật)
// - Hiển thị badge với tổng số lượng sản phẩm
class CartIconWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const CartIconWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // CONSUMER: Lắng nghe CartProvider và rebuild khi có thay đổi
    return Consumer<CartProvider>(
      // builder được gọi lại mỗi khi CartProvider gọi notifyListeners()
      builder: (context, cartProvider, child) {
        debugPrint(
          'CartIconWidget REBUILD - totalQuantity: ${cartProvider.totalQuantity}',
        );

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon giỏ hàng
                const Icon(Icons.shopping_cart_outlined, size: 28),

                // Badge hiển thị số lượng
                if (cartProvider.totalQuantity > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cartProvider.totalQuantity > 99
                            ? '99+'
                            : '${cartProvider.totalQuantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
