# Refined Request: Enhance Investigator Subagent with Pi-Intercom Supervisor Bridge

## Category
Development

## Objective
Enhance the existing `investigator_subagent` Pi extension so its child investigator process can coordinate with the supervising Pi session through the `pi-intercom` `contact_supervisor` bridge, following the authoritative integration pattern in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`, while preserving the current `investigator_subagent` tool parameters, output behavior, investigation-file contract, and normal non-interactive execution flow.

## Scope
- **In scope**:
  - Modify the investigator subagent extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent/`.
  - Add the required Pi intercom bridge metadata, stable child session naming, child `--name`, and child tool allowlist entries needed for `contact_supervisor` and `intercom`.
  - Add parent-side parsing of child JSON events so `contact_supervisor` waits are surfaced with a clear `/intercom-reply <decision>` notice.
  - Update the investigator child prompt so it knows when to use `contact_supervisor`, when not to use it, and how to behave if it is unavailable or times out.
  - Update the investigator extension README with the bridge behavior, reply instructions, validation steps, and validation evidence.
  - Validate loading and behavior according to the integration instructions, using safe, non-destructive tests.
  - Preserve existing investigation output generation under `docs/reference/investigation-<slug>.md`, including the parseable `**Research needed**: Yes|No` flag.
- **Out of scope**:
  - Rewriting the investigator subagent architecture beyond what is needed for the intercom bridge.
  - Changing, removing, or renaming existing `investigator_subagent` parameters.
  - Changing the investigation document template or the `Research needed` flag contract except where prompt additions are required for supervisor coordination.
  - Modifying `pi-intercom` itself unless implementation discovers a blocker that cannot be solved in the investigator extension.
  - Adding unrelated tools, dependencies, or model/runtime configuration.
  - Performing version-control operations.

