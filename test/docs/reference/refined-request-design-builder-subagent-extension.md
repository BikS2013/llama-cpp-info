# Refined Request: Design Builder Subagent Extension

## Category
Development

## Objective
Create a Pi extension for the `design-builder` subagent by studying `./subagent-specs/design-builder.md`, implementing the extension in a dedicated subfolder under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`, following the existing Pi subagent extension pattern used by the request-refiner, codebase-scanner, investigator, technical-researcher, and plan-builder extensions, and symlinking the extension into `~/.pi/agent/extensions` so the current Pi instance can discover it after reload or restart.

## Scope
- **In scope**:
  - Review `./subagent-specs/design-builder.md` as the source subagent specification.
  - Review existing subagent extension implementations under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions` to match naming, structure, invocation style, validation, and README conventions.
  - Create a dedicated extension folder, preferably `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent`.
  - Implement a TypeScript Pi extension entrypoint that registers a `design_builder_subagent` tool and delegates to an isolated child `pi` process using the adapted design-builder prompt.
  - Include an adapted prompt file derived from `./subagent-specs/design-builder.md`, preferably named `design-builder-agent.md`.
  - Include extension documentation, preferably `README.md`, explaining files, tool parameters, child tools, installation symlink, reload/restart instructions, and example invocations.
  - Support the design-builder launch inputs from the source spec: `request_file`, `plan_file`, optional investigation/research/codebase scan/project design/output path/integration directive/resolved questions/original request, plus practical wrapper parameters such as `cwd` and optional `model` if consistent with the existing pattern.
  - Validate required file inputs before launching the child process and return clear errors for missing required artifacts.
  - Symlink the extension folder into `/Users/giorgosmarinos/.pi/agent/extensions/design-builder-subagent` for Pi auto-discovery.
  - Perform lightweight verification that the files and symlink exist and that the TypeScript source is structurally consistent with the existing extensions.
- **Out of scope**:
  - Rewriting the design-builder subagent behavior beyond adapting it for Pi child-process execution.
  - Creating or modifying any actual technical design artifacts with the new subagent.
  - Changing Pi core code or global Pi configuration beyond adding/updating the extension symlink.
  - Adding new runtime dependencies unless unavoidable and explicitly vetted.
  - Performing version-control operations.
  - Updating unrelated project files.

## Requirements
1. The implementation must use `./subagent-specs/design-builder.md` as the authoritative source for the design-builder subagent prompt and behavior.
2. The implementation must follow the existing extension pattern under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`, especially the structure and child-Pi delegation approach used by `request-refiner-subagent`, `codebase-scanner-subagent`, `investigator-subagent`, `technical-researcher-subagent`, and `plan-builder-subagent`.
3. The extension folder must be dedicated to this subagent and named consistently with the existing convention, with `design-builder-subagent` as the recommended folder name.
4. The extension must register a Pi tool named `design_builder_subagent` unless an existing naming convention requires a different but clearly justified name.
5. The extension must be implemented in TypeScript, consistent with the project instruction that tools/extensions requiring code scripts are TypeScript.
6. The registered tool must expose parameters sufficient to launch the design-builder workflow described in the source spec, including:
   - `request_file` (required)
   - `plan_file` (required)
   - `investigation_file` (optional)
   - `research_files` (optional array)
   - `codebase_scan_file` (optional)
   - `project_design_file` (optional)
   - `output_path` (optional)
   - `integration_directive` (optional)
   - `resolved_open_questions` (optional)
   - `original_request` (optional)
   - `cwd` or equivalent project root parameter (optional, defaulting to current Pi working directory)
   - `model` (optional), if consistent with existing subagent extensions.
7. The extension must validate that required file parameters exist and are files before invoking the child Pi process.
8. Optional file parameters, when supplied, must be resolved relative to the chosen working directory and validated before invocation.
9. The extension must derive a sensible default design output path when `output_path` is omitted, matching the source spec intent: `<project root>/docs/design/design-NNN-<slug>.md`, with `NNN` and slug preferably derived from the plan metadata or existing naming conventions.
10. The child process task must instruct the subagent to treat `request_file` and `plan_file` as authoritative, write the per-request design file, update `docs/design/project-design.md` or the supplied `project_design_file`, and return the concise caller report required by the source spec.
11. The child process should be launched with only the tools needed for the design-builder behavior and available in the local Pi environment; if Serena MCP tools are not available to child processes, the prompt/task must clearly instruct the subagent to use local file/search tools and document verification limitations.
12. The extension must include a README documenting installation and usage, including the exact symlink command and the need to run `/reload` or restart Pi after installation.
13. The extension must be symlinked into `/Users/giorgosmarinos/.pi/agent/extensions/design-builder-subagent`, resolving to the source folder under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`.
14. The implementation must avoid adding new dependencies unless necessary; if dependencies are added or updated, the dependency-validation procedure must be followed first.
15. The implementation must not perform any git or other version-control operations.

