# Refined Request: Enhance Design Builder Subagent with Pi Intercom Supervisor Bridge

## Category
Development

## Objective
Enhance the existing `design-builder-subagent` Pi extension so its isolated child design-builder process can coordinate with the parent supervisor through `pi-intercom`, using the reusable integration pattern documented in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`, while preserving the design-builder’s current technical-design workflow, artifact-writing contract, input validation, and safety invariants.

## Scope
- **In scope**:
  - Study `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` and apply its relevant implementation, prompt, documentation, and validation guidance to the design-builder subagent.
  - Enhance the existing extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent/`.
  - Update the child process launch in `index.ts` to provide stable intercom identity, required `PI_SUBAGENT_*` bridge environment variables, and the appropriate child Pi `--name` value.
  - Add `contact_supervisor` and `intercom` to the design-builder child tool allowlist when supervisor coordination is intended.
  - Detect child JSON events for `contact_supervisor` and stream a clear parent-visible wait notice instructing the supervisor to use `/intercom-reply <decision>` while the foreground `design_builder_subagent` tool is running.
  - Update the design-builder child prompt guidance so it knows when to use `contact_supervisor`, when not to use it, and how to degrade safely if supervisor coordination is unavailable.
  - Update the design-builder README to document bridge metadata, child naming, tool allowlist additions, reply rules, validation steps, and foreground-tool steering limitations.
  - Validate the enhanced extension with static/source checks and load checks; perform an end-to-end bridge validation where feasible, or document any validation that could not be run and why.
  - Preserve the existing symlink-based installation pattern for the current Pi instance.
- **Out of scope**:
  - Changing the design-builder’s core purpose, design-file schema, project-design update behavior, implementation-unit contract rules, or artifact output contract beyond adding supervisor coordination.
  - Creating, rewriting, or modifying actual project technical design artifacts except for safe validation notes explicitly required by this enhancement.
  - Modifying the `pi-intercom` runtime package itself, unless a blocking defect is discovered and separately approved.
  - Replacing the design-builder subagent with the generic worker subagent or redesigning it as a full multi-agent framework.
  - Adding new runtime dependencies unless dependency validation is completed and the addition is clearly necessary.
  - Performing version-control operations.
  - Updating unrelated project files.

