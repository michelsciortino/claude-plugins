#!/usr/bin/env bash
# DocBase git post-commit hook
# Installed per-project by /docbase:init into .git/hooks/post-commit
# Checks committed source code for documentation conformance

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel)
CONFIG="$PROJECT_ROOT/.docbase.json"

# Not a docbase project
[[ ! -f "$CONFIG" ]] && exit 0

# Get changed files in this commit
CHANGED_FILES=$(git diff HEAD~1 --name-only 2>/dev/null || git diff --name-only HEAD)

if [[ -z "$CHANGED_FILES" ]]; then
  exit 0
fi

# Read source_roots from config
SOURCE_ROOTS=$(jq -r '.source_roots | to_entries[] | .value' "$CONFIG")

# Filter to only source code files (under any source_root)
CHANGED_SOURCE_FILES=""
while IFS= read -r file; do
  while IFS= read -r root; do
    if [[ "$file" == "$root"* ]]; then
      CHANGED_SOURCE_FILES+="$PROJECT_ROOT/$file"$'\n'
      break
    fi
  done <<< "$SOURCE_ROOTS"
done <<< "$CHANGED_FILES"

# No source files changed — skip
[[ -z "$CHANGED_SOURCE_FILES" ]] && exit 0

# Read config values
DOC_ROOT=$(jq -r '.doc_root' "$CONFIG")
ISSUES_DIR=$(jq -r '.issues_dir' "$CONFIG")
SOURCE_ROOTS_JSON=$(jq '.source_roots' "$CONFIG")

# Build sub-agent input
CHANGED_JSON=$(echo "$CHANGED_SOURCE_FILES" | grep -v '^$' | jq -R . | jq -s .)
AGENT_INPUT=$(jq -n \
  --argjson changed "$CHANGED_JSON" \
  --arg project_root "$PROJECT_ROOT" \
  --arg doc_root "$DOC_ROOT" \
  --argjson source_roots "$SOURCE_ROOTS_JSON" \
  --arg issues_dir "$ISSUES_DIR" \
  '{
    "changed_source_files": $changed,
    "project_root": $project_root,
    "doc_root": $doc_root,
    "source_roots": $source_roots,
    "issues_dir": $issues_dir
  }')

AGENT_INPUT_FILE=$(mktemp /tmp/docbase_commit_XXXXXX)
echo "$AGENT_INPUT" > "$AGENT_INPUT_FILE"

PROMPT=$(cat <<'PROMPT_END'
You are the DocBase code→doc conformance checker. Analyze committed source code for documentation coverage and conformance.

Read your input from the file path provided as the last argument.
The input is a JSON object with:
  - changed_source_files: array of absolute paths of source files changed in this commit
  - project_root: absolute path to the project root
  - doc_root: relative path to the documentation root
  - source_roots: object mapping names to relative paths (e.g. {"backend": "backend/src/"})
  - issues_dir: relative path to the issues directory

Your tasks:
1. For each changed source file:
   a. Search all .md files under project_root/doc_root for any that list this file in their `implementation:` frontmatter
   b. If none found: this is an UNDOCUMENTED file — create an issue
   c. If found: read the doc file(s) and the source file, check conformance:
      - Does the source code implement what the doc specifies? (APIs, schemas, behaviors, field names)
      - Flag any discrepancies as CONFORMANCE issues

2. Check existing issues in project_root/issues_dir:
   - For each open issue file whose `related_code` frontmatter matches a file in changed_source_files,
     re-evaluate whether the conflict still exists
   - If resolved: delete the issue file

3. For each new issue, write a markdown file to project_root/issues_dir using this format:
   Filename: YYYY-MM-DD_<source-root-name>_<file-slug>_<type>.md
   Content:
   ---
   type: undocumented | conformance
   status: open
   source: code-commit
   created: <ISO timestamp>
   related_doc: <path or null>
   related_code: <absolute path to source file>
   ---

   ## Issue
   <clear description of the problem>

   ## Resolution options
   - <option 1>
   - <option 2>

4. Create the issues_dir if it does not exist.

Return ONLY a JSON summary (no other text):
{
  "new_issues": <count>,
  "resolved": <count>,
  "issues_written": ["filename1.md", "filename2.md"]
}
PROMPT_END
)

RESULT=$(claude -p "$PROMPT Read input from: $AGENT_INPUT_FILE" 2>/dev/null)
rm -f "$AGENT_INPUT_FILE"

NEW_COUNT=$(echo "$RESULT" | jq '.new_issues // 0' 2>/dev/null || echo "0")
RESOLVED_COUNT=$(echo "$RESULT" | jq '.resolved // 0' 2>/dev/null || echo "0")

if [[ "$NEW_COUNT" -gt 0 ]]; then
  echo "DocBase: $NEW_COUNT new issue(s) created in $ISSUES_DIR — review before continuing."
fi
if [[ "$RESOLVED_COUNT" -gt 0 ]]; then
  echo "DocBase: $RESOLVED_COUNT issue(s) auto-closed."
fi

exit 0
