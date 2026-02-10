import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'app.dart';

void main() {
  // Đảm bảo Flutter binding được khởi tạo trước khi dùng SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // MultiProvider: Cung cấp nhiều Provider cho Widget tree
    //
    // DEMO PROXYPROVIDER:
    // 1. AuthProvider (gốc): Quản lý trạng thái đăng nhập
    // 2. CartProvider (phụ thuộc): Tự động load giỏ hàng khi AuthProvider thay đổi
    //
    // Khi user đăng nhập → AuthProvider.login() → notifyListeners()
    // → ProxyProvider phát hiện → gọi update() → CartProvider.updateUserId()
    // → CartProvider load giỏ hàng từ API
    MultiProvider(
      providers: [
        // 1. AuthProvider - Provider GỐC
        // Quản lý trạng thái đăng nhập/đăng xuất
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // 2. CartProvider - Provider PHỤ THUỘC (dùng ProxyProvider)
        // Tự động cập nhật khi AuthProvider thay đổi
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          // create: Tạo CartProvider ban đầu (chưa đăng nhập)
          create: (context) {
            final cartProvider = CartProvider();
            cartProvider
                .loadCart(); // Load từ SharedPreferences (chế độ offline)
            return cartProvider;
          },
          // update: Được gọi MỖI KHI AuthProvider thay đổi
          // - authProvider: Provider gốc (AuthProvider)
          // - previousCart: CartProvider hiện tại (để giữ lại hoặc cập nhật)
          update: (context, authProvider, previousCart) {
            // Giữ lại CartProvider cũ (không tạo mới)
            // Chỉ cập nhật userId để load giỏ hàng từ API
            if (previousCart != null) {
              // Gọi updateUserId để load giỏ hàng từ API
              previousCart.updateUserId(authProvider.userId);
              return previousCart;
            }

            return CartProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}
