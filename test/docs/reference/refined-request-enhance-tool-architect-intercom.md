# Refined Request: Enhance Tool Doc Config Architect Subagent with Pi Intercom Supervisor Coordination

## Category
Development

## Objective
Enhance the existing `tool-doc-config-architect-subagent` Pi extension so its isolated child Pi process can coordinate with the parent supervisor through `pi-intercom` using the reusable integration pattern documented in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`, while preserving the tool-doc-config-architect's scaffold/audit contracts, strict audit read-only behavior, no-fallback configuration rules, and structured report output.

## Scope
- **In scope**:
  - Study `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` before implementation and apply its required bridge pattern to the tool-doc-config-architect subagent.
  - Enhance the existing extension under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent/`, especially `index.ts`, `tool-doc-config-architect-agent.md`, and `README.md`.
  - Add stable child intercom naming and all required `PI_SUBAGENT_*` bridge environment variables when spawning the child Pi process.
  - Add `contact_supervisor` and `intercom` to the child tool allowlist while preserving the existing tool-doc-config-architect tools required for scaffold and audit workflows.
  - Launch the child Pi process with a stable `--name` value matching `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
  - Align child launch isolation with the integration instructions where compatible, including JSON print mode, no regular session, appropriate skills behavior, the prompt file, the tool allowlist, and the stable child name.
  - Parse child JSON events for `tool_execution_start` where `toolName === "contact_supervisor"` and stream a clear parent-visible wait notice.
  - Ensure the wait notice instructs the parent to use `/intercom-reply <decision>` and warns that normal steering cannot unblock a foreground subagent tool.
  - Surface useful child `tool_result_end` text when practical so the supervisor can see that a supervisor reply was received.
  - Update the child prompt so it explains when to use `contact_supervisor` sparingly, how to use `progress_update`, how to handle unavailable/timed-out supervisor coordination, and how to preserve scaffold/audit safety rules while waiting for decisions.
  - Update the extension README with bridge metadata, child naming, allowlist additions, reply instructions, steering limitations, and validation steps.
  - Validate the enhanced extension with static/source checks and load checks; perform an interactive bridge validation where feasible, or document any validation that could not be run and why.
- **Out of scope**:
  - Changing the core tool documentation/configuration conventions enforced by the tool-doc-config-architect.
  - Changing the scaffold/audit input contract, report frontmatter schema, or output report structure except for documentation needed to explain supervisor coordination.
  - Allowing audit mode to write files or relaxing any audit read-only invariant.
  - Modifying the `pi-intercom` runtime package unless a concrete defect is discovered and separately approved.
  - Enhancing unrelated subagents such as request-refiner, investigator, dependency-validator, design-builder, plan-builder, or test-builder.
  - Adding new runtime dependencies unless dependency validation is completed and the addition is clearly necessary.
  - Modifying project `CLAUDE.md` files, global instruction files, or unrelated tool artifacts.
  - Performing version-control operations.

## Requirements
1. The implementer must read `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` before modifying the tool-doc-config-architect subagent.
2. The implementer must inspect the current extension files under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent/`, including `index.ts`, `tool-doc-config-architect-agent.md`, and `README.md`.
3. The implementer should use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension/` as the local reference implementation for bridge metadata, child naming, parent wait notices, and documentation style.
4. `index.ts` must define or reuse constants for the required bridge environment variables: `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, `PI_SUBAGENT_CHILD_INDEX`, and `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
5. Each child invocation must generate a run-specific stable child intercom session name using a documented pattern equivalent to `subagent-tool-doc-config-architect-<run-id>-1` or another `subagent-<agent>-<run-id>-<index>` pattern.
6. The parent supervisor target must resolve to the current parent Pi session name when available, or to a stable fallback alias based on the parent session ID when unnamed.
7. The spawned child process environment must include all required `PI_SUBAGENT_*` bridge variables with values consistent with the generated run ID, child agent name, child index, supervisor target, and child session name.
8. The child Pi launch must include `--name <child intercom session name>` with the same value used for `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
9. The child tool allowlist must include the existing required tools plus `contact_supervisor` and `intercom`; based on current source, the existing allowlist is `read,write,edit,grep,find,ls,bash`.
10. The child launch should preserve or improve current isolation and output parsing behavior, including JSON mode and no regular persisted child session; if `--no-skills` or prompt flag changes are adopted, they must not break the child prompt behavior.
11. The parent launcher must parse child JSON output and detect `tool_execution_start` events where `toolName === "contact_supervisor"`.
12. When the child starts `contact_supervisor`, the parent launcher must stream a wait notice containing the contact reason, supervisor target, child intercom session name, child message, and exact instruction `/intercom-reply <your decision>`.
13. The wait notice must explicitly warn that normal steering messages are queued until the foreground subagent tool finishes and therefore cannot unblock the waiting child.
14. The wait notice may mention `intercom({ action: "reply", message: "..." })` only as an idle-parent alternative, not as the primary foreground reply path.
15. The parent launcher should surface `tool_result_end` output related to `contact_supervisor` when practical, so the supervisor can confirm the child received the reply.
16. The child prompt must explain that `contact_supervisor` with `reason='need_decision'` should be used only for rare unapproved decisions that would make the scaffold/audit result unsafe, misleading, or unusable if handled as an assumption.
17. The child prompt must explain that `reason='interview_request'` is for several related blocking answers in one exchange, and `reason='progress_update'` is only for meaningful non-blocking discoveries that materially change scope, constraints, risk, or ability to produce the report.
18. The child prompt must instruct the child not to make scaffold-mode writes while waiting for a required supervisor decision, and never to write in audit mode under any circumstance.
19. If `contact_supervisor` is unavailable, fails, or times out, the child must not invent a supervisor decision; it must proceed only when safe under the existing input contract and documented assumptions, or return a clear blocker/error report.
20. The enhancement must preserve scaffold mode behavior: writing only the requested tool's `docs/tools/<tool-name>.md` and `~/.tool-agents/<tool-name>/` artifacts, never modifying `CLAUDE.md`, never writing fallback configuration values, and returning the prescribed report.
21. The enhancement must preserve audit mode behavior: strictly read-only checks with no file modifications and the prescribed findings/remediation report.
22. The README must document the injected bridge environment variables, child `--name` convention, updated child tool allowlist, parent wait notice behavior, `/intercom-reply <decision>` foreground reply rule, normal steering limitation, and validation steps.
23. Any bridge validation evidence recorded by the implementer must include date, commands or manual steps, result, and whether any files were changed during bridge-only testing.
24. Existing installation/symlink compatibility should be preserved for `/Users/giorgosmarinos/.pi/agent/extensions/tool-doc-config-architect-subagent`.
25. Any ad hoc validation scripts created for this work must be placed under `/Users/giorgosmarinos/aiwork/llama-cpp/test/test_scripts/`.
26. No secrets, credential values, tokens, or private environment values may be written into source, documentation, logs, validation notes, or final reports.
27. No unrelated project files may be modified beyond this refined request artifact, the target extension files, and explicitly documented validation notes.

