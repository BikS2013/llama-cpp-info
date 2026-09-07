# Refined Request: Enhance Request Refiner Subagent with Pi Intercom Supervisor Coordination

## Category
Development

## Objective
Enhance the existing `request-refiner-subagent` Pi extension so its isolated child Pi process can use the reusable pi-intercom subagent integration pattern documented in `~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`. The enhanced request refiner must launch with stable child intercom identity, expose `contact_supervisor`/`intercom` to the child, surface parent-visible wait notices when supervisor input is requested, document the new behavior, and validate that supervisor replies can be delivered with `/intercom-reply` while the foreground `request_refiner_subagent` tool is still running.

## Scope
- **In scope**:
  - Study `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` before implementation and apply its required bridge pattern to the request-refiner subagent.
  - Inspect and modify the existing request-refiner extension source under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent/`, including `index.ts`, `request-refiner-agent.md`, and `README.md` as needed.
  - Add stable child intercom naming and required `PI_SUBAGENT_*` bridge environment variables when spawning the child Pi process.
  - Add `contact_supervisor` and `intercom` to the child tool allowlist while preserving the request-refiner's existing file-oriented capabilities.
  - Launch the child Pi process with a stable `--name` matching `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
  - Parse child JSON events for `tool_execution_start` where `toolName === "contact_supervisor"` and stream a clear parent-visible wait notice.
  - Ensure the wait notice instructs the parent to use `/intercom-reply <decision>` and warns that normal steering cannot unblock a foreground subagent tool.
  - Update the request-refiner child prompt so it understands when to use `contact_supervisor` sparingly, when to continue with documented assumptions/open questions, and how to behave if no supervisor reply is available.
  - Update the extension README with bridge metadata, child naming, allowlist additions, reply instructions, limitations, and validation steps.
  - Perform or define appropriate validation, including static/source validation, extension load validation, and an interactive bridge validation scenario.
- **Out of scope**:
  - Rewriting the request-refiner specification/template beyond what is necessary for pi-intercom integration.
  - Modifying the `pi-intercom` runtime package unless implementation reveals a concrete defect that must be handled as a separate issue.
  - Enhancing other subagents such as investigator, designer, test-builder, or dependency-validator.
  - Changing the broader request-refinement gate policy in project/user instructions.
  - Adding new runtime dependencies unless strictly necessary and dependency-validation is completed first.
  - Performing version-control operations.
  - Creating unrelated tools, prompts, plans, or project design artifacts not required for this enhancement.

## Requirements
1. The implementer must first read and use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the authoritative integration guide for this enhancement.
2. The implementer must inspect the current request-refiner extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent/` before modifying it.
3. The child Pi launch logic in `index.ts` must create a per-run stable run ID and child intercom session name using the documented subagent naming pattern or an equivalent deterministic pattern.
4. The child process environment must include all required bridge variables: `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, `PI_SUBAGENT_CHILD_INDEX`, and `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
5. The parent supervisor target must resolve to the current parent session name when available, or to a stable fallback alias based on the parent session ID when unnamed.
6. The child Pi process must be launched with `--name <child intercom session name>` matching `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
7. The child tool allowlist must include `contact_supervisor` and `intercom` in addition to the request-refiner's existing allowed tools.
8. The request-refiner child prompt must describe supervisor coordination behavior: use `contact_supervisor` with `reason='need_decision'` only for critical ambiguities that cannot safely be handled as assumptions/open questions, use `progress_update` only for meaningful non-blocking discoveries, and return the final caller report normally rather than through intercom.
9. The child prompt must instruct the subagent not to make unapproved edits while waiting for a required supervisor decision.
10. If `contact_supervisor` is unavailable or times out, the child must not silently invent a supervisor decision; it must proceed only with documented assumptions/open questions when safe, or report the blocker clearly.
11. The parent extension must parse child JSON output and detect `tool_execution_start` events for `contact_supervisor`.
12. When the child starts `contact_supervisor`, the parent extension must stream a wait notice containing the contact reason, supervisor target, child intercom session name, the child message, and the exact instruction `/intercom-reply <your decision>`.
13. The wait notice must explicitly warn that normal steering messages are queued while the foreground subagent tool is running and cannot unblock the waiting child.
14. The parent extension should surface the child-visible `contact_supervisor` tool result when practical so the supervisor can see that the reply was received.
15. Existing successful request-refinement behavior must remain intact: a refined request file is still saved under `docs/reference/refined-request-<slug>.md`, and the final subagent output still reports the output path, slug, category, scope boundaries, and open questions.
16. The extension README must document the new bridge variables, child `--name` convention, child tool allowlist, wait notice behavior, `/intercom-reply` instruction, steering limitation, and validation steps.
17. Any ad hoc validation scripts created for this work must be placed under the active project's `test_scripts/` directory.
18. The implementation must not add dependencies unless necessary; if a dependency is added, the dependency-validation process must be followed before updating manifests.
19. The implementation must not perform version-control operations.
20. The final implementation report must summarize changed files, validation performed, any skipped validation with rationale, and any remaining risks or follow-up items.

