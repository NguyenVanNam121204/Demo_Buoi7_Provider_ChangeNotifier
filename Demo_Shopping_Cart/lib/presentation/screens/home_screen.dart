import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/cart_icon_widget.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

// HomeScreen - Màn hình chính của ứng dụng
//
// Sử dụng BottomNavigationBar để chuyển đổi giữa các tab
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const ProductListScreen(), const CartScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Shopping Cart Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Nút Login/Logout - Demo ProxyProvider
          _buildAuthButton(context),

          // CartIconWidget sử dụng CONSUMER
          // Tự động cập nhật khi giỏ hàng thay đổi
          CartIconWidget(
            onTap: () {
              setState(() {
                _currentIndex = 1; // Chuyển sang tab giỏ hàng
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Sản phẩm',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
        ],
      ),
    );
  }

  // Widget hiển thị nút Login/Logout dựa trên trạng thái đăng nhập
  Widget _buildAuthButton(BuildContext context) {
    // Dùng context.watch để rebuild khi AuthProvider thay đổi
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoggedIn) {
      // Đã đăng nhập - Hiển thị avatar và menu
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'logout') {
            // Đăng xuất → Trigger ProxyProvider → CartProvider reset
            authProvider.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã đăng xuất'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userName ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  authProvider.userEmail ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: authProvider.userAvatar != null
                    ? NetworkImage(authProvider.userAvatar!)
                    : null,
                child: authProvider.userAvatar == null
                    ? Text(authProvider.userName?[0].toUpperCase() ?? '?')
                    : null,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );
    } else {
      // Chưa đăng nhập - Hiển thị nút Login
      return TextButton.icon(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        },
        icon: const Icon(Icons.login),
        label: const Text('Đăng nhập'),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