## Requirements
1. The implementer MUST read `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` before modifying the design-builder subagent.
2. The implementer MUST inspect the current design-builder extension files under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent/`, including `index.ts`, `design-builder-agent.md`, and `README.md`.
3. The implementer SHOULD use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension/index.ts` and `README.md` as the local reference implementation for bridge metadata, child naming, wait notices, and documentation style.
4. `index.ts` MUST define or reuse constants for the required bridge environment variables:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
5. Each design-builder child run MUST generate a stable run-specific child session name using a deterministic pattern equivalent to `subagent-design-builder-<run-id>-1` or another documented `subagent-<agent>-<run-id>-<index>` pattern.
6. Each design-builder child run MUST set the child Pi process `--name` argument to the same value used for `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
7. Each design-builder child run MUST set all required `PI_SUBAGENT_*` bridge environment variables in the spawned child process environment.
8. The parent supervisor target MUST resolve to the current Pi session name when available and to a stable fallback such as `subagent-chat-<session-id-prefix>` when unnamed.
9. The child tool allowlist MUST include the design-builder’s existing tools plus `contact_supervisor` and `intercom`, unless a validation shows they are unavailable and the limitation is documented.
10. The child Pi launch SHOULD continue to use isolated JSON print mode, `--no-session`, restricted tools, the design-builder prompt file, and the stable child `--name`, while preserving the current design-builder behavior.
11. The parent launcher MUST parse child JSON output for `tool_execution_start` events with `toolName === "contact_supervisor"`.
12. When the child starts `contact_supervisor`, the parent launcher MUST stream a wait notice that includes the contact reason, the supervisor target, the child intercom session name, the child message, and the exact foreground reply instruction `/intercom-reply <your decision>`.
13. The wait notice MUST warn that a normal steering message such as “reply to the subagent...” is queued until the foreground tool finishes and therefore cannot unblock the waiting child.
14. The wait notice MAY mention `intercom({ action: "reply", message: "..." })`, but only as an idle-parent alternative, not as the primary foreground reply path.
15. The parent launcher SHOULD surface useful `tool_result_end` text when the supervisor reply returns, so the supervisor can see that the child received the reply.
16. The design-builder child prompt MUST explain that `contact_supervisor` should be used for genuinely required supervisor decisions, blocking ambiguity, `need_decision`, or `interview_request`, and not for routine completion.
17. The design-builder child prompt MUST explain that `progress_update` is only for meaningful non-blocking discoveries that change the design, risk profile, or ability to satisfy the plan/request.
18. The design-builder child prompt MUST instruct the child not to write or modify design artifacts while waiting for a required supervisor decision if that decision affects the artifact content.
19. The design-builder child prompt MUST instruct the child to stop and report a blocker rather than silently choosing if `contact_supervisor` is unavailable and an unapproved decision is required.
20. The enhancement MUST preserve the existing design-builder behavior specification, including required `request_file` and `plan_file`, optional context artifacts, default output path derivation, design frontmatter schema, `docs/design/project-design.md` update behavior, source-file write prohibition, disjoint implementation-unit rules, and final caller report format.
21. The enhancement MUST NOT convert normal design review or routine “Decisions Requiring User Review” output into an always-blocking chat flow unless explicitly approved; by default, the subagent should still record user-review decisions in the design artifact and final report.
22. The README MUST document the injected bridge environment variables, child `--name` convention, updated child tool allowlist, parent wait notice behavior, `/intercom-reply <decision>` foreground reply rule, normal steering limitation, validation steps, and any validation evidence gathered.
23. The README or an appropriate reference note MUST record any bridge validation performed, including date, commands or manual steps, result, and files changed during bridge-only testing.
24. Existing installation/symlink paths SHOULD remain compatible with `/Users/giorgosmarinos/.pi/agent/extensions/design-builder-subagent`.
25. No secrets, credentials, tokens, or private environment values may be written into source, docs, or reports.
26. No unrelated project files may be modified beyond this refined request artifact, the design-builder subagent extension files, and any explicitly documented validation notes.

## Constraints
- Project root for this refined request: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request artifacts must be saved under `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/`.
- Target extension path: `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent/`.
- Current target extension source observed during refinement: `index.ts`, `README.md`, and `design-builder-agent.md` exist.
- Current child tool allowlist observed during refinement is `read,write,grep,find,ls,bash`; the bridge enhancement must add `contact_supervisor,intercom` where appropriate.
- Current child launch observed during refinement uses a spawned `pi` process in JSON mode with `--no-session` and restricted tools; the enhancement should build on that existing implementation rather than replacing it wholesale.
- `pi-intercom` is an installed runtime package and the active bridge behavior depends on it being loaded in the parent and child Pi sessions.
- The existing `pi-intercom` package already implements dedicated blocking client behavior and pending/deferred UI cleanup; this request should preserve and rely on that behavior rather than reimplementing it in the design-builder extension.
- Project-local `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, and `docs/design/project-functions.*` were not found in the project root during refinement; relevant conventions come from parent-provided project context, existing project reference files, and the observed extension files.
- `Issues - Pending Items.md` exists and currently records completed `pi-intercom`/subagent bridge fixes; it should be consulted before documenting any newly discovered issue.
- Tools/extensions created or modified in this project context should be TypeScript.
- Do not perform version-control operations unless explicitly requested.
- Do not add or update runtime dependencies without following the project dependency-validation procedure.

