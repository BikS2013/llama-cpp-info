# Pi Intercom Stale Queued Ask Display Fix

Date: 2026-06-30

## Issue

A later retest showed that the supervisor bridge could succeed, but the parent UI still displayed the original subagent ask after `worker_subagent` had already completed. The parent agent then attempted a second `intercom reply`, which failed with:

```text
Session not found
```

The transcript looked confusing because it showed both of these facts together:

- `worker_subagent` completed and reported that the supervisor reply was received successfully.
- The old intercom ask was rendered after completion with a reply hint, even though the child session had already exited.

## Root Cause

While the parent session was busy in the foreground `worker_subagent` tool, incoming intercom asks were stored in two places:

1. `ReplyTracker.pendingAsks` — used by `intercom reply` and `/intercom-reply` to resolve the pending ask.
2. `pendingIdleMessages` — used to defer rendering the inbound intercom message until the parent session becomes idle.

The immediate `/intercom-reply` command marked the ask as replied in `ReplyTracker`, but the corresponding deferred UI entry remained in `pendingIdleMessages`. When `worker_subagent` finished and the parent became idle, pi-intercom flushed that stale queued UI message, displaying a reply box for an ask that had already been answered and whose child session had already exited.

The same stale display could also occur when a child session left before the deferred message flushed.

## Solution

Updated `/Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom/index.ts`:

- Added `markRepliedAndDropQueued(replyTo)`.
  - Marks the ask as replied in `ReplyTracker`.
  - Removes matching deferred entries from `pendingIdleMessages`.
- Replaced direct `replyTracker.markReplied(...)` calls in send/reply command paths with `markRepliedAndDropQueued(...)`.
- Extended the `session_left` handler to remove deferred messages from `pendingIdleMessages` for the disconnected session, in addition to removing pending asks from `ReplyTracker`.
- Changed new incoming ask reply hints from the regular tool form to the immediate command:

```text
/intercom-reply <message>
```

The worker-subagent extension source was also verified to contain the updated wait notice:

```text
Reply from the parent Pi session with the immediate slash command:
/intercom-reply <your decision>
```

If a running Pi instance still shows the old `intercom({ action: "reply" ... })` notice, that process has not loaded the updated source and must be restarted or reloaded.

## Validation

Validated that the active edited extensions load together:

```bash
pi --no-extensions --offline \
  -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom \
  -e /Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension \
  --list-models
```

Result: exit code `0`.

## Retest Expectations

After `/reload` or restarting Pi:

1. `worker_subagent` should show the updated wait notice using `/intercom-reply <your decision>`.
2. The supervisor should answer with:

```text
/intercom-reply Do not modify any file. This was a bridge test only; report that contact_supervisor reply delivery worked.
```

3. The child should receive the reply and finish.
4. The old intercom ask should **not** render again after the worker has already completed.
5. The parent should not attempt a second reply to a completed child session.
