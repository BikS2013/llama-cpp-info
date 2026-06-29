<structure-and-conventions>
## Structure & Conventions

### Project Artifacts & Layout

- Test scripts go in the `test_scripts` folder; create the folder if it doesn't exist.
- Plans live under `docs/design/`, one file per plan, named `plan-NNN-<indicative-description>.md`.
- The complete project design is maintained in `docs/design/project-design.md`; update it with each new design or design change.
- All reference material used for the project is collected and kept under `docs/reference/`.
- All functional requirements and feature descriptions are registered in `docs/design/project-functions.md`.
- Every prompt created while working in a project goes in a dedicated `prompts` folder (create it if missing); each prompt file name has a sequential number prefix and is representative of the prompt's use and purpose.
- Maintain `Issues - Pending Items.md` at the project root: register every issue, pending item, inconsistency, or discrepancy you detect, and whenever you fix a defect or issue, check the file for an item to remove. Pending items come first (most critical and important on top), completed items after.
- Every time you are asked to solve an issue, you must resolve it AND thoroughly document both the issue and the solution.

<configuration-guide>
- If the user asks for a configuration guide, create it at `docs/design/configuration-guide.md` and make sure it explains:
  - When multiple configuration options exist (config file, env variables, CLI params, etc.), what the options are and the priority of each one.
  - The purpose and use of each configuration variable.
  - How the user can obtain such a configuration variable.
  - The recommended approach for storing or managing the variable.
  - Which options exist for the variable and what each option means for the project.
  - Any default value the parameter has.
  - For configuration parameters that expire (e.g., PAT keys, tokens), propose adding a parameter that captures the expiration date, so the app or service can proactively warn users to renew.
</configuration-guide>

### Tools

