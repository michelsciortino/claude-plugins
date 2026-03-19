---
name: flutter-arch-riverpod
description: Use when a Flutter project uses Riverpod for state management
---

# Flutter Architecture — Riverpod Variant

## ViewModel = AsyncNotifier
In Riverpod, the ViewModel is an `AsyncNotifier` (or `Notifier` for sync state). It lives in `lib/ui/<feature>/view_models/`.

```dart
// lib/ui/home/view_models/home_view_model.dart
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<List<Product>> build() async {
    return ref.watch(productRepositoryProvider).getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).getProducts(),
    );
  }
}
```

## Repository exposure via Provider
Repositories are exposed through Providers in the Data layer. ViewModels consume them via `ref.watch` / `ref.read`.

```dart
// lib/data/repositories/product_repository_provider.dart
@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepositoryImpl(ref.watch(apiServiceProvider));
}
```

## Layer placement
- `@riverpod` Providers for Repositories → `lib/data/repositories/`
- `@riverpod` Providers for Services → `lib/data/services/`
- `@riverpod` Notifiers (ViewModels) → `lib/ui/<feature>/view_models/`
- Domain UseCases (if present) → instantiated inside Notifier `build()`

## Before creating a new Provider
Use LSP `workspace/symbol` with the Repository or Service name to check if a Provider already exists. Validate:
- No duplicate provider for the same Repository
- Provider is in `lib/data/` (not in `lib/ui/`)
- ViewModel Notifier is in `lib/ui/<feature>/view_models/` (not in Data layer)
Duplicate providers cause runtime errors.

## Testing
```dart
// Override providers in tests
final container = ProviderContainer(overrides: [
  productRepositoryProvider.overrideWithValue(MockProductRepository()),
]);
```
