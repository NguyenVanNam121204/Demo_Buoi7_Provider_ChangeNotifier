import 'package:flutter/foundation.dart';

// AuthProvider - Quản lý trạng thái đăng nhập
//
// Đây là Provider GỐC trong demo ProxyProvider:
// - Khi AuthProvider thay đổi (login/logout)
// - ProxyProvider sẽ tự động cập nhật CartProvider
// - CartProvider sẽ load giỏ hàng từ API theo userId

class AuthProvider extends ChangeNotifier {
  // Thông tin user hiện tại
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;

  // Trạng thái loading
  bool _isLoading = false;

  // Getters
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userAvatar => _userAvatar;
  bool get isLoading => _isLoading;

  // Kiểm tra đã đăng nhập chưa
  bool get isLoggedIn => _userId != null;

  // Đăng nhập - cập nhật thông tin user
  // Sau khi gọi notifyListeners(), ProxyProvider sẽ phát hiện
  // và tự động cập nhật CartProvider với userId mới
  void login({
    required String userId,
    required String userName,
    required String userEmail,
    String? userAvatar,
  }) {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _userAvatar = userAvatar;

    notifyListeners(); // ← Trigger ProxyProvider
  }

  // Đăng xuất - xóa thông tin user
  // CartProvider sẽ được reset (userId = null)
  void logout() {
    final previousUser = _userName;

    _userId = null;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;

    debugPrint('AuthProvider: Đã đăng xuất ($previousUser)');

    notifyListeners(); // ← Trigger ProxyProvider
  }

  // Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
