# Refined Request: Extract Pi-Specific Zsh Configuration

## Category
Configuration

## Objective
Refactor `/Users/giorgosmarinos/.zshrc` so that all Pi-related shell functions, variables, aliases, helper functions, comments, and cohesive configuration blocks are moved into a separate sourced zsh file that represents the Pi-specific portion of the shell configuration, while preserving the current runtime behavior, command names, environment setup, and shell startup semantics.

## Scope
- **In scope**:
  - Inspect `/Users/giorgosmarinos/.zshrc` and identify Pi-related blocks, including Pi command wrappers, Pi local-model server helpers, Pi skill helpers, Pi-specific Azure/OpenAI compatibility exports, and comments directly documenting those blocks.
  - Create a separate zsh file for the extracted Pi-specific configuration.
  - Replace the extracted content in `/Users/giorgosmarinos/.zshrc` with a safe source statement for the new Pi-specific file.
  - Preserve the relative ordering needed for dependencies such as secrets loading, Azure/OpenAI environment variables, model wrapper variables, helper functions, aliases, and PATH-dependent commands.
  - Validate that existing Pi shell entry points continue to resolve after sourcing `.zshrc`, including the local model wrappers and skill wrapper functions.
  - Avoid printing, copying into project documentation, or otherwise exposing secret values discovered in shell configuration files.
- **Out of scope**:
  - Changing the behavior, names, arguments, provider selections, ports, model paths, or command semantics of any Pi wrapper.
  - Refactoring unrelated zsh configuration such as Oh My Zsh setup, general aliases, Python/Node/Go/Dotnet setup, fzf configuration, non-Pi Claude/Gemini wrappers, or OS setup helpers unless a block is required exclusively by Pi functionality.
  - Modifying Pi model configuration files such as `~/.pi/agent/models.json`.
  - Creating new tools, installing dependencies, or changing project source code under the llama.cpp repository.
  - Performing version-control operations.

## Requirements
1. Identify every Pi-related block in `/Users/giorgosmarinos/.zshrc` using a consistent definition: a block is Pi-related if its function/variable/alias name, comments, or command invocation explicitly targets `pi`, `pi-coding-agent`, `pi-*` wrappers, Pi skills, or local llama.cpp servers used by Pi providers.
2. Preserve each extracted block exactly in functional behavior, including variable names, function names, command-line arguments, comments needed for maintainability, local helper functions, and error messages.
3. Create a dedicated sourced zsh file for Pi configuration outside the project repository, because the source file is part of the user's home shell configuration rather than project documentation.
4. Update `/Users/giorgosmarinos/.zshrc` so it sources the dedicated Pi zsh file from a deterministic path using `$HOME` where practical.
5. Ensure the source statement is placed where the extracted Pi blocks' dependencies remain valid, especially any dependencies on secrets and general Azure/OpenAI environment variables already loaded by `.zshrc`.
6. If any Pi block currently depends on environment variables defined elsewhere in `.zshrc`, either leave the shared dependency in `.zshrc` or preserve the effective ordering so the extracted Pi file sees the same values as before.
7. Do not introduce fallback configuration values for missing environment variables; existing explicit error checks should remain error checks.
8. Do not expose or duplicate secret values in the refined request, implementation notes, terminal output, or project files.
9. Maintain zsh syntax compatibility for all moved content, including arrays, associative arrays, function definitions, subshells, and zsh parameter expansion.
10. Validate the refactor by starting a non-interactive zsh session that sources `/Users/giorgosmarinos/.zshrc` and confirms Pi-related functions are defined without executing long-running model starts.
11. Document the final extracted file path and the list of moved Pi entry-point functions in the implementation summary.

