# Investigation: CLI Toolchains to Substitute or Approximate Serena LSP MCP

## Executive Summary
This investigation evaluated local, scriptable CLI tools and toolchains that can substitute for, or approximate, Serena LSP MCP-style code intelligence for Pi subagents. The best-fit approach is a **hybrid stack**: use a thin scripted LSP query wrapper over language servers as the primary semantic layer for definitions, references, document/workspace symbols, and diagnostics; pair it with **ripgrep JSON** for fast lexical fallback and **ast-grep/tree-sitter** for structural search; optionally add **Universal Ctags / cscope / SCIP-LSIF indexes** when persistent workspace indexing is needed. No single off-the-shelf CLI fully replaces Serena across all target languages and workflows; the strongest replacement is therefore a small Pi-oriented toolchain that normalizes outputs from multiple local tools into a stable JSON contract.

## Context
- **What was investigated and why**: The request asked for local, scriptable CLI tools capable of substituting or approximating Serena LSP MCP functionality for Pi subagents, especially design-builder/codebase-scanner style workflows when Serena MCP tools are unavailable.
- **Authoritative scope**: `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/refined-request-cli-tools-substitute-serena-lsp-mcp.md`.
- **Codebase scan file**: None supplied.
- **Project context files**: `docs/design/project-design.md`, `CLAUDE.md`, and `AGENTS.md` were not present under the active project root `/Users/giorgosmarinos/aiwork/llama-cpp/test`; the investigation relies on the refined request and parent-supplied context.
- **Serena LSP MCP capability baseline used for comparison**: Because no verified Serena-specific API documentation was supplied locally, this investigation does not assume undocumented Serena features. The baseline is the refined-request capability list: symbol discovery, definition lookup, reference lookup, workspace indexing, semantic/structural search, broad language coverage, JSON or machine-readable output, local/offline operation, non-interactive scriptability, deterministic invocation from Pi child processes, and manageable setup/maintenance.
- **Mandatory/default language coverage**: TypeScript/JavaScript, Python, C/C++, shell, Markdown, and generic code/text.
- **Research limitations**: No browser-style web documentation lookup tool was available. Evidence was gathered from the refined request, local command help, Homebrew metadata, and npm registry metadata queried with `npm view` / `npm search`. Package metadata confirms existence, package descriptions, repository/homepage links, and CLI binaries, but it is not a substitute for implementation-level documentation. Claims about detailed command flags for non-installed tools should be validated before implementation.
- **No implementation actions performed**: No packages were installed, no project code was modified, and no version-control operations were performed.

## Options Identified

### Option 1: Thin scripted LSP query wrapper over language servers
- **Description**: Build or adopt a small command-line LSP client wrapper that starts a language server over stdio, sends JSON-RPC requests, and returns normalized JSON for operations such as `workspace/symbol`, `textDocument/documentSymbol`, `textDocument/definition`, `textDocument/references`, `textDocument/implementation`, `textDocument/typeDefinition`, and diagnostics. Candidate servers include `typescript-language-server` or `tsserver` for TypeScript/JavaScript, `pyright-langserver` for Python, `clangd` for C/C++, `bash-language-server` for shell, and `vscode-markdown-languageserver` for Markdown.
- **Strengths**:
  - Closest semantic match to Serena-style behavior because LSP natively models definitions, references, symbols, diagnostics, and workspace roots.
  - Naturally machine-readable: LSP is JSON-RPC.
  - Works locally/offline after language servers are installed and project dependencies are available.
  - Can support multiple languages behind one Pi-facing JSON contract.
  - `clangd` explicitly supports background indexing and persisted disk indexes; TypeScript and Pyright language servers use project configuration to provide semantic understanding.
- **Weaknesses**:
  - No mature, universal, high-confidence CLI was locally verified as a drop-in replacement; a small wrapper may need to be created or carefully selected.
  - Startup, indexing warm-up, workspace root detection, file-open lifecycle, and LSP position encoding are non-trivial.
  - Language servers differ in capabilities and configuration requirements.
  - Requires dependency validation before adding servers/wrappers to a project.
- **Effort/Complexity**: Medium to High.
- **Risk**: Medium.
- **Best suited when**: Pi subagents need true definitions/references/symbols and can tolerate a managed toolchain with per-language server configuration.

