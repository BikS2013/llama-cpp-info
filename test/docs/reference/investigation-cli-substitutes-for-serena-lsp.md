# Investigation: CLI Tools as Substitutes for Serena's LSP-Backed MCP Code Intelligence

## Executive Summary

Serena's distinctive value is **LSP-grade semantic code intelligence** (symbol-level find/references/definition, symbol-body reading and editing, 40+ languages via pluggable language servers) plus a memory/onboarding layer, all exposed through MCP. No single off-the-shelf CLI reproduces the full bundle, but the capability set decomposes cleanly into layers that have strong CLI substitutes.

The recommended substitute is a **layered combination** rather than one tool:

1. **`ast-grep` (sg)** as the everyday workhorse — a single static binary that delivers structural (AST-aware) search *and* rewrite across many languages with zero index/server setup, and ships an official MCP server. It covers symbol-overview, structural navigation, and the symbol-level *editing* dimension better than any other CLI option.
2. **An LSP-client layer** — either Serena's own engine reused headlessly, **`multilspy`** (Python LSP-client library), or direct invocation of language servers (`pyright`, `gopls`, `rust-analyzer`, `clangd`) — when you need *true* cross-file semantic precision (go-to-definition / find-references that resolve types, imports, and overloads). This is the only way to faithfully match Serena's reference-resolution accuracy, because Serena *is* an LSP client.
3. **`ripgrep`** as the fast lexical baseline, and optionally **universal-ctags** or **SCIP indexers** (`scip-typescript`, `scip-python`) for a precomputed cross-file symbol index when a persistent index is acceptable.

For an agent that needs maximum fidelity to Serena with the least new infrastructure, the highest-leverage single choice is **`ast-grep` + its MCP server**, escalating to a **multilspy/direct-language-server LSP layer** when reference accuracy matters. If you want Serena's *exact* semantic results without Serena's MCP packaging, the cleanest path is to **drive Serena's underlying LSP engine (solidlsp/multilspy-style) directly** from the shell/SDK.

## Context

**What was investigated and why.** The request asks whether CLI tools can substitute Serena (github.com/oraios/serena), an MCP server that gives AI coding agents LSP-powered semantic operations: symbol navigation (definitions, references, document/workspace symbols), semantic retrieval of just-relevant symbol bodies, symbol-level editing (insert before/after, replace symbol body), multi-language support via language servers, and a persistent project memory. The goal is to find shell-callable tools (CLIs, including MCP-capable CLIs) that an agent could use instead of Serena's MCP server.

**Key requirements / evaluation dimensions (from the request).** For each candidate: semantic capabilities vs. Serena; multi-language coverage; whether it needs a running language server or a pre-built index; editing vs. read-only; MCP availability; maturity/maintenance; install/runtime cost; and overall substitution quality for an agent workflow.

**What Serena actually is (capability baseline).** From Serena's README (fetched live):
- It provides "semantic code retrieval, editing, refactoring and debugging tools akin to an IDE's capabilities, operating at the symbol level."
- Its semantic backend is **language servers implementing LSP** — "support for over 40 programming languages." Serena is effectively an LSP *client* with an agent-friendly tool abstraction layer.
- Capability table confirms: find symbol, symbol overview (file outline), find referencing symbols, rename (symbols only), replace symbol body, insert after/before symbol.
- It has a **memory system** for long-lived workflows and integrates "via the model context protocol (MCP)" with terminal clients (Claude Code, Codex, OpenCode, Gemini-CLI).

This decomposition matters: the substitution question is really four sub-questions — (a) symbol *navigation/references*, (b) symbol *retrieval*, (c) symbol *editing*, (d) *memory/onboarding* — plus the MCP transport and language breadth.

