import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_total_widget.dart';

// CartScreen - Màn hình giỏ hàng
//
// DEMO CÁC CÁCH SỬ DỤNG PROVIDER:
//
// 1. Consumer: Được sử dụng trong CartIconWidget (AppBar)
//    - Rebuild toàn bộ khi giỏ hàng thay đổi
//
// 2. Selector: Được sử dụng trong CartTotalWidget (Footer)
//    - Chỉ rebuild khi totalPrice thay đổi
//
// 3. context.watch(): Lắng nghe và rebuild
// 4. context.read(): Chỉ đọc, không rebuild
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header hiển thị số loại sản phẩm
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cartProvider.isEmpty
                        ? 'Giỏ hàng trống'
                        : '${cartProvider.itemCount} loại sản phẩm (${cartProvider.totalQuantity} items)',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (!cartProvider.isEmpty)
                    TextButton.icon(
                      onPressed: () {
                        _showClearCartDialog(context);
                      },
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('Xóa tất cả'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                ],
              ),
            );
          },
        ),

        // Danh sách sản phẩm trong giỏ
        Expanded(
          // Sử dụng context.watch() để lắng nghe thay đổi
          child: context.watch<CartProvider>().isEmpty
              ? _buildEmptyCart()
              : _buildCartList(context),
        ),

        // Footer hiển thị tổng tiền (sử dụng SELECTOR)
        const CartTotalWidget(),
      ],
    );
  }

  // Widget hiển thị khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị danh sách sản phẩm
  Widget _buildCartList(BuildContext context) {
    final items = context.watch<CartProvider>().items;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return CartItemWidget(cartItem: items[index]);
      },
    );
  }

  // Dialog xác nhận xóa tất cả
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Provider.of với listen: false - Chỉ gọi method, không rebuild
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}