### Option 2: AST/structural search with ast-grep and tree-sitter
- **Description**: Use AST-based command-line tools to find syntactic structures and patterns across code. `@ast-grep/cli` is described in npm metadata as “Search and Rewrite code at large scale using precise AST pattern”; `tree-sitter-cli` provides parser tooling for tree-sitter grammars. These tools can support structural discovery such as function/class declarations, imports, call sites by syntax shape, and targeted code patterns.
- **Strengths**:
  - Better than plain text search for structural queries; reduces false positives for many code-navigation tasks.
  - Multi-language potential through tree-sitter grammars.
  - Well-suited for non-interactive Pi child processes because invocations can be stateless and output can be normalized.
  - Useful for design-builder/codebase-scanner tasks such as locating functions, classes, imports, route declarations, tests, and configuration blocks.
- **Weaknesses**:
  - Not true semantic navigation: definitions/references are approximations unless combined with language-specific knowledge.
  - Language grammar availability and pattern syntax vary.
  - Non-installed command details and JSON schema need validation before implementation.
  - Does not replace LSP type-aware resolution, project references, virtual files, or dynamic import resolution.
- **Effort/Complexity**: Medium.
- **Risk**: Medium.
- **Best suited when**: The workflow needs robust structural search across languages, especially as a fallback or complement to LSP.

### Option 3: Fast lexical search with ripgrep JSON plus project-aware heuristics
- **Description**: Use `rg --json`, `rg --files`, file globs, language type filters, and carefully designed regex heuristics to locate symbols, references, declarations, imports, Markdown headings, shell functions, configuration keys, and generic text/code patterns.
- **Strengths**:
  - Already available locally in this environment (`/opt/homebrew/bin/rg`).
  - Very low setup complexity and excellent scriptability.
  - `rg --json` emits JSON Lines with match, context, begin/end, and summary messages.
  - Works offline, respects ignore files by default, and covers any text/code language including Markdown and shell.
  - Ideal safety-net fallback for Pi child processes when semantic tools are unavailable or fail.
- **Weaknesses**:
  - Lexical only: cannot reliably distinguish declarations from references, resolve aliases/imports, handle overloads, or follow type-aware definitions.
  - Requires language-specific regex heuristics and careful output limits.
  - Can produce large outputs if queries are broad.
- **Effort/Complexity**: Low.
- **Risk**: Low.
- **Best suited when**: A universal, dependable, offline fallback is needed for discovery and approximate reference search.

### Option 4: Tag and cross-reference indexes with Universal Ctags, cscope, and C/C++ indexers
- **Description**: Generate local symbol/tag databases using Universal Ctags for broad symbol discovery and cscope for C-family cross-reference workflows. For C/C++, supplement with clang tooling such as `clangd` background indexing, `compile_commands.json`, and potentially clang index-store workflows.
- **Strengths**:
  - Mature model for static workspace symbol indexes.
  - Good fit for large C/C++ codebases where compile commands are available.
  - Universal Ctags is intended as a maintained implementation; Homebrew metadata lists it as separate from BSD `ctags`.
  - Indexes can be reused across Pi child process invocations if stored under a controlled cache directory.
- **Weaknesses**:
  - Tags generally provide definitions/declarations better than accurate references.
  - Local `/usr/bin/ctags` is BSD ctags with limited options, not Universal Ctags; JSON output and modern language support would require installing Universal Ctags.
  - cscope is C-oriented and was not installed locally.
  - Less useful for TypeScript/Python semantic imports and modern language features than LSP.
- **Effort/Complexity**: Low to Medium for tags; Medium for cscope/clang index integration.
- **Risk**: Medium.
- **Best suited when**: Persistent symbol indexes are desired, especially for C/C++ or broad multi-language declaration discovery, and exact references are not mandatory.

### Option 5: SCIP/LSIF static indexing toolchain
- **Description**: Use static code-intelligence indexers that emit SCIP or LSIF data. npm metadata identifies `@sourcegraph/scip-typescript` as a SCIP indexer for TypeScript/JavaScript, `@sourcegraph/scip-python` as a SCIP indexer for Python, and `@sourcegraph/lsif-tsc` / `lsif-tsc` as tools to create LSIF dumps for TypeScript projects. A Pi integration would need an index generation step and a local query layer over the generated index.
- **Strengths**:
  - Strong conceptual fit for workspace indexing and repeated cross-reference lookups.
  - Indexes can be generated offline after tools are installed and dependencies are available.
  - More deterministic for batch workflows than repeatedly starting language servers.
  - Potentially useful for large repositories where child processes need repeatable query results.
