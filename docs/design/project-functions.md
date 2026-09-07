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

## F004: Ornith-1.0-35B Agentic-Coding Inference

**Description:** Run the DeepReinforce **Ornith-1.0-35B** agentic-coding model (`qwen35moe` /
Qwen3-Next delta-net hybrid MoE — 35B total, ~3B active, 256K context, reasoning + OpenAI-style
tool calling) locally on Apple Silicon at Q8_0 with its recommended sampling settings.

**Capabilities:**
- Dedicated wrapper `run-ornith.sh` with three modes: `chat` (REPL), `serve` (OpenAI-compatible
  API with tool calling), `ask` (one-shot).
- Bakes in the DeepReinforce-recommended sampling (temp 0.6, top-p 0.95, top-k 20), full Metal
  offload (`-ngl 99`), flash attention, and `--jinja` so the embedded chat template drives
  `<think>` reasoning and `<tool_call>` parsing.
- Quant-selectable (`--quant`), context-selectable up to 262144 (`--ctx`), with passthrough of
  arbitrary llama.cpp flags after `--`.
- Reference: `docs/reference/ornith-models.md`.

**Status:** Implemented (Q8_0 downloaded; llama.cpp rebuilt to b9835 for `qwen35moe` support).

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

## F012: Thinking-Free Runs via `--no-think` (start-repl.sh / start-api.sh / ask.sh)

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
