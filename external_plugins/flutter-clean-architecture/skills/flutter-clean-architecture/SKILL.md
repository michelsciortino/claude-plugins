---
name: flutter-clean-architecture
description: Use when designing, planning, reviewing, or implementing any feature, screen, or component in a Flutter project
---

# Flutter Clean Architecture

## Overview
Google's 3-layer architecture for Flutter. Separation of concerns — layer boundaries are non-negotiable.

## Layers
- **UI**: Widgets + ViewModels. User interaction and UI state.
- **Data**: Repositories + Services. API, caching, single source of truth.
- **Domain** *(optional)*: Entities + Use Cases. Shared business logic only.

## Dependency direction
`UI → Domain (optional) → Data` — never reversed. Data has no knowledge of UI.

## Invariants
- No business logic in Widgets — use ViewModels
- ViewModels: `lib/ui/<feature>/view_models/`
- Shared widgets: `lib/ui/core/widgets/`
- Domain: pure Dart, no Flutter imports

## Key references
- `layers-reference.md`, `naming-conventions.md`, `anti-patterns.md`, `lsp-usage.md`

## Sub-skills
- `flutter-arch-riverpod` (Riverpod), `flutter-arch-bloc` (BLoC)
- `flutter-feature-generator` (new features), `flutter-ui-widgets` (UI)

## LSP first
Use Dart LSP for all semantic queries. Never scan manually when LSP can answer.