- Tools created in the context of a project are always written in TypeScript.
- **Tool creation is MANDATORY via `/tool-conventions scaffold <tool-name>`.** Do NOT scaffold a tool's documentation file or its `~/.tool-agents/<tool-name>/` configuration folder by hand under any circumstances. The slash command dispatches the `tool-doc-config-architect` subagent (`~/.claude/agents/tool-doc-config-architect.md`), which owns the full specification — the documentation file format (the `<toolName>` XML block under `docs/tools/<tool-name>.md`), the configuration folder structure and modes (`~/.tool-agents/<tool-name>/` at `0700`, `.env` at `0600`), the four-tier env-var resolution chain (shell env → `~/.tool-agents/<name>/.env` → local `.env` → CLI flags, lowest to highest priority), the vendor-canonical LLM provider env-var names (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GOOGLE_API_KEY`, `AZURE_OPENAI_*`, `AZURE_AI_INFERENCE_*`, `OLLAMA_HOST`, `LITELLM_*`), and the required set of eight standard LLM providers every LLM-enabled tool must support out of the box. Read the subagent prompt to inspect the full specification. For existing tools, run `/tool-conventions audit <tool-name>` to verify conformance.
- The project's CLAUDE.md must NOT contain full tool documentation. It must contain a "Tools" section with a concise entry per tool: the tool's name, a one-or-two-sentence description of what it is capable of, and the relative path to its dedicated documentation file (e.g. `docs/tools/<tool-name>.md`) so the full documentation can be retrieved any time it is needed. The slash command produces the recommended entry text after each scaffold.
- Before writing any code script, examine the tools already implemented in the project (via the "Tools" section of the project's CLAUDE.md and the documentation under `docs/tools/`) to detect whether the planned code fits the scope of an existing tool. If so, implement it as an extension of that tool; otherwise build a generic, abstract version of the code as a new tool in the project's toolset. The goal is to progressively grow the tools needed to test, evaluate, generate data, collect information, etc., and reuse them consistently — all referenced in the project's CLAUDE.md.

### General Rules

- When asked to locate code, report the folder, the file name, the class, and the line number together with the code extract.
- Don't perform any version-control operation unless explicitly requested.
- Database table naming: table names must be singular (e.g. the table keeping customers' data is `Customer`). Tables expressing references from one entity to another may be plural when the first entity links to many of the second — so with `Customer` and `Transaction` tables, the link table is `CustomerTransactions`.
- NEVER create fallback solutions for configuration settings. Whenever a configuration setting is not provided, raise the appropriate exception — never substitute the missing value with a default or fallback. If the user explicitly asks for an exception to this rule, write the exception in the project's memory file before implementing it.

<dependency-vetting>
- Before adding ANY new runtime dependency to a project (`package.json`, `pyproject.toml`, `go.mod`, etc.), you MUST verify the version you are about to pin is free of known security advisories. Apply this rule especially to:
  - **Browser/embedded-engine packages:** `electron`, `puppeteer`, `playwright`, `chromium`, `webview2` — they ship with full browser engines and accumulate CVEs fast.
  - **Test/build toolchains:** `vitest`, `vite`, `esbuild`, `webpack`, `rollup`, `parcel` — frequent dev-server-RCE advisories with transitive impact.
  - **Network/proxy libraries:** `node-http-proxy`, `http-proxy-3`, `proxy-chain`, `axios`, `node-fetch`, `request`, `got`, `undici`.
  - **Cryptography / auth libraries:** `jsonwebtoken`, `jose`, `bcrypt`, `node-forge`, `crypto-js`.

- Vetting procedure (run BEFORE writing the dependency into the manifest):
  1. Identify the latest stable major version available on the registry (e.g. `npm view <pkg> versions --json | tail -10` or `pnpm info <pkg> versions --json`).
  2. Check the package's security advisory page (GitHub Advisory Database, npmjs.com vulnerability tab, or `npm audit --package <pkg>@<version> --json`) for the candidate version.
  3. If the candidate version has unfixed advisories at HIGH severity or above, bump to the next non-vulnerable major (or, if no such version exists, surface the trade-off to the user via AskUserQuestion before proceeding).
  4. Pin to a caret range against the verified clean version (e.g. `"electron": "^39.8.5"`, not `"electron": "^38"`).
  5. Record the vetted-on date in a one-line comment in `Issues - Pending Items.md` under a "Dependency vetting log" section so future audits can date the decision.

- For ESPECIALLY fast-moving packages (`electron`, `vite`, `vitest`, `esbuild`), ALWAYS pull the latest stable major even when a reference implementation uses an older one. The reference's version is informational, not authoritative — verify it is still on a supported branch before adopting it verbatim.

- After installing, ALWAYS run the project's audit command (`pnpm audit`, `npm audit`, `pip-audit`, `cargo audit`, `go list -m -u -json all | nancy sleuth`, etc.) and confirm the advisory count is zero before marking the scaffolding step complete. Treat any HIGH-or-above advisory as a blocker; surface it before continuing.

- When a transitive dependency carries an advisory that the direct dependency has not yet fixed (e.g. `vitest@1` pulling `vite@5` with a CVE), use the package manager's override mechanism (`pnpm.overrides`, `npm overrides`, `yarn resolutions`, `cargo [patch]`) to force the fixed transitive version, AND document the override in `Issues - Pending Items.md` with its expiry condition (i.e. "remove this override once direct-dep X reaches version Y").
</dependency-vetting>

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
  - **Ornith-1.0-35B** (35B MoE, ~3B active, `qwen35moe` / Qwen3-Next delta-net hybrid, Q8_0 36.9 GB) — `models/Ornith-1.0-35B/ornith-1.0-35b-Q8_0.gguf`
    - Agentic-coding model from DeepReinforce; reasoning (`<think>`), OpenAI-style tool calling (qwen3 XML), 256K context, MIT licensed
    - Recommended sampling: **temp 0.6, top-p 0.95, top-k 20**
    - Performance: ~99 t/s prompt, ~93 t/s generation at Q8_0 on Apple M5 Max (128 GB unified memory)
    - Run via the dedicated wrapper `./run-ornith.sh` (bakes in the optimal flags). See `docs/reference/ornith-models.md`.
    - Requires a llama.cpp build that implements the `qwen35moe` arch (present since ~b8855; this repo is on b9835)
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

**Interactive chat (Ornith):**
```bash
./run-ornith.sh chat
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

**Ornith-1.0-35B (agentic coding) — use the dedicated wrapper:**
```bash
./run-ornith.sh chat                      # interactive REPL (temp 0.6, top-p 0.95, top-k 20, --jinja)
./run-ornith.sh serve --ctx 65536         # OpenAI-compatible API on :8080 with tool calling
./run-ornith.sh ask "Explain this stack trace ..." --tokens 2048
```
Equivalent raw command (what the wrapper runs):
```bash
./llama.cpp/build/bin/llama-cli -m ./models/Ornith-1.0-35B/ornith-1.0-35b-Q8_0.gguf \
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
./scripts/download-Ornith-1.0-35B.sh
./scripts/download-Qwen3-Coder-Next.sh
```

Download examples:
```bash
# Gemma 4 E4B (4.5B params, single file)
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/gemma-4-E4B-it-GGUF \
  --include "gemma-4-E4B-it-Q8_0.gguf" --local-dir models/gemma-4-E4B

# MiniMax-M2.7 UD-IQ4_XS (sharded, ~108 GB)
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/MiniMax-M2.7-GGUF \
  --include "UD-IQ4_XS/*" --local-dir models/MiniMax-M2.7

# Ornith-1.0-35B Q8_0 (single file, ~37 GB) — agentic coding MoE
HF_HUB_ENABLE_HF_TRANSFER=1 hf download deepreinforce-ai/Ornith-1.0-35B-GGUF \
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
| `pi-ornith` / `pi-ornith-stop` | Ornith-1.0-35B (agentic coding MoE) | 8090 | `ornith` |
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

**MiniMax memory note:** its ~108 GB working set exceeds the default Metal GPU budget
(~96 GB on a 128 GB Mac), so `-ngl 99` OOMs unless the GPU ceiling is raised. `pi-minimax`
raises it automatically via `sudo sysctl -w iogpu.wired_limit_mb=122880` on first use (prompts
for your password once per boot; the cap is a ceiling, not a reservation, and resets on reboot).
To set it manually: `sudo sysctl -w iogpu.wired_limit_mb=122880`.

@~/.claude/pre-implementation-pipeline.md
