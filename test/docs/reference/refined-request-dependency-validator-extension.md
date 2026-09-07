# Refined Request: Dependency Validator Pi Extension

## Category
Development

## Objective
Create a Pi extension, based on the dependency-validator subagent specification in `./subagent-specs/dependency-validator.md`, in a dedicated subfolder under `~/ai-coding/pi-workdocs/extensions`, and make it available to the current Pi instance by symlinking it into Pi's auto-discovered extension and subagent locations as needed.

## Scope
- **In scope**:
  - Read and interpret `/Users/giorgosmarinos/aiwork/llama-cpp/test/subagent-specs/dependency-validator.md` as the authoritative behavior specification for the dependency-validator subagent.
  - Create a dedicated extension source folder under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`, using a name aligned with `dependency-validator-extension` unless a more appropriate filesystem-safe name is required.
  - Implement the extension in TypeScript using Pi's documented extension API and the Pi subagent example pattern where applicable.
  - Package or expose the `dependency-validator` agent definition so that the extension can invoke it as a Pi subagent from the current Pi instance.
  - Symlink the extension into the current Pi auto-discovery location, expected to be `~/.pi/agent/extensions/<extension-folder>/index.ts` or an equivalent auto-discovered extension path.
  - Symlink or otherwise register the dependency-validator agent definition into the current Pi agent discovery location, expected to be `~/.pi/agent/agents/dependency-validator.md`, if the extension depends on Pi's standard subagent discovery.
  - Include minimal usage documentation or comments sufficient for another agent/user to invoke the dependency-validator subagent.
  - Validate that the symlink targets exist and that the extension structure matches Pi's extension loading requirements.
- **Out of scope**:
  - Running dependency validation against this or any other project after the extension is installed.
  - Modifying the behavior described in the source subagent specification beyond adaptation required for Pi extension/subagent packaging.
  - Creating a general-purpose dependency management tool unrelated to the provided dependency-validator specification.
  - Installing new runtime dependencies unless they are strictly necessary and approved through the project's dependency-validation process.
  - Performing version control operations.

## Requirements
1. The implementation MUST use the source specification at `/Users/giorgosmarinos/aiwork/llama-cpp/test/subagent-specs/dependency-validator.md` as the source for the `dependency-validator` agent prompt and metadata.
2. The extension source MUST be created in a dedicated directory under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`.
3. The extension MUST be implemented in TypeScript and follow Pi extension conventions: a default export accepting `ExtensionAPI`, and an `index.ts` entry point if implemented as a directory extension.
4. The extension MUST expose a way for the current Pi instance to run the dependency-validator as a subagent with isolated context, preserving the agent's documented inputs such as `target_path`, `output_path`, `request_file`, `mode`, `max_iterations`, and `include_security_audit`.
5. The extension MUST preserve the core dependency-validator workflow and invariants from the source specification, including report-only/fix/interactive modes, mandatory report frontmatter, command audit trail, iteration limits, and safety constraints.
6. The extension MUST not silently broaden the dependency-validator's authority: it must remain a validator/surgical fixer, not a general refactor agent.
7. The extension MUST be symlinked into the current Pi instance's auto-discovered extension location so that it can be loaded by `/reload` or by a new Pi session.
8. If the extension relies on a separate agent definition file, that file MUST be symlinked or registered in the current Pi instance's agent discovery location so the subagent can be selected by name.
9. The implementation MUST avoid storing secrets, credentials, or user-specific sensitive data in the extension source folder or generated documentation.
10. The implementation MUST include a brief verification note or command list documenting how to confirm that the extension and agent symlinks resolve correctly.

## Constraints
- Project root for this request: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request artifacts must be saved under `docs/reference/` inside the project root.
- Pi extension auto-discovery supports `~/.pi/agent/extensions/*.ts` and `~/.pi/agent/extensions/*/index.ts`; directory extensions should use an `index.ts` entry point.
- Pi subagent examples use `~/.pi/agent/agents/*.md` for user-level agent definitions and an extension tool that discovers agents from that location.
- Extensions run with full local permissions, so only the provided local source specification should be trusted as the dependency-validator prompt source.
- The user requested a dedicated folder under `~/ai-coding/pi-workdocs/extensions`; do not place primary extension source directly under `~/.pi/agent/extensions` except via symlink.
- Do not perform version control operations unless explicitly requested.
- Do not create unrelated project files.
- If new dependencies are considered, follow the project's dependency-validation procedure before adding them; prefer Pi's existing extension APIs and built-in Node.js modules.

