import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/mixins/validation_mixin.dart';
import '../../data/datasources/api_service.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

// CartProvider - ChangeNotifier quản lý state giỏ hàng

// 1. CHANGENOTIFIER:
//    - Kế thừa từ ChangeNotifier để có khả năng notify listeners
//    - Chứa state (_items) và các method thay đổi state
//
// 2. DART MIXINS:
//    - Sử dụng 'with' để thêm ValidationMixin
//    - Cho phép tái sử dụng code validate (isValidQuantity)
//
// 3. NOTIFYLISTENERS():
//    - Gọi sau mỗi lần thay đổi state
//    - Thông báo cho tất cả Widget đang lắng nghe để rebuild
//
// 4. SHAREDPREFERENCES:
//    - Lưu trữ giỏ hàng dưới dạng JSON
//    - Khi reload trang/app, dữ liệu được khôi phục từ storage
class CartProvider extends ChangeNotifier with ValidationMixin {
  // Key để lưu vào SharedPreferences
  static const String _cartKey = 'cart_items';

  // UserId hiện tại (null = chưa đăng nhập, dùng SharedPreferences)
  // ProxyProvider sẽ cập nhật userId khi AuthProvider thay đổi
  String? _userId;
  String? get userId => _userId;

  // Danh sách các item trong giỏ hàng (private)
  final List<CartItem> _items = [];

  // Trạng thái đã load dữ liệu từ storage chưa
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Danh sách ID sản phẩm đang được chọn (để demo Selector vs Consumer)
  // Khi thay đổi selectedProductIds:
  // - Consumer SẼ rebuild (vì notifyListeners() được gọi)
  // - Selector KHÔNG rebuild (vì totalPrice không đổi)
  final Set<String> _selectedProductIds = {};

  // Lấy danh sách items (unmodifiable để tránh thay đổi trực tiếp)
  List<CartItem> get items => List.unmodifiable(_items);

  // Lấy danh sách ID sản phẩm đang được chọn
  Set<String> get selectedProductIds => Set.unmodifiable(_selectedProductIds);

  // Kiểm tra sản phẩm có đang được chọn không
  bool isProductSelected(String productId) =>
      _selectedProductIds.contains(productId);

  // Tổng số lượng sản phẩm trong giỏ
  // Consumer sẽ lắng nghe giá trị này
  int get totalQuantity {
    if (_items.isEmpty) return 0;
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Tổng tiền của giỏ hàng
  // Selector sẽ lắng nghe giá trị này
  double get totalPrice {
    if (_items.isEmpty) return 0;
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Kiểm tra giỏ hàng có trống không
  bool get isEmpty => _items.isEmpty;

  // Số loại sản phẩm khác nhau trong giỏ
  int get itemCount => _items.length;

  // METHODS - Thay đổi state
  // Chọn/bỏ chọn sản phẩm (DEMO: Consumer rebuild, Selector không rebuild)
  // Vì totalPrice không thay đổi khi chọn sản phẩm
  void toggleSelectProduct(String productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }

    debugPrint('Selected products: $_selectedProductIds');
    debugPrint('totalPrice vẫn là: $totalPrice (không đổi)');
    debugPrint('Consumer SẼ rebuild, Selector KHÔNG rebuild');

    // notifyListeners() được gọi nhưng totalPrice không đổi
    // → Consumer rebuild, Selector KHÔNG rebuild
    notifyListeners();
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(ProductModel product) async {
    // Kiểm tra sản phẩm đã có trong giỏ chưa
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Sản phẩm đã có -> tăng số lượng
      final currentQuantity = _items[existingIndex].quantity;

      // Sử dụng ValidationMixin để kiểm tra
      if (isValidQuantity(currentQuantity + 1)) {
        _items[existingIndex].increment();

        // Sync với API nếu đã đăng nhập
        if (_userId != null && _items[existingIndex].cartItemId != null) {
          await ApiService.updateCartItem(
            _items[existingIndex].cartItemId!,
            _items[existingIndex].quantity,
          );
        }
      }
    } else {
      // Sản phẩm chưa có -> thêm mới
      final newItem = CartItem(product: product);
      _items.add(newItem);

      // Sync với API nếu đã đăng nhập
      if (_userId != null) {
        final result = await ApiService.addToCart(
          userId: _userId!,
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1,
          imageUrl: product.imageUrl,
        );
        if (result != null) {
          newItem.cartItemId = result['id'];
        }
      }
    }

    // Thông báo cho tất cả Widget đang lắng nghe để rebuild UI và lưu vào storage
    notifyListeners();
    _saveCart();

    debugPrint('Added: ${product.name} | Total items: $totalQuantity');
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(String productId) async {
    // Tìm item cần xóa để lấy cartItemId
    final itemToRemove = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          category: '',
          imageUrl: '',
        ),
      ),
    );

    // Sync với API nếu đã đăng nhập và có cartItemId
    if (_userId != null && itemToRemove.cartItemId != null) {
      await ApiService.deleteCartItem(itemToRemove.cartItemId!);
    }

    _items.removeWhere((item) => item.product.id == productId);

    // Thông báo cho UI rebuild và lưu vào storage
    notifyListeners();
    _saveCart();

