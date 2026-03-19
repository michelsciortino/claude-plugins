# Dart LSP — Integration Reference

## Starting the server

```bash
# Primary: use dart-lsp plugin if available in the Claude Code session
# Fallback: start manually
dart language-server --client-id claude --client-version 1.0
```

## Protocol
JSON-RPC 2.0 over stdio. Each message uses LSP framing:
```
Content-Length: <bytes>\r\n\r\n<json-body>
```

## Key requests used by Flutter skills

### Find all subclasses of a type (e.g. StatelessWidget)
1. `textDocument/prepareTypeHierarchy` — position cursor on the base class
2. `typeHierarchy/subtypes` — returns direct and transitive subtypes
3. Filter results by file path to scope to a directory

### Find all usages of a symbol
```json
{
  "method": "textDocument/references",
  "params": {
    "textDocument": { "uri": "file:///path/to/file.dart" },
    "position": { "line": 5, "character": 10 },
    "context": { "includeDeclaration": false }
  }
}
```

### Search symbol by name across workspace
```json
{
  "method": "workspace/symbol",
  "params": { "query": "ProductRepository" }
}
```

### Detect layer membership of a type
Use `textDocument/typeDefinition` to navigate to a type's declaration file, then check its file path against the layer map:
- Path starts with `lib/ui/` → UI layer
- Path starts with `lib/data/` → Data layer
- Path starts with `lib/domain/` → Domain layer

## Layer violation detection
To verify no UI imports exist inside a Domain file:
1. Call `workspace/symbol` with the names of known UI classes/ViewModels
2. Call `textDocument/references` on each — any reference inside `lib/domain/` is a violation
3. Flag and refuse to proceed until the violation is resolved
