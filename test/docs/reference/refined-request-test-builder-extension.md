# Refined Request: Test Builder Subagent Pi Extension

## Category
Development

## Objective
Create a Pi extension, in a dedicated source folder under `~/ai-coding/pi-workdocs/extensions`, that exposes the behavior described in `./subagent-specs/test-builder.md` as a reusable test-builder subagent capability, then symlink that extension into the current Pi instance extension auto-loading path so it can be loaded by the active Pi installation.

## Scope
- **In scope**:
  - Study `./subagent-specs/test-builder.md` and preserve its role, inputs, workflow, invariants, output format, and success criteria in the extension’s subagent behavior.
  - Read Pi extension documentation and relevant examples before implementation, especially `docs/extensions.md` and the `examples/extensions/subagent/` implementation.
  - Create a dedicated extension subfolder under `~/ai-coding/pi-workdocs/extensions`, using the requested slug/name `test-builder-extension` if it remains appropriate.
  - Implement the extension in TypeScript using Pi’s extension API.
  - Include any required local agent prompt/configuration files needed for the extension to run the test-builder subagent behavior.
  - Symlink the implemented extension into the current Pi instance extension loading path, expected to be `~/.pi/agent/extensions/`, in a way compatible with Pi auto-discovery and `/reload`.
  - Provide basic validation instructions or evidence showing that Pi can discover/load the extension.
- **Out of scope**:
  - Running the test-builder subagent against a real project scope unless separately requested.
  - Modifying the semantics of the test-builder agent beyond what is necessary to run it as a Pi extension.
  - Creating or changing unrelated Pi extensions, skills, prompts, or project source files.
  - Performing version-control operations.
  - Installing or updating runtime dependencies unless implementation requires it and dependency validation is explicitly performed first.

## Requirements
1. The implementation must use `./subagent-specs/test-builder.md` as the authoritative source for the test-builder subagent behavior.
2. The implementer must read Pi extension documentation before coding, including `/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md`.
3. The implementer must inspect relevant Pi extension examples before coding, including `/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/`.
4. A dedicated source directory must be created under `~/ai-coding/pi-workdocs/extensions`, preferably `~/ai-coding/pi-workdocs/extensions/test-builder-extension`.
5. The extension must be implemented as a TypeScript Pi extension with an auto-discoverable entry point, such as `index.ts` in the extension directory.
6. The extension must expose the test-builder capability in a way that Pi agents can invoke as a subagent-oriented function/tool/command, without requiring the user to manually paste the test-builder prompt each time.
7. The extension must preserve the test-builder agent’s non-interactive behavior: it must not ask user questions during execution, and missing or ambiguous inputs must be reported through structured status/output.
8. The extension must preserve the test-builder safety constraints: no production-source edits, ownership declaration before test writes, no shared test infrastructure edits, scope-only test execution, mandatory report frontmatter, and no fabricated tests.
9. The extension must support passing the test-builder inputs defined in the source spec, including at minimum `scope`, `target_path`, `output_path`, `codebase_scan_file`, `request_file`, `design_file`, `test_dir`, and `mode`.
10. The extension must run the test-builder subagent in an isolated Pi subprocess or equivalent isolated execution context, unless the implementer documents a safer Pi-native approach that preserves isolation and behavior.
11. The extension must handle subprocess/tool errors, aborts, and missing agent configuration gracefully, returning actionable diagnostics rather than crashing Pi.
12. The extension must truncate or otherwise bound model-visible child-agent output to avoid overwhelming the parent context, while preserving enough details for debugging.
13. The extension source directory must be symlinked into the current Pi instance extension loading path, expected to be `~/.pi/agent/extensions/test-builder-extension`, so `/reload` or Pi startup can discover it.
14. The implementation must avoid modifying unrelated project files and must not perform version-control operations.
15. If new runtime dependencies are needed, dependency validation must be performed before adding them; otherwise the implementation should prefer Pi’s existing extension APIs and Node.js built-ins.

## Constraints
- The active project root for this request is `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- The requested refined-request slug is `test-builder-extension`, and it fits the objective.
- The project root did not contain `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `docs/design/project-functions.MD`, or `Issues - Pending Items.md` at refinement time; parent-provided project instructions still apply.
- Project/user conventions require scripts/tools created in project contexts to be TypeScript when creating tools.
- Pi extensions are TypeScript modules loaded by Pi through trusted extension locations; for auto-discovery and `/reload`, use `~/.pi/agent/extensions/*.ts`, `~/.pi/agent/extensions/*/index.ts`, `.pi/extensions/*.ts`, or `.pi/extensions/*/index.ts`.
- Extensions run with full system permissions; the implementation must treat project-local prompts/agents as trusted only when appropriate and avoid unsafe implicit trust expansion.
- Do not create fallback behavior for missing configuration; missing required configuration/input should produce explicit errors or structured invalid-input status.
- Do not perform version-control operations unless explicitly requested.
- Do not modify unrelated project files.

