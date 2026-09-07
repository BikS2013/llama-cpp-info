# Refined Request: Enhance Plan Builder Subagent with Pi-Intercom Supervisor Bridge

## Category
Development

## Objective
Enhance the `plan_builder_subagent` Pi extension so its child Plan Builder process can communicate with the parent/supervisor Pi session through the existing `pi-intercom` supervisor bridge pattern, matching the proven behavior already implemented in `worker-subagent-extension` and `dependency-validator-subagent`. The enhancement must let the Plan Builder child use `contact_supervisor` for blocking decisions or meaningful progress updates, surface clear parent-visible wait notices, document the `/intercom-reply` foreground reply flow, and validate that the extension loads and follows the integration instructions.

## Scope
- **In scope**:
  - Study and apply `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
  - Modify `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent/index.ts` to add the supervisor bridge pattern used by the worker and dependency-validator subagents.
  - Update `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent/plan-builder-agent.md` with child prompt guidance for `contact_supervisor` usage.
  - Update `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent/README.md` with bridge behavior, reply instructions, and validation steps/evidence.
  - Validate the implementation through static/source checks and extension load checks; document interactive bridge tests that require a live foreground Pi session.
- **Out of scope**:
  - Rewriting the plan-builder planning workflow, plan file schema, or acceptance-criteria mapping behavior except where needed to document supervisor coordination.
  - Changing the `pi-intercom` runtime package unless implementation reveals a directly blocking defect in the existing bridge infrastructure.
  - Modifying unrelated subagent extensions beyond using them as references.
  - Performing broad refactors, dependency upgrades, or version-control operations.

## Requirements
1. The implementation must use the integration instructions in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the primary specification for the supervisor bridge.
2. The Plan Builder child process must be launched with a stable intercom session name via `--name <child-intercom-session-name>`.
3. The Plan Builder child process environment must include all required bridge metadata variables:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
4. The Plan Builder child tool allowlist must include `contact_supervisor` and `intercom` in addition to the tools it already needs for plan creation.
5. Parent/supervisor target resolution must follow the existing fallback pattern used by the reference subagents: use the parent session name when present, otherwise use `subagent-chat-<session-id-prefix>`.
6. Plan Builder child session naming must be deterministic for a run and use a sanitized `subagent-plan-builder-<run-id>-1`-style pattern.
7. The Plan Builder launcher must parse child JSON output and detect `tool_execution_start` events where `toolName === "contact_supervisor"`.
8. When the child starts `contact_supervisor`, the parent-visible update must include:
   - the contact reason,
   - the supervisor target,
   - the child intercom session name,
   - the child message,
   - the explicit foreground reply command `/intercom-reply <your decision>`, and
   - a warning that normal steering messages cannot unblock a foreground `plan_builder_subagent` call.
9. The Plan Builder launcher should surface useful `tool_result_end` text where practical so the supervisor can see that a reply was received.
10. The launcher should preserve existing behavior for model forwarding, required file validation, output path resolution, final plan creation checks, error diagnostics, and returned details.
11. The Plan Builder child prompt must explain when to use `contact_supervisor`:
    - `need_decision` for a required unapproved decision before continuing,
    - `interview_request` for structured multi-answer supervisor input,
    - `progress_update` only for meaningful non-blocking discoveries that affect the plan,
    - never for routine completion.
12. The Plan Builder child prompt must state that if `contact_supervisor` is unavailable and an unapproved decision is required, the child should stop or record the blocker/open question rather than silently choosing.
13. The Plan Builder child prompt must preserve its planning-only invariant: it must not modify source files, and must only write the plan file and project functions file as already allowed.
14. The README must document the injected environment variables, child naming convention, child tool allowlist additions, wait notice behavior, `/intercom-reply` rule, normal-steering limitation, and validation steps.
15. Validation must include at least a static/source check confirming required bridge code and documentation are present.
16. Validation must include a load check that Pi can load `pi-intercom` and `plan-builder-subagent` together without extension registration/runtime errors.
17. If an interactive foreground bridge test cannot be completed in the implementation environment, the README must explicitly record it as not run and explain that it requires an interactive Pi session after reload/restart.
18. No version-control operation may be performed unless separately requested by the user.

## Constraints
- The active project root for refinement artifacts is `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- The target implementation appears to live outside the active project root at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent/`.
- Existing reference implementations are available at:
  - `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension/`
  - `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/`
- The `pi-intercom` runtime package is expected to already implement the dedicated blocking-client behavior and `/intercom-reply` command; do not duplicate that runtime functionality in the Plan Builder extension.
- Implementation must remain TypeScript for extension code.
- Configuration settings must not use fallback values where project rules require explicit configuration; for this bridge, the only allowed fallback is the documented intercom target naming fallback for unnamed parent sessions.
- Any ad hoc test scripts, if created, must be placed under `/Users/giorgosmarinos/aiwork/llama-cpp/test/test_scripts/`.
- Do not modify unrelated project files.

## Acceptance Criteria
1. `plan-builder-subagent/index.ts` imports or otherwise uses UUID generation and defines the required `PI_SUBAGENT_*` bridge constants.
2. `plan-builder-subagent/index.ts` includes `contact_supervisor` and `intercom` in the child tool allowlist.
3. `plan-builder-subagent/index.ts` launches child Pi with `--name <child-intercom-session-name>` and injects all required bridge environment variables into the child process environment.
4. `plan-builder-subagent/index.ts` computes the parent supervisor target using the parent session name when available and the `subagent-chat-<session-id-prefix>` fallback otherwise.
5. `plan-builder-subagent/index.ts` detects `tool_execution_start` events for `contact_supervisor` and streams a wait notice containing `/intercom-reply <your decision>` and the warning against normal steering.
6. `plan-builder-subagent/index.ts` preserves existing successful plan-builder behavior: when the child completes successfully and the expected plan output file exists, the tool returns the child final text and relevant details.
7. `plan-builder-agent.md` contains a supervisor coordination section or equivalent guidance covering blocking decisions, progress updates, interview requests, routine completion, unavailable bridge behavior, and the no-source-edits planning invariant.
8. `README.md` documents the pi-intercom supervisor bridge, including env vars, child naming, tool allowlist, wait notice, `/intercom-reply`, normal-steering limitation, validation commands, and validation evidence.
9. Static validation using a command equivalent to `rg -n "PI_SUBAGENT_|contact_supervisor|intercom-reply|tool_execution_start|--name|--no-skills" /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent` shows the required bridge pieces.
10. Load validation using a command equivalent to `pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent --list-models` exits successfully.
11. If global autoload is configured, `pi --offline --list-models` exits successfully after the extension is updated/reloaded.
12. README validation evidence states which interactive tests were run or not run; any not-run tests include the reason and recommended manual follow-up.
13. No files outside the Plan Builder extension and required validation/reference documentation are changed, unless a directly blocking issue is found and explicitly documented.

## Assumptions
- The requested slug `enhance-plan-builder-intercom` fits the objective and is used for this refined request file.
- No `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, or `docs/design/project-functions.md` file exists inside `/Users/giorgosmarinos/aiwork/llama-cpp/test`; refinement proceeds using the provided project-level instructions and the discovered pending-items file.
- The parent agent has already obtained permission to run request refinement, as stated in the additional context.
- The Plan Builder extension should mirror the dependency-validator and worker bridge implementation patterns rather than introducing a new abstraction layer.
- Interactive bridge validation may require a live Pi UI session and may not be fully automatable in a non-interactive implementation run.

## Open Questions (if any)
Open Questions: none.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the plan-builder-subagent.
I fyou need it you can proceed with request refinement.
