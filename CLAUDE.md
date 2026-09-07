<structure-and-conventions>
## Structure & Conventions — Documentation Map

<!-- Maintained automatically. The master copy lives at
     ~/.claude/structure-and-conventions.md (claude-workdocs repo) and the SessionStart
     hook ~/.claude/scripts/sync-claude-md.sh keeps this copy of the block up to date —
     edit the master, never this block. The block is committed with the repository on
     purpose: it tells anyone (human or agent) working with this repo where the
     project's documentation lives and how to read and maintain it. -->

### Where the documentation lives

- `docs/plans/` — every plan, one file per plan, named `plan-NNN-<indicative-description>.md`.
- `docs/design/` — all other planning and design documents:
  - `project-design.md` — the complete, always-current project design; update it with every new design or design change.
  - `project-functions.md` — the registry of all functional requirements and feature descriptions.
  - `configuration-guide.md` — the project's configuration guide, when one exists (structure below).
- `docs/reference/` — all reference material collected for the project.
- `docs/refined_requests/` — every refined request specification (create the folder if missing), one file per request named `refined-request-NNN-<slug>.md`. `NNN` is a zero-padded three-digit sequential number: the next number is the highest `NNN` already present in the folder plus one, starting at `001` — and when the category has an archive history branch, the archive's numbering counts too (see "Archiving historical documents" below). `<slug>` is the request slug reused by all downstream artifacts of the same request.
- `docs/prompts/` — every prompt created while working on the project (create the folder if missing), one file per prompt named `NNN-<indicative-description>.md`. `NNN` is a zero-padded three-digit sequential number: the next number is the highest `NNN` already present in the folder plus one, starting at `001` — and when the category has an archive history branch, the archive's numbering counts too (see "Archiving historical documents" below). The description states the prompt's use and purpose.
- `docs/tools/<tool-name>.md` — one dedicated documentation file per project tool.
- `test_scripts/` — every test script goes here; create the folder if it doesn't exist.
- `Issues - Pending Items.md` (project root) — the register of every issue, pending item, inconsistency, or discrepancy detected while working on the project. Pending items come first (most critical and important on top), completed items after. Whenever a defect or issue is fixed, check this file for an item to remove.

### How to use the documentation

- Every time an issue is solved, it must be resolved AND both the issue and the solution must be thoroughly documented.
- This file's "Tools" section (when present) lists each project tool with a one-or-two-sentence description of what it is capable of and the relative path to its dedicated documentation file under `docs/tools/` — retrieve the full documentation from there whenever it is needed. Full tool documentation must never be inlined into this file.
- Before writing any code script, consult the "Tools" section and the documentation under `docs/tools/` to check whether the planned code fits the scope of an existing tool. If so, implement it as an extension of that tool; otherwise build a generic, abstract version of the code as a new tool in the project's toolset, document it under `docs/tools/`, and reference it in the "Tools" section. The goal is to progressively grow the tools needed to test, evaluate, generate data, collect information, etc., and reuse them consistently.

### Archiving historical documents (history branches)

