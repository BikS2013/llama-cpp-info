# Functional Requirements: llama.cpp + Gemma 4

## F001: Local LLM Inference via llama-cli

**Description:** Run Gemma 4 E2B model locally using llama-cli for text generation with Metal GPU acceleration.

**Capabilities:**
- Interactive conversation mode with chat history
- Single-turn prompt completion mode for scripting
- Configurable generation parameters (temperature, max tokens, context size)
- Full GPU offloading via Metal backend

**Status:** Implemented and verified

## F002: OpenAI-Compatible API Server via llama-server

**Description:** Run Gemma 4 E2B as an HTTP API server compatible with the OpenAI API format.

**Capabilities:**
- `/v1/chat/completions` endpoint
- `/v1/completions` endpoint
- Configurable port and host
- Full GPU offloading via Metal backend

**Status:** Available (binary built, not yet tested as server)

## F003: Model Management

**Description:** Download and manage GGUF model files from HuggingFace.

**Capabilities:**
- Download specific quantization variants via `huggingface-cli`
- Support for multiple Gemma 4 variants (E2B, E4B, 26B, 31B)
- Support for multiple quantization levels (Q4_K_M, Q5_K_M, Q8_0, etc.)

**Status:** Implemented (E2B Q8_0 downloaded)

## F004: Ornith Agentic-Coding Inference (Ornith-1.5-35B-A3B, Ornith-1.0-35B)

**Description:** Run the Ornith AI (formerly DeepReinforce) **Ornith-1.5-35B-A3B** agentic-coding
model — and its predecessor **Ornith-1.0-35B** — (`qwen35moe` / Qwen3-Next delta-net hybrid MoE —
35B total, ~3B active, 256K context, reasoning + OpenAI-style tool calling) locally on Apple
Silicon at Q8_0 with the recommended sampling settings. Ornith 1.5 (2026-08-24) is the wrapper
default; 1.0 remains selectable with `--version 1.0`. Ornith 1.5 additionally ships an mmproj,
loaded on demand with `--vision`.

**Capabilities:**
- Dedicated wrapper `run-ornith.sh` with three modes: `chat` (REPL), `serve` (OpenAI-compatible
  API with tool calling), `ask` (one-shot).
- Bakes in the DeepReinforce-recommended sampling (temp 0.6, top-p 0.95, top-k 20), full Metal
  offload (`-ngl 99`), flash attention, and `--jinja` so the embedded chat template drives
  `<think>` reasoning and `<tool_call>` parsing.
- Quant-selectable (`--quant`), context-selectable up to 262144 (`--ctx`), with passthrough of
  arbitrary llama.cpp flags after `--`.
- Generation-selectable (`--version 1.5|1.0`), optional vision projector (`--vision`, 1.5 only).
- Reference: `docs/reference/ornith-models.md`.

**Status:** Implemented (1.5 Q8_0 + mmproj downloaded 2026-09-07 and verified on the b9835 build; the 1.0 Q8_0 file was removed from disk the same day — `--version 1.0` requires a re-download).

## F005: Qwen3-Coder-Next Agentic-Coding Inference

**Description:** Run the Qwen team's **Qwen3-Coder-Next** agentic-coding model (Qwen3-Next hybrid
gated delta-net + MoE — 80B total, ~3B active, 256K context, **non-reasoning**, OpenAI-style
`qwen3_coder` tool calling) locally on Apple Silicon at UD-Q6_K_XL with its recommended sampling
settings.

**Capabilities:**
- Dedicated wrapper `run-qwen-coder.sh` with three modes: `chat` (REPL), `serve` (OpenAI-compatible
  API with tool calling), `ask` (one-shot).
- Bakes in the Qwen/Unsloth-recommended sampling (temp 1.0, top-p 0.95, top-k 40, min-p 0.01,
  repeat-penalty off), full Metal offload (`-ngl 99`), flash attention, `--no-context-shift`, and
  `--jinja` so the embedded chat template drives `qwen3_coder` tool-call parsing.
- Quant-selectable (`--quant`, resolves the per-quant sharded subfolder under
  `models/Qwen3-Coder-Next/`), context-selectable up to 262144 (`--ctx`), with passthrough of
  arbitrary llama.cpp flags after `--`.
- Reference: `docs/reference/qwen-coder-next.md`.

**Status:** Implemented (UD-Q6_K_XL — 73 GB, 3 shards — downloaded; loads on b9835 via the
Qwen3-Next hybrid arch already used by `qwen35moe`).

