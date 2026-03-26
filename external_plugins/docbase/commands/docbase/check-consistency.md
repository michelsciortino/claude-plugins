---
description: Run a full consistency sweep — checks doc cross-references for broken links and semantic conflicts, and verifies doc↔code conformance across all source roots.
---
# /docbase:check-consistency

Run a full consistency sweep across the entire project — doc cross-references and doc↔code conformance.

## Steps

1. **Check prerequisites**
   - Verify `.docbase.json` exists in the current directory. If not, tell the user to run `/docbase:init` first.
   - Read `doc_root`, `source_roots`, and `issues_dir` from `.docbase.json`.

2. **Read config and resolve all paths before spawning sub-agents**
   ```
   PROJECT_ROOT = current working directory (absolute path)
   DOC_ROOT = project_root + "/" + .docbase.json doc_root
   ISSUES_DIR = project_root + "/" + .docbase.json issues_dir
   SOURCE_ROOTS = .docbase.json source_roots (as JSON object)
   ```
   These resolved values are substituted into the sub-agent prompts below — do not pass literal placeholders.

3. **Run two sub-agents in parallel** using the Agent tool:

   **Sub-agent A — Doc integrity sweep**
   Prompt (substitute resolved values for PROJECT_ROOT and DOC_ROOT):
   ```
   You are the DocBase full doc integrity checker. Perform a complete cross-reference sweep.

   Project root: {PROJECT_ROOT}
   Doc root: {DOC_ROOT}

   Tasks:
   1. Find all .md files recursively under the doc root that have DocBase frontmatter
      (YAML block starting with --- containing at least one of: related, implementation, layer, status)
   2. For every file, check its `related:` entries:
      - Do all listed files exist?
      - Are related: links symmetric (if A lists B, does B list A)?
   3. For every pair of related files, check semantic consistency:
      - Do they agree on field names, types, API shapes, behaviors?
      - Are there any direct contradictions?
   4. Return JSON: { "issues": [{"file": "path", "related_file": "path", "issue": "description"}] }
   Return ONLY the JSON.
   ```

   **Sub-agent B — Doc↔code sweep**
   Prompt (substitute resolved values):
   ```
   You are the DocBase full doc↔code conformance checker.

   Project root: {PROJECT_ROOT}
   Doc root: {DOC_ROOT}
   Source roots: {SOURCE_ROOTS}
   Issues dir: {ISSUES_DIR}

   Tasks:
   1. Find all .md files with `implementation:` frontmatter entries
   2. For each implementation: entry, check:
      a. Does the file exist? If not: doc-drift issue
      b. Read the doc and the source file: does the code conform to the spec?
         Check: API signatures, field names, data shapes, described behaviors
         If not: conformance issue
   3. Find all source files under source_roots. For each:
      a. Is it listed in any doc's `implementation:`? If not: undocumented issue
   4. Check existing issues in issues_dir: delete any whose conflict no longer exists
   5. Write new issue files for new findings (same format as code→doc pipeline)
   6. Return JSON: { "new_issues": N, "resolved": N, "doc_drift": N }
   Return ONLY the JSON.
   ```

4. **Collect results** from both sub-agents once they complete.

5. **Report to the user**:
   - Total new issues created, where to find them (issues_dir)
   - Total resolved issues auto-closed
   - If zero issues: "All consistency checks passed."

6. **If issues were found**: list them from the issue files and ask the user which to address first.
