# Refined Request: Enhance Dependency Validator Subagent with Pi Intercom Supervisor Bridge

## Category
Development

## Objective
Enhance the existing `dependency-validator-subagent` Pi extension so its child dependency-validator process can coordinate with the parent supervisor through `pi-intercom` using the reusable integration pattern documented in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`, while preserving the dependency-validator’s current dependency hygiene workflow, safety invariants, and report output contract.

## Scope
- **In scope**:
  - Study `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` and apply relevant implementation, prompt, documentation, and validation guidance to the dependency-validator subagent.
  - Enhance the existing extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/`.
  - Update the child process launch in `index.ts` to provide stable intercom identity, required `PI_SUBAGENT_*` bridge environment variables, and the appropriate child Pi `--name` value.
  - Add `contact_supervisor` and `intercom` to the dependency-validator child tool allowlist when supervisor coordination is intended.
  - Detect child JSON events for `contact_supervisor` and stream a clear parent-visible wait notice that instructs the supervisor to use `/intercom-reply <decision>` while the foreground `dependency_validator_subagent` tool is running.
  - Update the dependency-validator child prompt guidance so it knows when to use `contact_supervisor`, when not to use it, and how to degrade safely if supervisor coordination is unavailable.
  - Update the dependency-validator README to document bridge metadata, child naming, tool allowlist additions, reply rules, validation steps, and known foreground-tool steering limitations.
  - Validate the enhanced extension with static/source checks and load checks; perform an end-to-end bridge validation where feasible, or document any validation that could not be run and why.
  - Preserve the existing symlink-based installation pattern for the current Pi instance.
- **Out of scope**:
  - Running dependency validation against this or any other target project except as a minimal, explicitly safe validation task required to test the supervisor bridge.
  - Changing the dependency-validator’s core purpose, modes, report frontmatter schema, dependency replacement policy, or package-manager behavior beyond adding supervisor coordination.
  - Modifying the `pi-intercom` runtime package itself, unless a blocking defect is discovered and separately approved.
  - Rebuilding the extension as a full generic multi-agent framework or replacing it with the worker subagent implementation.
  - Adding new runtime dependencies unless dependency validation is completed and the addition is clearly necessary.
  - Performing version-control operations.

