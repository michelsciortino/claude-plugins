# DocBase

Documentation-driven development system for Claude Code. Enforces docs as the sole source of truth, with automatic cross-reference integrity checking and doc↔code consistency enforcement.

## Concept

Every piece of code must have a corresponding documentation file. Documentation describes intent, API contracts, field names, and behaviors. When docs and code diverge, Claude detects it automatically and surfaces issues without blocking your workflow.

## Frontmatter Conventions

DocBase identifies managed docs by their YAML frontmatter:

```yaml
---
layer: services          # logical layer (api, services, data, etc.)
status: stable           # draft | stable | deprecated
implementation:          # source files this doc describes
  - backend/src/services/meals.ts
related:                 # cross-references to other doc files
  - docs/api/meals.md
updated: 2026-03-26
---
```

## How It Works

Three pipelines run automatically:

| Pipeline | Trigger | What it checks |
|---|---|---|
| **Doc integrity** | Every time Claude stops | Cross-references between docs (broken links, semantic conflicts) |
| **Code→doc** | `git commit` | Committed source files have corresponding documentation |
| **Full sweep** | `/docbase:check-consistency` | Both directions, entire project |

Issues are written to `.issues/` as markdown files, gitignored, and auto-closed when the conflict is resolved.

## Installation

### 1. Install the plugin

```sh
/plugin install docbase@michelsciortino-marketplace
```

### 2. Install global hooks

Copy the two Claude Code hooks and register them in `~/.claude/settings.json`:

```sh
cp ~/.claude/plugins/cache/docbase/hooks/docbase-track-change.sh ~/.claude/hooks/
cp ~/.claude/plugins/cache/docbase/hooks/docbase-stop.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/docbase-track-change.sh ~/.claude/hooks/docbase-stop.sh
```

Add to `~/.claude/settings.json` under `"hooks"`:

```json
"PostToolUse": [
  {
    "matcher": "Edit|Write",
    "hooks": [{ "type": "command", "command": "~/.claude/hooks/docbase-track-change.sh", "timeout": 10 }]
  }
],
"Stop": [
  {
    "matcher": "",
    "hooks": [{ "type": "command", "command": "~/.claude/hooks/docbase-stop.sh", "timeout": 120 }]
  }
]
```

### 3. Initialize a project

In your project root:

```
/docbase:init
```

This creates `.docbase.json`, updates `.gitignore`, and installs the git post-commit hook.

## Slash Commands

| Command | Description |
|---|---|
| `/docbase:init` | Initialize a project for DocBase |
| `/docbase:check-consistency` | Full doc↔code sweep |
| `/docbase:issues` | List and manage open issues |
| `/docbase:implement` | Implement docs that have no code yet |

## Requirements

- `jq` (`brew install jq`)
- `claude` CLI (Claude Code)