## Acceptance Criteria
1. `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent/index.ts` includes the required `PI_SUBAGENT_*` bridge metadata handling.
2. `index.ts` generates a run ID and stable design-builder child intercom session name for each child invocation.
3. The spawned child Pi process receives `--name <child-session-name>` and environment variable `PI_SUBAGENT_INTERCOM_SESSION_NAME=<child-session-name>` with matching values.
4. The spawned child Pi process receives `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, and `PI_SUBAGENT_CHILD_INDEX`.
5. The child tool allowlist includes `contact_supervisor` and `intercom` in addition to the design-builder’s normal tools.
6. The parent launcher detects child `contact_supervisor` start events and streams a wait notice containing the reason, supervisor target, child session name, `/intercom-reply <your decision>`, and the normal-steering warning.
7. The design-builder prompt file includes clear supervisor-coordination guidance and safe-degradation behavior.
8. The design-builder README documents the pi-intercom bridge implementation and foreground reply procedure.
9. Static source validation confirms the presence of bridge env vars, stable child naming, updated tool allowlist, contact-supervisor event parsing, and README/prompt guidance.
10. Load validation passes with a command equivalent to loading `pi-intercom` and the design-builder extension together, or any failure is documented with exact error output and next action.
11. If feasible, an interactive bridge validation demonstrates that the supervisor can reply using `/intercom-reply ...` while `design_builder_subagent` is still running and the child receives the reply.
12. If end-to-end bridge validation is not feasible in the implementation session, the reason is documented and the README includes exact manual validation steps.
13. After a successful bridge validation, no stale ask should render after completion and `intercom({ action: "pending" })` should report no unresolved inbound asks where this can be checked.
14. The existing design-builder output contract remains unchanged: the design file still includes mandatory YAML frontmatter and required sections, and the living project design document is still created or appended when the tool performs actual design work.
15. No unrelated files are modified, no secrets are exposed, no new runtime dependencies are added without vetting, and no version-control operations are performed.

## Assumptions
- The requested slug `enhance-design-builder-intercom` fits the objective and is used for this refined request file: it is under 40 characters and directly describes the enhancement.
- The intended target is the existing extension folder `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/design-builder-subagent/`: the raw request names `design-builder-subagent`, and this folder exists with the expected source files.
- The reusable integration instructions at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` are authoritative for bridge implementation details: the raw request explicitly asks to study and use them.
- The existing `worker-subagent-extension` is the best concrete local implementation reference: the integration instructions identify it as the primary reference implementation, and it already contains the required bridge pattern.
- The enhancement should preserve the design-builder’s current technical-design behavior rather than redesigning its workflow: the raw request asks to enhance it with the instructions, not to change its core design contract.
- The project root lacks local project design/function documents, so this specification relies on existing extension files, prior refined requests, completed issue notes, and parent-provided conventions.

## Open Questions (if any)
- **Question**: Should `design_builder_subagent` proactively call `contact_supervisor` whenever the design contains “Decisions Requiring User Review”, or should it continue to record those decisions in the design artifact and final report without blocking?
  - **Why it matters**: Blocking for every design-review decision changes the design-builder workflow and may require a broader orchestrator design-review loop; preserving the current artifact-based review keeps this enhancement focused on runtime blockers and unexpected unapproved decisions.
  - **Recommended default**: Preserve existing design-builder semantics; use `contact_supervisor` only when an unexpected decision is required before the child can safely write accurate design artifacts.
- **Question**: Should end-to-end bridge validation create real design artifacts from sample request/plan files, or should it use a safe bridge-only task that forces `contact_supervisor` before any artifact write?
  - **Why it matters**: Real design generation validates the full workflow but may modify project design documents; bridge-only testing validates supervisor communication with minimal risk.
  - **Recommended default**: Use a safe bridge-only task or controlled temporary fixture under the test project that explicitly forbids production/source edits and requires supervisor approval before writing artifacts.
- **Question**: Should timeout, abort, progress-update, and interview-request bridge scenarios all be tested during this enhancement?
  - **Why it matters**: Full lifecycle testing provides stronger assurance but can take significant time, especially timeout testing; some paths may be better documented as manual follow-ups.
  - **Recommended default**: Require static, load, and successful blocking `need_decision` validation now; document timeout/abort/progress/interview tests as manual or follow-up validation unless they are quick and safe to run.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the design-builder-subagent.
If you need it you can proceed with request refinement.
