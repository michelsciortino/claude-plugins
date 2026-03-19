---
name: flutter-feature-generator
description: Use when creating a new feature or module (e.g., feature folder or Dart package) in a Flutter project
---

# Flutter Feature Generator

## Pre-generation checklist (always run first)
1. Use LSP `workspace/symbol` with the feature name to verify it does not already exist
2. Check `CLAUDE.md` to confirm: state management variant (Riverpod / BLoC) and whether Domain layer is active
3. If Domain layer is active, also generate Entity and UseCase files

## Generation order
Always generate Data layer first, then Domain (if needed), then UI last. This ensures the ViewModel can import the correct interfaces.

1. **Data layer** — Repository interface + implementation + Service/DataSource
2. **Domain layer** *(if active)* — Entity + UseCase
3. **UI layer** — ViewModel (Notifier / Cubit) + View widget

## Folder scaffold

```
lib/
├── ui/<feature>/
│   ├── view_models/
│   │   └── <feature>_view_model.dart    (AsyncNotifier or Cubit)
│   └── widgets/
│       └── <feature>_view.dart          (main View widget)
├── data/
│   ├── repositories/
│   │   ├── <entity>_repository.dart     (interface)
│   │   └── <entity>_repository_impl.dart
│   └── services/
│       └── <entity>_api_service.dart
└── domain/                              (only if Domain layer is active)
    ├── models/
    │   └── <entity>.dart
    └── use_cases/
        └── get_<entity>_use_case.dart
```

## Code templates
See `templates.md` for exact Dart code templates for each file type.

## Post-generation
After creating all files, run LSP `textDocument/references` on the new Repository interface to confirm it is correctly imported by the ViewModel (not the implementation class).