## Acceptance Criteria
1. A directory exists at `~/ai-coding/pi-workdocs/extensions/test-builder-extension` or an explicitly documented equivalent dedicated path under `~/ai-coding/pi-workdocs/extensions`.
2. The extension directory contains a valid Pi extension entry point, such as `index.ts`, that exports the expected default extension factory.
3. The extension implementation references or incorporates the behavior from `/Users/giorgosmarinos/aiwork/llama-cpp/test/subagent-specs/test-builder.md` without omitting its core workflow, safety invariants, and report contract.
4. The extension exposes an invocable Pi capability for launching the test-builder subagent with structured inputs.
5. The extension accepts or maps all inputs listed in the test-builder specification: `scope`, `target_path`, `output_path`, `codebase_scan_file`, `request_file`, `design_file`, `test_dir`, and `mode`.
6. The extension is symlinked into the current Pi instance auto-load location, expected at `~/.pi/agent/extensions/test-builder-extension`, and the symlink points to the source directory under `~/ai-coding/pi-workdocs/extensions`.
7. The extension can be discovered/loaded by Pi via startup or `/reload` without TypeScript syntax/import errors.
8. A dry validation path is documented or executed, such as listing the extension location, confirming symlink resolution, and/or running Pi with the extension in a non-destructive mode.
9. No unrelated project files are modified.
10. No version-control operation is performed.
11. If any dependency is added, dependency-validation evidence is recorded; if no dependencies are added, the implementation notes that it used existing APIs/built-ins.

## Assumptions
- `test-builder-extension` is an appropriate slug and extension directory name: the parent request explicitly suggested this slug and it accurately describes the objective.
- The current Pi instance extension auto-loading path is `~/.pi/agent/extensions/`: Pi documentation identifies this as the global extension auto-discovery path.
- A directory-style extension with `index.ts` is preferred: Pi documentation supports `~/.pi/agent/extensions/*/index.ts`, and a dedicated subfolder was requested.
- The extension should be source-controlled/workspace-managed under `~/ai-coding/pi-workdocs/extensions` and symlinked into Pi’s runtime path rather than authored directly under `~/.pi/agent/extensions`: this matches the raw request.
- The implementation may use the Pi subagent example as a reference pattern rather than copying it verbatim: the request asks for functionality based on the local test-builder spec, not a general-purpose subagent clone.
- No project-local context files were available in `/Users/giorgosmarinos/aiwork/llama-cpp/test`; refinement proceeded using the parent-provided instructions, Pi extension documentation, the subagent example, and `subagent-specs/test-builder.md`.

## Open Questions (if any)
- **Question**: Should the extension expose a narrowly named tool such as `test_builder`, or should it integrate with/extend a generic `subagent` tool pattern?
  - **Why it matters**: A narrow tool gives a clearer purpose-specific interface, while a generic subagent interface may be more reusable but could duplicate existing Pi example behavior.
  - **Recommended default**: Implement a dedicated `test_builder` tool/command in the `test-builder-extension` extension that launches the test-builder subagent behavior.
- **Question**: Should the test-builder prompt be copied into the extension directory, loaded from the original `subagent-specs/test-builder.md`, or symlinked as an agent definition?
  - **Why it matters**: Copying makes the extension self-contained but risks drift; loading/symlinking preserves a single source but depends on the project path remaining available.
  - **Recommended default**: Copy or embed the prompt into the extension directory and document that `subagent-specs/test-builder.md` was the source, so the extension remains portable under `~/ai-coding/pi-workdocs/extensions`.
- **Question**: Should project-local agent definitions be enabled when the test-builder subprocess runs?
  - **Why it matters**: Enabling project-local agents can increase capability but expands trust and security considerations.
  - **Recommended default**: Do not enable arbitrary project-local agents by default; run only the dedicated test-builder prompt/configuration bundled with this extension.

## Original Request
I want you to study the agent described into the ./subagent-specs/test-builder.md document
 and create the extension in a dedicated subfolder under the ~/ai-coding/pi-workdocs/extensions folder
 to be used as a subagent to support this functionality.

 Then I want you to symlink the extension to be used by the current pi instance.
 If needed you can refine the request.
