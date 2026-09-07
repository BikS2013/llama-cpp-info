# Pi Intercom Immediate Subagent Reply Command Fix

Date: 2026-06-30

## Issue

After the subagent reply lifecycle fix, the child worker stayed alive and the parent displayed the expected waiting notice, but the supervisor still could not answer from the same Pi session by typing a normal message such as:

```text
reply to worker subagent to not touch any file
```

The UI showed the message as steering while `worker_subagent` was still running. The child remained blocked waiting for `contact_supervisor`.

## Root Cause

Pi steering messages are queued until the current assistant turn finishes executing its tool calls. In this scenario, the current assistant turn cannot finish because it is inside the foreground `worker_subagent` tool, and that tool cannot finish because the child is waiting for the supervisor reply.

That creates a deadlock for normal typed steering:

1. Child calls `contact_supervisor(reason="need_decision")`.
2. Parent `worker_subagent` tool keeps running while the child waits.
3. User types a normal steering message to the parent agent.
4. Pi queues the steering until `worker_subagent` finishes.
5. `worker_subagent` cannot finish until the queued answer is delivered.

The regular tool form below also cannot be invoked by the parent agent while the foreground tool is still running, because the parent model is not active at that moment:

```typescript
intercom({ action: "reply", message: "..." })
```

Pi extension slash commands, however, are allowed to execute immediately during streaming/tool execution.

## Solution

Added an immediate slash command to the active `pi-intercom` extension:

```text
/intercom-reply <message>
```

Changed files:

- `/Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom/index.ts`
  - Registered `intercom-reply` as an extension command.
  - The command resolves the active/single pending intercom ask from the existing `ReplyTracker` and sends a threaded reply immediately through the intercom client.
  - The command records the sent reply in session history and notifies success/failure through the UI.

- `/Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension/index.ts`
  - Updated the `worker_subagent` waiting notice to instruct the user to use `/intercom-reply <your decision>` while the foreground tool is running.
  - Explicitly warns that normal steering is queued and cannot unblock the waiting child.

- `/Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension/README.md`
  - Updated operational guidance for blocking `contact_supervisor` calls.

- `/Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom/README.md`
  - Documented `/intercom-reply` and when to use it.

- `/Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom/skills/pi-intercom/SKILL.md`
  - Updated subagent escalation guidance to prefer `/intercom-reply` while a foreground subagent tool is still running.

## How to Use

When the parent is still showing `worker_subagent` as working and the child asks for a decision, type the slash command directly in the Pi input box:

```text
/intercom-reply Do not modify any file. This is only a bridge test; report that the supervisor reply was received.
```

Do **not** type a normal sentence like `reply to the worker...` in that state; it will be queued as steering and cannot unblock the child.

When the parent agent is already idle, this regular tool form remains valid:

```typescript
intercom({ action: "reply", message: "Do not modify any file." })
```

## Validation

Validated that both edited extensions load successfully:

```bash
pi --no-extensions --offline \
  -e /Users/giorgosmarinos/.pi/agent/npm/node_modules/pi-intercom \
  -e /Users/giorgosmarinos/.pi/agent/extensions/worker-subagent-extension \
  --list-models
```

Result: exit code `0`.

Validated global extension autoload:

```bash
pi --offline --list-models
```

Result: exit code `0`.

## Retest Procedure

1. Restart or `/reload` the parent Pi session so the updated extensions are active.
2. Run:

```text
Use worker_subagent with task="Inspect the current project and before making any edit, contact the supervisor with reason need_decision asking which file you should modify first."
```

3. When the worker wait notice appears, answer with the immediate slash command:

```text
/intercom-reply Do not modify any file. This was a bridge test only; report that contact_supervisor reply delivery worked.
```

4. Expected result: the child receives the answer, `contact_supervisor` returns a tool result, and `worker_subagent` completes normally instead of hanging.
