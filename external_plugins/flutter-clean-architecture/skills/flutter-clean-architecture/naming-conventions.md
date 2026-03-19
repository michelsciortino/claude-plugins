# Flutter Naming Conventions

## Official Source
https://docs.flutter.dev/app-architecture/guide (Google examples)

## Class Naming

| Type | Convention | Example |
|------|-----------|---------|
| View (Widget) | `<Feature>View` | `LoginView`, `HomeView` |
| ViewModel | `<Feature>ViewModel` | `LoginViewModel`, `HomeViewModel` |
| Repository (interface) | `<Entity>Repository` | `UserRepository`, `BookingRepository` |
| Repository (impl) | `<Entity>RepositoryImpl` | `UserRepositoryImpl` |
| Service | `<Purpose>Service` | `AuthApiService`, `LocalStorageService` |
| Entity | singular noun | `User`, `Booking`, `Product` |
| DTO | `<Entity>Dto` | `UserDto`, `BookingDto` |
| Use Case | `<Verb><Entity>UseCase` | `GetUserUseCase`, `SubmitOrderUseCase` |

## File Naming (snake_case)

| Type | Convention | Example |
|------|-----------|---------|
| View file | `<feature>_view.dart` | `login_view.dart` |
| ViewModel file | `<feature>_view_model.dart` | `login_view_model.dart` |
| Repository interface | `<entity>_repository.dart` | `user_repository.dart` |
| Repository impl | `<entity>_repository_impl.dart` | `user_repository_impl.dart` |
| Service | `<purpose>_service.dart` | `auth_api_service.dart` |
| Entity | `<entity>.dart` | `user.dart` |
| DTO | `<entity>_dto.dart` | `user_dto.dart` |
| Use Case | `<verb>_<entity>_use_case.dart` | `get_user_use_case.dart` |

## Variable and Method Naming (camelCase)

- ViewModel methods exposed to Views: use imperative verbs → `login()`, `logout()`, `fetchUser()`
- Repository methods: use CRUD verbs → `getUser()`, `saveBooking()`, `deleteProduct()`
- State fields in ViewModel: use descriptive nouns → `isLoading`, `errorMessage`, `currentUser`
- Private fields: prefix with underscore → `_repository`, `_authService`

## Dart-Specific Conventions
- Constants: `lowerCamelCase` (not SCREAMING_SNAKE)
- Enums: `PascalCase` for type, `camelCase` for values
- Extensions: `<Type>Extension` → `StringExtension`, `DateTimeExtension`