    debugPrint('Removed product: $productId | Total items: $totalQuantity');
  }

  // Tăng số lượng sản phẩm
  Future<void> incrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final currentQuantity = _items[index].quantity;

      // Sử dụng ValidationMixin
      if (isValidQuantity(currentQuantity + 1)) {
        _items[index].increment();

        // Sync với API nếu đã đăng nhập
        if (_userId != null && _items[index].cartItemId != null) {
          await ApiService.updateCartItem(
            _items[index].cartItemId!,
            _items[index].quantity,
          );
        }

        // Thông báo UI rebuild + Lưu vào storage
        notifyListeners();
        _saveCart();

        debugPrint(
          'Incremented: ${_items[index].product.name} -> ${_items[index].quantity}',
        );
      }
    }
  }

  // Giảm số lượng sản phẩm
  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].decrement();

        // Sync với API nếu đã đăng nhập
        if (_userId != null && _items[index].cartItemId != null) {
          await ApiService.updateCartItem(
            _items[index].cartItemId!,
            _items[index].quantity,
          );
        }

        // Thông báo UI rebuild + Lưu vào storage
        notifyListeners();
        _saveCart();

        debugPrint(
          'Decremented: ${_items[index].product.name} -> ${_items[index].quantity}',
        );
      } else {
        // Số lượng = 1, xóa luôn
        await removeFromCart(productId);
      }
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart() async {
    // Sync với API nếu đã đăng nhập
    if (_userId != null) {
      await ApiService.clearCart(_userId!);
    }

    _items.clear();

    // Thông báo UI rebuild + Lưu vào storage
    notifyListeners();
    _saveCart();

    debugPrint('Cart cleared');
  }

  // Kiểm tra sản phẩm có trong giỏ không
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Lấy số lượng của một sản phẩm trong giỏ
  int getQuantity(String productId) {
    final item = _items
        .where((item) => item.product.id == productId)
        .firstOrNull;
    return item?.quantity ?? 0;
  }

  // SHAREDPREFERENCES - Lưu trữ dữ liệu giỏ hàng vào local storage
  // Load giỏ hàng từ SharedPreferences khi khởi động app
  // Gọi method này trong main() hoặc sau khi Provider được tạo
  Future<void> loadCart() async {
    if (_isInitialized) return; // Đã load rồi, không load lại

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null && cartJson.isNotEmpty) {
        // Decode JSON string thành List
        final List<dynamic> decoded = jsonDecode(cartJson);

        // Chuyển đổi từng item từ JSON thành CartItem
        _items.clear();
        for (final itemJson in decoded) {
          _items.add(CartItem.fromJson(itemJson as Map<String, dynamic>));
        }

        debugPrint('Loaded ${_items.length} items from storage');
      } else {
        debugPrint('No saved cart found');
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Lưu giỏ hàng vào SharedPreferences
  // Gọi tự động sau mỗi lần thay đổi giỏ hàng
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Chuyển đổi List<CartItem> thành JSON string
      final List<Map<String, dynamic>> itemsJson = _items
          .map((item) => item.toJson())
          .toList();
      final cartJson = jsonEncode(itemsJson);

      await prefs.setString(_cartKey, cartJson);

      debugPrint('Saved ${_items.length} items to storage');
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // ============================================
  // PROXYPROVIDER - Load giỏ hàng từ API
  // ============================================
  // Method này được gọi bởi ProxyProvider khi AuthProvider thay đổi
  // - Khi user đăng nhập: userId != null → load từ API
  // - Khi user đăng xuất: userId = null → clear cart

  // Cập nhật userId và load giỏ hàng từ API
  // Được gọi từ ProxyProvider.update()
  Future<void> updateUserId(String? newUserId) async {
    debugPrint('CartProvider: updateUserId được gọi');
    debugPrint('   userId cũ: $_userId');
    debugPrint('   userId mới: $newUserId');

    // Nếu userId không đổi thì không làm gì
    if (_userId == newUserId) {
      debugPrint('   → userId không đổi, bỏ qua');
      return;
    }

    _userId = newUserId;

    if (newUserId != null) {
      // Đã đăng nhập → Load giỏ hàng từ API
      debugPrint('   → User đã đăng nhập, load giỏ hàng từ API...');
      await _loadCartFromApi(newUserId);
    } else {
      // Đăng xuất → Clear giỏ hàng
      debugPrint('   → User đăng xuất, clear giỏ hàng');
      _items.clear();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Load giỏ hàng từ API theo userId
  Future<void> _loadCartFromApi(String userId) async {
    try {
      debugPrint('CartProvider: Gọi API load giỏ hàng cho $userId');

      final cartData = await ApiService.getCartByUserId(userId);

      if (cartData != null) {
        final List<dynamic> items = cartData['items'] ?? [];

        _items.clear();

        // Chuyển đổi từ API response sang CartItem
        for (final item in items) {
          // Tạo ProductModel từ dữ liệu API
          final product = ProductModel(
            id: item['productId'] ?? '',
            name: item['productName'] ?? '',
            description: item['description'] ?? '',
            price: (item['price'] ?? 0).toDouble(),
            category: item['category'] ?? '',
            imageUrl: item['imageUrl'] ?? '',
          );

          // Tạo CartItem với quantity và cartItemId từ API
          final cartItem = CartItem(
            product: product,
            quantity: item['quantity'] ?? 1,
            cartItemId: item['id'], // Lưu ID từ backend để sync
          );

          _items.add(cartItem);
        }
      } else {
        debugPrint('Không có dữ liệu giỏ hàng từ API');
        _items.clear();
      }
    } catch (e) {
      debugPrint('Lỗi load giỏ hàng từ API: $e');
      _items.clear();
    }

    _isInitialized = true;
    notifyListeners();
  }
}
