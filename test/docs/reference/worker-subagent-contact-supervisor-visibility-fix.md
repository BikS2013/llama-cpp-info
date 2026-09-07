# Worker Subagent contact_supervisor Visibility Fix

Date: 2026-06-30

## Issue

During the first `worker_subagent` bridge test, the child worker successfully received the `contact_supervisor` tool and sent a blocking `need_decision` request back to the parent Pi session. The parent received the intercom message, proving that the bridge metadata was working.

However, the parent-visible `worker_subagent` tool output did not clearly state that the child worker was paused waiting for a supervisor reply. The user interpreted the foreground tool call as hanging and manually aborted it. The abort propagated to the child process, producing exit code `143`, and the later `intercom reply` failed because the child session was already gone.

## Root Cause

`worker-subagent-extension/index.ts` parsed child Pi JSON events only for `message_end` events. A blocking `contact_supervisor` call appears first as a child JSON event like:

```json
{
  "type": "tool_execution_start",
  "toolName": "contact_supervisor",
  "args": { "reason": "need_decision", "message": "..." }
}
```

Because the extension ignored `tool_execution_start`, it did not stream a parent-facing status update explaining that the child was waiting for an intercom reply.

## Solution

Updated `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension/index.ts` to:

1. Detect child JSON events where `type === "tool_execution_start"` and `toolName === "contact_supervisor"`.
2. Stream an explicit status update through `onUpdate` showing:
   - the `contact_supervisor` reason,
   - that the worker is paused and waiting for the supervisor reply,
   - the supervisor target,
   - the child intercom session name,
   - the recommended parent reply command.
3. Also parse `tool_result_end` events so the eventual supervisor reply/tool result can be surfaced before the worker produces its final answer.
4. Updated the extension README with troubleshooting guidance: do not abort the parent `worker_subagent` tool call while a `need_decision` or `interview_request` contact is pending; reply via `intercom` instead.

## Validation

Validated direct extension loading:

```bash
pi --no-extensions --offline -e "$HOME/ai-coding/pi-workdocs/extensions/worker-subagent-extension" --list-models
```

Result: exit code `0`.

Validated global extension autoload:

```bash
pi --offline --list-models
```

Result: exit code `0`.

## Expected Retest Behavior

When the worker calls `contact_supervisor`, the parent should now see a streamed worker-subagent update similar to:

```text
Worker called contact_supervisor with reason=need_decision.
The worker is paused waiting for the supervisor reply; this is expected for need_decision/interview_request.
Supervisor target: <parent>
Child intercom session: <child>
Reply from the parent Pi session with:
intercom({ action: "reply", message: "<your decision>" })
```

Then the user/parent should reply with:

```text
intercom({ action: "reply", message: "Do not modify any file. This was a bridge test only. Report back that contact_supervisor worked." })
```

The child should receive the reply and continue to its final response.