## Constraints
- Active project root for this refined request: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request output path: `docs/reference/refined-request-enhance-request-refiner-intercom.md` under the active project root.
- Requested slug `enhance-request-refiner-intercom` fits the objective and the slug constraints.
- The active project root has no local `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, or `docs/design/project-functions.*`; project conventions come from parent-provided instructions and existing files in this test project.
- `Issues - Pending Items.md` exists and currently has no pending items, but includes completed context about recent `pi-intercom` supervisor-reply lifecycle fixes.
- The existing request-refiner extension source is in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent/` and is symlinked/discoverable from `/Users/giorgosmarinos/.pi/agent/extensions/request-refiner-subagent`.
- The reusable pi-intercom subagent integration instructions are already present at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
- Existing `pi-intercom` behavior is expected to provide `contact_supervisor`, `/intercom-reply`, dedicated blocking-client lifecycle, and stale pending/deferred-message cleanup; this request should rely on that behavior rather than reimplementing it in the request-refiner extension.
- The request-refiner extension is TypeScript; code changes must remain TypeScript and compatible with the Pi extension API.
- Do not expose credentials or private token values in code, documentation, logs, or reports.
- Missing required configuration or required inputs must result in explicit errors, not silent fallback behavior.

## Acceptance Criteria
1. `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` has been reviewed and the final report references its use.
2. The request-refiner extension source has been inspected before modification.
3. `index.ts` launches the child Pi process with all required `PI_SUBAGENT_*` bridge environment variables.
4. `index.ts` launches the child Pi process with `--name` set to the stable child intercom session name.
5. The child tool allowlist includes both `contact_supervisor` and `intercom`.
6. The parent launcher detects `tool_execution_start` events where `toolName === "contact_supervisor"`.
7. The parent wait notice includes the contact reason, supervisor target, child intercom session name, `/intercom-reply <your decision>`, and the warning that normal steering cannot unblock the child.
8. The request-refiner child prompt documents the intended `contact_supervisor` behavior and preserves the ability to complete refinements with assumptions/open questions when appropriate.
9. The README for the request-refiner extension documents the integration and validation workflow.
10. Existing non-interactive refinement still works for a request that does not require supervisor input and still writes the refined request under `docs/reference/`.
11. Load validation passes for the enhanced extension together with `pi-intercom`, for example with `pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent --list-models` or an equivalent supported command.
12. An interactive bridge validation demonstrates that a request-refiner child can call `contact_supervisor` with `reason='need_decision'`, the parent sees the wait notice, `/intercom-reply <decision>` is accepted while the foreground tool is running, and the child receives the reply and completes normally.
13. Stale pending ask cleanup is checked after successful bridge validation using `intercom({ action: "pending" })` or an equivalent method, and no unresolved inbound asks remain.
14. Timeout or abort behavior is tested or explicitly documented as not tested with a reason.
15. No unrelated project files are modified.
16. No version-control operations are performed.
17. If any dependency is added, dependency-validation evidence is provided; otherwise the final report states that no new dependencies were added.

## Assumptions
- The enhancement target is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent/`: this directory exists and contains the current `request_refiner_subagent` Pi extension.
- The existing symlink/discovery path `/Users/giorgosmarinos/.pi/agent/extensions/request-refiner-subagent` should continue to be used: it already exists and points to the extension intended for the current Pi instance.
- The task is an implementation enhancement, not merely documentation, because the user asked to use the integration instructions to enhance the request-refiner subagent.
- The existing pi-intercom package already contains the required dedicated blocking-client and stale cleanup behavior described by the instructions, so request-refiner changes should focus on launcher/prompt/README integration.
- The request-refiner should remain primarily non-interactive and should only block on `contact_supervisor` for critical ambiguities where a supervisor decision is genuinely needed before producing a useful specification.
- The requested slug `enhance-request-refiner-intercom` is used because it fits the objective, is lowercase hyphen-separated, has four words, and is under 40 characters.

## Open Questions (if any)
- **Question**: Should the enhanced request-refiner actively call `contact_supervisor` for critical ambiguities, or should it only be technically capable of doing so while continuing to always produce open questions without blocking?
  - **Why it matters**: Active blocking improves real-time clarification but can pause the foreground tool until the supervisor replies; non-blocking behavior preserves the current isolated refinement workflow but underuses the new intercom bridge.
  - **Recommended default**: Allow `contact_supervisor` only for rare, critical ambiguities that would make the refined specification misleading or unusable; otherwise continue documenting assumptions and open questions.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the request-refiner-subagent.
If you need it you can proceed with request refinement.
