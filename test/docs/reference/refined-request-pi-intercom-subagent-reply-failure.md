# Refined Request: Pi Intercom Subagent Reply Failure

## Category
Development

## Objective
Diagnose and fix the pi-intercom / worker subagent communication failure where a child worker successfully sends a `contact_supervisor` ask to the parent supervisor, the pending ask remains visible, but supervisor replies are not delivered to the child and fail with `Session not found`. The completed work must identify the root cause, update the correct implementation so the child receives supervisor replies and continues execution, validate the exact reported scenario, and document both the issue and the solution.

## Scope
- **In scope**:
  - Inspect the current project context and the currently loaded pi-intercom / worker subagent implementation paths relevant to `worker_subagent`, `contact_supervisor`, intercom pending asks, and intercom replies.
  - Reproduce or validate the reported failure using the user-provided `worker_subagent` task where practical and safe.
  - Diagnose why a pending ask can be listed while `intercom({ action: "reply", ... })` and `intercom({ action: "reply", to: "...", ... })` fail with `Reply was not delivered: Session not found`.
  - Fix the actual reply-delivery/session-routing/lifecycle bug in the implementation that is used by the current Pi instance.
  - Preserve or improve the expected blocking request flow: child calls `contact_supervisor`, parent receives the ask, parent replies through intercom, child receives the reply and resumes.
  - Add or update focused tests, diagnostics, or manual validation steps sufficient to prove the fix.
  - Document the issue, root cause, solution, changed files, and validation results in project documentation, including the required issue/solution record.
- **Out of scope**:
  - Redesigning pi-intercom or worker subagents beyond what is necessary to fix the reply-delivery failure.
  - Adding unrelated features to `worker_subagent`, `contact_supervisor`, or intercom.
  - Changing model behavior, prompts, or worker agent task semantics except where necessary to validate the communication fix.
  - Performing version-control operations.
  - Adding runtime dependencies unless strictly necessary and dependency validation is completed first.
  - Modifying unrelated project files or unrelated Pi extensions.

## Requirements
1. The implementer must inspect the active project root `/Users/giorgosmarinos/aiwork/llama-cpp/test` and relevant documentation before making code changes.
2. The implementer must identify the implementation files actually used by the current Pi instance for `worker_subagent`, `contact_supervisor`, and `intercom` reply handling before editing any code.
3. The implementer must use the reported scenario as the primary reproduction/validation case: `worker_subagent` with task text instructing the worker to inspect the project and, before any edit, contact the supervisor with reason `need_decision` asking which file should be modified first.
4. The implementer must account for the observed failure details: child session name `subagent-worker-52867e11-11bb-46a6-b907-95eb127d142f-1` or equivalent generated name, pending ask visible via intercom, reply attempts with and without explicit `to`, and error `Reply was not delivered: Session not found`.
5. The diagnosis must explain how asks are registered, how pending asks are resolved, how reply targets are mapped to sessions, and why the reply target was not found despite the pending ask remaining listed.
6. The fix must ensure that supervisor replies can be delivered to the child worker session while the child is blocked waiting for `contact_supervisor`.
7. The fix must keep pending ask state and session registry state consistent; stale pending asks must not remain indefinitely after the child exits, aborts, or receives a reply.
8. The fix must handle both normal successful reply delivery and failure/abort cleanup paths with clear errors or cleanup behavior.
9. If both implicit reply-to-current-pending-ask and explicit `to: <child-session>` reply forms are supported by pi-intercom, the implementation must preserve both forms or clearly document any intentionally unsupported form.
10. The implementer must avoid masking missing configuration or missing sessions with silent fallbacks; missing required state must produce an explicit diagnostic error.
11. The implementer must not perform version-control operations.
12. The implementer must avoid new runtime dependencies; if a dependency is unavoidable, the dependency-validation workflow must be completed and documented before adding it.
13. Any test script created for validation must be placed under `test_scripts/` in accordance with project conventions.
14. The implementer must document the issue and solution, including root cause and validation evidence, in `Issues - Pending Items.md` and/or a dedicated file under `docs/reference/`.
15. The final report must list all modified files with concise explanations and must include the validation commands or manual steps performed.