- A project MAY move accumulated historical, write-once process artifacts — deployment reports, codebase scans, refined requests, plans, session handoffs, and similar — off the default branch to keep its documentation lean. Living, authoritative documents (`project-design.md`, `project-functions.md`, the guides, tool docs, the issue register) are never archived.
- Each archived category gets a dedicated **orphan, docs-only branch** named `<category>-history`, whose tree contains ONLY that category's files at their original repository paths — so retrieval paths never change: `git show <category>-history:<original-path>`, no branch switching required. A pointer note/README stays in the category's folder on the default branch stating the branch name, the retrieval command, and (for numbered categories) the next number. Archive branches are append-only: never rebase, rewrite, delete, or merge them.
- **Numbering across the archive**: for every `NNN`-numbered folder, the next number is `max(highest NNN in the folder, highest NNN on the category's archive branch) + 1`. Before creating the FIRST document of a numbered category, check whether an archive branch exists for it (the folder's README/pointer note, or `git branch --list --all '*-history'`) and continue from the archive's highest number — never restart at `001`, never reuse an archived number. The archive branch is authoritative over the pointer note's recorded "next number" if they disagree.
- **Migration** runs in a temporary linked worktree so the main checkout — and any uncommitted changes in it — is never disturbed: `git worktree add <tmp> <category>-history` (first-time archiving: `git worktree add --detach <tmp> <default-branch>`, then inside it `git switch --orphan <category>-history` and `git checkout <default-branch> -- <category-paths>`); bring the new artifacts over at their original paths and commit ONLY the category's files; then on the default branch `git rm` the migrated files, update the pointer note, and commit referencing the archive commit. Verify with `git ls-tree -r <category>-history --name-only` and a `git show` spot-check.
- The project's concrete category → branch registry (which categories are archived, under which branch names) is project-specific and lives OUTSIDE this synced block — typically a "Document Archiving Strategy" section in the project's CLAUDE.md.

<configuration-guide>
- A configuration guide, when requested, is created at `docs/design/configuration-guide.md` and explains:
  - When multiple configuration options exist (config file, env variables, CLI params, etc.), what the options are and the priority of each one.
  - The purpose and use of each configuration variable.
  - How the user can obtain such a configuration variable.
  - The recommended approach for storing or managing the variable.
  - Which options exist for the variable and what each option means for the project.
  - Any default value the parameter has.
  - For configuration parameters that expire (e.g., PAT keys, tokens), propose adding a parameter that captures the expiration date, so the app or service can proactively warn users to renew.
</configuration-guide>

</structure-and-conventions>

## Project: llama.cpp Local Inference

### Setup

- **llama.cpp**: Cloned to `llama.cpp/` directory, built with Metal GPU support
- **Models available:**
  - **Gemma 4 E2B** (2.3B params, Q8_0, 4.7 GB) — `models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf`
    - Performance: ~67 t/s prompt, ~120 t/s generation on Apple M4 Max
  - **MiniMax-M2.7** (229B params MoE, ~10B active, UD-IQ4_XS ~101 GB, 4 shards) — `models/MiniMax-M2.7/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf`
    - Performance: ~34 t/s prompt, ~5 t/s generation (cold) on Apple M-series with 128 GB unified memory
    - 200K context; load the **first shard only** — llama.cpp auto-loads the rest
  - **Ornith-1.5-35B-A3B** (35B MoE, ~3B active, `qwen35moe` / built on Qwen3.6-35B-A3B, Q8_0 37.8 GB + 0.9 GB mmproj) — `models/Ornith-1.5-35B/Ornith-1.5-35B-Q8_0.gguf`
    - Current-generation agentic-coding model from Ornith AI (2026-08-24); reasoning (`<think>`), OpenAI-style tool calling (qwen3 XML), 256K context, optional vision via `--vision`, MIT licensed
    - Recommended sampling: **temp 0.6, top-p 0.95, top-k 20** (temp 1.0 to reproduce the published benchmarks)
    - Run via the dedicated wrapper `./run-ornith.sh` (defaults to 1.5). See `docs/reference/ornith-models.md`.
    - Same `qwen35moe` arch as Ornith 1.0 — runs on the existing b9835 build
    - Performance (Ornith 1.0, same arch/quant): ~99 t/s prompt, ~93 t/s generation on Apple M5 Max (128 GB unified memory)
    - **Removed from disk 2026-09-07 (superseded):** Ornith-1.0-35B and Qwen3.6-35B-A3B. Re-download with `./scripts/download-Ornith-1.0-35B.sh` / `./scripts/download-qwen-3.6-35B.sh`; `./run-ornith.sh <mode> --version 1.0` then selects Ornith 1.0.
  - **Qwen3.8-27B** (27B dense VLM, `qwen35` arch, UD-Q8_K_XL 31.5 GB + 0.9 GB mmproj) — `models/qwen-3.8-27B/Qwen3.8-27B-UD-Q8_K_XL.gguf`
    - Successor of the Qwen3.6 series (2026-08-14); thinking on by default (`<think>`), `reasoning_effort` / `preserve_thinking` via chat template, 256K context, Apache-2.0
    - Recommended sampling: thinking **temp 1.0, top-p 0.95, top-k 20, min-p 0**; instruct temp 0.7, top-p 0.80, top-k 20, presence-penalty 1.5
    - Runs on b9835 (same arch as Qwen3.5/3.6 dense). See `docs/reference/qwen38-27b.md`.
  - **Qwen3-Coder-Next** (80B MoE, ~3B active, Qwen3-Next delta-net hybrid, UD-Q6_K_XL ~73 GB, 3 shards) — `models/Qwen3-Coder-Next/UD-Q6_K_XL/Qwen3-Coder-Next-UD-Q6_K_XL-00001-of-00003.gguf`
    - Agentic-coding model from the Qwen team; **non-reasoning** (no `<think>`), OpenAI-style tool calling (`qwen3_coder`), 256K context, Apache-2.0
    - Recommended sampling: **temp 1.0, top-p 0.95, top-k 40, min-p 0.01, repeat-penalty off**
    - Run via the dedicated wrapper `./run-qwen-coder.sh` (bakes in the optimal flags). See `docs/reference/qwen-coder-next.md`.
    - Loads on b9835 via the same Qwen3-Next hybrid lineage as `qwen35moe`; load the **first shard only** — llama.cpp auto-loads the rest

### Quick Start

**Interactive chat (Gemma):**
```bash
./llama.cpp/build/bin/llama-cli -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf -ngl 99 --temp 0.7
```

**Interactive chat (Ornith 1.5):**
```bash
./run-ornith.sh chat
```

**Interactive chat (Qwen3.8-27B, thinking mode):**
```bash
./llama.cpp/build/bin/llama-cli -m ./models/qwen-3.8-27B/Qwen3.8-27B-UD-Q8_K_XL.gguf \
  -ngl 99 -fa on -c 32768 --jinja --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0
```

**Interactive chat (Qwen3-Coder-Next):**
```bash
./run-qwen-coder.sh chat
```

**Interactive chat (MiniMax-M2.7):**
```bash
./llama.cpp/build/bin/llama-cli -m ./models/MiniMax-M2.7/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf -ngl 99 --temp 1.0 --top-p 0.95 --top-k 40
```

**Single prompt (non-interactive, Gemma):**
```bash
./llama.cpp/build/bin/llama-cli -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf -p "Your prompt" -n 200 -ngl 99 --temp 0.7 -no-cnv -st
```

**API server (either model):**
```bash
./llama.cpp/build/bin/llama-server -m <path-to-gguf> -ngl 99 --port 8080
```

**Without thinking (generic pickers):** `./start-repl.sh --no-think` / `./start-api.sh --no-think` / `./ask.sh "..." --no-think`
disable `<think>` reasoning (llama.cpp `--reasoning off --reasoning-budget 0
--reasoning-budget-message $'\n'`). Works for Gemma 4, Qwen 3.x, Ornith (template
`enable_thinking=false`) and MiniMax-M2.7 (forced `</think>`). API callers can re-enable per request
with `chat_template_kwargs.enable_thinking=true` **and** `thinking_budget_tokens>0`. See
`scripts/README.md` for the details.

**Ornith-1.5-35B-A3B (agentic coding) — use the dedicated wrapper:**
```bash
./run-ornith.sh chat                      # interactive REPL (temp 0.6, top-p 0.95, top-k 20, --jinja)
./run-ornith.sh serve --ctx 65536         # OpenAI-compatible API on :8080 with tool calling
./run-ornith.sh serve --vision            # also load the mmproj so images can be sent
./run-ornith.sh ask "Explain this stack trace ..." --tokens 2048
./run-ornith.sh chat --version 1.0        # Ornith-1.0-35B (not on disk; re-download first)
```
Equivalent raw command (what the wrapper runs):
```bash
./llama.cpp/build/bin/llama-cli -m ./models/Ornith-1.5-35B/Ornith-1.5-35B-Q8_0.gguf \
  -ngl 99 -fa on -c 32768 --jinja --temp 0.6 --top-p 0.95 --top-k 20
```

**Qwen3-Coder-Next (agentic coding, non-reasoning) — use the dedicated wrapper:**
```bash
./run-qwen-coder.sh chat                      # interactive REPL (temp 1.0, top-p 0.95, top-k 40, min-p 0.01, --jinja)
./run-qwen-coder.sh serve --ctx 131072        # OpenAI-compatible API on :8080 with tool calling
./run-qwen-coder.sh ask "Refactor this function ..." --tokens 4096
```
Equivalent raw command (what the wrapper runs):
```bash
./llama.cpp/build/bin/llama-cli \
  -m ./models/Qwen3-Coder-Next/UD-Q6_K_XL/Qwen3-Coder-Next-UD-Q6_K_XL-00001-of-00003.gguf \
  -ngl 99 -fa on -c 65536 --no-context-shift --jinja --temp 1.0 --top-p 0.95 --top-k 40 --min-p 0.01
```

### Rebuilding llama.cpp

Using the setup script (recommended):
```bash
./scripts/setup-llama-cpp.sh
```

Or manually:
```bash
cd llama.cpp
git pull
cmake -B build -DGGML_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

## Scripts

The project includes several helper scripts in the `scripts/` folder:

- **setup-llama-cpp.sh** — Clone and build llama.cpp with Metal GPU support
- **download-models.sh** — Download all models from HuggingFace
- **download-*.sh** — Individual model download scripts for each model

See `scripts/README.md` for detailed documentation.

### Downloading Additional Models

Install the HF CLI via uv (once):
```bash
uv tool install --with hf_transfer huggingface_hub
```

Download all models with the helper script:
```bash
./scripts/download-models.sh
```

Or download individual models:
```bash
./scripts/download-Ornith-1.5-35B.sh
./scripts/download-qwen-3.8-27B.sh
./scripts/download-Qwen3-Coder-Next.sh
./scripts/download-Ornith-1.0-35B.sh      # previous generation (removed from disk 2026-09-07)
```

Download examples:
```bash
# Gemma 4 E4B (4.5B params, single file)
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/gemma-4-E4B-it-GGUF \
  --include "gemma-4-E4B-it-Q8_0.gguf" --local-dir models/gemma-4-E4B

# MiniMax-M2.7 UD-IQ4_XS (sharded, ~108 GB)
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/MiniMax-M2.7-GGUF \
  --include "UD-IQ4_XS/*" --local-dir models/MiniMax-M2.7

# Ornith-1.5-35B-A3B Q8_0 (single file, ~38 GB) + mmproj — agentic coding MoE
HF_HUB_ENABLE_HF_TRANSFER=1 hf download ornith-ai/Ornith-1.5-35B-A3B-GGUF \
  --include "Ornith-1.5-35B-Q8_0.gguf" --include "mmproj-Ornith-1.5-35B-BF16.gguf" \
  --local-dir models/Ornith-1.5-35B

# Qwen3.8-27B UD-Q8_K_XL (single file, ~32 GB) + mmproj — dense VLM, thinking by default
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/Qwen3.8-27B-GGUF \
  --include "Qwen3.8-27B-UD-Q8_K_XL.gguf" --include "mmproj-BF16.gguf" \
  --local-dir models/qwen-3.8-27B

# Ornith-1.0-35B Q8_0 (previous generation, ~37 GB, removed from disk 2026-09-07) — HF org moved to ornith-ai
HF_HUB_ENABLE_HF_TRANSFER=1 hf download ornith-ai/Ornith-1.0-35B-GGUF \
  --include "ornith-1.0-35b-Q8_0.gguf" --local-dir models/Ornith-1.0-35B

# Qwen3-Coder-Next UD-Q6_K_XL (sharded, ~73 GB) — 80B/3B-active agentic coding MoE
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/Qwen3-Coder-Next-GGUF \
  --include "UD-Q6_K_XL/*" --local-dir models/Qwen3-Coder-Next
```

### Local pi-agent wrappers (in `~/.zshrc`, alongside `pi5.5` / `pi-opus`)

Each wrapper starts a dedicated llama-server (if not already running, identity-checked via
`/v1/models`) and runs the **pi** agent against it through a matching provider in
`~/.pi/agent/models.json`. Dedicated ports avoid the AIHub Registry container on `:8080`.

| Command | Model | Port | pi provider |
|---------|-------|------|-------------|
| `pi-ornith` / `pi-ornith-stop` | Ornith-1.5-35B-A3B (agentic coding MoE; alias `ornith-1.5-35b`) | 8090 | `ornith` |
| `pi-gemma31` / `pi-gemma31-stop` | Gemma 4 31B IT (dense) | 8091 | `gemma31` |
| `pi-minimax` / `pi-minimax-stop` | MiniMax-M2.7 (229B MoE, ~101 GB) | 8092 | `minimax` |
| `pi-qwen-coder` / `pi-qwen-coder-stop` | Qwen3-Coder-Next (80B MoE, ~68 GB) | 8093 | `qwencoder` |

```bash
pi-ornith "Refactor and add tests for the auth module"
pi-gemma31 -p "Summarize this file: ..."
pi-minimax "Plan a refactor of this service"
pi-qwen-coder "Implement the parser and wire up the tests"
pi-ornith-stop   # / pi-gemma31-stop / pi-minimax-stop / pi-qwen-coder-stop to free the server
```

**Served context windows:** Ornith, Gemma 31B and Qwen-Coder are set to the native **262144
(256K)** — KV stays cheap there (Ornith/Qwen-Coder are SSM-hybrid; Gemma caps 50 of 60 layers
at a 1024-token sliding window). **MiniMax** is set to **131072 (128K)** with a **q8_0 KV
cache** — at 101 GiB of weights, f16 KV at 128K would need ~134 GiB (> 128 GiB RAM), so the KV
is quantized (≈120 GiB working set; 64K would be the largest MiniMax can do with full f16 KV).
Adjust via the `*_CTX` vars (inline wrappers) or the `--ctx` passed to `run-*.sh`.

**MiniMax memory note:** its working set exceeds the default Metal GPU budget (~96 GB on a 128 GB
Mac), so `-ngl 99` OOMs unless the GPU ceiling is raised. `pi-minimax` raises it automatically via
`sudo sysctl -w iogpu.wired_limit_mb=125952` on first use (prompts for your password once per boot;
the cap is a ceiling, not a reservation, and resets on reboot). To set it manually:
`sudo sysctl -w iogpu.wired_limit_mb=125952`.
