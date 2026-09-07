# Refined Request: Worker Subagent Extension Based on Online pi-subagents

## Category
Development

## Objective
Find the `pi-subagents` extension on the internet, study its implementation of the `worker` agent, and only if that online extension is successfully found and understood, create a dedicated worker subagent Pi extension under the user’s extension workspace and symlink it into the current Pi instance so it can be discovered and used after reload or restart.

## Scope
- **In scope**:
  - Search the internet for the `pi-subagents` extension and record the source(s) found, such as repository URL, documentation URL, package URL, commit/tag, and relevant file paths.
  - Verify that the discovered online project is actually a Pi subagent extension and includes or documents a `worker` agent implementation.
  - Study the online implementation enough to identify the worker agent’s purpose, prompt/frontmatter, tool/model configuration, subprocess or isolation approach, registration mechanism, discovery paths, and installation/symlink pattern.
  - Compare the online implementation with Pi’s local extension documentation and the bundled subagent example under `/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/`.
  - Create a dedicated TypeScript Pi extension subfolder for a worker subagent only if the online `pi-subagents` extension is found and studied.
  - Place the extension source under the corrected extension workspace path by default: `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension`.
  - Symlink the extension into the current Pi instance’s global extension auto-discovery location, expected at `/Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension`.
  - Include minimal documentation or implementation notes identifying the upstream source studied and explaining how to reload/use the extension.
  - Perform lightweight validation that the created files and symlink exist and match Pi extension discovery conventions.
- **Out of scope**:
  - Creating, copying, or symlinking any worker subagent extension if the online `pi-subagents` extension cannot be found or cannot be verified as the source requested by the user.
  - Inventing a worker agent implementation solely from local examples without finding and studying the online `pi-subagents` extension.
  - Running the worker subagent on a real implementation task unless separately requested.
  - Modifying Pi core code or unrelated Pi extensions.
  - Installing or updating runtime dependencies unless strictly necessary and dependency validation is completed first.
  - Performing version-control operations.

## Requirements
1. The implementer must perform an internet search for `pi-subagents` before creating any extension files or symlinks.
2. The implementer must treat the creation condition as binding: if `pi-subagents` is not found online, or if the found material cannot be verified as a Pi subagent extension containing a worker agent implementation, the implementer must stop after reporting the search outcome and must not create or symlink the extension.
3. When a candidate online source is found, the implementer must record sufficient provenance in the final implementation report and/or extension documentation: source URL, retrieval date, repository/package name, branch/tag/commit when available, and the specific files or documentation sections studied.
4. The implementer must study how the online implementation defines the worker agent, including its name, description, model configuration, allowed tools, system prompt, expected output format, and any safety or handoff instructions.
5. The implementer must study how the online implementation runs subagents, including whether it spawns isolated `pi` subprocesses, uses JSON mode, passes prompts/system prompts, handles output, streams progress, truncates output, propagates aborts, and handles errors.
6. The implementer must read Pi extension documentation before implementation, including `/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md`.
7. The implementer must inspect the bundled local Pi subagent example before implementation, especially `/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts`, `agents.ts`, `agents/worker.md`, and `README.md`.
8. If implementation proceeds, the extension must be implemented in TypeScript as a Pi extension with a valid auto-discoverable entry point, preferably `index.ts` in a dedicated directory.
9. If implementation proceeds, the extension source directory must be created under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension` unless the path typo open question is resolved differently.
10. If implementation proceeds, the extension must expose a worker subagent capability compatible with Pi’s extension model, such as a dedicated `worker_subagent` tool or a documented worker agent registration consumed by a subagent tool.
11. If implementation proceeds, the worker subagent behavior must be derived from the verified online `pi-subagents` implementation, while remaining compatible with the current local Pi extension API.
12. If implementation proceeds, the extension must preserve isolated execution semantics for the worker agent where supported by the studied implementation, preferably by launching a child `pi` process or using an equivalent Pi-native isolated context approach.
13. If implementation proceeds, the extension must include robust error handling for missing agent definitions, failed child processes, aborted executions, invalid inputs, and unavailable Pi commands.
14. If implementation proceeds, the extension must bound or truncate model-visible child-agent output to avoid overwhelming the parent Pi context, while preserving detailed output in tool details or local diagnostic notes when practical.
15. If implementation proceeds, the extension must be symlinked into `/Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension` or another documented current-Pi auto-discovery path supported by Pi.
16. If implementation proceeds and a separate worker agent definition is required, it must be installed, bundled, or symlinked in the appropriate Pi agent discovery location without overwriting unrelated agent definitions.
17. The implementer must not store secrets, credentials, tokens, or private data in the extension source or reports.
18. The implementer must not perform version-control operations.
19. The implementer must avoid new runtime dependencies; if a dependency is unavoidable, dependency validation must be performed before adding it.

## Constraints
- Active project root: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request output location: `docs/reference/` inside the project root.
- Requested refined-request slug: `worker-subagent-extension`, which fits the objective.
- The project root did not contain `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `docs/design/project-functions.MD`, or `Issues - Pending Items.md` at refinement time; refinement relies on parent-provided instructions, observed workspace state, and Pi documentation.
- The user explicitly allowed refinement if needed, and the parent agent classified this as a non-trivial internet research plus implementation request.
- The creation/symlink work is conditional on successfully finding and studying the internet-hosted `pi-subagents` extension.
- Local inspection found `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions` exists and contains existing subagent-style extensions; `/Users/giorgosmarinos/ai-coding/pi-wokdocs/extensions` does not exist.
- Pi global extension auto-discovery supports `~/.pi/agent/extensions/*.ts` and `~/.pi/agent/extensions/*/index.ts`; directory extensions should use an `index.ts` entry point.
- Pi extensions run with full local permissions, so only trusted online sources should be adapted and provenance must be explicit.
- Existing project/user conventions require TypeScript for tools/extensions that involve code creation.
- Existing project/user conventions prohibit version-control operations unless explicitly requested.
- Existing project/user conventions require dependency validation before adding or updating runtime dependencies.
- Missing required configuration or required inputs must produce explicit errors; do not silently fall back to unrelated defaults.