**Research limitations.** External web access *was available* in this environment; sources below were fetched live from canonical repositories (GitHub raw READMEs, npm registry, gnu.org). Where exact version numbers, benchmark figures, or per-language fidelity are not quoted from a fetched source, they are deliberately omitted rather than fabricated. No `refined_request_file` or `codebase_scan_file` was supplied; the cwd (`/Users/giorgosmarinos/aiwork/llama-cpp/test`) contains unrelated artifacts and provided no additional integration constraints.

## Options Identified

### Option 1: ast-grep (`sg`) — structural search + rewrite CLI (+ official MCP)
- **Description**: A Rust CLI for AST-based structural **search, lint, and rewrite** using tree-sitter grammars. Patterns are written as code with `$VAR` wildcards; supports YAML rule files and a programmatic API. An official `ast-grep-mcp` server exposes structural search to MCP clients.
- **Semantic capabilities vs. Serena**: Strong on **symbol overview / structural navigation** and **symbol-level editing** (match a function/class/method node and rewrite its body — close analog to "replace symbol body" / "insert before/after"). It is *syntactic*, not *semantic*: it does not resolve types, imports, or cross-file references, so "find all references to this symbol accounting for scope/overloads" is approximate (name-based) rather than LSP-accurate.
- **Multi-language coverage**: Broad via tree-sitter (TypeScript/JS, Python, Go, Rust, Java, C/C++, C#, and many more).
- **Needs language server or index?**: **Neither.** Single static binary, parses on the fly. Zero setup.
- **Editing vs read-only**: **Both** — this is its biggest advantage over most alternatives; structural rewrite is first-class and safe relative to regex.
- **MCP availability**: **Yes** (official `ast-grep-mcp`, marked experimental).
- **Maturity/maintenance**: Mature, actively maintained, widely packaged (npm, pip, cargo, brew, scoop, MacPorts), large community.
- **Install/runtime cost**: Minimal — `brew install ast-grep` / `npm i -g @ast-grep/cli` / `pip install ast-grep-cli`. No runtime daemon.
- **Best suited when**: You want one low-friction tool covering structural navigation and *editing* across languages, and can tolerate name-based (non-type-resolved) reference finding.

### Option 2: LSP-client layer — multilspy / direct language servers / Serena's own engine
- **Description**: Talk to real language servers (LSP) from code/CLI. Options: **`multilspy`** (Microsoft research Python library that auto-downloads server binaries, manages JSON-RPC, exposes definition/references/completion/hover/documentSymbol over a uniform API); **direct invocation** of `pyright`, `gopls`, `rust-analyzer`, `clangd`, `typescript-language-server` (each speaks LSP over stdio); or **reusing Serena's own LSP engine** (Serena is built on a multilspy-derived engine, "solidlsp") headlessly.
- **Semantic capabilities vs. Serena**: **Highest fidelity** — this is literally how Serena obtains its results. Provides true go-to-definition, find-references (type/scope/import-aware), document/workspace symbols, hover signatures. multilspy README explicitly lists definition, references, completion, hover, and documentSymbol.
- **Multi-language coverage**: Any language with an LSP server (40+, same family Serena uses). multilspy supports a documented subset; direct invocation covers anything with a server.
- **Needs language server or index?**: **Requires a running language server** per language (no separate prebuilt index; the server indexes in-memory on startup).
- **Editing vs read-only**: Primarily **read/navigation**; LSP can do rename/edits but multilspy focuses on analysis queries. Editing precision (rename) is available but more work to wire than ast-grep rewrite.
- **MCP availability**: multilspy itself is a library, not MCP. (Several community "LSP MCP" servers exist that wrap language servers, but the canonical, best-maintained MCP packaging of this exact capability *is Serena itself*.)
- **Maturity/maintenance**: multilspy is research-grade (NeurIPS 2023 lineage, microsoft/monitors4codegen) but real and pip-installable; individual language servers are production-grade and heavily maintained.
- **Install/runtime cost**: Higher — Python env + per-language server binaries; servers consume memory and have warm-up latency.
- **Best suited when**: Reference/definition accuracy is non-negotiable, and you accept per-language server setup and a daemon-like runtime.

### Option 3: SCIP / LSIF indexers + `scip` CLI (Sourcegraph)
- **Description**: Precompute a language-agnostic code-intelligence index with an indexer (`scip-typescript`, `scip-python`, `scip-go`, `rust-analyzer` can emit SCIP/LSIF, `scip-clang`), then query/inspect it. The `scip` CLI can `print`, `snapshot`, and experimentally `convert` an index to SQLite for querying. SCIP powers go-to-definition / find-references / find-implementations.
- **Semantic capabilities vs. Serena**: High-fidelity, **cross-file** definitions/references/implementations — semantically precise like LSP, but served from a **static, precomputed index** rather than a live server.
- **Multi-language coverage**: Good for the languages with mature indexers (TS/JS, Python, Go, Java/Scala via scip-java, C++ via scip-clang, Rust).
- **Needs language server or index?**: **Requires building an index** (and rebuilding as code changes). No live server needed at query time.
- **Editing vs read-only**: **Read-only** — navigation/intelligence only; no editing.
- **MCP availability**: Not natively; would need a wrapper. (Sourcegraph's own products consume SCIP; the bare CLI is index-tooling.)
- **Maturity/maintenance**: SCIP is a maintained, documented protocol with multiple official indexers; the `scip` CLI is real but its SQLite query path is experimental.
- **Install/runtime cost**: Medium-high — per-language indexer toolchains + an index build step + staleness management.
- **Best suited when**: You have a large/monorepo codebase, want precise cross-file navigation, and can tolerate a build-and-refresh index pipeline; editing handled separately.

### Option 4: universal-ctags / GNU GLOBAL (gtags) — classic tag indexers
- **Description**: Generate a tag index of language objects (definitions; GLOBAL also handles **references**). ctags is the de-facto multi-language tagger; GNU GLOBAL adds reference lookups and works uniformly across environments.
- **Semantic capabilities vs. Serena**: Provides **symbol definitions** (ctags) and **definitions + references** (GLOBAL), plus file outlines. It is name/heuristic-based, not type-resolved, so accuracy on overloaded/imported symbols is lower than LSP/SCIP.
- **Multi-language coverage**: Very broad (ctags supports dozens of languages and user-defined ones).
- **Needs language server or index?**: **Prebuilt index (tags file)**; no server. Fast to regenerate.
- **Editing vs read-only**: **Read-only.**
- **MCP availability**: None natively.
- **Maturity/maintenance**: Extremely mature and maintained (universal-ctags is the active fork; GLOBAL is a long-standing GNU project).
- **Best suited when**: You want a cheap, ubiquitous, fast symbol/definition index (and references via GLOBAL) as a lightweight navigation baseline.

### Option 5: ripgrep (`rg`) — lexical search baseline
- **Description**: Extremely fast regex/text search across the tree.
- **Semantic capabilities vs. Serena**: **None semantic.** No symbol awareness, no references, no editing of symbol bodies. It finds *text*, not *symbols*; it cannot distinguish a definition from a comment or a same-named unrelated identifier, and cannot scope by type.
- **Multi-language coverage**: Language-agnostic (because it ignores language structure).
- **Needs server/index?**: Neither.
- **Editing**: Read-only (search only).
- **MCP availability**: Various community wrappers; not the point.
- **Maturity**: Excellent, ubiquitous.
- **Best suited when**: As the **fast first-pass locator** feeding the structural/semantic layers — necessary but **not sufficient** to substitute Serena.

### Option 6: comby / semgrep — structural match-and-rewrite alternatives
- **Description**: **comby** does language-aware structural match/rewrite using lightweight parsers (`if (:[cond])` style); **semgrep** does semantic-ish pattern matching primarily for static analysis/security, with autofix.
- **Semantic capabilities vs. Serena**: Structural **editing** (comby rewrite, semgrep autofix) and pattern search; like ast-grep, **syntactic not type-resolving**. semgrep has some cross-function/taint analysis but is oriented to rules/security, not agent navigation. Neither provides LSP-grade find-references.
- **Multi-language coverage**: Broad (comby many "C-like" and other langs; semgrep 30+ languages).
- **Needs server/index?**: Neither (semgrep can use a registry/rules).
- **Editing vs read-only**: **Both** (comby rewrite; semgrep autofix), though less ergonomic for "replace this one symbol's body" than ast-grep.
- **MCP availability**: semgrep has an MCP server; comby does not officially.
- **Maturity/maintenance**: comby mature but lower recent activity; semgrep very actively maintained (commercial backing).
- **Best suited when**: comby — quick structural rewrites in mixed/odd languages; semgrep — when you also want lint/security rules. As Serena substitutes they overlap ast-grep without surpassing it for agent navigation.

### Option 7: Stack Graphs / tree-sitter-stack-graphs, Glean, Kythe (heavy semantic-index platforms)
- **Description**: Incremental name-resolution (stack graphs) and large-scale code-knowledge graphs (Glean, Kythe) used by GitHub code navigation / Meta / Google.
- **Semantic capabilities vs. Serena**: Potentially very high (precise name resolution, cross-repo), but these are **platforms/libraries**, not turnkey agent CLIs.
- **Caveat**: GitHub's `stack-graphs` repo README (fetched live) states it is **no longer supported or updated by GitHub** ("we recommend you fork it"). Kythe/Glean require substantial infrastructure.
- **Editing**: Read-only (analysis).
- **MCP availability**: None turnkey.
- **Maturity/maintenance**: Powerful but **high integration cost / uncertain maintenance** for stack-graphs; Glean/Kythe are heavyweight.
- **Best suited when**: Large org with platform engineering capacity. **Not a practical drop-in substitute** for an individual agent workflow.

### Option 8: Coding-agent CLIs with bundled code intelligence (Aider, etc.)
- **Description**: Agent CLIs like **Aider** build a repository map using **tree-sitter** (and ctags historically) to give an LLM structural context; other agent CLIs ship their own indexers.
- **Semantic capabilities vs. Serena**: Provide **repo-map / symbol-outline context** to feed an LLM, plus their own editing flows — but they are *whole agents*, not composable semantic primitives an external agent calls. Their navigation is typically tree-sitter/name-based, not full LSP.
- **Editing**: Yes (they edit code as agents).
- **MCP availability**: Varies; many are MCP *clients*, not servers exposing semantic primitives.
- **Maturity**: Aider is mature and active.
- **Best suited when**: You want a ready-made agent, not a semantic backend for *your* agent. As a Serena substitute they are orthogonal — they consume the same kind of intelligence rather than exposing it.

## Comparison Matrix

Ratings: ✓✓ strong / ✓ partial / ✗ none. "Type-accurate refs" = resolves references like an LSP (scope/imports/overloads), not just by name.

| Criterion | ast-grep | LSP layer (multilspy / servers / Serena engine) | SCIP indexers + scip | ctags / GLOBAL | ripgrep | comby / semgrep | stack-graphs/Glean/Kythe | agent CLIs (Aider) |
|---|---|---|---|---|---|---|---|---|
| Symbol overview / outline | ✓✓ | ✓✓ | ✓✓ | ✓✓ | ✗ | ✓ | ✓✓ | ✓ |
| Find definition | ✓ (name) | ✓✓ | ✓✓ | ✓✓ | ✓ (text) | ✓ (name) | ✓✓ | ✓ |
| Find references (type-accurate) | ✗ (name) | ✓✓ | ✓✓ | ✓ (GLOBAL, heuristic) | ✗ | ✗ | ✓✓ | ✗/✓ |
| Symbol-level editing | ✓✓ | ✓ (rename) | ✗ | ✗ | ✗ | ✓ | ✗ | ✓✓ (agent) |
| Multi-language breadth | ✓✓ | ✓✓ | ✓ | ✓✓ | ✓✓ (agnostic) | ✓✓ | ✓ | ✓ |
| No language server needed | ✓✓ | ✗ | ✓✓ (at query) | ✓✓ | ✓✓ | ✓✓ | ✓/✗ | varies |
| No prebuilt index needed | ✓✓ | ✓✓ | ✗ | ✗ | ✓✓ | ✓✓ | ✗ | ✗ |
| MCP available | ✓✓ (official) | ✗ (Serena is the canonical MCP wrapper) | ✗ | ✗ | community | ✓ (semgrep) | ✗ | client-side |
| Maturity / maintenance | ✓✓ | ✓✓ servers / ✓ multilspy | ✓✓ proto / ✓ CLI | ✓✓ | ✓✓ | ✓✓ semgrep / ✓ comby | ✗ stack-graphs / ✓ Glean | ✓✓ |
| Install / runtime cost (lower better) | ✓✓ low | ✗ high | ✓ med-high | ✓✓ low | ✓✓ low | ✓ low-med | ✗ high | ✓ med |
| Persistent memory/onboarding | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ (own) |

**Note on memory/onboarding**: *No* candidate replicates Serena's memory system; that dimension is a project-file convention (write `.md` notes to a known directory) the agent must supply itself, independent of the chosen code-intelligence tool.

## Recommendation

**Use a layered combination; lead with `ast-grep`, escalate to an LSP-client layer for reference accuracy.**

1. **Primary substitute — `ast-grep` (+ `ast-grep-mcp`).** It is the only low-cost, zero-setup, multi-language CLI that covers *both* structural navigation/outline *and* the symbol-level **editing** that Serena's "replace symbol body / insert before/after" provides, and it already ships an MCP server so an MCP-speaking agent can adopt it with minimal change. This single tool recovers the majority of day-to-day Serena value.

2. **Accuracy escalation — the LSP-client layer.** ast-grep's reference finding is *name-based*, whereas Serena's is *LSP-accurate*. When the task needs faithful find-references / go-to-definition (refactors, monorepo dependency jumps, overload-heavy or heavily-imported code), add an LSP layer:
   - Easiest fidelity-preserving path: **reuse Serena's own LSP engine headlessly** or **`multilspy`** to get the *identical class* of results Serena returns, callable from a script the agent shells out to.
   - Or invoke language servers directly (`pyright`, `gopls`, `rust-analyzer`, `clangd`) for specific languages.

3. **Baseline & indexing helpers.** Keep **`ripgrep`** as the fast first-pass locator. For large/monorepo codebases where a live LSP server per language is too heavy, substitute the LSP layer with **SCIP indexers + `scip`** (precise, precomputed) or **GNU GLOBAL** (cheap heuristic references).

**Why this over alternatives.** ripgrep alone is insufficient (no symbol/semantic awareness). ctags/GLOBAL and SCIP are read-only and don't cover editing. comby/semgrep overlap ast-grep without beating it for agent navigation. stack-graphs is unmaintained by GitHub; Glean/Kythe are too heavy. Agent CLIs (Aider) consume rather than expose semantic primitives. Only the LSP layer truly matches Serena's *semantic accuracy*, and only ast-grep cheaply matches Serena's *editing* — hence the combination.

**Conditions that would change the recommendation.**
- If type-accurate cross-file references are rarely needed → **ast-grep alone** suffices.
- If you must match Serena's results *exactly* with minimal re-engineering → **drive Serena's underlying LSP engine directly** (you are then substituting the *MCP packaging*, not the engine).
- If the codebase is a huge monorepo with CI → **SCIP indexers** become the better navigation backend than live servers.

**Caveats / prerequisites.** (a) None of these provide Serena's **memory/onboarding** — implement it as agent-owned markdown notes. (b) An MCP-only agent gets ast-grep via `ast-grep-mcp`; the LSP/SCIP/ctags layers need either a thin MCP wrapper or a shell/SDK call path. (c) ast-grep-mcp and scip's SQLite query path are marked experimental — validate before relying on them.

## Technical Research Guidance

This section signals whether deeper technical research is needed before planning/implementation. The candidates differ substantially in API surface, exact language coverage, and integration mechanics, and the request explicitly targets implementation-level substitution for an agent — so confirm the precise capabilities/commands before building.

**Research needed**: Yes

### Topic 1: ast-grep CLI + ast-grep-mcp for agent-driven structural navigation and editing
- **Name**: ast-grep (`sg`) and `ast-grep-mcp`
- **Why**: It is the recommended primary substitute; exact rule/pattern syntax, the `run`/`scan` rewrite commands, JSON output for agent parsing, per-language node-kind names, and the MCP server's tool schema/stability must be confirmed to build reliable symbol-overview and symbol-edit operations.
- **Focus**: Pattern + YAML rule syntax; structural rewrite (`replace`/rewrite) semantics; `--json` output; language/grammar coverage and node-kind discovery; ast-grep-mcp tool list, transport, and experimental limitations.
- **Depth**: Deep dive
- **Relevance**: Directly powers layers 1 (navigation/outline) and the editing dimension of the recommended substitute.

### Topic 2: LSP-client layer — multilspy and/or Serena's headless LSP engine
- **Name**: multilspy (microsoft/multilspy) and Serena's underlying LSP engine (solidlsp / multilspy-derived)
- **Why**: This is the only way to match Serena's type-accurate references/definitions; need the API for definition/references/documentSymbol, server auto-download behavior, supported-language matrix, lifecycle/latency, and whether Serena's engine can be invoked standalone without the MCP server.
- **Focus**: Public API for definition/references/hover/documentSymbol; supported languages and required server binaries; startup/warm-up cost and concurrency; feasibility of reusing Serena's engine headlessly; editing/rename support.
- **Depth**: Deep dive
- **Relevance**: Powers layer 2 (accuracy escalation), the highest-fidelity part of the substitution.

### Topic 3: SCIP indexers + `scip` CLI as an index-based navigation backend
- **Name**: Sourcegraph SCIP (`scip` CLI, `scip-typescript`, `scip-python`, `scip-go`, scip-clang, scip-java) and rust-analyzer SCIP/LSIF output
- **Why**: For monorepo-scale precise navigation without live servers; need to confirm which indexers are production-ready, index build/refresh cost, and how to query an index from the CLI (the SQLite `expt-convert` path is experimental).
- **Focus**: Indexer availability/maturity per language; index build commands and staleness handling; query approaches (`scip print`, SQLite convert, or wrapper); whether find-references/implementations are practically queryable from the CLI.
- **Depth**: Intermediate
- **Relevance**: Alternative backend for layer 2 when live LSP servers are too costly.

## Implementation Considerations

- **Key decisions still open**: (a) How much type-accuracy the agent truly needs (decides whether the LSP/SCIP layer is mandatory). (b) MCP-only integration vs. shell/SDK calls (decides how much wrapping the LSP/ctags/SCIP layers need). (c) Live-server (LSP) vs. precomputed-index (SCIP/ctags) trade-off, driven by repo size and edit frequency.
- **Dependencies/prerequisites**: ast-grep binary; for the LSP layer, a Python env + per-language server binaries (`pyright`, `gopls`, `rust-analyzer`, `clangd`, `typescript-language-server`); for SCIP, per-language indexer toolchains.
- **Pitfalls**: ast-grep references are name-based — don't present them as type-accurate. Language servers have warm-up latency and memory cost; index-based tools go stale. ast-grep-mcp and scip SQLite query are experimental. GitHub `stack-graphs` is unmaintained — avoid as a foundation. Memory/onboarding must be re-implemented (agent-owned markdown), as no candidate provides it.
- **Suggested first steps**: (1) Install `ast-grep`; validate symbol-outline + a structural rewrite with `--json` on a target repo. (2) Stand up the LSP layer for one language (e.g., `pyright` via multilspy) and compare find-references output against ast-grep name matches to quantify the accuracy gap. (3) Decide whether the gap justifies the LSP/SCIP layer for your workloads. (4) If MCP is required, wire `ast-grep-mcp` and prototype a thin MCP wrapper over the LSP layer (or reuse Serena's engine).

## References

| # | Source | URL or Path | What was learned |
|---|--------|-------------|-----------------|
| 1 | Serena README (oraios/serena) | https://raw.githubusercontent.com/oraios/serena/main/README.md | Serena's capabilities baseline: LSP-backed semantic tools, 40+ languages, find symbol / referencing symbols / overview, replace symbol body, insert before/after, memory system, MCP integration |
| 2 | multilspy README (microsoft/multilspy) | https://raw.githubusercontent.com/microsoft/multilspy/main/README.md | Python LSP-client library; auto-downloads servers; exposes definition, references, completion, hover, documentSymbol over a uniform API; NeurIPS 2023 / monitors4codegen lineage |
| 3 | ast-grep README (ast-grep/ast-grep) | https://raw.githubusercontent.com/ast-grep/ast-grep/main/README.md | AST-based structural search/lint/rewrite CLI; `$VAR` patterns; broad tree-sitter language support; installable via npm/pip/cargo/brew/etc. |
| 4 | ast-grep MCP server README | https://raw.githubusercontent.com/ast-grep/ast-grep-mcp/main/README.md | Official (experimental) MCP server exposing ast-grep structural search to AI assistants |
| 5 | SCIP README (sourcegraph/scip) | https://raw.githubusercontent.com/sourcegraph/scip/main/README.md | Language-agnostic indexing protocol powering go-to-def/find-refs/find-impl; `scip` CLI; bindings; indexer ecosystem |
| 6 | SCIP CLI reference | https://raw.githubusercontent.com/sourcegraph/scip/main/docs/CLI.md | `scip print`, `scip snapshot`, experimental `expt-convert` to SQLite for querying indexes |
| 7 | universal-ctags README | https://raw.githubusercontent.com/universal-ctags/ctags/master/README.md | Maintained multi-language tag/index generator for symbol definitions; user-definable languages |
| 8 | GNU GLOBAL homepage | https://www.gnu.org/software/global/ | Source tagging system handling both definitions and references; environment-agnostic |
| 9 | comby README (comby-tools/comby) | https://raw.githubusercontent.com/comby-tools/comby/master/README.md | Language-aware structural match/rewrite (`:[hole]` syntax); simplifies refactors vs regex |
| 10 | Stack Graphs README (github/stack-graphs) | https://raw.githubusercontent.com/github/stack-graphs/main/README.md | Incremental name-resolution framework — explicitly "no longer supported or updated by GitHub"; recommends forking |
| 11 | npm registry (lsp-cli) | https://registry.npmjs.org/lsp-cli | Confirms the npm `lsp-cli` package is an unrelated/placeholder package, not a viable LSP-client CLI |

## Original Request

Investigate whether there are CLI tools capable of substituting the Serena LSP MCP tool — shell-callable tools (including MCP-capable CLIs) that could replace the LSP-backed semantic code intelligence Serena provides (symbol navigation, semantic retrieval, symbol-level editing, multi-language LSP support, project memory). Compare across LSP-client CLIs, standalone semantic code-intelligence CLIs, structural search/replace tools, the ripgrep baseline, and coding-agent CLIs with bundled intelligence, on the dimensions: semantic capability vs. Serena, multi-language coverage, server/index requirement, editing vs. read-only, MCP availability, maturity, install/runtime cost, and substitution quality. Conclude with a recommended single tool or combination. (No refined_request_file or codebase_scan_file supplied.)
