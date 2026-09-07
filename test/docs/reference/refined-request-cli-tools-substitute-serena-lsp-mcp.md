# Refined Request: CLI Tools to Substitute Serena LSP MCP

## Category
Research

## Objective
Investigate local, scriptable CLI tools that can substitute for, or approximate, the capabilities of the Serena LSP MCP tool in Pi subagent and design-builder workflows, with emphasis on symbol discovery, definition/reference lookup, workspace indexing, semantic or structural search, language coverage, JSON or machine-readable output, offline operation, and suitability for invocation from Pi child processes.

## Scope
- **In scope**:
  - Identify CLI tools and toolchains that can provide code-intelligence capabilities similar to Serena LSP MCP.
  - Compare tools against the capability baseline provided by the parent agent: symbol discovery, definitions, references, workspace indexing, semantic or structural search, language coverage, scriptability, JSON output, local/offline operation, and integration with Pi child processes.
  - Include both language-agnostic tools and language/server-specific CLI options where relevant.
  - Assess practical fit for Pi subagents and design-builder workflows, including non-interactive execution, deterministic command usage, output parsing, and installation/configuration complexity.
  - Produce a research/investigation report with a comparison matrix, ranked recommendations, limitations, and suggested integration patterns.
- **Out of scope**:
  - Implementing, installing, or configuring any selected CLI tool.
  - Modifying Pi extensions, subagent prompts, design-builder code, or project source files.
  - Replacing Serena MCP in production workflows without a separate implementation request.
  - Performing benchmarks beyond documented evidence or lightweight, explicitly scoped validation if downstream execution chooses to do so.
  - Performing version-control operations.

## Requirements
1. The investigation must define the Serena LSP MCP capability baseline using the raw request plus the parent-provided focus areas, without assuming undocumented Serena features are mandatory unless verified.
2. The investigation must identify candidate CLI tools or CLI-accessible toolchains capable of supporting at least one of the target capabilities.
3. The candidate set must include, where applicable, tools from these categories:
   - Language Server Protocol clients or wrappers that can query LSP servers from scripts.
   - Language-specific servers or analyzers with CLI interfaces.
   - Workspace indexing and cross-reference tools.
   - Structural or AST-based search tools.
   - Fast lexical/search tools that can serve as fallback approximations.
4. For each shortlisted candidate, the investigation must evaluate:
   - Supported languages and ecosystems.
   - Capability coverage for symbols, definitions, references, indexing, and structural/semantic search.
   - Whether it supports JSON or another reliably machine-parseable output format.
   - Whether it can run locally/offline after installation.
   - How well it can be invoked by Pi child processes without interactive state.
   - Installation/configuration complexity and ongoing maintenance risk.
   - Limitations relative to Serena LSP MCP.
5. The investigation must explicitly distinguish true LSP/semantic capabilities from approximations based on text search, tags, AST pattern matching, or static indexes.
6. The investigation must assess cross-language viability for common agentic coding workflows and for the known project context, including TypeScript/JavaScript, Python, C/C++, shell scripts, Markdown, and other languages if strongly supported by candidate tools.
7. The investigation must provide a comparison matrix with clear scoring or qualitative ratings for the target capabilities.
8. The investigation must provide a recommended primary option and at least one fallback/secondary option, with rationale.
9. The investigation must include example command shapes or pseudo-invocations showing how Pi subagents could call the recommended tools and consume their output.
10. The investigation must identify integration risks for Pi child processes, such as workspace root handling, persistent index location, environment variables, startup latency, concurrency, output size, and failure modes.
11. The investigation deliverable should be saved under `docs/reference/`, preferably as `docs/reference/investigation-cli-tools-substitute-serena-lsp-mcp.md`, unless the downstream investigator uses an equivalent descriptive filename and reports it clearly.
12. The investigation must avoid changing project code, installing dependencies, or adding tools unless a downstream execution plan explicitly requests and validates that work.

## Constraints
- The active project root is `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- This refined request is saved under `docs/reference/` inside the project root.
- The requested slug `cli-tools-substitute-serena-lsp-mcp` fits the objective and is used for the refined request filename.
- Project instructions require reference materials and investigation outputs to be collected under `docs/reference/`.
- Project instructions prohibit version-control operations unless explicitly requested.
- The requested work is research/investigation only; implementation and dependency installation are excluded unless separately authorized.
- Candidate tools should favor local/offline operation and machine-readable output because the intended consumers are Pi child processes and subagents.
- If downstream work proposes adding or updating runtime dependencies in a later implementation phase, the project dependency-validation procedure must be followed first.

## Acceptance Criteria
1. A research/investigation report exists under `docs/reference/` and is clearly linked to this refined request.
2. The report states the Serena LSP MCP capability baseline used for comparison.
3. The report lists and evaluates multiple candidate CLI tools/toolchains rather than a single option.
4. The report includes a comparison matrix covering symbol discovery, definitions, references, indexing, semantic/structural search, language coverage, scriptability, JSON/machine-readable output, offline operation, and Pi child-process suitability.
5. The report clearly identifies which candidates provide true semantic/LSP behavior and which are approximations.
6. The report provides a ranked recommendation with at least one primary option and one fallback option.
7. The report includes practical command examples or pseudo-invocations suitable for Pi subagent/design-builder integration.
8. The report documents limitations, risks, and open integration considerations.
9. No project source code, Pi extension code, or global configuration is modified as part of this research request.
10. No version-control operations are performed.

## Assumptions
- The user wants an investigation deliverable, not an immediate implementation: the raw request asks to “investigate” CLI tools.
- The parent-provided capability list is the authoritative comparison baseline for this refinement: it identifies the Serena-like capabilities that matter for Pi subagents and design-builder workflows.
- The investigation should prioritize local/offline and scriptable tools: the parent context explicitly emphasizes CLI tools, JSON output, local/offline operation, and Pi child-process integration.
- The project root does not currently contain `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `docs/design/project-functions.MD`, or `Issues - Pending Items.md`; refinement therefore relies on injected project instructions, existing refined-request patterns, and the parent-provided context.
- The downstream investigator may use public documentation and tool repositories to validate current capabilities, but should keep the deliverable in the local project under `docs/reference/`.

## Open Questions (if any)
- **Question**: Which programming languages should be treated as mandatory for Serena substitution?
  - **Why it matters**: Tool recommendations differ significantly between broad multi-language indexing, C/C++-focused workflows, TypeScript/Python workflows, and documentation-heavy repositories.
  - **Recommended default**: Prioritize TypeScript/JavaScript, Python, C/C++, shell, Markdown, and generic text/code support because they are common in Pi workflows and visible in the current project context.
- **Question**: Is the desired outcome only a research recommendation, or should downstream work also prototype/install the top candidate?
  - **Why it matters**: Prototyping would require dependency validation, installation decisions, local configuration, test scripts, and possibly Pi extension or prompt changes, which are outside a pure investigation.
  - **Recommended default**: Produce the research recommendation only; create a separate refined request if the user wants implementation or prototyping.
- **Question**: Are there specific Serena MCP features currently used by design-builder beyond the parent-provided baseline?
  - **Why it matters**: Undocumented required features could change the ranking or eliminate tools that otherwise appear sufficient.
  - **Recommended default**: Use the parent-provided baseline as sufficient for this investigation and document any uncovered Serena-specific gaps as risks.

## Original Request
can you investigate if there are cli tools capable of sustituting the serena lsp mcp tool ?
