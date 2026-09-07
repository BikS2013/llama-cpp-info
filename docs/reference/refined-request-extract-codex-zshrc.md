# Refined Request: Extract Codex-Specific Zsh Configuration

## Category
Configuration

## Objective
Refactor `/Users/giorgosmarinos/.zshrc` so that Codex-related shell functions, aliases, variables, comments, and cohesive configuration blocks are moved into a separate sourced zsh file representing the Codex-specific portion of the user's shell configuration, while preserving the current runtime behavior, command names, arguments, shell startup semantics, and confidentiality of any secrets or sensitive configuration.

## Scope
- **In scope**:
  - Inspect `/Users/giorgosmarinos/.zshrc` and identify Codex-related blocks, including functions, aliases, variables, comments, or configuration whose names, comments, or command invocations explicitly target `codex`, `Codex`, `CODEX`, or Codex CLI behavior.
  - Create a separate Codex-specific zsh file outside the project repository, using a deterministic home-directory path by default.
  - Move the identified Codex-specific content from `/Users/giorgosmarinos/.zshrc` into the new file without changing its behavior.
  - Replace the moved content in `/Users/giorgosmarinos/.zshrc` with a guarded source statement for the new Codex-specific file.
  - Preserve any ordering dependencies between shared environment setup, secrets loading, PATH setup, and the extracted Codex-specific shell definitions.
  - Validate zsh syntax and confirm Codex-related entry points still resolve after sourcing `/Users/giorgosmarinos/.zshrc`.
  - Avoid printing, copying into project documentation, or otherwise exposing secret values discovered in shell configuration files.
- **Out of scope**:
  - Changing Codex command behavior, wrapper names, flags, sandbox mode, argument forwarding, or command semantics.
  - Refactoring unrelated zsh configuration such as Oh My Zsh setup, general aliases, language toolchains, Pi wrappers, Claude/Gemini wrappers, local model wrappers, or OS setup helpers unless a block is required exclusively by Codex functionality.
  - Installing, upgrading, configuring, or testing the Codex CLI itself beyond verifying shell wrapper availability.
  - Creating new project tools, adding dependencies, or changing source code under the llama.cpp repository.
  - Performing version-control operations.

## Requirements
1. Identify every Codex-related block in `/Users/giorgosmarinos/.zshrc` using a consistent definition: a block is Codex-related if its function, alias, variable, comment, or command invocation explicitly targets Codex CLI usage or behavior.
2. Preserve each extracted block's behavior exactly, including function names, aliases, variable names, command-line flags, argument forwarding, comments needed for maintainability, and error messages if present.
3. Create a dedicated sourced zsh file for Codex configuration outside the project repository; the recommended default path is `$HOME/.zshrc.codex`.
4. Update `/Users/giorgosmarinos/.zshrc` so it sources the dedicated Codex zsh file using a guarded source statement such as `[ -f "$HOME/.zshrc.codex" ] && source "$HOME/.zshrc.codex"`.
5. Place the source statement where extracted Codex definitions retain the same effective dependencies and shell startup behavior as before, especially with respect to PATH and any shared secrets or environment variables loaded elsewhere in `.zshrc`.
6. If any Codex-related block depends on shared environment variables or PATH entries also used by non-Codex tools, leave those shared dependencies in `.zshrc` unless they are exclusively Codex-specific.
7. Do not introduce fallback configuration values for missing environment variables; existing explicit error checks, if any, should remain error checks.
8. Do not expose or duplicate secret values from `.zshrc`, `~/.secrets.env`, Codex configuration files, or related shell configuration in project files, logs, or final summaries.
9. Maintain zsh syntax compatibility for all moved content, including function definitions, aliases, arrays, parameter expansion, quoting, and argument forwarding.
10. Validate the refactor with non-interactive zsh checks that source `/Users/giorgosmarinos/.zshrc` and confirm Codex-related functions or aliases resolve without invoking Codex workflows that could perform external actions or consume credentials.
11. Document the final extracted file path and the list of moved Codex entry points in the implementation summary.

## Constraints
- The project root is `/Users/giorgosmarinos/aiwork/llama-cpp`; this refined request is saved under `docs/reference/` in that project.
- The target shell configuration file is `/Users/giorgosmarinos/.zshrc`.
- The parent context states this should follow the same approach as the immediately previous Pi zsh refactor, which moved Pi-related blocks into `~/.zshrc.pi` and sourced them from `.zshrc`.
- The change must preserve existing Codex behavior, including any full-filesystem sandbox flags or argument forwarding currently configured.
- Project instructions prohibit version-control operations unless explicitly requested.
- Project instructions prohibit fallback solutions for configuration settings; missing required configuration should continue to fail explicitly rather than being silently substituted.
- Shell configuration may contain sensitive credentials or credential-derived values; such values must not be printed, copied, or documented.
- Validation should avoid executing Codex commands that could modify files, contact external services, use credentials, or start long-running workflows.

## Acceptance Criteria
1. A separate Codex-specific zsh file exists at the selected path, preferably `/Users/giorgosmarinos/.zshrc.codex`, and contains the extracted Codex-related definitions and related comments.
2. `/Users/giorgosmarinos/.zshrc` no longer contains the full Codex-related function bodies or configuration blocks that were extracted; it contains a guarded source statement for the new Codex-specific file.
3. Sourcing `/Users/giorgosmarinos/.zshrc` in a non-interactive zsh session completes without syntax errors introduced by the refactor.
4. After sourcing `/Users/giorgosmarinos/.zshrc`, all previously existing Codex entry points resolve as functions, aliases, or commands without invoking their bodies; based on the current scan this includes `codexy` if it remains present in `.zshrc` at implementation time.
5. The extracted `codexy` wrapper, if present, continues to invoke `codex --sandbox danger-full-access "$@"` with the same argument forwarding semantics.
6. No unrelated Pi, Claude, Gemini, language-toolchain, package-manager, or general shell configuration is moved or behaviorally changed.
7. No secret values from `.zshrc`, `~/.secrets.env`, Codex configuration files, or related configuration are written into project files or included in responses.
8. The implementation summary reports the extracted file path, the source statement added to `.zshrc`, and the Codex-related entry points moved.

## Assumptions
- The requested slug `extract-codex-zshrc` fits the objective and should be used for this refined request file.
- A safe default destination for the extracted Codex-specific shell configuration is `$HOME/.zshrc.codex`, mirroring the previous Pi extraction pattern that uses `$HOME/.zshrc.pi`.
- The phrase "codex related fulctions" means Codex-related shell functions and any cohesive Codex-specific configuration needed by those functions, despite the typo in the original request.
- A preliminary scan of `/Users/giorgosmarinos/.zshrc` found a Codex wrapper named `codexy`; downstream implementation must still inspect the full file at implementation time to avoid missing any additional Codex-related blocks.
- Shared PATH, secrets loading, or provider configuration used by non-Codex tools should remain in `.zshrc` unless it is exclusively Codex-specific.
- Project context was available and reviewed: `/Users/giorgosmarinos/aiwork/llama-cpp/CLAUDE.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `Issues - Pending Items.md`, and the prior Pi extraction refined request.

## Open Questions (if any)
- **Question**: What exact path/name should be used for the separated Codex-specific zsh file?
  - **Why it matters**: The chosen path becomes part of the user's shell startup contract and affects future maintenance and discoverability.
  - **Recommended default**: Use `$HOME/.zshrc.codex` and source it from `/Users/giorgosmarinos/.zshrc` with `[ -f "$HOME/.zshrc.codex" ] && source "$HOME/.zshrc.codex"`.

## Original Request
i want you to do a similar approach for the codex related fulctions
