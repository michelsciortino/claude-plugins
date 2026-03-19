# Flutter Architecture — Anti-Pattern Blacklist

Read this file BEFORE writing any code and when reviewing existing code.

## Layer Violations

### ❌ Business logic in Widgets
```dart
// FORBIDDEN
class ProductCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final discountedPrice = price * (1 - discount); // logic in widget
    return Text('$discountedPrice');
  }
}
```
```dart
// CORRECT — logic in ViewModel
class ProductCard extends StatelessWidget {
  Widget build(BuildContext context) {
    return Text('${viewModel.formattedPrice}');
  }
}
```

### ❌ Direct service calls from Widgets
```dart
// FORBIDDEN
class HomeView extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiService().fetchProducts(), // widget calling service directly
    );
  }
}
```

### ❌ Flutter imports in Domain layer
```dart
// FORBIDDEN in lib/domain/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### ❌ ViewModel importing from Data layer directly
```dart
// FORBIDDEN — ViewModel must use Repository interface, not implementation
import 'package:myapp/data/repositories/user_repository_impl.dart';
```
```dart
// CORRECT — depend on interface
import 'package:myapp/domain/models/user_repository.dart';
```

### ❌ Reversed dependencies
```dart
// FORBIDDEN in lib/data/
import 'package:myapp/ui/home/view_models/home_view_model.dart';
```

---

## Structure Violations

### ❌ Feature code outside its feature folder
```
// FORBIDDEN
lib/ui/widgets/product_card.dart  ← if only used in 'product' feature
```
```
// CORRECT
lib/ui/product/widgets/product_card.dart
lib/ui/core/widgets/product_card.dart  ← only if used in 2+ features
```

### ❌ Shared widget not extracted
If the same widget structure appears in 2+ features with similar constructor signatures, it MUST be extracted to `lib/ui/core/widgets/`.

### ❌ Skipping Repository interface
```dart
// FORBIDDEN — using implementation directly
class HomeViewModel {
  final UserRepositoryImpl _repo; // impl, not interface
}
```
```dart
// CORRECT
class HomeViewModel {
  final UserRepository _repo; // interface from domain or data
}
```

---

## Naming Violations

- ❌ `ProductWidget` → ✅ `ProductView` or `ProductCard`
- ❌ `ProductController` → ✅ `ProductViewModel`
- ❌ `ProductBloc` outside `view_models/` folder
- ❌ `UserRepoImpl` → ✅ `UserRepositoryImpl`
- ❌ `DISCOUNT_RATE` (constant) → ✅ `discountRate`
