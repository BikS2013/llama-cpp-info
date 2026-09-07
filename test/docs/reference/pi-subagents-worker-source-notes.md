# pi-subagents Worker Source Notes

Retrieved: 2026-06-30

## Verified online source

- Repository: https://github.com/nicobailon/pi-subagents
- npm package: https://www.npmjs.com/package/pi-subagents
- Repository description from GitHub API: Pi extension for async subagent delegation with truncation, artifacts, and session sharing
- Commit studied: `85348a7fcf2c6a9e46ccf4ff3f9d7a9d8a1288c0`
- Commit date: `2026-06-26T06:39:15Z`

## Files studied

- `agents/worker.md`
- `README.md`
- `src/extension/index.ts`
- `src/runs/foreground/subagent-executor.ts`
- `src/runs/background/subagent-runner.ts`
- `src/runs/shared/pi-args.ts`
- `src/agents/agents.ts`

## Worker implementation summary

The upstream `worker` agent is an implementation agent for normal tasks and approved oracle handoffs. Its frontmatter sets:

```yaml
name: worker
description: Implementation agent for normal tasks and approved oracle handoffs
thinking: high
systemPromptMode: replace
inheritProjectContext: true
inheritSkills: false
tools: read, grep, find, ls, bash, edit, write, contact_supervisor
defaultContext: fork
defaultReads: context.md, plan.md
defaultProgress: true
```

Key behavior:

- Acts as the single writer thread.
- Executes assigned tasks or approved directions with narrow, coherent edits.
- Validates the task against actual code.
- Does not silently make new product, architecture, or scope decisions.
- Escalates new required decisions through `contact_supervisor` when available.
- Reads supplied context/plan files first, especially `context.md` and `plan.md`.
- Final response format: implemented change, changed files, validation, open risks/questions, recommended next step.

## Local adaptation

Created a focused worker-only Pi extension at:

`/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/worker-subagent-extension`

The local extension registers `worker_subagent`, launches a child `pi` process with `--system-prompt worker-agent.md`, forwards the calling agent model by default, and uses a restricted tool allowlist matching the upstream worker's local tools where available.
