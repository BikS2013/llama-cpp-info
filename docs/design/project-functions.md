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