## Constraints
- Active project root: `/Users/giorgosmarinos/aiwork/llama-cpp/test`.
- Refined request output location: `docs/reference/` inside the project root.
- Requested slug: `pi-intercom-subagent-reply-failure`, which fits the objective and is used for this specification.
- The user explicitly approved request refinement via the parent agent.
- The current project root does not contain a local `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, or `docs/design/project-functions.*` file at refinement time; refinement relies on parent-provided project instructions and the existing project artifacts.
- `Issues - Pending Items.md` exists and already contains a completed entry for a previous `contact_supervisor` visibility fix; the new work must distinguish the current reply-delivery failure from that prior visibility issue.
- Project conventions require documenting every solved issue and its solution.
- Project conventions require test scripts to be created under `test_scripts/` if test scripts are needed.
- Project conventions prohibit version-control operations unless explicitly requested.
- Project conventions require dependency validation before adding or updating runtime dependencies.
- Configuration values must not be silently replaced with fallback values; missing required configuration/state must raise or return explicit errors.

## Acceptance Criteria
1. The relevant loaded implementation paths for `worker_subagent`, `contact_supervisor`, and intercom reply handling are identified and recorded in the implementation notes or final report.
2. The root cause is documented and specifically explains why `intercom pending` could list the ask while `intercom reply` failed with `Session not found`.
3. The code change fixes the reply delivery path so a child worker blocked in `contact_supervisor` receives the supervisor reply and resumes execution.
4. The exact reported validation scenario is run or a justified equivalent is run, and the worker completes without being aborted after the supervisor replies.
5. At least one supervisor reply form succeeds; if both implicit reply and explicit `to` reply are intended supported behaviors, both are validated successfully.
6. Pending ask state is removed or marked resolved after successful reply delivery and is cleaned up after child abort/exit.
7. Failure cases produce clear diagnostics and do not leave misleading pending asks that cannot be delivered because the session is gone.
8. No unrelated files are modified.
9. No version-control operations are performed.
10. No new runtime dependencies are added unless dependency-validation evidence is documented.
11. The issue and solution are documented in `Issues - Pending Items.md` and/or a dedicated `docs/reference/` document with root cause, fix summary, and validation evidence.
12. The final handoff/report includes modified file paths, validation evidence, and any remaining limitations.

## Assumptions
- The failure is in the local pi-intercom / worker subagent integration rather than in the user’s reply text: the pending ask remains visible, but delivery cannot locate the target session.
- The implementation to modify may live outside the active project root, such as in the user Pi extension workspace or installed pi-intercom package, because the active project root primarily contains reference documentation and subagent specs.
- The previous completed visibility fix documented in `docs/reference/worker-subagent-contact-supervisor-visibility-fix.md` did not fully resolve the reply-delivery/session-routing failure described in this request.
- The intended outcome is a functional blocking supervisor interaction, not merely improved error messaging.
- The generated worker session identifier in the raw request is an example from the observed run; downstream validation should use the session identifier generated during the new run.

## Open Questions (if any)
- **Question**: Which installed source should be treated as authoritative if multiple copies of pi-intercom or worker-subagent code are found?
  - **Why it matters**: Editing a non-loaded copy would not fix the current Pi behavior, while editing an installed package versus a source workspace has different maintainability implications.
  - **Recommended default**: Modify the source path that the current Pi instance actually loads during reproduction, and document that path explicitly.
- **Question**: Should both reply forms, `intercom({ action: "reply", message: "..." })` and `intercom({ action: "reply", to: "<child-session>", message: "..." })`, be considered required behavior?
  - **Why it matters**: Supporting both forms affects routing logic and validation coverage; supporting only one form may still unblock the workflow but could leave the originally observed explicit form broken.
  - **Recommended default**: Treat both forms as required if pi-intercom documentation or current behavior advertises both; otherwise require the documented form and clearly report the unsupported form.

## Original Request
I test the implementation of the pi-intercom extension
 and it seems that the subagent sends message to the caller
 but when the caller is answering the subagent does not get the message
 so i aborted the process

 can you examine and solve it ?




 Use worker_subagent with task="Inspect the current project and before making any edit, contact the supervisor with reason
   need_decision asking which file you should modify first."

[Observed failure]
worker_subagent failed with exit code 143 after the child called contact_supervisor. The supervisor received an intercom ask from subagent-worker-52867e11-11bb-46a6-b907-95eb127d142f-1, but intercom({ action: "reply", message: "..." }) and intercom({ action: "reply", to: "subagent-worker-52867e11-11bb-46a6-b907-95eb127d142f-1", message: "..." }) both failed with: Reply was not delivered: Session not found. intercom pending still listed the pending ask, but reply delivery could not reach the subagent session. The worker was then aborted. Need inspect and solve.
