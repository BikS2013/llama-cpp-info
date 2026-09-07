# Pi Intercom Subagent Reply Lifecycle Fix

Date: 2026-06-30

## Issue

A `worker_subagent` child could successfully call `contact_supervisor` with `reason: "need_decision"`, and the parent/supervisor Pi session received the formatted intercom ask. However, when the supervisor replied with either:

```typescript
intercom({ action: "reply", message: "..." })
```

or:

```typescript
intercom({ action: "reply", to: "subagent-worker-<run-id>-1", message: "..." })
```

the reply failed with:

```text
Reply to "subagent-worker-<run-id>-1" was not delivered: Session not found
```

`intercom({ action: "pending" })` still listed the ask, so the parent retained a stale pending ask whose sender was no longer present in the broker session registry.

## Root Cause

The failure involved two lifecycle gaps:

1. **Blocking `contact_supervisor` reused the normal session-scoped intercom client.**
   - `contact_supervisor` sent the supervisor ask using the child session's regular `IntercomClient` and then waited through the extension-level `replyWaiter`.
   - In foreground/print-mode subagent execution, the normal Pi session lifecycle can shut down or disconnect while the child process is still inside a tool execution waiting for a supervisor reply.
   - When that regular client disconnected, the broker removed the child session. The parent still had the ask recorded locally, but the reply target ID no longer existed in the broker, producing `Session not found`.

2. **Parent pending-ask state did not react to sender disconnects.**
   - The broker already emits `session_left` when a session disconnects.
   - The parent-side `ReplyTracker` stored pending asks by message ID but had no method to remove asks from a leaving session.
   - Therefore a stale pending ask could remain visible even after its child sender disconnected.

## Solution

Updated the active `pi-intercom` implementation at:

`/Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom`

### Code changes

- `index.ts`
  - Added `waitForReplyOnClient(...)`, a local reply waiter that listens on a specific `IntercomClient` instead of the global session-level reply waiter.
  - Added `buildSupervisorToolRegistration(...)` so `contact_supervisor` can create a tool-owned intercom presence using the stable child subagent name from `PI_SUBAGENT_INTERCOM_SESSION_NAME`.
  - Changed blocking `contact_supervisor` flows (`need_decision` and `interview_request`) to:
    1. create a dedicated `IntercomClient`,
    2. register it with the child subagent intercom name,
    3. send the supervisor ask through that dedicated client,
    4. wait for the matching `replyTo` on that same client,
    5. disconnect the dedicated client in `finally` after reply/timeout/cancel/failure.
  - Added a `session_left` handler that removes pending asks from disconnected sessions.
  - On `reply` delivery failure with `Session not found`, the stale pending ask is removed so it is not listed indefinitely.

- `reply-tracker.ts`
  - Added `removePendingFromSession(sessionId)` to remove pending asks and queued/current turn context for a disconnected sender.

- `README.md`
  - Documented that blocking `contact_supervisor` calls keep a dedicated per-tool intercom connection alive while waiting for supervisor replies and clean stale pending state when children exit.

- `test_scripts/pi-intercom-reply-tracker-stale-session.test.ts`
  - Added a focused regression test for stale pending ask cleanup when a child sender session leaves.

## Expected Behavior After Fix

For the reported scenario:

```text
Use worker_subagent with task="Inspect the current project and before making any edit, contact the supervisor with reason need_decision asking which file you should modify first."
```

1. The child worker calls `contact_supervisor`.
2. The supervisor receives the formatted ask and sees the reply hint.
3. The blocking `contact_supervisor` tool keeps a dedicated child intercom connection registered while it waits.
4. The supervisor replies with either the implicit or disambiguated `reply` form.
5. The broker delivers the reply to the dedicated child client.
6. `contact_supervisor` returns the supervisor answer as the child tool result.
7. The child worker continues and returns its final response.
8. If the child is aborted before the reply, the pending ask is cleaned up instead of remaining as a stale `Session not found` target.

## Validation

Ran the focused regression test:

```bash
cd /Users/giorgosmarinos/aiwork/llama-cpp/test
/Users/giorgosmarinos/.pi/agent/npm/node_modules/.bin/tsx --test test_scripts/pi-intercom-reply-tracker-stale-session.test.ts
```

Result: passed.

Validated that the edited `pi-intercom` extension still loads in Pi:

```bash
pi --no-extensions --offline -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom --list-models
```

Result: exit code `0`.

## Operational Note

Reload or restart Pi sessions that already loaded `pi-intercom` so the updated extension code is active. Existing stale pending asks from before the reload may need to be cleared by reload/restart because they were created before the new `session_left` cleanup handler existed.