## Acceptance Criteria
1. A directory exists under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions` for the dependency-validator extension.
2. The extension directory contains a valid TypeScript Pi extension entry point, expected at `index.ts`, exporting a default function that registers the dependency-validator subagent functionality.
3. The dependency-validator agent definition is available to the extension and preserves the name `dependency-validator` and the source specification's behavior-relevant content.
4. A symlink exists from the current Pi instance's extension auto-discovery location to the extension source, and the symlink target resolves successfully.
5. If a separate agent definition is required, a symlink or registration exists for `dependency-validator.md` in the current Pi instance's agent discovery path, and the symlink target resolves successfully.
6. The extension can be loaded by the current Pi instance after `/reload` or a new session without TypeScript import or module-resolution errors.
7. The available subagent/tool interface allows a caller to invoke `dependency-validator` with at least the documented target path and mode inputs.
8. No dependency validation run is performed as part of this request unless separately requested.
9. No unrelated files outside the extension source folder, Pi symlink locations, and this refined request artifact are modified.
10. The implementer reports the created extension path, symlink path(s), and the verification performed.

## Assumptions
- The requested slug `dependency-validator-extension` fits the objective and is used for this refined request and likely for the extension folder name: it directly names the requested extension.
- The active project does not contain `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `docs/design/project-functions.MD`, or `Issues - Pending Items.md`: these files were checked and were absent, so refinement relies on parent-provided project context and Pi documentation.
- The current user's home directory is `/Users/giorgosmarinos`: inferred from the project root and parent context, so `~/ai-coding/pi-workdocs/extensions` resolves to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`.
- The implementation may reuse/adapt Pi's documented `examples/extensions/subagent` pattern rather than inventing a completely new subagent runner: this is the safest default because the request is explicitly about Pi subagent functionality.
- The existing Pi installation provides the extension API and runtime dependencies needed for a TypeScript extension: Pi documentation states TypeScript extensions are loaded through Pi's runtime without a separate compilation step.

## Open Questions (if any)
- **Question**: Should the extension be a bespoke `dependency_validator` tool only, or should it reuse/generalize the existing Pi `subagent` tool pattern and add the `dependency-validator` agent definition?
  - **Why it matters**: A bespoke tool is narrower and may expose fewer subagent orchestration modes, while the existing subagent pattern provides single/parallel/chain execution and standard agent discovery.
  - **Recommended default**: Reuse the Pi subagent extension pattern and include/register the `dependency-validator` agent, unless an existing global subagent extension is already installed and can simply consume the new agent definition.
- **Question**: Should the dependency-validator agent be installed globally under `~/.pi/agent/agents` or kept project-local under `.pi/agents` with project trust?
  - **Why it matters**: Global installation makes the subagent available to the current Pi instance across projects; project-local installation limits exposure but depends on project trust and current working directory.
  - **Recommended default**: Install/symlink it globally under `~/.pi/agent/agents/dependency-validator.md` because the user asked for the current Pi instance to use it.
- **Question**: Should the implementation add slash commands/prompts in addition to the subagent tool?
  - **Why it matters**: Slash commands can improve usability but add scope and additional files beyond the requested subagent capability.
  - **Recommended default**: Do not add slash commands/prompts initially; expose the subagent functionality through the extension/tool and document a minimal invocation example.

## Original Request
I want you to study the agent described into the ./subagent-specs/dependency-validator.md document
 and create the extension in a dedicated subfolder under the ~/ai-coding/pi-workdocs/extensions folder
 to be used as a subagent to support this functionality.

 Then I want you to symlink the extension to be used by the current pi instance.
 If needed you can refine the request.
