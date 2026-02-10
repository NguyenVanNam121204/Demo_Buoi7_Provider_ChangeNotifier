# 🛒 Demo Shopping Cart - Provider & ChangeNotifier

> Dự án demo ứng dụng giỏ hàng sử dụng **Provider** và **ChangeNotifier** để quản lý State trong Flutter, kết hợp với Backend API.

---

## 📋 Mục Đích

Dự án này được xây dựng để **demo và học tập** các khái niệm:

- **Provider Pattern** - Quản lý state toàn cục
- **ChangeNotifier** - Class cơ sở để notify listeners khi state thay đổi
- **Consumer** - Widget rebuild toàn bộ khi `notifyListeners()` được gọi
- **Selector** - Widget chỉ rebuild khi giá trị được chọn thay đổi (tối ưu performance)
- **ProxyProvider** - Kết hợp nhiều Provider phụ thuộc lẫn nhau
- **Dart Mixins** - Tái sử dụng code với `PriceFormatterMixin` và `ValidationMixin`
- **SharedPreferences** - Lưu trữ dữ liệu persistent

---

## 📁 Cấu Trúc Dự Án

```
DemoBuoi7_Provider_ChangeNotifier/
├── README.md                     # File này
├── Demo_Backend/                 # Backend API (Node.js)
│   ├── package.json
│   ├── db.json                   # Database (JSON)
│   └── server.js
└── Demo_Shopping_Cart/           # Flutter App
    └── lib/
        ├── main.dart
        ├── app.dart
        ├── core/                 # Constants, Mixins
        ├── data/                 # DataSources, Models, Repositories
        ├── domain/               # Entities
        └── presentation/         # Providers, Screens, Widgets
```

---

## 🚀 Cách Chạy

### 1. Chạy Backend

```bash
cd Demo_Backend

# Cài dependencies
npm install

# Chạy server
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

### 2. Chạy Flutter App

```bash
cd Demo_Shopping_Cart

# Cài dependencies
flutter pub get

# Chạy ứng dụng
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run              # Device mặc định
```

---

## 📌 Backend APIs

### Authentication

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/auth/login` | Đăng nhập |
| GET | `/auth/users` | Lấy danh sách users |

**Login request:**
```json
POST /auth/login
{
  "email": "user1@test.com",
  "password": "123456"
}
```

### Cart APIs

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/carts?userId=xxx` | Lấy giỏ hàng của user |
| GET | `/carts/user/:userId` | Lấy giỏ hàng (chi tiết) |
| POST | `/carts` | Thêm item vào giỏ |
| PUT | `/carts/:id` | Cập nhật số lượng |
| DELETE | `/carts/:id` | Xóa item khỏi giỏ |

### Products & Users

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/products` | Lấy tất cả sản phẩm |
| GET | `/users` | Lấy tất cả users |

---

## 🔐 Test Accounts

| Email | Password | Giỏ hàng |
|-------|----------|----------|
| user1@test.com | 123456 | 2 items (MacBook, iPhone x2) |
| user2@test.com | 123456 | 3 items (iPad, Apple Watch, AirPods x3) |
| user3@test.com | 123456 | Trống |

---

## ⚡ Consumer vs Selector

### Consumer
```dart
Consumer<CartProvider>(
  builder: (context, cart, child) {
    // Rebuild MỖI KHI notifyListeners() được gọi
    return Badge(count: cart.totalQuantity);
  },
)
```

### Selector
```dart
Selector<CartProvider, double>(
  selector: (context, cart) => cart.totalPrice,
  builder: (context, totalPrice, child) {
    // CHỈ rebuild khi totalPrice thay đổi
    return Text('Total: $totalPrice');
  },
)
```

| Tiêu chí | Consumer | Selector |
|----------|----------|----------|
| Khi nào rebuild? | Mỗi khi `notifyListeners()` | Chỉ khi giá trị selected thay đổi |
| Performance | Thấp hơn | Cao hơn |
| Use case | Cần toàn bộ state | Chỉ cần một phần state |

---

## 🔄 Luồng Demo ProxyProvider

```
1. App khởi động
   └── AuthProvider: userId = null
   └── CartProvider: items = [] (trống)

2. User đăng nhập (POST /auth/login)
   └── AuthProvider.login("user_1") → notifyListeners()

3. ProxyProvider phát hiện AuthProvider thay đổi
   └── Tự động gọi update()

4. CartProvider được tạo mới với userId
   └── Gọi GET /carts/user/user_1
   └── Load items từ server

5. User đăng xuất
   └── AuthProvider.logout() → userId = null
   └── CartProvider reset về trống
```

---

## 🎯 Tính Năng Demo

- ✅ Thêm/Xóa sản phẩm vào giỏ hàng
- ✅ Tăng/Giảm số lượng sản phẩm
- ✅ Hiển thị tổng số lượng (Consumer)
- ✅ Hiển thị tổng tiền (Selector)
- ✅ Lưu giỏ hàng vào SharedPreferences
- ✅ Demo sự khác biệt rebuild giữa Consumer và Selector

---

## 📦 Dependencies

### Flutter App
| Package | Mục đích |
|---------|----------|
| `provider` | State management |
| `shared_preferences` | Lưu trữ local storage |
| `google_fonts` | Font hỗ trợ tiếng Việt |

### Backend
| Package | Mục đích |
|---------|----------|
| `json-server` | REST API server |
| `express` | Web framework |

---

## 📚 Tài Liệu Tham Khảo

| Ref | Tên Tài Liệu | Nguồn |
|-----|--------------|-------|
| [1] | Simple app state management | https://docs.flutter.dev/data-and-backend/state-mgmt/simple |
| [2] | Provider Package Documentation | https://pub.dev/packages/provider |
| [3] | SharedPreferences Package | https://pub.dev/packages/shared_preferences |
| [4] | Flutter State Management Overview | https://docs.flutter.dev/data-and-backend/state-mgmt/options |

---

## 👨‍💻 Tác Giả

Nhóm 5 - Demo project để học tập Flutter State Management với Provider.

---

## 📄 License

MIT License - Sử dụng tự do cho mục đích học tập.
