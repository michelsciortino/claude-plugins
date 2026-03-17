# Claude Code Plugins - michelsciortino's Marketplace

A personal marketplace of plugins for Claude Code.

> **⚠️ Important:** Make sure you trust a plugin before installing, updating, or using it. This is not an official Anthropic marketplace.

## Installation

To install a plugin from this marketplace, run:

```
/plugin install {plugin-name}@michelsciortino-marketplace
```

Or browse for plugins in `/plugin > Discover`.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| _(more coming soon)_ | |

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
