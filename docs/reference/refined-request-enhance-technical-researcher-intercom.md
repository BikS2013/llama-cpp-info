# Refined Request: Enhance Technical Researcher Subagent with Pi Intercom Supervisor Coordination

## Category
Development

## Objective
Enhance the existing `technical_researcher_subagent` Pi extension so child technical-researcher processes can coordinate with their parent supervisor through `pi-intercom`, especially by using `contact_supervisor` for blocking decisions, while preserving the current tool parameters, default behavior, output contract, and isolated child-process research workflow.

## Scope
- **In scope**:
  - Study and apply the authoritative integration instructions in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
  - Update the technical-researcher subagent extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent/`.
  - Preserve the existing `technical_researcher_subagent` tool name, parameter schema, validation behavior, defaults, model-forwarding behavior, output-path behavior, and caller-facing final result behavior.
  - Add child bridge metadata environment variables required by `pi-intercom`.
  - Launch child Pi processes with a stable child intercom session name via `--name`.
  - Add `contact_supervisor` and `intercom` to the child tool allowlist without removing the existing research tools.
  - Detect child `contact_supervisor` tool-start JSON events and stream a parent-visible wait notice that instructs the supervisor to use `/intercom-reply <decision>`.
  - Update `technical-researcher-agent.md` with guidance for appropriate use of `contact_supervisor`, including blocking decision handling, progress updates, routine completion behavior, and unavailable-tool behavior.
  - Update the extension `README.md` with bridge behavior, environment variables, naming conventions, wait notice behavior, `/intercom-reply` instructions, validation steps, and any validation evidence collected.
  - Validate that the enhanced extension loads with `pi-intercom` and that existing non-intercom technical research behavior still works.
- **Out of scope**:
  - Changing the `technical_researcher_subagent` public API or removing any existing parameters.
  - Replacing the technical-researcher prompt or changing its research-document structure except for supervisor-coordination guidance.
  - Modifying the `pi-intercom` package itself unless a defect is discovered and separately approved.
  - Creating a new subagent extension instead of enhancing the existing one.
  - Performing version-control operations.
  - Modifying unrelated llama.cpp model scripts, model files, or inference wrappers.

## Requirements
1. The implementation MUST use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the authoritative integration source.
2. The implementation MUST enhance `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent/index.ts` rather than creating a separate technical-researcher extension.
3. The `technical_researcher_subagent` tool MUST retain its existing public parameters: `topic`, `why_needed`, `focus_areas`, `depth_level`, `investigation_file`, `output_path`, `cwd`, and `model`.
4. Existing parameter validation MUST be preserved, including required `topic`, existing `cwd` validation, existing `investigation_file` existence validation, and default output path resolution to `docs/research/<topic-slug>.md` under `cwd`.
5. Existing child-model selection behavior MUST be preserved, including forwarding the caller model by default and honoring explicit model selectors.
6. The child Pi launch MUST inject the following environment variables when invoking the child process:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
7. The parent supervisor target MUST be resolvable even when the parent session is unnamed, using the fallback pattern described in the integration instructions, such as `subagent-chat-<session-id-prefix>`.
8. The child intercom session name MUST be stable and deterministic for a run, using a pattern equivalent to `subagent-technical-researcher-<run-id>-1` with sanitized components.
9. The child Pi command MUST include `--name <child intercom session name>`.
10. The child tool allowlist MUST keep the existing tools `read,write,grep,find,ls,bash` and add `contact_supervisor,intercom`.
11. The parent launcher MUST parse child JSON output and detect `event.type === "tool_execution_start" && event.toolName === "contact_supervisor"`.
12. When a child starts `contact_supervisor`, the parent launcher MUST stream an `onUpdate` wait notice that includes:
    - the subagent type or tool context,
    - the `contact_supervisor` reason,
    - the child message,
    - the supervisor target,
    - the child intercom session name,
    - the exact instruction `/intercom-reply <your decision>`, and
    - a warning that normal steering cannot unblock a foreground subagent tool.
13. The wait notice MUST NOT imply that a normal steering message is sufficient while the foreground subagent tool is still running.
14. The child prompt file `technical-researcher-agent.md` MUST document when to use `contact_supervisor` with `reason: "need_decision"`, `reason: "interview_request"`, and `reason: "progress_update"`.
15. The child prompt MUST state that routine completion handoffs should be returned normally, not sent through `contact_supervisor`.
16. The child prompt MUST state that if `contact_supervisor` is unavailable or times out for a required unapproved decision, the child should stop/report the blocker rather than silently choosing.
17. The extension README MUST be updated to document the bridge environment variables, child naming convention, child tool additions, wait notice behavior, `/intercom-reply` usage, normal-steering warning, and validation steps.
18. The implementation MUST keep the extension loadable through the existing symlink path `/Users/giorgosmarinos/.pi/agent/extensions/technical-researcher-subagent` if that symlink points to the target source folder.
19. The implementation MUST avoid version-control operations.
20. Any ad hoc validation scripts, if created, MUST be placed under `/Users/giorgosmarinos/aiwork/llama-cpp/test_scripts/`.
21. If new runtime dependencies are considered, dependency validation MUST be performed before adding them; the preferred implementation should avoid new runtime dependencies by using Node/Pi APIs already available in the extension.
22. If implementation reveals a defect or pending issue, it MUST be documented in `/Users/giorgosmarinos/aiwork/llama-cpp/Issues - Pending Items.md` according to project conventions.

## Constraints
- The active project root for artifacts is `/Users/giorgosmarinos/aiwork/llama-cpp`.
- The implementation target is outside the active project root at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent/`.
- The authoritative integration reference is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
- No version-control operations are allowed.
- Existing technical-researcher behavior and parameters must remain backward compatible.
- Child processes should continue to run as isolated `pi --mode json -p --no-session` processes.
- Existing local research-tool limitations remain valid: external web/search/Context7/MCP tooling must not be assumed or fabricated.
- Project convention requires test scripts, if any, under `test_scripts/`.
- Project convention requires documenting detected issues or resolved defects in `Issues - Pending Items.md` when applicable.
- New runtime dependencies should be avoided; if unavoidable, dependency-vetting rules apply.

