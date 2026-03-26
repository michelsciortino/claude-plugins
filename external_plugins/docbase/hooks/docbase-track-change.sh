#!/usr/bin/env bash
# DocBase PostToolUse hook
# Tracks doc files modified by Claude during a turn.
# Fires after every Edit or Write tool call.
# Input: JSON via stdin with tool_input.file_path and session_id

set -euo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit if we can't read required fields
[[ -z "$SESSION_ID" || -z "$FILE_PATH" ]] && exit 0

# Resolve project root: walk up from FILE_PATH looking for .docbase.json
PROJECT_ROOT=""
DIR="$FILE_PATH"
while [[ "$DIR" != "/" ]]; do
  DIR=$(dirname "$DIR")
  if [[ -f "$DIR/.docbase.json" ]]; then
    PROJECT_ROOT="$DIR"
    break
  fi
done

# No .docbase.json found — not a docbase project
[[ -z "$PROJECT_ROOT" ]] && exit 0

# Read doc_root from config
DOC_ROOT=$(jq -r '.doc_root' "$PROJECT_ROOT/.docbase.json")
DOC_ROOT_ABS="$PROJECT_ROOT/$DOC_ROOT"

# Check the file is under doc_root
case "$FILE_PATH" in
  "$DOC_ROOT_ABS"*) ;;
  *) exit 0 ;;
esac

# Check the file has DocBase frontmatter (starts with --- and contains a docbase key)
if [[ -f "$FILE_PATH" ]]; then
  HEAD=$(head -20 "$FILE_PATH")
  if ! echo "$HEAD" | grep -q "^---"; then
    exit 0
  fi
  if ! echo "$HEAD" | grep -qE "^(related|implementation|layer|status):"; then
    exit 0
  fi
fi

# Append to session turn file
TURN_FILE="/tmp/docbase_${SESSION_ID}_turn.txt"
echo "$FILE_PATH" >> "$TURN_FILE"

exit 0
