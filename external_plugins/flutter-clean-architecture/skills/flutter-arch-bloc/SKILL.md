---
name: flutter-arch-bloc
description: Use when a Flutter project uses BLoC or Cubit for state management
---

# Flutter Architecture — BLoC Variant

## ViewModel = Cubit or BLoC
In BLoC, the ViewModel is a `Cubit` (simple) or `BLoC` (event-driven). It lives in `lib/ui/<feature>/view_models/`.

**Choose Cubit when:** state changes are triggered by simple method calls.
**Choose BLoC when:** complex event-to-state mappings, state history, or event transformations are needed.

```dart
// lib/ui/home/view_models/home_cubit.dart  (Cubit variant)
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._productRepository) : super(HomeInitial());

  final ProductRepository _productRepository;

  Future<void> loadProducts() async {
    emit(HomeLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(HomeLoaded(products));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
```

## State classes
Define sealed state classes in the same file as the Cubit/BLoC or in a separate `<feature>_state.dart` file in the same `view_models/` folder.

```dart
sealed class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState { final List<Product> products; ... }
class HomeError extends HomeState { final String message; ... }
```

## Dependency injection
Inject Repository interfaces (never implementations) into Cubit/BLoC constructors. Provide via `BlocProvider` in the widget tree or your DI container.

## Layer placement
- Cubits/BLoCs (ViewModels) → `lib/ui/<feature>/view_models/`
- State classes → `lib/ui/<feature>/view_models/`
- Repository interfaces → `lib/domain/models/` or `lib/data/repositories/`

## Before creating a new Cubit/BLoC
Use LSP `workspace/symbol` with the feature name to check if a Cubit/BLoC already exists. Validate:
- No duplicate BLoC/Cubit for the same feature
- BLoC/Cubit file is in `lib/ui/<feature>/view_models/` (not in Data or Domain layer)
- Repository injected as interface (not implementation)

## Testing
```dart
blocTest<HomeCubit, HomeState>(
  'emits [HomeLoading, HomeLoaded] when loadProducts succeeds',
  build: () => HomeCubit(MockProductRepository()),
  act: (cubit) => cubit.loadProducts(),
  expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
);
```
