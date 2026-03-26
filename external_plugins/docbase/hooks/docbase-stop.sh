#!/usr/bin/env bash
# DocBase Stop hook
# Runs the doc integrity sub-agent when doc files were modified this turn.
# Manages the session conflict chain.
# Input: JSON via stdin with session_id, cwd, stop_hook_active

set -euo pipefail

INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

[[ -z "$SESSION_ID" || -z "$CWD" ]] && exit 0

# Check for .docbase.json
[[ ! -f "$CWD/.docbase.json" ]] && exit 0

TURN_FILE="/tmp/docbase_${SESSION_ID}_turn.txt"
CHAIN_FILE="/tmp/docbase_${SESSION_ID}_chain.json"

# Nothing changed this turn
[[ ! -f "$TURN_FILE" ]] && exit 0
[[ ! -s "$TURN_FILE" ]] && exit 0

# Snapshot and clear the turn file
CHANGED_FILES=$(sort -u "$TURN_FILE")
rm -f "$TURN_FILE"

# Read pending findings from chain (empty array if no chain yet)
PENDING_FINDINGS="[]"
if [[ -f "$CHAIN_FILE" ]]; then
  PENDING_FINDINGS=$(jq '[.chain[].findings[] | select(.status == "pending")]' "$CHAIN_FILE")
fi

# Safety: if the chain has grown beyond 10 turns without resolving, stop cycling
# and let Claude inform the user the conflict chain is stuck.
MAX_TURNS=10
if [[ -f "$CHAIN_FILE" ]]; then
  CHAIN_TURNS=$(jq '.chain | length' "$CHAIN_FILE")
  if [[ "$CHAIN_TURNS" -ge "$MAX_TURNS" ]]; then
    echo "DocBase: conflict chain has reached $MAX_TURNS turns without resolving. Manual intervention required. Check $CHAIN_FILE for details." >&2
    exit 2
  fi
fi

# Note: we intentionally do NOT check stop_hook_active here.
# We want the hook to re-fire even after a continuation turn so that
# fixes made by Claude in response to findings are re-evaluated.
# The chain resolves naturally when no issues remain.

# Build sub-agent input JSON
DOC_ROOT=$(jq -r '.doc_root' "$CWD/.docbase.json")
CHANGED_JSON=$(echo "$CHANGED_FILES" | jq -R . | jq -s .)

AGENT_INPUT=$(jq -n \
  --argjson changed "$CHANGED_JSON" \
  --argjson pending "$PENDING_FINDINGS" \
  --arg project_root "$CWD" \
  --arg doc_root "$DOC_ROOT" \
  '{
    "changed_files": $changed,
    "pending_findings": $pending,
    "project_root": $project_root,
    "doc_root": $doc_root
  }')

# Write input to temp file for sub-agent
AGENT_INPUT_FILE="/tmp/docbase_${SESSION_ID}_agent_input.json"
echo "$AGENT_INPUT" > "$AGENT_INPUT_FILE"

# Build the sub-agent prompt
PROMPT=$(cat <<'PROMPT_END'
You are the DocBase doc integrity checker. Analyze documentation files for cross-reference consistency.

Read your input from the file path provided as the last argument on this command line.
The input is a JSON object with:
  - changed_files: array of absolute paths of doc files changed this turn
  - pending_findings: array of unresolved findings from previous turns
    each has: { "file": "path", "issue": "description", "status": "pending" }
  - project_root: absolute path to the project root
  - doc_root: relative path to the doc root (e.g. "docs/")

Your tasks:
1. Read each changed file and extract its `related:` frontmatter entries (forward links)
2. Find all doc files in doc_root whose `related:` list includes any changed file (backlinks)
   Search recursively: find all .md files in project_root/doc_root, read their frontmatter
3. Read all forward-linked and backlinked files
4. Check semantic consistency across all related files:
   - Do field names, types, API shapes, behaviors agree between cross-linked docs?
   - Are there any contradictions (e.g., one doc says field is named X, another says Y)?
   - Are related: links symmetric? If A lists B, does B list A?
5. For each pending finding, check if the issue still exists in the current file content
   - If resolved: mark as resolved
   - If still present: keep as still_pending

Return ONLY a JSON object, no other text:
{
  "new_issues": [
    { "file": "absolute/path/to/file.md", "issue": "description of inconsistency" }
  ],
  "resolved": [
    "description of what was fixed"
  ],
  "still_pending": [
    { "file": "absolute/path/to/file.md", "issue": "description" }
  ]
}
PROMPT_END
)