- **Weaknesses**:
  - Not a complete cross-language answer for shell, Markdown, and generic text.
  - Requires an index consumer/query interface; index generation alone is not a Serena replacement.
  - Tool maturity and current maintenance status need deeper validation before adoption.
  - May be overkill for design-builder/codebase-scanner tasks unless the same workspace is queried many times.
- **Effort/Complexity**: High.
- **Risk**: Medium to High.
- **Best suited when**: A persistent, reusable semantic index is required for TypeScript/JavaScript or Python-heavy repositories and implementation time is available.

### Option 6: Language-specific analyzer CLIs without full navigation
- **Description**: Use existing analyzer CLIs directly for diagnostics and partial semantic checks: `pyright --outputjson` for Python diagnostics, `tsc --noEmit` for TypeScript diagnostics, `clangd --check=<file>` or `clang -fsyntax-only` for C/C++ parsing/semantic validation, and shell/Markdown language servers where available. These are not full navigation interfaces but can support validation and contextual analysis.
- **Strengths**:
  - Lower integration cost than full LSP for diagnostics and sanity checks.
  - Machine-readable output is available for some tools, especially Pyright.
  - Useful as adjunct evidence for subagents before edits or designs.
- **Weaknesses**:
  - Does not generally provide definition/reference queries as a scriptable API.
  - Output formats and capabilities vary by language.
  - Better as a validation layer than a Serena substitute.
- **Effort/Complexity**: Low to Medium.
- **Risk**: Low to Medium.
- **Best suited when**: The immediate need is diagnostics or semantic validation, not interactive code navigation.

## Comparison Matrix

| Criterion | Option 1: Scripted LSP wrapper | Option 2: ast-grep/tree-sitter | Option 3: ripgrep JSON | Option 4: tags/cscope/clang indexes | Option 5: SCIP/LSIF | Option 6: analyzer CLIs |
|-----------|--------------------------------|--------------------------------|------------------------|-------------------------------------|--------------------|--------------------------|
| True semantic capability | High | Low-Medium | Low | Low-Medium; High for some C/C++ clang flows | Medium-High for supported languages | Medium for diagnostics only |
| Symbol discovery | High | Medium-High structural | Medium heuristic | High for declarations | High where indexer exists | Low-Medium |
| Definition lookup | High | Low-Medium approximation | Low approximation | Medium for tags/declarations | High where indexed/queryable | Low |
| Reference lookup | High if server supports it | Medium syntactic approximation | Low-Medium lexical approximation | Low-Medium; cscope better for C | High where indexed/queryable | Low |
| Workspace indexing | Medium-High; server-specific | Low-Medium; on-demand scans | Low; no index | Medium-High | High | Low |
| Structural search | Medium via symbols + LSP | High | Low | Low-Medium | Low-Medium | Low |
| TypeScript/JavaScript | High with TS language server | High structural | Medium | Medium tags | High with SCIP/LSIF TS | Medium diagnostics |
| Python | High with Pyright LSP | Medium-High structural | Medium | Medium tags | Medium-High with SCIP Python | Medium-High diagnostics |
| C/C++ | High with clangd + compile commands | Medium-High structural | Medium | High for tags/cscope/clang | Medium if suitable indexer is added | Medium-High diagnostics |
| Shell | Medium with bash-language-server | Medium if grammar configured | Medium-High lexical | Low-Medium | Low | Medium if shell tooling added |
| Markdown | Medium with Markdown LS for headings/links | Medium if grammar configured | High lexical/headings | Low | Low | Low-Medium |
| Generic code/text | Medium via fallback only | Medium if parser exists | High | Medium tags if language supported | Low | Low |
| JSON/machine-readable output | High via JSON-RPC; wrapper normalizes | Likely High; validate schema | High (`rg --json`) | Medium; Universal Ctags likely, BSD ctags no | High index formats; query layer needed | Mixed |
| Offline operation | High after install | High after install | High | High after install | High after install/index | High after install |
| Pi child-process suitability | Medium-High with wrapper/cache | High | High | Medium; index lifecycle needed | Medium; index lifecycle/query needed | Medium |
| Setup complexity | Medium-High | Medium | Low | Medium | High | Low-Medium |
| Performance profile | Warm LSP/index best; cold start cost | Fast scans; parser cost | Very fast | Fast queries after index | Good after index; build cost | Variable |
| Gaps versus Serena baseline | Needs custom orchestration | No true semantics | No true semantics | Weak references/mixed languages | Limited languages/query layer | Mostly diagnostics only |
| Overall fit | Best primary | Best structural companion | Best universal fallback | Good indexing adjunct | Niche advanced indexing | Useful adjunct |

