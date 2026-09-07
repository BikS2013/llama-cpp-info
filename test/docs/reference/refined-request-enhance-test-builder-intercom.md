# Refined Request: Enhance Test Builder Subagent with Pi Intercom Supervisor Bridge

## Category
Development

## Objective
Enhance the Pi `test_builder_subagent` extension so its child Pi process can communicate with the supervising parent session through `pi-intercom`, including blocking `contact_supervisor` decisions that can be answered with `/intercom-reply` while the foreground `test_builder_subagent` tool is still running. The implementation should follow the reusable bridge instructions in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` and align with the proven pattern already used by `worker-subagent-extension`, `dependency-validator-subagent`, and `plan-builder-subagent`.

## Scope
- **In scope**:
  - Update the existing test builder subagent extension implementation, identified by the registered tool name `test_builder_subagent` and the discovered source directory `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/test-builder-extension/`.
  - Add child intercom bridge metadata environment variables, stable child session naming, parent supervisor target resolution, and child `--name` launch configuration.
  - Add `contact_supervisor` and `intercom` to the child Pi tool allowlist while preserving the test builder's existing tool permissions and safety model.
  - Parse child JSON events for `contact_supervisor` tool starts and stream a clear parent-visible wait notice that instructs use of `/intercom-reply <decision>`.
  - Surface useful child tool-result/final-output information so the supervisor can see when the child received a reply and completed.
  - Update the test builder child prompt with appropriate `contact_supervisor` usage guidance while preserving the current no-production-edits, test ownership, and non-interactive safety invariants.
  - Update the test builder extension README with bridge behavior, reply instructions, limitations of normal steering, and validation steps.
  - Validate the enhanced extension at least with static/source validation and load validation; document which interactive/lifecycle validations were performed or intentionally deferred.
- **Out of scope**:
  - Changing the `pi-intercom` package internals unless a blocker is found in the already-implemented bridge support.
  - Reworking the test builder workflow, report schema, test ownership rules, or test-writing behavior beyond supervisor-bridge integration.
  - Adding new runtime dependencies.
  - Creating or modifying unrelated subagent extensions other than using them as implementation references.
  - Performing version-control operations.

## Requirements
1. Read and apply `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the primary integration specification.
2. Use the implementation pattern from the already-enhanced subagent extensions, especially stable session naming and wait-notice behavior in `worker-subagent-extension`, `dependency-validator-subagent`, and `plan-builder-subagent`.
3. Define and use the required bridge environment variables when launching the child Pi process:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
4. Resolve the parent supervisor target to the current session name when available, and otherwise use the documented fallback pattern `subagent-chat-<session-id-prefix>`.
5. Generate a deterministic child intercom session name using the documented pattern `subagent-<agent>-<run-id>-<index>` with sanitized target parts.
6. Launch the child Pi process with `--name <child intercom session name>` and bridge environment variables so `pi-intercom` can register child-only `contact_supervisor` support.
7. Preserve JSON print-mode execution and the test builder's child prompt usage, while matching the established launcher pattern where practical.
8. Extend the child tool allowlist from `read,write,edit,grep,find,ls,bash` to include `contact_supervisor,intercom`.
9. Detect child JSON events where `event.type === "tool_execution_start"` and `event.toolName === "contact_supervisor"`.
10. When a `contact_supervisor` start event is detected, stream a parent-visible wait notice that includes:
    - the reason,
    - the child message,
    - the supervisor target,
    - the child intercom session name,
    - the exact instruction `/intercom-reply <your decision>`, and
    - a warning that normal steering messages cannot unblock a foreground subagent tool.
11. If the parent launcher surfaces `tool_result_end` events, include enough text for the supervisor to confirm that a reply was received, without flooding output.
12. Update `test-builder-agent.md` so the child subagent knows when to use `contact_supervisor` for `need_decision`, `interview_request`, and meaningful `progress_update` cases, and knows not to send routine completion through `contact_supervisor`.
13. Preserve the test builder prompt's existing rule that it must not ask interactive user questions; supervisor contact is only for live supervisor coordination when the tool is available and a required unapproved decision would otherwise block safe progress.
14. Preserve the test builder safety invariants: no production source edits, declared `test_files_owned`, no shared test infrastructure edits, scope-only test execution, and structured report output.
15. Update `README.md` in the test builder extension to document:
    - injected bridge environment variables,
    - child `--name` convention,
    - child tool allowlist addition,
    - parent wait notice behavior,
    - `/intercom-reply <decision>` as the foreground reply mechanism,
    - warning against normal steering while the foreground tool is running,
    - validation commands and expected outcomes.
16. Run or document static validation confirming the source contains the bridge variables, `--name`, `contact_supervisor`, `intercom`, wait-notice detection, and README/prompt updates.
17. Run or document load validation for the enhanced extension together with `pi-intercom` using a command equivalent to `pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/test-builder-extension --list-models`.
18. If interactive bridge, stale-message cleanup, timeout, abort, progress-update, or interview-request validation cannot be performed in the current execution context, explicitly record them as deferred with recommended follow-up steps.
19. Do not add dependencies or change dependency manifests as part of this work.
20. Do not modify files outside the target extension and any required project reference/test evidence files.