## Requirements
1. The implementer MUST read `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` before modifying the dependency-validator subagent.
2. The implementer MUST inspect the current dependency-validator extension files under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/`, including `index.ts`, `dependency-validator-agent.md`, and `README.md`.
3. The implementer SHOULD use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension/index.ts` and `README.md` as the local reference implementation for bridge metadata, child naming, wait notices, and documentation style.
4. `index.ts` MUST define or reuse constants for the required bridge environment variables:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
5. Each dependency-validator child run MUST generate a stable run-specific child session name using a deterministic pattern equivalent to `subagent-dependency-validator-<run-id>-1` or another documented `subagent-<agent>-<run-id>-<index>` pattern.
6. Each dependency-validator child run MUST set the child Pi process `--name` argument to the same value used for `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
7. Each dependency-validator child run MUST set all required `PI_SUBAGENT_*` bridge environment variables in the spawned child process environment.
8. The parent supervisor target MUST resolve to the current Pi session name when available and to a stable fallback such as `subagent-chat-<session-id-prefix>` when unnamed.
9. The child tool allowlist MUST include the dependency-validator’s existing tools plus `contact_supervisor` and `intercom`, unless a validation shows they are unavailable and the limitation is documented.
10. The child Pi launch SHOULD align with the reusable integration instructions by using isolated JSON print mode, `--no-session`, `--no-skills`, `--tools <allowlist>`, the dependency-validator prompt file, and the stable child `--name`.
11. The parent launcher MUST parse child JSON output for `tool_execution_start` events with `toolName === "contact_supervisor"`.
12. When the child starts `contact_supervisor`, the parent launcher MUST stream a wait notice that includes the contact reason, the supervisor target, the child intercom session name, the child message, and the exact foreground reply instruction `/intercom-reply <your decision>`.
13. The wait notice MUST warn that a normal steering message such as “reply to the subagent...” is queued until the foreground tool finishes and therefore cannot unblock the waiting child.
14. The wait notice MAY mention `intercom({ action: "reply", message: "..." })`, but only as an idle-parent alternative, not as the primary foreground reply path.
15. The parent launcher SHOULD surface useful `tool_result_end` text when the supervisor reply returns, so the supervisor can see that the child received the reply.
16. The dependency-validator child prompt MUST explain that `contact_supervisor` should be used for new unapproved decisions, blocking ambiguity, `need_decision`, or `interview_request`, and not for routine completion.
17. The dependency-validator child prompt MUST explain that `progress_update` is only for meaningful non-blocking discoveries that change the plan or risk profile.
18. The dependency-validator child prompt MUST instruct the child not to make edits while waiting for a required supervisor decision.
19. The dependency-validator child prompt MUST instruct the child to stop and report a blocker rather than silently choosing if `contact_supervisor` is unavailable and an unapproved decision is required.
20. The enhancement MUST preserve the dependency-validator’s existing behavior specification, including `report-only`, `fix`, and `interactive` modes; mandatory markdown report frontmatter; command audit trail; iteration limits; read-only report-only invariant; and safety constraints around transitive dependencies and major-version bumps.
21. The enhancement MUST NOT change `interactive` mode into an always-blocking chat flow unless explicitly approved; by default, interactive mode should continue to write an unapplied plan/report and return it to the caller.
22. The README MUST document the injected bridge environment variables, child `--name` convention, updated child tool allowlist, parent wait notice behavior, `/intercom-reply <decision>` foreground reply rule, normal steering limitation, validation steps, and any validation evidence gathered.
23. The README or an appropriate reference note MUST record any bridge validation performed, including date, commands or manual steps, result, and files changed during bridge-only testing.
24. Existing installation/symlink paths SHOULD remain compatible with `/Users/giorgosmarinos/.pi/agent/extensions/dependency-validator-subagent` and `/Users/giorgosmarinos/.pi/agent/agents/dependency-validator.md`.
25. No secrets, credentials, tokens, or private environment values may be written into source, docs, or reports.
26. No unrelated project files may be modified beyond this refined request artifact, the dependency-validator subagent extension files, and any explicitly documented validation notes.

## Constraints
- Project root for this refined request: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request artifacts must be saved under `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/`.
- Target extension path: `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/`.
- Current target extension source observed during refinement: `index.ts`, `README.md`, and `dependency-validator-agent.md` exist.
- Current child tool allowlist observed during refinement is `read,write,edit,grep,find,ls,bash`; the bridge enhancement must add `contact_supervisor,intercom` where appropriate.
- Current child launch observed during refinement uses a spawned `pi` process in JSON mode; the enhancement should build on that existing implementation rather than replacing it wholesale.
- `pi-intercom` is an installed runtime package and the active bridge behavior depends on it being loaded in the parent and child Pi sessions.
- The existing `pi-intercom` package already implements dedicated blocking client behavior and pending/deferred UI cleanup; this request should preserve and rely on that behavior rather than reimplementing it in the dependency-validator extension.
- Project-local `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, and `docs/design/project-functions.*` were not found in the project root during refinement; relevant conventions come from parent-provided project context and existing project reference files.
- `Issues - Pending Items.md` exists and currently records completed `pi-intercom`/subagent bridge fixes; it should be consulted before documenting any newly discovered issue.
- Tools/extensions created or modified in this project context should be TypeScript.
- Do not perform version-control operations unless explicitly requested.
- Do not add or update runtime dependencies without following the project dependency-validation procedure.

