# Issues & Pending Items

## Pending Items

### P001: Test llama-server API endpoint
- **Priority:** Medium
- **Description:** The llama-server binary has been built but not tested as an API server. Should verify `/v1/chat/completions` endpoint works with Gemma 4 E2B.

### P002: Evaluate larger Gemma 4 variants
- **Priority:** Low
- **Description:** With 128GB RAM, the machine can run much larger models (E4B, 26B MoE, 31B). Consider downloading and benchmarking these for quality comparison.

### P003: Multimodal support not configured
- **Priority:** Low
- **Description:** Gemma 4 E2B supports image input, but the multimodal projector file (`mmproj-BF16.gguf`) has not been downloaded. Requires `llama-mtmd-cli` binary.

---

## Completed Items

### C001: Install build prerequisites (cmake)
- **Completed:** 2026-04-13
- **Resolution:** Installed cmake 4.3.1 via Homebrew

### C002: Clone and compile llama.cpp with Metal support
- **Completed:** 2026-04-13
- **Resolution:** Build b8770-82764d8f4, Metal and Accelerate/BLAS enabled

### C003: Download Gemma 4 E2B model
- **Completed:** 2026-04-13
- **Resolution:** Downloaded gemma-4-E2B-it-Q8_0.gguf (4.7 GB) from unsloth/gemma-4-E2B-it-GGUF

### C004: Verify inference
- **Completed:** 2026-04-13
- **Resolution:** Successfully ran inference. Prompt: 67 t/s, Generation: 120 t/s on M4 Max