## Constraints
- The active project root for artifacts is `/Users/giorgosmarinos/aiwork/llama-cpp/test`; refined requests and reference material belong under its `docs/reference/` directory.
- The target extension source discovered during refinement is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/test-builder-extension/`, although the raw request refers to `test-builder-subagent` conceptually.
- Project context files `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, and `docs/design/project-functions.*` were not present under the active project root; the root `Issues - Pending Items.md` was present and contains prior pi-intercom bridge fixes.
- Existing pi-intercom bridge behavior is documented in prior fix notes and should not be regressed, especially the immediate `/intercom-reply` workflow and stale queued ask cleanup.
- The implementation must respect the existing test builder extension safety contract and must not broaden its test-writing authority.
- No version-control operations may be performed unless explicitly requested.
- Any ad hoc test scripts, if needed, must be placed under `test_scripts/` in the active project root.
- Configuration settings must not use silent fallback behavior; missing required configuration should produce explicit errors.

## Acceptance Criteria
1. The test builder extension source contains the five required `PI_SUBAGENT_*` bridge environment variables and uses them when spawning the child Pi process.
2. The child Pi launch includes a stable `--name <child intercom session name>` argument and passes a deterministic child session name to both the launch args and environment.
3. The child tool allowlist includes `contact_supervisor` and `intercom` in addition to the original test builder tools.
4. The parent launcher detects `tool_execution_start` events for `contact_supervisor` and streams a wait notice containing the reason, supervisor target, child session name, `/intercom-reply <your decision>`, and the normal-steering warning.
5. The child prompt includes supervisor coordination guidance for `need_decision`, `interview_request`, and meaningful `progress_update`, and still forbids routine completion handoffs through `contact_supervisor`.
6. The child prompt still preserves all existing test builder safety invariants and output/report requirements.
7. The README documents the bridge metadata, child naming convention, tool allowlist, wait notice, `/intercom-reply` usage, normal-steering limitation, and validation steps.
8. Static/source validation confirms the expected bridge-related strings and code paths are present in the enhanced extension.
9. Load validation of the enhanced test builder extension with `pi-intercom` exits successfully without extension registration or runtime import errors, or any failure is documented with actionable diagnostics.
10. If an interactive bridge test is performed, a foreground `test_builder_subagent` task can call `contact_supervisor(reason="need_decision")`, the parent can reply with `/intercom-reply`, the child receives the reply, and the child completes without modifying files unless explicitly authorized.
11. If stale-message cleanup validation is performed, no old ask reappears after completion and `intercom({ action: "pending" })` reports no unresolved asks.
12. Any deferred validations are listed with reason, risk, and exact recommended follow-up command or procedure.
13. No new runtime dependencies are added.
14. No unrelated files are modified.

## Assumptions
- The requested slug `enhance-test-builder-intercom` fits the objective and is used for the refined request file: it directly describes enhancing the test builder with intercom support.
- The intended target is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/test-builder-extension/`: the parent context named a `test-builder-subagent` extension, but the filesystem contains `test-builder-extension/` with the `test_builder_subagent` tool and matching README/prompt/source.
- The existing `pi-intercom` package already implements the required dedicated blocking client and stale pending/deferred UI cleanup behavior: this is stated in the integration instructions and prior issue notes.
- The implementation should copy/adapt the established bridge pattern rather than invent a new bridge architecture: the raw request explicitly points to the reusable integration instructions and parent context names three existing reference implementations.
- Interactive validation may require a live Pi session and supervisor input; if the downstream implementation context cannot provide that, documenting deferred validation is acceptable for non-blocking lifecycle tests.

## Open Questions (if any)
- **Question**: Should the extension directory be renamed from `test-builder-extension` to `test-builder-subagent` for naming consistency?
  - **Why it matters**: Renaming would affect installation symlinks, documentation paths, and any users/scripts that reference the existing extension directory.
  - **Recommended default**: Do not rename; keep `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/test-builder-extension/` and document that it provides the `test_builder_subagent` tool.
- **Question**: Should the child launch switch from the current `--append-system-prompt` style to the `--system-prompt` style shown in the integration instructions?
  - **Why it matters**: The reference bridge examples use `--system-prompt`, but the test builder currently appends its prompt; changing prompt semantics could alter inherited behavior.
  - **Recommended default**: Preserve the current prompt-loading semantics unless a load/behavior test proves it prevents bridge operation.
- **Question**: Which validation levels must be completed before marking the implementation done in this environment?
  - **Why it matters**: Full interactive, timeout, abort, progress-update, and interview-request tests require live Pi sessions and can take significant time.
  - **Recommended default**: Require static/source and load validation immediately; perform one successful interactive `need_decision` bridge test if a live supervisor session is available; document timeout/abort/interview tests as deferred unless explicitly requested.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the test-builder-subagent.
I fyou need it you can proceed with request refinement.
