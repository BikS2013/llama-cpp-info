# Refined Request: Enhance Codebase Scanner Subagent with Pi Intercom Supervisor Coordination

## Category
Development

## Objective
Enhance the existing Pi `codebase-scanner-subagent` extension so its child codebase-scanner Pi process can coordinate with the parent/supervisor through `pi-intercom`, following the reusable integration pattern documented in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`. The enhancement must add child bridge metadata, stable intercom naming, `contact_supervisor`/`intercom` tool availability, parent-visible wait notices, prompt guidance, documentation, and validation without changing llama.cpp product inference code.

## Scope
- **In scope**:
  - Study and apply the integration requirements from `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
  - Modify the codebase-scanner subagent extension source at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent/`, especially `index.ts`, `codebase-scanner-agent.md`, and `README.md` as needed.
  - Ensure the child Pi process is launched with stable intercom session naming, required bridge environment variables, and access to `contact_supervisor` and `intercom` tools.
  - Ensure the parent extension detects child `contact_supervisor` JSON events and streams a clear wait notice instructing the supervisor to use `/intercom-reply <decision>`.
  - Add child prompt guidance describing when to use `contact_supervisor`, when not to use it, and how to behave if the tool is unavailable.
  - Validate the enhancement using static/source checks, Pi extension load checks, and a safe bridge test plan or execution where feasible.
  - Create any ad hoc test scripts under `/Users/giorgosmarinos/aiwork/llama-cpp/test_scripts/` if scripts are needed.
  - Update project reference/design documentation only if downstream implementation materially changes documented Pi workflow extension behavior.
- **Out of scope**:
  - Changes to llama.cpp model files, inference wrappers, build configuration, or local model-serving behavior.
  - Rewriting the codebase scanner's scanning algorithm or output schema beyond prompt adjustments required for supervisor coordination.
  - Modifying the `pi-intercom` package itself unless implementation reveals a blocking defect that prevents the documented integration from working.
  - Adding new runtime dependencies unless explicitly necessary and validated through the project dependency-vetting rules.
  - Performing version-control operations.

## Requirements
1. The implementation must use `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` as the authoritative integration reference.
2. The existing codebase-scanner subagent extension must remain discoverable from its current source location `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent/` and compatible with its existing Pi discovery symlink under `~/.pi/agent/extensions/`.
3. The child `pi` process launched by `codebase_scanner_subagent` must receive these bridge environment variables:
   - `PI_SUBAGENT_ORCHESTRATOR_TARGET`
   - `PI_SUBAGENT_RUN_ID`
   - `PI_SUBAGENT_CHILD_AGENT`
   - `PI_SUBAGENT_CHILD_INDEX`
   - `PI_SUBAGENT_INTERCOM_SESSION_NAME`
4. The parent/supervisor intercom target must be resolved using the documented stable fallback pattern for unnamed parent sessions, including the `subagent-chat-<session-id-prefix>` style fallback.
5. The child intercom session name must be deterministic for a single run and follow the documented `subagent-<agent>-<run-id>-<index>` style naming pattern with sanitized name parts.
6. The child `pi` invocation must include `--name <child intercom session name>` so `pi-intercom` can address the child session reliably.
7. The child tool allowlist must preserve the scanner's required tools and add `contact_supervisor` and `intercom`.
8. The child launch should include `--no-skills` if compatible with the current extension behavior, to match the documented subagent integration pattern and keep child execution bounded.
9. The parent extension must parse child JSON output for `tool_execution_start` events where `toolName === "contact_supervisor"`.
10. When the child starts `contact_supervisor`, the parent extension must stream a supervisor-visible wait notice that includes:
    - the reason supplied by the child;
    - the child message;
    - the supervisor target when available;
    - the child intercom session name when available;
    - the exact instruction `/intercom-reply <your decision>`;
    - a warning that normal steering cannot unblock a foreground subagent tool.
11. The implementation must not treat a blocking `contact_supervisor` call as a hang; the parent should continue waiting for normal child completion unless the process exits, errors, is aborted, or times out through `pi-intercom` semantics.
12. The parent extension should surface useful evidence that a supervisor reply was received when child JSON events make this available, without exposing excessive raw JSON.
13. `codebase-scanner-agent.md` must instruct the child scanner to:
    - use `contact_supervisor` with `reason='need_decision'` only when a new unapproved decision is required before continuing;
    - use `reason='progress_update'` only for meaningful non-blocking discoveries that change the plan;
    - avoid routine completion handoffs through `contact_supervisor`;
    - stop and report the blocker if `contact_supervisor` is unavailable and a required unapproved decision exists;
    - avoid edits while waiting for a required supervisor decision, noting that the scanner may only write its output artifact.
14. `README.md` for the codebase-scanner subagent extension must document the injected bridge environment variables, child `--name` convention, tool allowlist additions, wait-notice behavior, exact `/intercom-reply <decision>` instruction, warning about normal steering deadlock, and validation steps.
15. Existing `codebase_scanner_subagent` parameters and default behavior must remain backward compatible: `request_file`, `output_path`, `cwd`, and `model` should keep their current meanings.
16. The scanner must still write exactly one scan artifact at the resolved output path and must not modify source files other than its intended output artifact.
17. No version-control operations may be performed.
18. No new runtime dependencies may be added unless the dependency-validation procedure is followed and the need is justified.

## Constraints
- Project root for refinement and any project-local validation artifacts: `/Users/giorgosmarinos/aiwork/llama-cpp`.
- Primary extension source to modify: `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent/`.
- Current extension state shows `index.ts` launches child `pi` with `--mode json -p --no-session --tools read,write,grep,find,ls,bash --append-system-prompt <prompt>` and currently lacks intercom bridge metadata, `--name`, and `contact_supervisor`/`intercom` in the child tool list.
- Follow the integration instructions in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md`.
- Use TypeScript for extension code changes.
- Create any ad hoc validation scripts only under `/Users/giorgosmarinos/aiwork/llama-cpp/test_scripts/`.
- Preserve project rule: do not perform version-control operations unless explicitly requested.
- Preserve project rule: do not create fallback substitutions for missing configuration settings; for required runtime values, report clear errors rather than silently inventing invalid values. Stable naming fallback for unnamed Pi sessions is allowed because it is explicitly required by the integration reference.
- Treat external credentials and user-level configuration as sensitive; do not print secrets.
- The active `pi-intercom` package is expected to already implement dedicated blocking-client behavior; do not duplicate or reimplement that package inside the scanner extension.

