import '../constants/app_constants.dart';

// DART MIXIN - ValidationMixin
//
// Mixin chứa các logic validate dữ liệu
// Có thể được sử dụng bởi nhiều class khác nhau

mixin ValidationMixin {
  // Kiểm tra số lượng có hợp lệ không
  bool isValidQuantity(int quantity) {
    return quantity >= AppConstants.minQuantityPerItem &&
        quantity <= AppConstants.maxQuantityPerItem;
  }
}
