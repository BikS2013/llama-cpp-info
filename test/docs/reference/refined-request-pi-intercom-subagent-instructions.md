# Refined Request: Pi Intercom Integration Instructions for Subagents

## Category
Documentation

## Objective
Create reusable implementation instructions inside `/Users/giorgosmarinos/ai-coding/pi-workdocs` that explain how future Pi subagent extensions should integrate with `pi-intercom`, especially the `contact_supervisor` supervisor-reply flow. The instructions must capture the lessons learned from recent `worker_subagent` and `pi-intercom` fixes so future subagents can implement stable child intercom identity, supervisor escalation, immediate replies while a foreground subagent tool is running, pending-ask cleanup, and test/documentation guidance consistently.

## Scope
- **In scope**:
  - Write a reusable documentation artifact under `/Users/giorgosmarinos/ai-coding/pi-workdocs` for future subagent-extension work.
  - Cover the required child-process bridge environment variables: `PI_SUBAGENT_ORCHESTRATOR_TARGET`, `PI_SUBAGENT_RUN_ID`, `PI_SUBAGENT_CHILD_AGENT`, `PI_SUBAGENT_CHILD_INDEX`, and `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
  - Explain the need for stable child intercom session names and launching child Pi processes with `--name` matching `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
  - Document how subagents should surface parent-visible status when `contact_supervisor` starts, including the fact that the child is intentionally paused for `need_decision` or `interview_request`.
  - Document when supervisors must use `/intercom-reply <message>` instead of normal steering or regular `intercom({ action: "reply" })` while a foreground subagent tool is still running.
  - Include lifecycle guidance for `contact_supervisor`, including the dedicated per-tool intercom client/presence used while blocking for a reply, cleanup on reply/timeout/cancel/failure, and stale pending cleanup when sessions leave.
  - Include testing and validation guidance based on the recent fixes: extension load checks, bridge-flow retests, stale queued ask prevention, and regression tests for pending cleanup.
  - Include guidance that future subagent extensions should degrade safely when `pi-intercom` or `contact_supervisor` is unavailable by reporting blockers rather than inventing supervisor decisions.
- **Out of scope**:
  - Implementing or modifying any subagent extension code in this request.
  - Modifying the active `pi-intercom` extension or `worker_subagent` implementation.
  - Performing version-control operations.
  - Creating a full replacement for existing `pi-intercom` or `worker_subagent` documentation.
  - Adding dependencies, build tooling, or runtime configuration.

## Requirements
1. Create a clear markdown instruction document inside `/Users/giorgosmarinos/ai-coding/pi-workdocs` that can be reused when enhancing multiple future subagent extensions.
2. The document must state the intended audience: developers/agents implementing Pi subagent extensions that may need supervisor communication through `pi-intercom`.
3. The document must include an implementation checklist for adding `pi-intercom` support to a subagent extension.
4. The checklist must specify all bridge environment variables and describe the purpose of each variable.
5. The checklist must require stable child intercom session naming, including use of a run ID and child index, and require the child Pi process `--name` to match `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
6. The instructions must explain how child subagents gain access to `contact_supervisor` and `intercom` when `pi-intercom` is installed and loaded.
7. The instructions must distinguish blocking supervisor contacts (`need_decision`, `interview_request`) from non-blocking or informational contacts such as progress updates.
8. The instructions must warn that normal parent steering is queued while a foreground subagent tool is running and cannot unblock a child waiting in `contact_supervisor`.
9. The instructions must prescribe `/intercom-reply <message>` as the user-facing reply mechanism while the foreground subagent tool is still running, and note that the regular `intercom({ action: "reply", message: "..." })` form is only appropriate when the parent agent is idle.
10. The document must include guidance for streaming parent-visible status when the child starts `contact_supervisor`, including the reason, supervisor target, child session name, and exact reply instruction.
11. The document must capture lifecycle lessons from the `pi-intercom` fixes: use a dedicated blocking `contact_supervisor` client/presence, keep it registered while waiting, disconnect it in a `finally`-style lifecycle, and clean stale pending asks on session leave or delivery failure.
12. The document must include stale pending/queued-message cleanup guidance so answered or disconnected child asks do not render later as stale UI prompts.
13. The document must include testing guidance for future subagent integrations, including at least: direct extension load validation, global autoload validation when applicable, an end-to-end supervisor bridge test, and a stale pending cleanup regression scenario.
14. The document must include troubleshooting guidance for common failures: apparent hangs, `Session not found`, stale ask displayed after completion, child killed by aborting the parent foreground tool, and old instructions still visible due to needing `/reload` or restart.
15. The document must reference the relevant prior fix documents in `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/` as background material without copying secrets or unrelated content.
16. The document must avoid performing or instructing version-control operations as part of this task.
17. The document must not require new runtime dependencies.

## Constraints
- The refined request must be executed without version-control operations.
- The deliverable must be placed under `/Users/giorgosmarinos/ai-coding/pi-workdocs`, not only inside the current project root.
- Current project context has no `CLAUDE.md`, `AGENTS.md`, `docs/design/project-design.md`, or `docs/design/project-functions.*` in `/Users/giorgosmarinos/aiwork/llama-cpp/test`; project-level conventions were supplied by the parent agent context.
- Existing issue/fix context is available in `/Users/giorgosmarinos/aiwork/llama-cpp/test/Issues - Pending Items.md` and related files under `/Users/giorgosmarinos/aiwork/llama-cpp/test/docs/reference/`.
- The target workspace already contains subagent extension documentation under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/`, including `worker-subagent-extension/README.md`, which can be used as style/context.
- Do not expose credential material or environment values beyond the documented non-secret variable names and expected structural values.
- Keep the document reusable and implementation-oriented, but do not over-prescribe internal code organization for every future subagent.

