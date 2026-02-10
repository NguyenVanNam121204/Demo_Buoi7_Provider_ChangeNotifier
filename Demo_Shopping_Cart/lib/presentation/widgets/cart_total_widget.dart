import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../providers/cart_provider.dart';

// CartTotalWidget - Sử dụng SELECTOR để tối ưu rebuild
//
// SELECTOR vs CONSUMER:
//
// CONSUMER:
// - Rebuild khi BẤT KỲ state nào trong Provider thay đổi
// - Ví dụ: Thêm sản phẩm mới (quantity thay đổi) -> Consumer rebuild
//
// SELECTOR:
// - Chỉ rebuild khi PHẦN STATE ĐƯỢC CHỌN thay đổi
// - Ví dụ: Chỉ rebuild khi totalPrice thay đổi
// - Nếu thêm cùng 1 sản phẩm (quantity tăng nhưng price/item không đổi)
//   -> totalPrice thay đổi -> Selector rebuild
// - Nếu chỉ thay đổi metadata không liên quan đến price
//   -> Selector KHÔNG rebuild
//
// Cú pháp: `Selector<ProviderType, SelectedValueType>`
class CartTotalWidget extends StatelessWidget with PriceFormatterMixin {
  const CartTotalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // SELECTOR: Chỉ lắng nghe totalPrice, không quan tâm các state khác
    return Selector<CartProvider, double>(
      // selector: Chọn phần state cần lắng nghe
      selector: (context, provider) => provider.totalPrice,

      // builder: Chỉ được gọi khi totalPrice thay đổi
      builder: (context, totalPrice, child) {
        debugPrint('CartTotalWidget REBUILD - totalPrice: $totalPrice');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tổng tiền',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Hiển thị tổng tiền đã format (sử dụng Mixin)
                    Text(
                      formatPrice(totalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),

                // Nút thanh toán
                ElevatedButton.icon(
                  onPressed: totalPrice > 0
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Đặt hàng thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear cart after checkout
                          // Provider.of với listen: false - Chỉ gọi method, không rebuild
                          Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).clearCart();
                        }
                      : null,
                  icon: const Icon(Icons.payment),
                  label: const Text('Thanh toán'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