## Constraints
- Active project root for this refined request: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request output path: `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/refined-request-enhance-tool-architect-intercom.md`.
- Requested slug `enhance-tool-architect-intercom` is used because it fits the objective, is lowercase hyphen-separated, has four words, and is under 40 characters.
- The active project root has no local `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, or `docs/design/project-functions.*`; relevant conventions come from parent-provided instructions, existing test-project reference files, and the target extension files.
- `Issues - Pending Items.md` exists and currently lists no pending items, but includes completed context about recent `pi-intercom` supervisor-reply lifecycle fixes.
- Target extension path observed during refinement: `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent/`.
- Current target extension files observed during refinement: `index.ts`, `README.md`, and `tool-doc-config-architect-agent.md`.
- Current child tool allowlist observed during refinement: `read,write,edit,grep,find,ls,bash`; bridge enhancement must add `contact_supervisor,intercom` where appropriate.
- Current child launch observed during refinement uses a spawned `pi` process in JSON mode with `--no-session`, `--tools`, and `--append-system-prompt`; implementation should build on this existing launcher rather than replacing the extension wholesale.
- The reusable pi-intercom integration instructions are already present at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
- The active `pi-intercom` package is expected to provide `contact_supervisor`, `/intercom-reply`, dedicated blocking-client behavior, and stale pending/deferred-message cleanup; this request should rely on that behavior rather than reimplementing it in the target extension.
- Tools/extensions created or modified in this project context should be TypeScript.
- Do not perform version-control operations unless explicitly requested.
- Do not add or update runtime dependencies without following the project dependency-validation procedure.
- Missing required configuration or required inputs must result in explicit errors, not silent fallback behavior.

## Acceptance Criteria
1. The final implementation report states that `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` was reviewed and used.
2. The target extension source has been inspected before modification.
3. `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent/index.ts` includes handling for all required `PI_SUBAGENT_*` bridge metadata.
4. `index.ts` generates a run ID and stable tool-doc-config-architect child intercom session name for each child invocation.
5. The spawned child Pi process receives `--name <child-session-name>` and `PI_SUBAGENT_INTERCOM_SESSION_NAME=<child-session-name>` with matching values.
6. The spawned child Pi process receives `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, and `PI_SUBAGENT_CHILD_INDEX`.
7. The child tool allowlist includes both `contact_supervisor` and `intercom` in addition to the subagent's normal tools.
8. The parent launcher detects child `contact_supervisor` start events from JSON output.
9. The parent wait notice includes the contact reason, supervisor target, child intercom session name, `/intercom-reply <your decision>`, the child message, and a warning that normal steering cannot unblock the child.
10. The child prompt documents supervisor coordination behavior and preserves the scaffold/audit safety invariants.
11. The README documents the pi-intercom bridge implementation, foreground reply procedure, normal steering limitation, and validation workflow.
12. Existing audit mode remains read-only; validation or code inspection shows audit mode does not write files because of the supervisor bridge enhancement.
13. Existing scaffold mode still writes only the requested tool artifacts and still refuses to modify `CLAUDE.md` directly.
14. Static source validation confirms bridge env vars, stable child naming, updated tool allowlist, contact-supervisor event parsing, wait-notice text, and README/prompt guidance.
15. Load validation passes with a command equivalent to loading `pi-intercom` and the target extension together, such as `pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom -e /Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent --list-models`, or any failure is documented with exact error output and next action.
16. If feasible, an interactive bridge validation demonstrates that the child can call `contact_supervisor` with `reason='need_decision'`, the parent sees the wait notice, `/intercom-reply <decision>` works while `tool_doc_config_architect_subagent` is still running, and the child receives the reply and completes normally.
17. After successful bridge validation, no stale ask renders after completion and `intercom({ action: "pending" })` or an equivalent check reports no unresolved inbound asks where this can be checked.
18. Timeout or abort behavior is tested or explicitly documented as not tested with a reason.
19. No unrelated files are modified, no secrets are exposed, no new runtime dependencies are added without validation, and no version-control operations are performed.