## Constraints
- The active project root for this refinement is `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- The refined request must be saved under `docs/reference/` inside the project root.
- Existing project-specific instructions require non-trivial work to begin with request refinement; the user explicitly allowed refinement.
- Existing project-specific instructions require code scripts/tools to be written in TypeScript.
- Existing project-specific instructions prohibit version-control operations unless explicitly requested.
- Existing project-specific instructions require dependency validation before adding or updating runtime dependencies.
- The implementation should modify only the new extension folder and the user-level Pi extensions symlink, not unrelated project files.
- The implementation should not print or expose secrets; no secret material is expected for this task.
- Pi auto-discovery requires the extension to be present under `~/.pi/agent/extensions`; reload or restart may be required for the current Pi instance to detect it.

## Acceptance Criteria
1. A folder exists at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent` or a justified equivalent dedicated folder name.
2. The folder contains a TypeScript extension entrypoint, preferably `index.ts`, that registers a Pi tool for the design-builder subagent.
3. The folder contains an adapted prompt file derived from `./subagent-specs/design-builder.md`, preferably `design-builder-agent.md`.
4. The folder contains a `README.md` documenting the tool, parameters, child tools, symlink installation, reload/restart requirement, and example invocations.
5. The registered tool name is `design_builder_subagent` or an explicitly justified convention-compatible alternative.
6. The tool requires `request_file` and `plan_file` and validates that they exist before launching the child Pi process.
7. Supplied optional artifact paths are resolved and validated consistently with the existing subagent extensions.
8. The child Pi task includes all source-spec launch inputs and instructs the design-builder subagent to write the design file and update the living project design document.
9. If `output_path` is omitted, the extension computes or instructs the child to compute a default output path under `docs/design/` using the `design-NNN-<slug>.md` convention.
10. The symlink `/Users/giorgosmarinos/.pi/agent/extensions/design-builder-subagent` exists and resolves to the dedicated source extension folder.
11. No new dependencies are added unless dependency validation evidence is produced first.
12. No version-control operations are performed.
13. A final implementation report can identify the created files, symlink target, verification performed, and any limitations such as unavailable Serena MCP tools in child processes.

## Assumptions
- The requested slug `design-builder-subagent-extension` fits the objective and is used for this refined request file: it directly names the extension to be created.
- The project root does not currently contain `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, `docs/design/project-functions.md`, `docs/design/project-functions.MD`, or `Issues - Pending Items.md`; refinement therefore relies on the injected project instructions, the source spec, and existing extension examples.
- The existing extension convention is the authoritative implementation pattern because the parent agent explicitly identified it as the pattern to follow and matching examples exist under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions`.
- The extension source folder should be named `design-builder-subagent` because all comparable extensions use the `<function>-subagent` folder naming pattern.
- The tool should be named `design_builder_subagent` because existing tools use lowercase snake_case names matching their folder purpose.
- The extension should avoid adding dependencies because the existing extension examples use Node built-ins, `@earendil-works/pi-coding-agent`, and `typebox` already provided by the Pi extension environment.

## Open Questions (if any)
- **Question**: Should the child design-builder process request Serena MCP tools explicitly, or should it use only locally available file/search tools?
  - **Why it matters**: The source spec mentions Serena symbol-verification tools, but existing Pi extension examples do not assume MCP tools are available in child processes; requesting unavailable tools may break execution.
  - **Recommended default**: Use the locally proven tool set from existing extensions (`read`, `write`, `grep`, `find`, `ls`, and `bash` if needed), and instruct the child to document any limitations when Serena is unavailable.
- **Question**: Should `output_path` default derivation parse the plan frontmatter for `plan_number` and `slug`, or use a simpler next-number/slug fallback in the wrapper?
  - **Why it matters**: Parsing plan frontmatter gives better parity with the source spec, while a fallback is more robust if plans are missing metadata or use unexpected formatting.
  - **Recommended default**: Attempt to parse `plan_number` and `slug` from the plan file first; if unavailable, derive the next `design-NNN` number from existing design files and a slug from the request file or `output_slug` if the wrapper supports it.

## Original Request
I want you to study the agent described into the ./subagent-specs/design-builder.md document
 and create the extension in a dedicated subfolder under the ~/ai-coding/pi-workdocs/extensions folder
 to be used as a subagent to support this functionality.

 Then I want you to symlink the extension to be used by the current pi instance.
 If needed you can refine the request.
