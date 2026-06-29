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
