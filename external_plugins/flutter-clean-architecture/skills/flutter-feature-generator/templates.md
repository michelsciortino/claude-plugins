# Feature Code Templates

## Repository Interface

```dart
// lib/data/repositories/<entity>_repository.dart
abstract interface class <Entity>Repository {
  Future<List<<Entity>>> getAll();
  Future<<Entity>> getById(String id);
  Future<void> save(<Entity> entity);
  Future<void> delete(String id);
}
```

## Repository Implementation

```dart
// lib/data/repositories/<entity>_repository_impl.dart
class <Entity>RepositoryImpl implements <Entity>Repository {
  <Entity>RepositoryImpl(this._apiService);

  final <Entity>ApiService _apiService;

  @override
  Future<List<<Entity>>> getAll() async {
    final dtos = await _apiService.fetchAll();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  // implement remaining methods...
}
```

## API Service

```dart
// lib/data/services/<entity>_api_service.dart
class <Entity>ApiService {
  <Entity>ApiService(this._httpClient);

  final http.Client _httpClient;

  Future<List<<Entity>Dto>> fetchAll() async {
    final response = await _httpClient.get(Uri.parse('/api/<entities>'));
    if (response.statusCode != 200) throw Exception('Failed to fetch');
    final list = jsonDecode(response.body) as List;
    return list.map((json) => <Entity>Dto.fromJson(json)).toList();
  }
}
```

## Entity (Domain layer)

```dart
// lib/domain/models/<entity>.dart
class <Entity> {
  const <Entity>({
    required this.id,
    required this.name,
    // add fields...
  });

  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is <Entity> && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
```

## UseCase (Domain layer, optional)

```dart
// lib/domain/use_cases/get_<entity>_use_case.dart
class Get<Entity>UseCase {
  Get<Entity>UseCase(this._repository);

  final <Entity>Repository _repository;

  Future<List<<Entity>>> execute() => _repository.getAll();
}
```

## ViewModel — Riverpod (AsyncNotifier)

```dart
// lib/ui/<feature>/view_models/<feature>_view_model.dart
@riverpod
class <Feature>ViewModel extends _$<Feature>ViewModel {
  @override
  Future<List<<Entity>>> build() async {
    return ref.watch(<entity>RepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(<entity>RepositoryProvider).getAll(),
    );
  }
}
```

## ViewModel — BLoC (Cubit variant)

```dart
// lib/ui/<feature>/view_models/<feature>_cubit.dart
class <Feature>Cubit extends Cubit<<Feature>State> {
  <Feature>Cubit(this._repository) : super(<Feature>Initial());

  final <Entity>Repository _repository;

  Future<void> load() async {
    emit(<Feature>Loading());
    try {
      final items = await _repository.getAll();
      emit(<Feature>Loaded(items));
    } catch (e) {
      emit(<Feature>Error(e.toString()));
    }
  }
}

sealed class <Feature>State {}
class <Feature>Initial extends <Feature>State {}
class <Feature>Loading extends <Feature>State {}
class <Feature>Loaded extends <Feature>State {
  <Feature>Loaded(this.items);
  final List<<Entity>> items;
}
class <Feature>Error extends <Feature>State {
  <Feature>Error(this.message);
  final String message;
}
```

## View Widget

```dart
// lib/ui/<feature>/widgets/<feature>_view.dart
class <Feature>View extends StatelessWidget {
  const <Feature>View({super.key});

  @override
  Widget build(BuildContext context) {
    // Riverpod: use ref.watch(<feature>ViewModelProvider)
    // BLoC: use BlocBuilder<<Feature>Cubit, <Feature>State>
    return Scaffold(
      appBar: AppBar(title: const Text('<Feature>')),
      body: const <Feature>Body(),
    );
  }
}
```