## Acceptance Criteria
1. `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/index.ts` includes the required `PI_SUBAGENT_*` bridge metadata handling.
2. `index.ts` generates a run ID and stable dependency-validator child intercom session name for each child invocation.
3. The spawned child Pi process receives `--name <child-session-name>` and environment variable `PI_SUBAGENT_INTERCOM_SESSION_NAME=<child-session-name>` with matching values.
4. The spawned child Pi process receives `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, and `PI_SUBAGENT_CHILD_INDEX`.
5. The child tool allowlist includes `contact_supervisor` and `intercom` in addition to the dependency-validator’s normal tools.
6. The parent launcher detects child `contact_supervisor` start events and streams a wait notice containing the reason, supervisor target, child session name, `/intercom-reply <your decision>`, and the normal-steering warning.
7. The dependency-validator prompt file includes clear supervisor-coordination guidance and safe-degradation behavior.
8. The dependency-validator README documents the pi-intercom bridge implementation and foreground reply procedure.
9. Static source validation confirms the presence of bridge env vars, stable child naming, updated tool allowlist, contact-supervisor event parsing, and README/prompt guidance.
10. Load validation passes with a command equivalent to loading `pi-intercom` and the dependency-validator extension together, or any failure is documented with exact error output and next action.
11. If feasible, an interactive bridge validation demonstrates that the supervisor can reply using `/intercom-reply ...` while `dependency_validator_subagent` is still running and the child receives the reply.
12. If end-to-end bridge validation is not feasible in the implementation session, the reason is documented and the README includes exact manual validation steps.
13. After a successful bridge validation, no stale ask should render after completion and `intercom({ action: "pending" })` should report no unresolved inbound asks where this can be checked.
14. The existing dependency-validator output report contract remains unchanged: reports still include mandatory YAML frontmatter and the documented sections when the tool is used for actual validation.
15. No unrelated files are modified, no secrets are exposed, no new runtime dependencies are added without vetting, and no version-control operations are performed.

## Assumptions
- The requested slug `enhance-dependency-validator-intercom` fits the objective and is used for this refined request file: it is under 40 characters and directly describes the enhancement.
- The intended target is the existing extension folder `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/dependency-validator-subagent/`: parent context named the dependency-validator subagent/tooling, and this folder exists with the expected source files.
- The reusable integration instructions at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` are authoritative for bridge implementation details: the raw request explicitly asks to study and use them.
- The existing `worker-subagent-extension` is the best concrete local implementation reference: the integration instructions identify it as the primary reference implementation, and it already contains the required bridge pattern.
- The enhancement should preserve the dependency-validator’s existing validation/fix behavior rather than redesigning its workflow: the raw request asks to enhance it with the instructions, not to change its core dependency-validation contract.
- The project root lacks local project design/function documents, so this specification relies on existing extension files, prior refined requests, the completed issue notes, and parent-provided conventions.

## Open Questions (if any)
- **Question**: Should `dependency_validator_subagent` proactively call `contact_supervisor` during `interactive` mode to request approval, or should `interactive` mode remain a non-blocking plan/report mode that returns approval needs to the caller?
  - **Why it matters**: Making `interactive` mode block for supervisor approval changes the tool’s established contract and may require a larger workflow redesign; preserving it keeps the enhancement focused on unapproved decisions discovered during execution.
  - **Recommended default**: Preserve existing `interactive` semantics; use `contact_supervisor` only when an unexpected unapproved decision is required during execution.
- **Question**: Should end-to-end bridge validation intentionally run a real package-manager dependency validation task, or should it use a safe bridge-only task that forces `contact_supervisor` before any dependency work?
  - **Why it matters**: Real validation may mutate target projects or take substantial time, especially outside report-only mode; bridge-only testing validates the integration with minimal risk.
  - **Recommended default**: Use a safe bridge-only or report-only validation task that explicitly forbids edits and asks the child to contact the supervisor before proceeding.
- **Question**: Should timeout, abort, progress-update, and interview-request bridge scenarios all be tested during this enhancement?
  - **Why it matters**: Full lifecycle testing provides stronger assurance but can take significant time, especially timeout testing; some paths may be better documented as manual follow-ups.
  - **Recommended default**: Require static, load, and successful blocking `need_decision` validation now; document timeout/abort/progress/interview tests as manual or follow-up validation unless they are quick and safe to run.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the dependency-validator-subagent.
I fyou need it you can proceed with request refinement.