# Run sub-agent synchronously
AGENT_OUTPUT=$(claude -p "$PROMPT Read input from: $AGENT_INPUT_FILE" 2>/dev/null)

# Clean up input file
rm -f "$AGENT_INPUT_FILE"

# Parse output
NEW_ISSUES=$(echo "$AGENT_OUTPUT" | jq '.new_issues // []' 2>/dev/null || echo "[]")
RESOLVED=$(echo "$AGENT_OUTPUT" | jq '.resolved // []' 2>/dev/null || echo "[]")
STILL_PENDING=$(echo "$AGENT_OUTPUT" | jq '.still_pending // []' 2>/dev/null || echo "[]")

NEW_COUNT=$(echo "$NEW_ISSUES" | jq 'length')
PENDING_COUNT=$(echo "$STILL_PENDING" | jq 'length')

# If everything is clean, wipe chain and exit silently
if [[ "$NEW_COUNT" -eq 0 && "$PENDING_COUNT" -eq 0 ]]; then
  rm -f "$CHAIN_FILE"
  exit 0
fi

# Append new entry to chain
TURN_NUMBER=1
if [[ -f "$CHAIN_FILE" ]]; then
  TURN_NUMBER=$(jq '.chain | length + 1' "$CHAIN_FILE")
fi

CHANGED_FOR_CHAIN=$(echo "$CHANGED_FILES" | jq -R . | jq -s .)
ALL_FINDINGS=$(jq -n \
  --argjson new "$NEW_ISSUES" \
  --argjson pending "$STILL_PENDING" \
  '($new + $pending) | map(. + {"status": "pending"})')

NEW_ENTRY=$(jq -n \
  --argjson turn "$TURN_NUMBER" \
  --argjson changed "$CHANGED_FOR_CHAIN" \
  --argjson findings "$ALL_FINDINGS" \
  '{"turn": $turn, "changed": $changed, "findings": $findings}')

if [[ -f "$CHAIN_FILE" ]]; then
  TMP=$(jq --argjson entry "$NEW_ENTRY" '.chain += [$entry]' "$CHAIN_FILE")
else
  TMP=$(jq -n \
    --arg sid "$SESSION_ID" \
    --argjson entry "$NEW_ENTRY" \
    '{"session_id": $sid, "chain": [$entry]}')
fi
echo "$TMP" > "$CHAIN_FILE"

# Build human-readable findings summary for Claude
SUMMARY="DocBase cross-reference check found issues that need resolution:"$'\n\n'

if [[ "$NEW_COUNT" -gt 0 ]]; then
  SUMMARY+="**New issues:**"$'\n'
  while IFS= read -r issue; do
    FILE=$(echo "$issue" | jq -r '.file')
    ISSUE=$(echo "$issue" | jq -r '.issue')
    SUMMARY+="- \`$FILE\`: $ISSUE"$'\n'
  done < <(echo "$NEW_ISSUES" | jq -c '.[]')
  SUMMARY+=$'\n'
fi

if [[ "$PENDING_COUNT" -gt 0 ]]; then
  SUMMARY+="**Still unresolved from previous turn:**"$'\n'
  while IFS= read -r issue; do
    FILE=$(echo "$issue" | jq -r '.file')
    ISSUE=$(echo "$issue" | jq -r '.issue')
    SUMMARY+="- \`$FILE\`: $ISSUE"$'\n'
  done < <(echo "$STILL_PENDING" | jq -c '.[]')
  SUMMARY+=$'\n'
fi

SUMMARY+="Please review these issues and ask the user how to resolve them."

# Exit 2 to notify Claude
echo "$SUMMARY" >&2
exit 2