## Acceptance Criteria
1. `technical_researcher_subagent` still exposes the same public parameter schema and existing invocation examples remain valid.
2. `index.ts` contains the required `PI_SUBAGENT_*` bridge metadata constants or equivalent implementation.
3. Child process launch includes all required bridge environment variables and uses `--name <stable child intercom session name>`.
4. Child process launch preserves the existing child tools and includes `contact_supervisor` and `intercom`.
5. Child JSON event parsing detects `tool_execution_start` events for `contact_supervisor`.
6. A parent-visible wait notice is emitted when `contact_supervisor` starts and includes `/intercom-reply <your decision>` plus the warning that normal steering cannot unblock the child.
7. `technical-researcher-agent.md` includes supervisor-coordination guidance matching the semantics in the integration instructions.
8. `README.md` documents the bridge integration, reply procedure, normal-steering limitation, and validation approach.
9. Load validation succeeds with a command equivalent to:
   ```bash
   pi --no-extensions --offline \
     -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom \
     -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent \
     --list-models
   ```
10. Global autoload validation succeeds when the extension is symlinked under `~/.pi/agent/extensions`, using a command equivalent to `pi --offline --list-models`.
11. A normal technical research invocation that does not need supervisor coordination still writes exactly one research document at the expected output path and returns the existing concise caller report shape.
12. A bridge validation invocation can cause the child to call `contact_supervisor` before proceeding; the parent receives the wait notice while the foreground tool is still running.
13. Replying with `/intercom-reply Do not modify any file. This is a bridge test only; report that contact_supervisor reply delivery worked.` allows the child to continue and report that the supervisor reply was received.
14. The bridge-only validation does not modify files other than explicitly expected documentation or validation-evidence files.
15. No stale pending ask remains after successful completion, as verified where practical by `intercom({ action: "pending" })` or documented if not interactively tested.
16. Timeout and abort behavior are either tested or explicitly documented as not tested with a reason in the extension README or a project reference note.

## Assumptions
- The requested slug `enhance-technical-researcher-intercom` fits the objective and is used for this refined request: it directly describes enhancing the technical-researcher subagent with intercom support.
- The target extension path is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent/`: this was provided by the parent agent and confirmed by the existing project design and functional requirements.
- The symlink path is `/Users/giorgosmarinos/.pi/agent/extensions/technical-researcher-subagent`: this was provided by parent context and reflected in project documentation.
- The existing implementation should remain a TypeScript Pi extension: current extension source is `index.ts`, and project conventions require tools/extensions created in project context to be TypeScript.
- The implementation should avoid new dependencies: the required bridge behavior can reasonably be implemented with existing Node APIs, Pi extension context, and `pi-intercom` runtime integration.
- Interactive bridge tests may require a live Pi session and may not be fully automatable from a non-interactive implementation run: the integration instructions distinguish static/load validation from interactive reply validation.

## Open Questions (if any)
- **Question**: Should timeout, abort, progress-update, and interview-request validations all be executed interactively before marking the enhancement complete, or may some be documented as not tested with rationale?
  - **Why it matters**: Full interactive validation can take significantly longer, especially timeout testing, but provides stronger confidence in lifecycle behavior.
  - **Recommended default**: Perform static validation, load validation, global autoload validation, one successful blocking `need_decision` bridge test, and stale-pending verification; document timeout/abort/interview-request as not tested unless the user explicitly requests exhaustive lifecycle testing.
- **Question**: Should the implementation update `/Users/giorgosmarinos/aiwork/llama-cpp/docs/design/project-design.md` and `/Users/giorgosmarinos/aiwork/llama-cpp/docs/design/project-functions.md` after enhancing the external extension?
  - **Why it matters**: The active project already documents Pi workflow extensions, but the raw request only asks to enhance the extension, not update project design/function artifacts.
  - **Recommended default**: Update the extension README as mandatory, and update project design/functions only if downstream workflow rules or the parent agent explicitly require project documentation updates after implementation.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the technical-researcher-subagent.
I fyou need it you can proceed with request refinement.