## Acceptance Criteria
1. `index.ts` in `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent/` defines and uses the required `PI_SUBAGENT_*` bridge environment variables when spawning the child process.
2. Child process arguments include `--name <resolved child intercom session name>` and the child tool allowlist includes both `contact_supervisor` and `intercom` while preserving scanner-required tools.
3. The extension computes stable parent and child intercom targets using sanitized names consistent with the documented integration pattern.
4. A static review of child process launch code confirms that the bridge metadata values are passed in the spawned process environment.
5. A static review of child JSON event handling confirms `tool_execution_start` events for `contact_supervisor` produce a parent-visible wait notice with `/intercom-reply <your decision>` and the warning about normal steering being unable to unblock the foreground tool.
6. `codebase-scanner-agent.md` contains explicit `contact_supervisor` usage guidance matching the requirements above.
7. `README.md` documents the bridge env vars, child `--name` naming convention, child tool allowlist additions, wait notice, exact reply instruction, normal-steering warning, and validation steps.
8. The enhanced extension can be loaded by Pi without TypeScript/runtime loading errors using an appropriate Pi extension load check.
9. A safe validation task can trigger or simulate the child calling `contact_supervisor`, and the parent displays the wait notice before the child completes.
10. When the supervisor replies with `/intercom-reply Do not modify any file. This is a bridge test only; report that contact_supervisor reply delivery worked.`, the child receives the reply and continues or reports the received decision without modifying project source files.
11. Existing scanner behavior still works for a normal scan that does not require supervisor coordination: it writes the expected scan artifact and returns the concise final report.
12. No llama.cpp product code, model files, or inference wrappers are modified.
13. Any validation scripts created for this work are located under `/Users/giorgosmarinos/aiwork/llama-cpp/test_scripts/`.

## Assumptions
- The requested slug `enhance-codebase-scanner-intercom` fits the objective and is used for this refined request file: it directly names the enhancement target and integration domain.
- The implementation target is the Pi extension at `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent/`, not the llama.cpp inference project itself: project design and parent context identify this as the existing codebase-scanner subagent extension source.
- The symlink under `~/.pi/agent/extensions/codebase-scanner-subagent` already points to the extension source and does not need to be recreated unless validation shows it is missing or stale.
- `pi-intercom` is installed at `~/.pi/agent/npm/node_modules/pi-intercom/` and already provides the child-only `contact_supervisor` tool when bridge metadata is present, as stated by the integration instructions.
- The enhancement should prioritize source/prompt/documentation changes and validation; it should not redesign the scanner's functional scan output.
- Interactive bridge validation may require a live Pi parent session and `/reload` or restart after code changes; if not executable in the implementation environment, downstream work should document the unexecuted manual validation steps and complete static/load validation.

## Open Questions (if any)
- **Question**: Should downstream implementation also update the user-level skill file `/Users/giorgosmarinos/.pi/agent/skills/codebase-scanner/SKILL.md` with supervisor-coordination guidance, or only the subagent extension prompt and README?
  - **Why it matters**: Updating the skill broadens the behavior guidance for direct skill use, while limiting changes to the extension avoids altering standalone scanner behavior outside the intercom-enabled subagent.
  - **Recommended default**: Update only the subagent extension prompt and README unless implementation discovers that the skill file is the source of truth used to regenerate the subagent prompt.
- **Question**: Should the child launch switch from `--append-system-prompt` to `--system-prompt` when adding `--name` and `--no-skills`?
  - **Why it matters**: The integration reference examples use `--system-prompt`, but the current extension uses `--append-system-prompt`; changing this may affect how default Pi system behavior and tool instructions are combined.
  - **Recommended default**: Preserve `--append-system-prompt` unless testing shows it prevents the bridge from working; add the intercom launch requirements without changing prompt composition semantics unnecessarily.
- **Question**: Is full interactive bridge validation required before completion, or is static/load validation plus documented manual validation acceptable if the active harness cannot provide a live supervisor reply?
  - **Why it matters**: Interactive validation is the strongest proof of `/intercom-reply` behavior but may require a foreground Pi session and manual timing that an automated implementation pass cannot guarantee.
  - **Recommended default**: Perform static and load validation automatically, then perform interactive validation if a live Pi session is available; otherwise document exact manual validation steps and mark interactive validation as pending.

## Original Request
I want you to study the ~/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md
and use it to enhance the codebase-scanner-subagent.
I fyou need it you can proceed with request refinement.
