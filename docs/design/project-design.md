# Project Design: llama.cpp + Gemma 4 Local Inference

## Overview

This project sets up llama.cpp on macOS (Apple M4 Max, arm64, 128GB RAM) to run Google's Gemma 4 model locally with Metal GPU acceleration.

## System Architecture

```
[User] --> [llama-cli / llama-server] --> [ggml Metal Backend] --> [Apple M4 Max GPU]
                    |
                    v
            [GGUF Model File]
            (gemma-4-E2B-it-Q8_0.gguf)
```

## Hardware

| Component | Specification |
|-----------|---------------|
| CPU | Apple M4 Max (arm64) |
| RAM | 128 GB unified memory |
| GPU | Apple M4 Max (Metal, MTLGPUFamilyApple9) |
| GPU Available Memory | ~110 GB |
| Memory Bandwidth | ~546 GB/s |

## Software Stack

| Component | Version/Details |
|-----------|-----------------|
| llama.cpp | Build b8770-82764d8f4 (April 2026) |
| CMake | 4.3.1 |
| Metal Backend | Enabled (default on Apple Silicon) |
| Accelerate/BLAS | Enabled (Apple framework) |
| Model Format | GGUF (quantized) |

## Model: Gemma 4 E2B

| Property | Value |
|----------|-------|
| Model | Google Gemma 4 E2B (instruction-tuned) |
| Effective Parameters | 2.3 billion |
| Context Length | 128K tokens |
| Quantization | Q8_0 |
| File Size | 4.7 GB |
| Source | `unsloth/gemma-4-E2B-it-GGUF` on HuggingFace |
| Release Date | April 2, 2026 |

### Gemma 4 Family Overview

| Variant | Effective Params | Context | Total Params | Use Case |
|---------|-----------------|---------|-------------|----------|
| **E2B** (selected) | 2.3B | 128K | 2.3B | Lightweight, 4-8 GB RAM |
| E4B | 4.5B | 128K | 4.5B | Mid-range, 6-12 GB RAM |
| 26B A4B (MoE) | 4B active | 256K | 25.2B | Speed + quality balance |
| 31B | 30.7B | 256K | 30.7B | Maximum quality |

## Directory Structure

```
llama-cpp/
  CLAUDE.md                           # Project instructions
  Issues - Pending Items.md           # Issue tracker
  docs/
    design/
      project-design.md               # This file
      project-functions.md            # Functional requirements
    reference/
      llama-cpp-setup.md              # llama.cpp build reference
      gemma4-models.md                # Gemma 4 model reference
  models/
    gemma-4-E2B/
      gemma-4-E2B-it-Q8_0.gguf       # Model file (4.7 GB)
  llama.cpp/                          # Cloned llama.cpp repository
    build/
      bin/
        llama-cli                     # CLI inference tool
        llama-server                  # OpenAI-compatible API server
  test_scripts/                       # Test scripts
```

## Build Configuration

### CMake Configuration

```bash
cmake -B build -DGGML_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

Metal is enabled by default on Apple Silicon. The `-DGGML_METAL=ON` flag is explicit but not strictly required.

### Key Build Outputs

| Binary | Path | Purpose |
|--------|------|---------|
| `llama-cli` | `llama.cpp/build/bin/llama-cli` | Interactive CLI for text generation |
| `llama-server` | `llama.cpp/build/bin/llama-server` | OpenAI-compatible HTTP API server |

## Inference Configuration

### CLI Usage (llama-cli)

**Interactive conversation mode (default):**
```bash
./llama.cpp/build/bin/llama-cli \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  -ngl 99 \
  --temp 0.7
```

**Single-turn mode (non-interactive):**
```bash
./llama.cpp/build/bin/llama-cli \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  -p "Your prompt here" \
  -n 200 \
  -ngl 99 \
  --temp 0.7 \
  -no-cnv -st
```

### Server Usage (llama-server)

```bash
./llama.cpp/build/bin/llama-server \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  -ngl 99 \
  --port 8080
```

### Key Parameters

| Parameter | Description | Recommended Value |
|-----------|-------------|-------------------|
| `-m` | Model file path | `./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf` |
| `-ngl` | Number of GPU layers (99 = all) | `99` |
| `-n` | Max tokens to generate | `200` (adjustable) |
| `--temp` | Sampling temperature | `0.7` |
| `-t` | CPU threads | `14` (M4 Max optimal) |
| `-c` | Context size | `4096` (default, up to 128K) |
| `-st` | Single turn (exit after one response) | Use for scripting |
| `-no-cnv` | Disable conversation mode | Use for raw completion |
| `--port` | Server port (llama-server only) | `8080` |
| `-fa` | Flash Attention | `on` (recommended) |

## Performance (Measured on M4 Max)

| Metric | Value |
|--------|-------|
| Prompt Processing | 67-70 tokens/sec |
| Token Generation | 115-120 tokens/sec |
| GPU Memory Usage | ~6 GB |
| Model Load Time | ~7 seconds (first run, shader compilation) |
| Model Load Time | <1 second (subsequent runs, cached shaders) |

## Known Issues & Notes

1. **Gemma 4 requires llama.cpp build from April 11, 2026+** -- earlier builds have chat template (PR #21326) and tokenizer (PR #21343) bugs that cause garbage output
2. **Do NOT use CUDA 13.2** with Gemma 4 -- causes incorrect outputs (not relevant for Metal/macOS)
3. **Image/multimodal inference** requires additional `mmproj-BF16.gguf` projector file and `llama-mtmd-cli` binary
4. **Audio inference** (E2B/E4B) is still in active development as of April 2026
