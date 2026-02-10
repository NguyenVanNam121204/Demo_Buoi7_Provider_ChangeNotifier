// DART MIXIN - PriceFormatterMixin
//
// Mixin là một cách để tái sử dụng code trong nhiều class khác nhau.
// Sử dụng từ khóa 'with' để thêm mixin vào class.
//
// Ưu điểm của Mixin:
// 1. Tái sử dụng code mà không cần kế thừa
// 2. Một class có thể sử dụng nhiều mixin
// 3. Tách biệt logic, dễ maintain
//
// Cú pháp: class MyClass with Mixin.....
mixin PriceFormatterMixin {
  // Format số tiền thành chuỗi có dấu phân cách hàng nghìn
  // Ví dụ: 1000000 -> "1.000.000 VNĐ"
  String formatPrice(double price) {
    // Làm tròn và chuyển thành int
    final intPrice = price.round();

    // Chuyển thành chuỗi và thêm dấu chấm phân cách
    final priceString = intPrice.toString();
    final buffer = StringBuffer();

    int count = 0;
    for (int i = priceString.length - 1; i >= 0; i--) {
      buffer.write(priceString[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString().split('').reversed.join()} VNĐ';
  }
}
