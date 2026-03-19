# flutter-clean-architecture

Flutter Clean Architecture skill system for Claude Code, enforcing Google's official 3-layer architecture guidelines across all your Flutter projects.

## What it does

Installs 5 Claude Code skills that act as automatic guardrails during Flutter development:

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `flutter-clean-architecture` | Any Flutter project work | Master guardrail: layers, invariants, naming rules, anti-patterns |
| `flutter-arch-riverpod` | Riverpod projects | AsyncNotifier patterns, Provider placement, test conventions |
| `flutter-arch-bloc` | BLoC/Cubit projects | Cubit/BLoC patterns, state class organization, test conventions |
| `flutter-feature-generator` | Creating new features | Full scaffold with code templates: Data → Domain → UI |
| `flutter-ui-widgets` | Adding/modifying UI | Two-phase widget reusability check using Dart LSP |

## Architecture

Follows [Google's official Flutter architecture](https://docs.flutter.dev/app-architecture/guide):

```
lib/
├── ui/                    ← UI layer (Widgets + ViewModels), by feature
│   ├── core/widgets/      ← shared reusable widgets
│   └── <feature>/
│       ├── view_models/
│       └── widgets/
├── domain/                ← Domain layer (optional), by type
│   ├── models/
│   └── use_cases/
└── data/                  ← Data layer, by type
    ├── repositories/
    ├── services/
    └── models/
```

## Installation

```
/plugin install flutter-clean-architecture@michelsciortino-marketplace
```

## Per-project setup

Add a `CLAUDE.md` file to the root of each Flutter project:

```markdown
## Architecture
This project follows Google's official Flutter architecture.
State management: Riverpod
Domain layer: yes

Skills: flutter-clean-architecture, flutter-arch-riverpod
```

## How it works

Skills are auto-triggered by Claude based on their descriptions — no manual invocation needed. Claude reads your project's `CLAUDE.md` to detect the state management variant and whether the Domain layer is active.

## LSP integration

The skills use the Dart LSP server for semantic code queries (finding widget subclasses, detecting layer violations, checking for duplicate symbols). The `dart-lsp` plugin from this same marketplace is recommended alongside this plugin.

## Requirements

- Flutter SDK installed
- Dart SDK (included with Flutter)
- `dart-lsp` plugin recommended for full LSP support
