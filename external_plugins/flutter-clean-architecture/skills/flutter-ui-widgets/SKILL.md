---
name: flutter-ui-widgets
description: Use when adding, modifying, or reviewing any Flutter UI widget or screen
---

# Flutter UI Widgets

## Two-phase protocol — always execute both phases

### Phase 1: Before writing any widget code

1. Use LSP to find existing widgets similar to what you are about to create:
   - Call `textDocument/prepareTypeHierarchy` on `StatelessWidget`, then `typeHierarchy/subtypes`
   - Filter results to `lib/ui/core/widgets/` and `lib/ui/<current_feature>/widgets/`
2. Compare names, constructor parameters, and layout structure to your planned widget
3. Decision tree:
   - Same structure, same purpose → **reuse existing**
   - Similar structure, slightly different → **extend or parameterize existing**
   - Different enough → **create new**, document why

### Phase 2: After writing widget code

1. For each widget you created or modified, call LSP `textDocument/references` to count usages
2. If a widget appears in **2 or more features** with similar constructor signatures:
   - Propose extraction to `lib/ui/core/widgets/`
   - Suggest a name and constructor interface
   - **Wait for user approval before moving any files**
3. If a widget is used only in one feature: leave it in `lib/ui/<feature>/widgets/`

## Extraction location rule
| Usage | Location |
|-------|---------|
| 1 feature only | `lib/ui/<feature_name>/widgets/` |
| 2+ features | `lib/ui/core/widgets/` |

## Widget naming
- Screen-level widgets: `<Feature>View` (e.g., `ProductDetailView`)
- Reusable UI components: descriptive noun (e.g., `PriceTag`, `AvatarBadge`, `LoadingOverlay`)
- Never: `ProductWidget`, `MyCard`, `CustomButton` (too generic)

## Cross-session note
Widget reuse tracking is scoped to the current session. If you recognize a pattern from a previous session, flag it explicitly to trigger extraction.