## Recommendation
The recommended approach is a **three-layer local CLI code-intelligence stack**:

1. **Primary semantic layer: scripted LSP wrapper over language servers**.
   - Use LSP where semantics matter: definitions, references, document/workspace symbols, diagnostics, and project-aware navigation.
   - Target servers: TypeScript/JavaScript via `typescript-language-server`/`tsserver`, Python via `pyright-langserver`, C/C++ via `clangd`, shell via `bash-language-server`, and Markdown via `vscode-markdown-languageserver` where useful.
   - Normalize all responses into a Pi-specific JSON schema such as `{ tool, language, root, query, results, diagnostics, errors }`.

2. **Secondary structural layer: ast-grep/tree-sitter**.
   - Use this for deterministic structural discovery when LSP is unavailable, incomplete, slow to warm up, or when the query is syntactic rather than semantic.
   - Particularly useful for design-builder/codebase-scanner tasks such as finding declarations, imports, classes, functions, route registrations, test cases, config blocks, and Markdown-like structures if grammar support exists.

3. **Universal fallback layer: ripgrep JSON**.
   - Use `rg --json` for broad discovery, approximate references, Markdown headings, shell functions, config keys, and any unsupported language.
   - Because it is already installed locally and supports JSON Lines output, it is the safest minimum fallback for Pi child processes.

Add **Universal Ctags/cscope/SCIP-LSIF** only when persistent indexing becomes a demonstrated need:
- Universal Ctags is useful for fast declaration indexes across many languages, but the local `/usr/bin/ctags` is not sufficient as a modern replacement.
- cscope is worth considering for C/C++-heavy workspaces.
- SCIP/LSIF is promising for repeated workspace queries in TypeScript/Python projects, but it needs deeper validation and a local query interface before it can be treated as a Serena substitute.

### Why this option was selected over alternatives
- It is the only approach that can provide **true semantic definitions and references** across the most important languages.
- It preserves local/offline operation and scriptability because LSP uses JSON-RPC over local processes.
- It avoids over-relying on brittle regex or tags while still using them as resilient fallbacks.
- It aligns with Pi subagent constraints: non-interactive invocation, explicit workspace root, parseable output, controllable output size, and no dependency on an MCP server.

### Conditions under which the recommendation would change
- If implementation must be zero-dependency and immediate, use **ripgrep JSON + existing system tools** as the temporary fallback.
- If the repository is almost entirely C/C++, prioritize **clangd + compile_commands.json + cscope/Universal Ctags**.
- If the same TypeScript/Python workspace will be queried heavily by many child processes, investigate **SCIP/LSIF** more deeply and consider a persistent local index cache.
- If only structural search is required and semantic references are not needed, **ast-grep/tree-sitter** may be sufficient without LSP.

### Caveats or prerequisites
- Adding new runtime/tooling dependencies later must follow the project dependency-validation procedure.
- LSP integration must handle line/column encoding, URI normalization, workspace folders, project config discovery, server startup failures, partial results, cancellation/timeouts, and output truncation.
- For C/C++, good results require `compile_commands.json`; without it, clangd may provide degraded behavior.
- For TypeScript/Python, project configuration and dependency availability influence accuracy.

### Example command shapes for Pi subagents
These are pseudo-invocations or command shapes for a future implementation, not commands executed in this investigation:

```bash
# Semantic symbol lookup through a Pi-owned wrapper over LSP JSON-RPC.
pi-code-intel lsp workspace-symbol \
  --root "$PWD" \
  --language typescript \
  --server "typescript-language-server --stdio" \
  --query "DesignBuilder" \
  --json

# Definition lookup through pyright language server.
pi-code-intel lsp definition \
  --root "$PWD" \
  --language python \
  --server "pyright-langserver --stdio" \
  --file src/package/module.py \
  --line 42 \
  --character 17 \
  --json

# C/C++ definition/reference lookup through clangd.
pi-code-intel lsp references \
  --root "$PWD" \
  --language cpp \
  --server "clangd --compile-commands-dir=build --background-index" \
  --file src/main.cpp \
  --line 120 \
  --character 8 \
  --json

# Structural search fallback with ast-grep-style syntax.
pi-code-intel structural search \
  --root "$PWD" \
  --language ts \
  --pattern 'class $NAME { $$$BODY }' \
  --json

# Lexical fallback using ripgrep JSON directly.
rg --json --glob '!node_modules' --glob '!build' 'class\s+DesignBuilder|function\s+scanCodebase' "$PWD"

# Universal Ctags-style symbol index, if Universal Ctags is installed.
ctags -R --output-format=json --fields=+n -f - "$PWD" > .pi-cache/tags.jsonl
```

## Technical Research Guidance

This section signals whether deeper technical research is needed on specific technologies, libraries, or patterns before proceeding to planning and implementation.

**Research needed**: Yes

### Topic 1: Scripted LSP client/wrapper design for Pi child processes
- **Name**: Scripted LSP JSON-RPC wrapper over stdio language servers
- **Why**: The recommendation depends on turning language servers into deterministic one-shot or cached CLI queries with normalized JSON output.
- **Focus**: LSP initialization sequence, workspace folders, file-open lifecycle, position encoding, request methods for symbols/definitions/references, timeout/cancellation handling, output limits, and process/cache lifecycle.
- **Depth**: Deep dive
- **Relevance**: This is the primary Serena substitute layer and the largest integration risk.

### Topic 2: ast-grep and tree-sitter CLI integration
- **Name**: ast-grep/tree-sitter structural search CLI
- **Why**: Structural search is the recommended fallback for syntactic discovery, but command flags, JSON schemas, language grammar setup, and pattern behavior must be verified before implementation.
- **Focus**: JSON output format, supported language list, grammar installation/configuration, reusable rule files, performance on large workspaces, and pattern examples for functions/classes/imports/references.
- **Depth**: Intermediate
- **Relevance**: This layer covers gaps when semantic LSP is unavailable or unnecessary.

### Topic 3: SCIP/LSIF local index querying
- **Name**: SCIP/LSIF static code-intelligence indexes
- **Why**: SCIP/LSIF may be useful for persistent workspace indexing, but the available local query workflow and language coverage need validation.
- **Focus**: Index generation for TypeScript/Python/C/C++, local index file formats, query tooling, JSON extraction, incremental rebuild strategy, and suitability for concurrent Pi child processes.
- **Depth**: Intermediate
- **Relevance**: This determines whether a persistent index should be added beyond LSP and search fallbacks.

## Implementation Considerations
- **Define a stable Pi JSON contract first**: Subagents should not parse raw outputs from five unrelated tools. A wrapper should normalize results into common records: `symbol`, `definition`, `reference`, `diagnostic`, `match`, `file`, `range`, `score`, `sourceTool`, and `confidence`.
- **Separate true semantics from approximations**: Every result should include `mode: semantic | structural | lexical | tag-index` so downstream agents understand reliability.
- **Workspace root handling**: Always pass an explicit root and reject ambiguous roots. LSP servers and indexers are sensitive to root selection.
- **Cache/index location**: Use a project-local or user-cache path such as `.pi-cache/code-intel/<hash>` if implementation is later authorized. Avoid global state unless intentionally configured.
- **Concurrency**: Multiple Pi child processes may query the same workspace. Either keep invocations stateless or use lock files around index generation and shared LSP daemons.
- **Startup latency**: LSP servers have cold-start and indexing costs. For short subagent runs, use ripgrep/ast-grep first and escalate to LSP only for precise questions.
- **Output size control**: All commands should support result limits, file globs, ignore patterns, and maximum byte budgets to prevent overwhelming child-process context.
- **Failure modes**: Handle missing binaries, unsupported languages, invalid project configs, missing `compile_commands.json`, server crashes, large monorepos, and partial LSP responses.
- **Language routing**: Use file extension and project files (`package.json`, `tsconfig.json`, `pyproject.toml`, `compile_commands.json`, shell shebangs) to select tools.
- **Dependency governance**: Any future installation or project dependency addition must go through dependency validation before implementation.
- **Suggested first steps if implementation is requested later**:
  1. Research and select/build the minimal LSP wrapper.
  2. Prototype read-only queries for one TypeScript file, one Python file, and one C/C++ file.
  3. Add `rg --json` fallback because it is already available and reliable.
  4. Add structural search only after validating ast-grep/tree-sitter JSON output and grammar setup.
  5. Consider indexing tools only after repeated-query performance requirements are measured.

