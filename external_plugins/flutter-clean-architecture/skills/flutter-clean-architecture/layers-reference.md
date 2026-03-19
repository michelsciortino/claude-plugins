# Flutter Architecture — Layer Reference

## Official Source
https://docs.flutter.dev/app-architecture/guide

## Layer Definitions

### UI Layer
**Folder:** `lib/ui/`
**Components:** Widgets (Views) + ViewModels
**Responsibilities:**
- Widgets: display data, handle user input, delegate events to ViewModel
- ViewModels: maintain UI state, expose commands, convert repository data into displayable format
- One ViewModel per View (1:1 relationship)

**Never in UI layer:**
- Direct repository calls from Widgets
- Business logic in Widgets
- Network requests

### Data Layer
**Folder:** `lib/data/`
**Components:** Repositories, Services (remote API, local storage, device sensors)
**Responsibilities:**
- Repositories: single source of truth, caching strategy, error normalization
- Services: raw data access (HTTP, SQLite, SharedPreferences, device APIs)
- Data models (DTOs) for serialization/deserialization

**Never in Data layer:**
- Flutter UI imports
- Knowledge of ViewModel state
- Business logic that belongs in Domain

### Domain Layer *(optional)*
**Folder:** `lib/domain/`
**Components:** Entities, Use Cases
**Responsibilities:**
- Entities: pure Dart business objects (no Flutter, no data annotations)
- Use Cases: encapsulate logic shared across 2+ ViewModels OR too complex for a single ViewModel

**Add Domain layer only when:**
- Business logic would be duplicated across multiple ViewModels
- A UseCase needs independent unit testing
- Logic is not a simple data transformation

**Never in Domain layer:**
- Flutter imports (`import 'package:flutter/...'`)
- Data annotations (`@JsonSerializable`, etc.)
- Repository implementations

---

## Folder Structure (Google Hybrid)

```
lib/
├── ui/                          ← UI layer, organized by feature
│   ├── core/                    ← shared across features
│   │   └── widgets/             ← reusable shared widgets
│   └── <feature_name>/
│       ├── view_models/         ← ViewModels for this feature
│       └── widgets/             ← widgets local to this feature
├── domain/                      ← Domain layer (optional), by type
│   ├── models/                  ← Entities (pure Dart)
│   └── use_cases/               ← Use Cases
└── data/                        ← Data layer, by type
    ├── repositories/            ← Repository interfaces + implementations
    ├── services/                ← Remote API, local storage, device
    └── models/                  ← DTOs / data transfer objects
```

---

## Dependency Rules (Enforced via LSP)

| From | May depend on | May NOT depend on |
|------|--------------|-------------------|
| UI Layer | Domain, Data | — |
| Domain Layer | nothing (pure Dart) | UI, Data |
| Data Layer | Domain (for interfaces) | UI |

**Checking with LSP:**
1. Open a file in `lib/domain/`
2. Call `workspace/symbol` to find its imports
3. Any import from `lib/ui/` or `lib/data/` is a violation

---

## LSP Quick Reference

| Goal | LSP method | Notes |
|------|-----------|-------|
| Find all widget subclasses | `textDocument/prepareTypeHierarchy` → `typeHierarchy/subtypes` | Position cursor on `StatelessWidget` or `StatefulWidget` |
| Find all usages of a class | `textDocument/references` | Used for widget extraction threshold |
| Find existing symbol by name | `workspace/symbol` | Use before creating a new Repository or ViewModel |
| Check layer of a type | `textDocument/typeDefinition` | Verify which layer a class belongs to |

**Starting the language server:**
```bash
dart language-server --client-id claude --client-version 1.0
```
Protocol: JSON-RPC 2.0 over stdio.