## Constraints
- The project root is `/Users/giorgosmarinos/aiwork/llama-cpp`; the refined request must be saved under `docs/reference/` in that project.
- The target shell configuration file is `/Users/giorgosmarinos/.zshrc`.
- The change must not alter behavior of existing Pi commands, including provider/model arguments and local llama.cpp server management.
- The project instructions prohibit version-control operations unless explicitly requested.
- The project instructions prohibit fallback solutions for configuration settings; missing required configuration should continue to raise clear errors.
- Shell configuration may contain sensitive credentials or credential-derived values; such values must not be printed, copied, or documented.
- The implementation should avoid executing Pi wrappers that start large local model servers; validation should use function/type/syntax checks rather than invoking model startup commands.

## Acceptance Criteria
1. A separate Pi-specific zsh file exists at the selected path and contains the extracted Pi-related variables, helper functions, user-facing Pi functions, and related comments.
2. `/Users/giorgosmarinos/.zshrc` no longer contains the full Pi-related function bodies and variable blocks that were extracted; it contains a source statement for the new Pi-specific file.
3. Sourcing `/Users/giorgosmarinos/.zshrc` in a non-interactive zsh session completes without syntax errors introduced by the refactor.
4. After sourcing `/Users/giorgosmarinos/.zshrc`, the following existing Pi entry points resolve as functions or commands without invoking their bodies: `pi5.5`, `pi-opus`, `pi-ornith`, `pi-ornith-stop`, `pi-gemma31`, `pi-gemma31-stop`, `pi-minimax`, `pi-minimax-stop`, `pi-qwen-coder`, `pi-qwen-coder-stop`, `pi-llm-status`, and `pi-skill`.
5. Existing helper functions required by those entry points, such as local model server readiness checks and Pi skill resolution helpers, resolve after sourcing the shell configuration.
6. The effective values of Pi-specific exported variables that were previously set by `.zshrc` remain available after sourcing `.zshrc`, subject to the same pre-existing dependencies on secrets or other environment setup.
7. No local model server is started during validation unless the user explicitly requests runtime testing of a wrapper.
8. No secret values from `.zshrc`, `~/.secrets.env`, or related configuration files are written into project files or included in the final response.

## Assumptions
- The requested slug `extract-pi-zshrc` fits the objective and should be used for this refined request file.
- A safe default destination for the extracted Pi-specific shell configuration is `$HOME/.zshrc.pi`, because it is clearly associated with `.zshrc`, remains outside the project repository, and can be sourced directly from `.zshrc`.
- The phrase "all the pi-related functions" includes cohesive Pi-related variables and comments, not only `function` declarations, because the Pi functions depend on associated variables such as ports, paths, logs, context sizes, and provider compatibility exports.
- Generic provider environment variables and secrets that are also used by non-Pi tools should remain in `.zshrc` unless they are part of a clearly Pi-specific compatibility block.
- Project context was available and reviewed: `/Users/giorgosmarinos/aiwork/llama-cpp/CLAUDE.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, and `Issues - Pending Items.md`.

## Open Questions (if any)
- **Question**: What exact path/name should be used for the separated Pi-specific zsh file?
  - **Why it matters**: The chosen path becomes part of the user's shell startup contract and affects future maintenance/discovery.
  - **Recommended default**: Use `$HOME/.zshrc.pi` and source it from `/Users/giorgosmarinos/.zshrc` with `[ -f "$HOME/.zshrc.pi" ] && source "$HOME/.zshrc.pi"`.
- **Question**: Should shared Azure/OpenAI environment exports used by both Pi and non-Pi commands be moved into the Pi-specific file?
  - **Why it matters**: Moving shared exports could change behavior for non-Pi tools, while leaving them in `.zshrc` makes the Pi file less fully self-contained.
  - **Recommended default**: Leave shared provider/secrets configuration in `.zshrc` and move only the explicitly Pi-specific compatibility exports and Pi wrapper blocks.

## Original Request
can you get all the pi-related functions from the ~/.zshrc file and put them in a separated file 
which is going to be the pi part of the ~/.zshrc ?