## F006: Pi Request Refiner Subagent Support

**Description:** Provide a Pi extension that exposes the request-refiner agent specification as an isolated subagent tool for refining broad or complex requests into structured `docs/reference/refined-request-<slug>.md` specifications.

**Capabilities:**
- Registers the `request_refiner_subagent` tool through a TypeScript Pi extension.
- Runs request refinement in a child `pi --mode json -p --no-session` process with restricted file-oriented tools.
- Uses an adapted request-refiner prompt derived from `test/subagent-specs/request-refiner.md`.
- Writes refined request artifacts under the target project's `docs/reference/` folder.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/request-refiner-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/request-refiner-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F007: Pi Codebase Scanner Subagent Support

**Description:** Provide a Pi extension that exposes the codebase-scanner agent specification as an isolated subagent tool for producing concise markdown codebase scans with YAML metadata, module maps, conventions, and optional request-specific integration points.

**Capabilities:**
- Registers the `codebase_scanner_subagent` tool through a TypeScript Pi extension.
- Runs codebase scanning in a child `pi --mode json -p --no-session` process with restricted scanner-oriented tools.
- Uses an adapted codebase-scanner prompt derived from `test/subagent-specs/codebase-scanner.md`.
- Supports optional `request_file`, optional `output_path`, optional `cwd`, and optional child `model` parameters.
- Writes scan artifacts under `docs/reference/codebase-scan-<slug>.md` by default.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/codebase-scanner-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/codebase-scanner-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F008: Pi Investigator Subagent Support

**Description:** Provide a Pi extension that exposes the investigator agent specification as an isolated subagent tool for researching available approaches, comparing options, and recommending a best-fit approach before downstream planning or implementation.

**Capabilities:**
- Registers the `investigator_subagent` tool through a TypeScript Pi extension.
- Runs investigation in a child `pi --mode json -p --no-session` process with restricted locally available tools.
- Uses an adapted investigator prompt derived from `test/subagent-specs/investigator.md`.
- Supports required `investigation_request` plus optional `cwd`, `refined_request_file`, `codebase_scan_file`, `output_path`, `output_slug`, `additional_context`, and child `model` parameters.
- Writes investigation artifacts under `docs/reference/investigation-<slug>.md` by default.
- Ensures successful investigation documents include a parseable `**Research needed**: Yes` or `**Research needed**: No` flag for downstream technical-research routing.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/investigator-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/investigator-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F009: Pi Technical Researcher Subagent Support

**Description:** Provide a Pi extension that exposes the technical-researcher agent specification as an isolated subagent tool for creating implementation-level technical research documentation for specific technologies, libraries, APIs, SDKs, protocols, platforms, frameworks, or patterns.

**Capabilities:**
- Registers the `technical_researcher_subagent` tool through a TypeScript Pi extension.
- Runs technical research in a child `pi --mode json -p --no-session` process with restricted locally available tools.
- Uses an adapted technical-researcher prompt derived from `test/subagent-specs/technical-researcher.md`.
- Supports required `topic` plus optional `why_needed`, `focus_areas`, `depth_level`, `investigation_file`, `output_path`, `cwd`, and child `model` parameters.
- Writes technical research artifacts under `docs/research/<topic-slug>.md` by default.
- Documents unavailable external web/search/Context7 tooling as a research limitation rather than fabricating sources.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/technical-researcher-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/technical-researcher-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F010: Pi Plan Builder Subagent Support

**Description:** Provide a Pi extension that exposes the plan-builder agent specification as an isolated subagent tool for creating executable implementation plans from refined requests and optional investigation, technical research, codebase scan, and design artifacts.

**Capabilities:**
- Registers the `plan_builder_subagent` tool through a TypeScript Pi extension.
- Runs plan creation in a child `pi --mode json -p --no-session` process with restricted locally available tools.
- Uses an adapted plan-builder prompt derived from `test/subagent-specs/plan-builder.md`.
- Requires `request_file` and supports optional `investigation_file`, `research_files`, `codebase_scan_file`, `design_file`, `output_path`, `output_slug`, `duplication_directive`, `original_request`, `cwd`, and child `model` parameters.
- Writes implementation plans under `docs/design/plan-NNN-<slug>.md` by default.
- Produces plans with mandatory YAML frontmatter, atomic dependency-ordered steps, implementation units, risks, acceptance-criteria mapping, deviation rules, and verification commands.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/plan-builder-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/plan-builder-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F011: Pi Tool Doc Config Architect Subagent Support