## References
| # | Source | URL or Path | What was learned |
|---|--------|-------------|-----------------|
| 1 | Refined request | `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/refined-request-cli-tools-substitute-serena-lsp-mcp.md` | Defined authoritative scope, acceptance criteria, baseline capabilities, language defaults, and no-install/no-code-change constraints. |
| 2 | `rg --help` local output | Local command: `/opt/homebrew/bin/rg --help` | ripgrep recursively searches directories, respects ignore files by default, supports `--files`, type filters, and `--json` JSON Lines output with begin/end/match/context/summary messages. |
| 3 | `clangd --help` local output | Local command: `/usr/bin/clangd --help` | clangd is a language server; supports `--compile-commands-dir`, `--background-index`, persisted disk indexing, `--check=<file>`, result/reference limits, and JSON protocol behavior. |
| 4 | BSD `ctags` local output | Local command: `/usr/bin/ctags --help` | The locally available ctags is BSD-style with limited options (`usage: ctags [-BFTaduwvx]`), so it is not sufficient as a modern Universal Ctags replacement. |
| 5 | Homebrew metadata: ast-grep | `brew info ast-grep` / `https://ast-grep.github.io/` | Homebrew describes ast-grep as “Code searching, linting, rewriting”; package was not installed locally. |
| 6 | Homebrew metadata: tree-sitter | `brew info tree-sitter` / `https://tree-sitter.github.io/` | Homebrew describes tree-sitter as an incremental parsing library; installed formula is the library and the CLI requires `tree-sitter-cli`. |
| 7 | Homebrew metadata: Universal Ctags | `brew info universal-ctags` / `https://ctags.io/` | Universal Ctags is a maintained ctags implementation, separate from the local BSD ctags, and was not installed locally. |
| 8 | Homebrew metadata: cscope | `brew info cscope` / `https://cscope.sourceforge.net/` | cscope is described as a source-code browsing tool and was not installed locally. |
| 9 | npm metadata: `@ast-grep/cli` | `npm view @ast-grep/cli ...` / `https://ast-grep.github.io` | npm metadata describes it as “Search and Rewrite code at large scale using precise AST pattern” and exposes `sg` / `ast-grep` binaries. |
| 10 | npm metadata: `tree-sitter-cli` | `npm view tree-sitter-cli ...` / `https://github.com/tree-sitter/tree-sitter#readme` | npm metadata identifies a CLI package for tree-sitter parser tooling. |
| 11 | npm metadata: TypeScript | `npm view typescript ...` / `https://www.typescriptlang.org/` | npm metadata exposes `tsc` and `tsserver` binaries for TypeScript/JavaScript tooling. |
| 12 | npm metadata: `typescript-language-server` | `npm view typescript-language-server ...` / `https://github.com/typescript-language-server/typescript-language-server#readme` | npm metadata describes it as an LSP implementation for TypeScript using tsserver and exposes `typescript-language-server`. |
| 13 | npm metadata: Pyright | `npm view pyright ...` / `https://github.com/Microsoft/pyright#readme` | npm metadata describes Pyright as a Python type checker and exposes `pyright` and `pyright-langserver` binaries. |
| 14 | npm metadata: shell and Markdown language servers | `npm view bash-language-server ...`; `npm view vscode-markdown-languageserver ...` | npm metadata identifies a Bash language server and the Markdown language server powering VS Code Markdown support. |
| 15 | npm metadata: SCIP/LSIF indexers | `npm view @sourcegraph/scip-typescript ...`; `npm view @sourcegraph/scip-python ...`; `npm view @sourcegraph/lsif-tsc ...` | npm metadata identifies SCIP indexers for TypeScript/JavaScript and Python and LSIF tooling for TypeScript projects. |
| 16 | npm search: LSP client ecosystem | `npm search "lsp cli language server client" --json` | Search results showed language servers and libraries, but no locally verified mature universal CLI drop-in; this supports treating the LSP wrapper as an implementation topic requiring deeper research. |

## Original Request
Raw request: “can you investigate if there are cli tools capable of sustituting the serena lsp mcp tool ?”

Refined request reference: `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/refined-request-cli-tools-substitute-serena-lsp-mcp.md`
