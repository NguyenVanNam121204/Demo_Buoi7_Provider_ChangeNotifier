const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();

// Cho phép CORS từ Flutter app
server.use(middlewares);
server.use(jsonServer.bodyParser);

// ============================================
// CUSTOM ROUTES - Authentication API
// ============================================

// POST /auth/login - Đăng nhập
// Body: { "email": "user1@test.com", "password": "123456" }
// Response: { "success": true, "user": {...} } hoặc { "success": false, "message": "..." }
server.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Lấy database
  const db = router.db;
  const users = db.get('users').value();
  
  // Tìm user theo email và password
  const user = users.find(u => u.email === email && u.password === password);
  
  if (user) {
    // Đăng nhập thành công - trả về user (không trả password)
    const { password: _, ...userWithoutPassword } = user;
    res.json({
      success: true,
      message: 'Đăng nhập thành công',
      user: userWithoutPassword
    });
  } else {
    // Đăng nhập thất bại
    res.status(401).json({
      success: false,
      message: 'Email hoặc mật khẩu không đúng'
    });
  }
});

// GET /auth/users - Lấy danh sách users (để chọn login nhanh khi demo)
server.get('/auth/users', (req, res) => {
  const db = router.db;
  const users = db.get('users').value();
  
  // Trả về users không có password
  const usersWithoutPassword = users.map(({ password, ...user }) => user);
  res.json(usersWithoutPassword);
});

// ============================================
// CUSTOM ROUTES - Cart API helpers
// ============================================

// GET /carts/user/:userId - Lấy giỏ hàng theo userId (cách viết rõ ràng hơn)
server.get('/carts/user/:userId', (req, res) => {
  const { userId } = req.params;
  const db = router.db;
  const carts = db.get('carts').filter({ userId }).value();
  
  // Tính tổng tiền
  const totalPrice = carts.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const totalQuantity = carts.reduce((sum, item) => sum + item.quantity, 0);
  
  res.json({
    userId,
    items: carts,
    totalPrice,
    totalQuantity,
    itemCount: carts.length
  });
});

// DELETE /carts/user/:userId - Xóa toàn bộ giỏ hàng của user
server.delete('/carts/user/:userId', (req, res) => {
  const { userId } = req.params;
  const db = router.db;
  
  // Xóa tất cả cart items của user
  db.get('carts').remove({ userId }).write();
  
  res.json({
    success: true,
    message: `Đã xóa giỏ hàng của ${userId}`
  });
});

// ============================================
// DEFAULT JSON-SERVER ROUTES
// ============================================
// Các routes mặc định của json-server vẫn hoạt động:
// GET    /users
// GET    /users/:id
// GET    /carts
// GET    /carts/:id
// GET    /carts?userId=user_1  (filter)
// POST   /carts
// PUT    /carts/:id
// PATCH  /carts/:id
// DELETE /carts/:id
// GET    /products
// GET    /products/:id

server.use(router);

// ============================================
// START SERVER
// ============================================
const PORT = 3000;
server.listen(PORT, () => {
  console.log(`JSON Server is running on http://localhost:${PORT}`);
});