**Description:** Provide a Pi extension that exposes the tool-doc-config-architect agent specification as an isolated subagent tool for scaffolding and auditing TypeScript CLI tool documentation and configuration conventions.

**Capabilities:**
- Registers the `tool_doc_config_architect_subagent` tool through a TypeScript Pi extension.
- Runs scaffold or audit mode in a child `pi --mode json -p --no-session` process with restricted locally available tools.
- Uses an adapted tool-doc-config-architect prompt derived from `test/subagent-specs/tool-doc-config-architect.md`.
- Supports required `mode` and `tool_name`, optional `project_root`, scaffold-required `tool_description`, `tool_command`, and `llm_required`, optional `extra_config_vars`, and optional child `model`.
- Supports scaffold artifacts for `docs/tools/<tool-name>.md` and `~/.tool-agents/<tool-name>/` while never modifying `CLAUDE.md` directly.
- Supports read-only audit reporting for docs/config/env-var/provider/no-fallback convention compliance.
- Installed for Pi discovery through the symlink `/Users/giorgosmarinos/.pi/agent/extensions/tool-doc-config-architect-subagent` pointing to `/Users/giorgosmarinos/ai-coding/pi-workdocs/extensions/tool-doc-config-architect-subagent`.

**Status:** Implemented and symlinked for Pi reload/restart discovery.

## F012: Qwen3.8-27B Dense Vision-Language Inference

**Description:** Run the Qwen team's **Qwen3.8-27B** (27B dense, `qwen35` arch, native VLM,
thinking on by default, 256K context) locally at UD-Q8_K_XL with the Qwen-recommended sampling.
Successor of the Qwen3.6 series; downloaded as the upgrade path for `qwen-3.6-35B`.

**Capabilities:**
- Downloaded via `scripts/download-qwen-3.8-27B.sh` (or `llama-setup.sh download qwen-3.8-27B`)
  together with its mmproj (`mmproj-BF16.gguf`) for image input.
- Raw `llama-cli` / `llama-server` invocation with `--jinja` so the embedded template drives
  `<think>` reasoning, `reasoning_effort` and tool calling; sampling temp 1.0, top-p 0.95,
  top-k 20, min-p 0 (thinking) or temp 0.7, top-p 0.80, presence-penalty 1.5 (instruct).
- Reference: `docs/reference/qwen38-27b.md`.

**Status:** Implemented (UD-Q8_K_XL + mmproj downloaded 2026-09-07; no llama.cpp rebuild needed).

## F013: Thinking-Free Runs via `--no-think` (start-repl.sh / start-api.sh / ask.sh)

**Description:** Run any downloaded model without reasoning/thinking (`<think>` blocks) from the
generic model-picker scripts, so answers are returned directly and faster.

**Capabilities:**
- `./start-repl.sh --no-think`, `./start-api.sh --no-think` and `./ask.sh "..." --no-think` (default
  remains `auto` = the chat template decides; `--think` restores the default explicitly).
  `ask.sh` also gained `--ctx SIZE` (previously it always used llama-cli's default).
- Discoverability: without the flags, the interactive model picker follows up with a context-size
  menu (`select_ctx` in `lib/model-select.sh`: 4K–256K presets or a custom value, default 4096)
  and a "Thinking / reasoning mode" menu (`select_thinking`); a `--model` run prints a reminder
  for each missing flag (`--ctx SIZE`, `--think`/`--no-think`), and the startup banner always
  states the active context size and thinking mode with the flag that changes each.
- Implemented with llama.cpp b9835 flags: `--reasoning off` (sets `enable_thinking=false` in the
  jinja chat template — honoured by Gemma 4, Qwen 3.x, Ornith) plus `--reasoning-budget 0`
  (forces the end-of-thinking tag as soon as a think block opens — covers MiniMax-M2.7, whose
  template always opens `<think>` and ignores `enable_thinking`).
- API server: a request can opt back into thinking by sending both
  `chat_template_kwargs: {"enable_thinking": true}` and `thinking_budget_tokens: N` (N > 0);
  sending only `enable_thinking` yields a force-closed think block and the reasoning leaks into
  `content`.
- Verified 2026-09-07 with one-shot prompts (thinking present by default, absent with the flag):
  Gemma 4 E2B (4.3 s → 1.1 s), Qwen3.6-35B (13.2 s → 2.8 s), Ornith-1.0-35B (14.5 s → 3.3 s),
  MiniMax-M2.7 (llama-cli, 40 GPU layers: 44 s → 23 s); same result through `llama-server`.

**Status:** Implemented.
