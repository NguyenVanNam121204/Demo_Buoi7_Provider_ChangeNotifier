import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mixins/price_formatter_mixin.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';

// CartItemWidget - Widget hiển thị một item trong giỏ hàng
// Sử dụng PriceFormatterMixin để format giá tiền
class CartItemWidget extends StatelessWidget with PriceFormatterMixin {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra sản phẩm có đang được chọn không
    final isSelected = context.watch<CartProvider>().isProductSelected(
      cartItem.product.id,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Highlight khi được chọn
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        // Tap để chọn/bỏ chọn (DEMO: Consumer rebuild, Selector không rebuild)
        onTap: () {
          Provider.of<CartProvider>(
            context,
            listen: false,
          ).toggleSelectProduct(cartItem.product.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox chọn sản phẩm
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).toggleSelectProduct(cartItem.product.id);
                },
              ),

              // Hình ảnh sản phẩm
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    cartItem.product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      cartItem.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Giá đơn vị
                    Text(
                      formatPrice(cartItem.product.price),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tổng tiền item
                    Text(
                      formatPrice(cartItem.totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Điều chỉnh số lượng
              Column(
                children: [
                  // Nút xóa
                  IconButton(
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).removeFromCart(cartItem.product.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: 20,
                  ),

                  // Điều chỉnh số lượng
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút giảm
                        IconButton(
                          onPressed: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).decrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.remove),
                          iconSize: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),

                        // Số lượng
                        Container(
                          constraints: const BoxConstraints(minWidth: 32),
                          child: Text(
                            '${cartItem.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        // Nút tăng
                        IconButton(
                          onPressed: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).incrementQuantity(cartItem.product.id);
                          },
                          icon: const Icon(Icons.add),
                          iconSize: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
