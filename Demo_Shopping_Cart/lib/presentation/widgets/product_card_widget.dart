import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';

// ProductCardWidget - Card hiển thị sản phẩm
//
// Sử dụng:
// - context.read() để gọi method (không cần rebuild)
// - context.watch() để đọc state và rebuild khi thay đổi
// - PriceFormatterMixin để format giá tiền
class ProductCardWidget extends StatelessWidget with PriceFormatterMixin {
  final ProductModel product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // context.watch: Lắng nghe thay đổi để cập nhật UI (nút đã thêm/chưa)
    final cartProvider = context.watch<CartProvider>();
    final isInCart = cartProvider.isInCart(product.id);
    final quantityInCart = cartProvider.getQuantity(product.id);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              color: Colors.grey.shade200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Hiển thị ảnh sản phẩm từ API
                  ClipRRect(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  // Badge số lượng trong giỏ
                  if (isInCart)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'x$quantityInCart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Danh mục
                Text(
                  product.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),

                // Giá tiền (sử dụng PriceFormatterMixin)
                Text(
                  formatPrice(product.price),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Nút thêm vào giỏ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Provider.of với listen: false - Chỉ gọi method, không lắng nghe thay đổi
                      // Provider.of<CartProvider>(
                      //   context,
                      //   listen: false,
                      // ).addToCart(product);
                      context.read<CartProvider>().addToCart(product);
                    },
                    icon: Icon(isInCart ? Icons.add : Icons.add_shopping_cart),
                    label: Text(isInCart ? 'Thêm nữa' : 'Thêm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