## Requirements
1. The implementation must use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the authoritative integration specification.
2. The implementation must target the existing investigator extension source at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent/`, which is expected to be symlinked for Pi discovery at `/Users/giorgosmarinos/.pi/agent/extensions/investigator-subagent`.
3. The existing `investigator_subagent` public parameter schema must remain backward-compatible, including `investigation_request`, `cwd`, `refined_request_file`, `codebase_scan_file`, `output_path`, `output_slug`, `additional_context`, and `model`.
4. Existing validation behavior for missing or invalid inputs must be preserved, including checks for `cwd`, `refined_request_file`, `codebase_scan_file`, output creation, and parseable `Research needed` flag.
5. The child Pi process launch must inject all required bridge environment variables:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
6. The child Pi process launch must use a stable `--name <child intercom session name>` derived from the run id, agent name, and child index according to the integration instructions.
7. The child tool allowlist must preserve the investigator's current available tools and add `contact_supervisor` and `intercom`.
8. The parent launcher must resolve a supervisor/orchestrator target that works even when the parent session is unnamed, using the fallback naming pattern from the integration instructions.
9. The parent launcher must parse child JSON output and detect `tool_execution_start` events where `toolName === "contact_supervisor"`.
10. When the child calls `contact_supervisor`, the parent launcher must stream a wait notice to the supervisor that includes the contact reason, the child message, the supervisor target, the child intercom session name, the exact command `/intercom-reply <your decision>`, and a warning that normal steering cannot unblock a foreground subagent tool.
11. The wait notice wording should be adapted to the investigator context, not left as worker-specific text except where generic examples are unavoidable.
12. The investigator child prompt must instruct the child to use `contact_supervisor` with `reason='need_decision'` only when a new unapproved decision is required before continuing, use `reason='progress_update'` only for meaningful non-blocking updates or unexpected discoveries, avoid routine completion handoffs through `contact_supervisor`, and report blockers clearly if supervisor coordination is unavailable.
13. The child must continue to return its final result normally through the existing parent tool result flow after receiving a supervisor reply or after completing without needing coordination.
14. Timeout or failed supervisor replies must not result in silent unapproved decisions; the investigator should report the limitation/blocker clearly.
15. The extension README must document the injected bridge environment variables, child naming convention, child tool allowlist additions, parent wait notice, `/intercom-reply <decision>` usage, normal-steering deadlock warning, and validation steps/evidence.
16. If test scripts are created, they must be placed under `/Users/giorgosmarinos/aiwork/llama-cpp/test_scripts/` in accordance with project conventions.
17. If project-level functional/design documentation is updated as part of implementation, updates must be limited to the relevant investigator subagent capability in `docs/design/project-design.md` and `docs/design/project-functions.md`.
18. No version-control operations may be performed.
19. No runtime dependency may be added unless strictly necessary; any dependency addition must follow the project's dependency-vetting rules before changing a manifest.

## Constraints
- The authoritative implementation guide is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
- The current investigator extension has no observed `package.json` in its extension folder; avoid assuming local package scripts exist.
- Preserve existing `investigator_subagent` behavior, especially parameter compatibility and investigation output validation.
- The child investigator currently runs with restricted local tools and must not fabricate web/documentation findings when external tools are unavailable.
- The active project root for documentation and test-script conventions is `/Users/giorgosmarinos/aiwork/llama-cpp`.
- Test scripts, if any, belong in `test_scripts/` under the active project root.
- Do not modify unrelated project files.
- Do not perform version-control operations.
- Do not create configuration fallbacks; missing required configuration must fail clearly.

## Acceptance Criteria
1. Static source inspection of `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent/index.ts` confirms all required `PI_SUBAGENT_*` bridge environment variables are set for the child process.
2. Static source inspection confirms the child Pi launch includes `--name <stable child intercom session name>`.
3. Static source inspection confirms the child tool allowlist includes both `contact_supervisor` and `intercom` while preserving the investigator's existing core tools.
4. Static source inspection confirms the parent launcher detects `tool_execution_start` events for `contact_supervisor`.
5. Static source inspection confirms the parent wait notice includes `/intercom-reply <your decision>` and explicitly warns that normal steering cannot unblock the foreground subagent tool.
6. Static source inspection confirms the wait notice includes the contact reason, supervisor target, child intercom session name, and child message.
7. The investigator prompt includes supervisor-coordination guidance aligned with the integration instructions.
8. The README for the investigator extension documents the bridge behavior, required reply command, normal-steering warning, and validation steps/evidence.
9. Load validation passes with `pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent --list-models` or an equivalent Pi load command appropriate to the local environment.
10. Global autoload validation passes after reload/restart when the symlink under `/Users/giorgosmarinos/.pi/agent/extensions/investigator-subagent` is active.
11. A safe bridge validation demonstrates that when the investigator child calls `contact_supervisor` with `reason='need_decision'`, the supervisor receives the wait notice while the foreground `investigator_subagent` tool is still running.
12. A safe bridge validation demonstrates that replying with `/intercom-reply <decision>` unblocks the child, the child receives the reply, and the investigator returns a normal final result.
13. The bridge validation does not modify files unless the supervisor explicitly authorizes such modifications.
14. After successful completion, `intercom({ action: "pending" })` reports no unresolved inbound asks, or equivalent validation evidence shows there are no stale pending asks.
15. Timeout and abort behavior are either tested according to the integration instructions or explicitly documented as intentionally not tested with the reason.
16. Existing investigator behavior still works for a normal investigation that does not call `contact_supervisor`: it writes the expected investigation markdown file and returns a parseable `Research needed` value.
17. No existing `investigator_subagent` parameter is removed, renamed, or made incompatible.
18. No unrelated files are modified, and no version-control operations are performed.

## Assumptions
- The requested slug `enhance-investigator-intercom` fits the objective and is used for this refined request file: The raw request asks to enhance the investigator subagent using pi-intercom integration instructions.
- The target extension is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent/`: The parent agent identified this as the likely target, and project documentation lists it as the source for the installed investigator extension.
- The discovery symlink is expected at `/Users/giorgosmarinos/.pi/agent/extensions/investigator-subagent`: Project documentation lists this symlink as the installed Pi extension path.
- The existing investigator subagent should remain locally focused and non-fabricating when web tools are unavailable: This is already part of the investigator prompt and README.
- The implementation can follow the worker-subagent integration pattern referenced by the instructions without reading or modifying `pi-intercom` internals unless a blocker appears: The integration instructions state the active `pi-intercom` package already implements the required dedicated blocking-client behavior.

## Open Questions (if any)
- **Question**: Should timeout and abort bridge validations be executed fully, given that timeout validation can take up to approximately 10 minutes and abort validation may require manual/session-level interaction?
  - **Why it matters**: Fully executing these tests increases confidence in lifecycle cleanup but may slow implementation and require interactive supervision.
  - **Recommended default**: Run static, load, normal-investigation, and successful blocking-reply validations; document timeout/abort validation as not fully executed unless the user explicitly authorizes the additional interactive/time-consuming tests.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the investigator-subagent.
I fyou need it you can proceed with request refinement.