## Assumptions
- The intended enhancement target is `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent/`: this folder exists and contains the current Pi extension for `tool_doc_config_architect_subagent`.
- The requested slug `enhance-tool-architect-intercom` is acceptable even though the precise target name is `tool-doc-config-architect-subagent`, because the user explicitly requested it and it fits the objective.
- The reusable integration instructions are authoritative for the supervisor bridge: the raw request explicitly asks to study and use them.
- The existing `worker-subagent-extension` is the best concrete local implementation reference because the integration instructions identify it as the primary reference implementation.
- The enhancement should focus on launcher, prompt, README, and validation changes; it should not redesign the tool-doc-config-architect's scaffold/audit workflow or tool-conventions specification.
- The existing `pi-intercom` package already implements the dedicated blocking-client and stale cleanup behavior described by the integration instructions, so the target extension should integrate with it instead of duplicating that logic.
- The tool-doc-config-architect should remain mostly non-interactive and should only block on `contact_supervisor` for critical ambiguities or unapproved decisions that cannot safely be represented in the existing report's decisions/errors.
- Because the active project root lacks local project design/function documents, this specification relies on parent-provided conventions, existing completed issue notes, the integration instructions, and observed target extension files.

## Open Questions (if any)
- **Question**: Should `tool_doc_config_architect_subagent` proactively use `contact_supervisor` during scaffold mode when tool metadata is ambiguous, or should missing/ambiguous required inputs continue to return an error report without blocking?
  - **Why it matters**: Proactive blocking could improve recoverability but may weaken the current strict input contract that says required inputs must not be guessed and should produce an error report.
  - **Recommended default**: Preserve the strict input contract; use `contact_supervisor` only for unexpected critical decisions discovered after required inputs have already passed validation.
- **Question**: Should audit mode ever call blocking `contact_supervisor`, or should it remain fully non-interactive and report decisions needed in the final audit report?
  - **Why it matters**: Blocking during audit mode could help resolve ambiguous findings, but audit mode is expected to be deterministic, read-only, and non-mutating.
  - **Recommended default**: Keep audit mode non-blocking by default; allow only non-blocking `progress_update` for material discoveries, and report user decisions in the final report.
- **Question**: Should timeout, abort, progress-update, and interview-request lifecycle scenarios all be tested during this enhancement?
  - **Why it matters**: Full lifecycle validation provides stronger assurance but can take significant time, especially timeout testing; some paths may be better documented as manual follow-ups.
  - **Recommended default**: Require static, load, successful blocking `need_decision`, and stale-pending checks now; document timeout/abort/progress/interview tests as manual or follow-up validation unless quick and safe to run.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the tool-doc-config-architect.
If you need it you can proceed with request refinement.
