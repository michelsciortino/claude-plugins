# Claude Code Plugins - michelsciortino's Marketplace

A personal marketplace of plugins for Claude Code.

> **⚠️ Important:** Make sure you trust a plugin before installing, updating, or using it. This is not an official Anthropic marketplace.

## Installation

### 1. Add this marketplace

```
/plugin marketplace add https://github.com/michelsciortino/claude-plugins
```

### 2. Install a plugin

```
/plugin install {plugin-name}@michelsciortino-marketplace
```

Or browse for plugins in `/plugin > Discover`.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [`dart-lsp`](external_plugins/dart-lsp/README.md) | Dart/Flutter language server — go-to-definition, find references, hover info, and error checking for `.dart` files |
| [`docbase`](external_plugins/docbase/README.md) | Documentation-driven development system that enforces docs as the sole source of truth, with automatic cross-reference integrity checking and doc↔code consistency enforcement |
| [`flutter-clean-architecture`](external_plugins/flutter-clean-architecture/README.md) | Flutter Clean Architecture skill system — enforces Google's 3-layer architecture, naming conventions, anti-patterns, and UI widget reusability |

## Plugin Structure

Each plugin follows a standard layout:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata (required)
├── .mcp.json            # MCP server configuration (optional)
├── commands/            # Slash commands (optional)
├── agents/              # Agent definitions (optional)
├── skills/              # Skill definitions (optional)
└── README.md            # Documentation
```

## Contributing

This is a personal marketplace. External contributions are not accepted at this time.

## License

[MIT](LICENSE)

## Documentation

For more information on developing Claude Code plugins, see the [official documentation](https://code.claude.com/docs/en/plugins).