## Acceptance Criteria
1. The final work report includes the internet search outcome and identifies whether the online `pi-subagents` extension was found.
2. If the online `pi-subagents` extension is not found or cannot be verified, no `worker-subagent-extension` source directory is created and no Pi extension symlink is created; the report clearly states why implementation did not proceed.
3. If the online `pi-subagents` extension is found, the report or extension documentation records at least one source URL plus the specific upstream files/sections studied.
4. If implementation proceeds, the upstream worker agent implementation is summarized with its agent name, description, model/tools configuration, prompt behavior, output contract, and isolation/execution mechanism.
5. If implementation proceeds, a dedicated source directory exists at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension` or a documented equivalent path resolved from the user’s chosen workspace.
6. If implementation proceeds, the source directory contains a valid TypeScript Pi extension entry point, preferably `index.ts`, exporting the expected default extension factory.
7. If implementation proceeds, the extension exposes an invocable worker subagent capability in the current Pi instance through a tool, agent registration, or documented equivalent mechanism.
8. If implementation proceeds, the worker subagent behavior is demonstrably derived from the verified online `pi-subagents` source and is not invented solely from the bundled local example.
9. If implementation proceeds, the extension follows local Pi extension compatibility requirements from `docs/extensions.md` and the bundled `examples/extensions/subagent/` pattern where applicable.
10. If implementation proceeds, the symlink `/Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension` exists and resolves to the dedicated source directory or entry point.
11. If implementation proceeds and a separate worker agent definition is required, the agent definition exists in the extension bundle or Pi agent discovery path and does not overwrite unrelated files.
12. If implementation proceeds, lightweight validation confirms the extension path, entry point, symlink resolution, and reload/startup discovery expectations.
13. No unrelated project files are modified beyond this refined request artifact, the conditional extension source directory, and the conditional Pi symlink/agent registration paths.
14. No version-control operations are performed.
15. If any dependency is added, dependency-validation evidence is available; otherwise the report states that no new dependencies were added.

## Assumptions
- `worker-subagent-extension` is an appropriate refined-request slug and extension folder name: it was requested by the parent agent and directly describes the objective.
- The intended extension workspace is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`: the raw request path `~/ai-coding/pi-wokdocs/extensions` appears to contain a typo, while the corrected `pi-workdocs` workspace exists and contains related extensions.
- The current Pi global extension path is `/Users/giorgosmarinos/.pi/agent/extensions`: Pi documentation identifies `~/.pi/agent/extensions/` as the global auto-discovery path, and the directory exists locally.
- A directory-style extension with `index.ts` is preferred: Pi documentation supports `~/.pi/agent/extensions/*/index.ts`, and the user requested a dedicated subfolder.
- The implementation should prefer existing Pi APIs and Node.js built-ins over new dependencies: this matches local Pi examples and avoids unnecessary dependency-vetting work.
- The local bundled Pi subagent example is useful for compatibility checks, but it is not sufficient by itself to satisfy the user’s creation condition because the user specifically required finding and studying the internet-hosted `pi-subagents` extension.

## Open Questions (if any)
- **Question**: Should the implementation use the raw path from the user request, `~/ai-coding/pi-wokdocs/extensions`, or the observed existing workspace, `~/ai-coding/pi-workdocs/extensions`?
  - **Why it matters**: Using the raw path would create a new workspace that appears to be misspelled; using the existing path aligns with established local extension organization.
  - **Recommended default**: Use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions` and document the correction.
- **Question**: Should the created extension expose a dedicated `worker_subagent` tool, or should it install/register only a `worker` agent definition to be consumed by an existing generic `subagent` tool if one is already available?
  - **Why it matters**: A dedicated tool is self-contained and directly satisfies the request, while reusing a generic subagent tool avoids duplicating orchestration code if the current Pi instance already has one loaded.
  - **Recommended default**: Create a dedicated `worker_subagent` extension/tool unless the verified online `pi-subagents` implementation clearly uses a different pattern that should be preserved.
- **Question**: If the online `pi-subagents` worker specifies a model that is unavailable or unconfigured locally, should the extension preserve that model setting or allow the current Pi default model?
  - **Why it matters**: Preserving upstream model metadata improves fidelity, but an unavailable model can make the worker unusable in this environment.
  - **Recommended default**: Preserve the upstream model setting in documentation/frontmatter when present, but allow an optional invocation parameter to override it; if no model is configured, use the current Pi default rather than inventing a fallback model name.

## Original Request
I want you to search the internet and find the pi-subagents extension.

if you manage to find it, and only in this case, I want you to make the following steps:
- I want you to study it and find how the worker agent has been implemented 
- I want you to use these information to create a worker subagent extension for me in a dedicated subfolder under the ~/ai-coding/pi-wokdocs/extensions folder
- Then I want you to symlink the extension to be used by the current pi instance.

If needed you can refine the request.
