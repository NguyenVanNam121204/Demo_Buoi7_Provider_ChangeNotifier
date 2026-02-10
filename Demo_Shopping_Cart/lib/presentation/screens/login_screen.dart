import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/api_service.dart';
import '../providers/auth_provider.dart';

// LoginScreen - Màn hình đăng nhập
//
// Demo ProxyProvider:
// 1. User chọn account và nhấn Đăng nhập
// 2. AuthProvider.login() được gọi
// 3. ProxyProvider phát hiện thay đổi
// 4. CartProvider tự động load giỏ hàng từ API

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Danh sách users từ API (để demo chọn nhanh)
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingUsers = true;
  bool _isLoggingIn = false;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Load danh sách users từ API để demo chọn nhanh
  Future<void> _loadUsers() async {
    final users = await ApiService.getUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoadingUsers = false;
        if (users.isNotEmpty) {
          _selectedUserId = users[0]['id'];
        }
      });
    }
  }

  // Đăng nhập nhanh bằng cách chọn user
  Future<void> _quickLogin(Map<String, dynamic> user) async {
    setState(() {
      _isLoggingIn = true;
      _selectedUserId = user['id'];
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isLoggingIn = false);

    // Gọi AuthProvider.login() → Trigger ProxyProvider
    context.read<AuthProvider>().login(
      userId: user['id'],
      userName: user['name'],
      userEmail: user['email'],
      userAvatar: user['avatar'],
    );

    // Quay về
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xin chào, ${user['name']}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            const Icon(Icons.account_circle, size: 80, color: Colors.blue),
            const SizedBox(height: 24),

            // Title
            Text(
              'Demo ProxyProvider',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để xem giỏ hàng được load tự động từ API',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Quick login section
            _buildQuickLoginSection(),
          ],
        ),
      ),
    );
  }

  // Quick login - Chọn user từ danh sách
  Widget _buildQuickLoginSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Đăng nhập nhanh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Chọn user để demo (mỗi user có giỏ hàng khác nhau)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Users list
            if (_isLoadingUsers)
              const Center(child: CircularProgressIndicator())
            else if (_users.isEmpty)
              const Text(
                'Không thể kết nối đến server.\n'
                'Hãy chắc chắn đã chạy: npm start trong Demo_Backend',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              )
            else
              ..._users.map((user) => _buildUserTile(user)),
          ],
        ),
      ),
    );
  }

  // User tile cho quick login
  Widget _buildUserTile(Map<String, dynamic> user) {
    final isSelected = _selectedUserId == user['id'];

    return Card(
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar'] != null
              ? NetworkImage(user['avatar'])
              : null,
          child: user['avatar'] == null
              ? Text(user['name'][0].toUpperCase())
              : null,
        ),
        title: Text(user['name']),
        subtitle: Text(user['email']),
        trailing: _isLoggingIn && isSelected
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.login),
        onTap: _isLoggingIn ? null : () => _quickLogin(user),
      ),
    );
  }
}