## Acceptance Criteria
1. A markdown instructions file exists under `/Users/giorgosmarinos/ai-coding/pi-workdocs` and is clearly named for Pi intercom subagent integration.
2. The instructions explicitly cover all required bridge environment variables and stable child session naming.
3. The instructions explain the foreground-tool deadlock and prescribe `/intercom-reply <message>` for supervisor replies while a subagent tool is still running.
4. The instructions describe parent-visible `contact_supervisor` status streaming requirements.
5. The instructions document dedicated `contact_supervisor` client/lifecycle handling and stale pending/queued ask cleanup.
6. The instructions include a practical test/validation section with load checks, end-to-end bridge test, and stale pending cleanup regression guidance.
7. The instructions include troubleshooting entries for the known failure modes from the recent fixes.
8. The instructions reference the prior fix documents used as source context.
9. No code files are changed as part of satisfying this documentation request unless the user separately approves implementation work.
10. No version-control operation is performed.

## Assumptions
- The requested slug `subagent-pi-intercom-integration-instructions` accurately describes the objective, but it exceeds the 40-character slug limit for refined-request files; the shortened slug `pi-intercom-subagent-instructions` is used instead.
- The task is documentation-only because the user asked to “create instructions” for future use, not to modify the active extension implementations.
- The reusable instructions should be durable source material for future subagent-extension enhancements, not a one-off note embedded only in a single extension README.
- The recent fix documents in the current project are authoritative for the lessons learned from `worker_subagent` and `pi-intercom` contact-supervisor flows.

## Open Questions (if any)
- **Question**: What exact path and filename should be used for the new instructions under `/Users/giorgosmarinos/ai-coding/pi-workdocs`?
  - **Why it matters**: The target workspace does not currently expose a central `docs/` folder; placing the file at the root versus under `extensions/` changes discoverability for future subagent authors.
  - **Recommended default**: Create `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/pi-intercom-subagent-integration-instructions.md` so it sits near the subagent extension documentation it is meant to guide.
- **Question**: Should existing subagent extension READMEs under `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/*/README.md` be updated to link to the new reusable instructions?
  - **Why it matters**: Links improve discoverability, but updating many READMEs broadens the change beyond creating a standalone instruction document.
  - **Recommended default**: Do not update existing READMEs in this request; create only the standalone reusable instruction document unless the user explicitly requests cross-linking.

## Original Request
I want you now to create instructions inside the ~/ai-coding/pi-workdocs 
on how to implement the pi-intercom integration in subagents 

I want you to use this instructions in the future to enhance various subagents
