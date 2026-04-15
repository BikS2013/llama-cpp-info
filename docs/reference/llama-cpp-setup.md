# llama.cpp — macOS Apple Silicon Setup & Reference

> Platform target: macOS with Apple Silicon (M4 Max, arm64)
> Last researched: 2026-04-13
> Source repository: https://github.com/ggml-org/llama.cpp

---

## Overview

llama.cpp is a plain C/C++ LLM inference library with minimal dependencies. Apple Silicon is
treated as a first-class citizen: the codebase is optimised through ARM NEON intrinsics, Apple's
Accelerate framework, and the Metal GPU framework. On M-series hardware this gives near-native
performance without any proprietary driver stack.

The project produces a core shared library (`libllama`) plus a set of CLI tools. GGUF is the
native model format; most models available on Hugging Face now provide GGUF variants.

---

## Key Concepts

| Term | Meaning |
|---|---|
| **GGUF** | Binary model format used by llama.cpp. Replaces the older GGML format. |
| **Metal** | Apple's GPU compute framework; used as the GPU backend on macOS/iOS. |
| **n-gpu-layers (`-ngl`)** | Number of transformer layers offloaded to the GPU. Set to 99 or "all" to offload everything. |
| **Quantization** | Weight compression (e.g. Q4_K_M). Reduces model size and memory bandwidth required. |
| **Context size (`-c`)** | Maximum token window the model can attend to at once. |
| **Unified memory** | Apple Silicon has a single memory pool shared by CPU and GPU — no separate VRAM. |

---

## Build Dependencies

Install the following with Homebrew before cloning.

```bash
# Xcode Command Line Tools — required for Metal SDK and clang
xcode-select --install

# CMake — the build system used by llama.cpp
brew install cmake

# (Optional) ccache — significantly speeds up repeated compilations
brew install ccache

# (Optional) Ninja — faster build generator than the default Makefiles
brew install ninja

# (Optional) Git LFS — needed only when downloading large model files via git
brew install git-lfs
```

Notes:
- The **Accelerate** and **Metal** frameworks ship with macOS and Xcode Command Line Tools —
  no separate installation is required.
- OpenSSL is optional; without it the build compiles normally but HTTPS model-download features
  (`-hf`, `-mu`) will be unavailable.

  ```bash
  brew install openssl
  ```

---

## Clone and Build from Source

### 1. Clone the repository

```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
```

### 2. Standard Metal build (recommended for Apple Silicon)

Metal is **enabled by default** on macOS. A plain CMake configure step will pick it up
automatically.

```bash
# Configure — Metal is on by default, no extra flag required
cmake -B build

# Build all targets using all available CPU cores
cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

The compiled binaries are placed under `build/bin/`.

### 3. Explicit Metal flag (makes intent clear)

Although Metal is auto-detected, you can pass the flag explicitly for clarity or CI pipelines:

```bash
cmake -B build -DGGML_METAL=ON
cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

### 4. Disable Metal (CPU-only build)

```bash
cmake -B build -DGGML_METAL=OFF
cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

---

## CMake Flags Reference

### Metal and GPU flags

| Flag | Default | Effect |
|---|---|---|
| `-DGGML_METAL=ON` | ON on macOS | Enable Metal GPU backend |
| `-DGGML_METAL=OFF` | — | Force CPU-only build |
| `-DGGML_METAL_SHADER_DEBUG=ON` | OFF | Compile Metal shaders with debug info; disables fast-math |
| `-DGGML_METAL_MACOSX_VERSION_MIN=<ver>` | — | Set minimum macOS version for Metal shader compilation |
| `-DGGML_METAL_NDEBUG` | OFF | Disable Metal debug assertions (slight perf gain) |

### General build flags

| Flag | Default | Effect |
|---|---|---|
| `-DCMAKE_BUILD_TYPE=Release` | Release | Optimised build with -O3 |
| `-DCMAKE_BUILD_TYPE=Debug` | — | Debug symbols, no optimisation |
| `-DBUILD_SHARED_LIBS=OFF` | ON | Build static libraries |
| `-DGGML_NATIVE=ON` | ON | Compile for the host CPU's exact instruction set |
| `-DGGML_NATIVE=OFF` | — | Generic portable binary |
| `-DGGML_BLAS=ON` | OFF | Enable BLAS acceleration for prompt processing |
| `-DLLAMA_CURL=ON` | OFF | Enable model download from URLs (requires curl) |

### Full recommended build command for M4 Max

```bash
cmake -B build \
      -DGGML_METAL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DGGML_NATIVE=ON

cmake --build build --config Release -j$(sysctl -n hw.ncpu)
```

The Accelerate framework (BLAS for prompt processing) is **enabled by default on Mac** — no
extra flag is needed for it.

---

## Produced Executables

After a successful build, the binaries appear in `build/bin/`. Key ones are:

| Executable | Purpose |
|---|---|
| `llama-cli` | Interactive chat or single-shot text completion from the terminal |
| `llama-server` | OpenAI-compatible HTTP API server (chat completions, embeddings, reranking) |
| `llama-bench` | Benchmarks prompt-processing (PP) and text-generation (TG) speed |
| `llama-run` | Minimal single-command model runner |
| `llama-simple` | Minimal code-level inference example |
| `llama-quantize` | Converts FP16/FP32 GGUF models to quantized formats |
| `llama-perplexity` | Evaluates model perplexity on a dataset |
| `llama-embedding` | Generates text embeddings |
| `llama-batched-bench` | Benchmarks multi-user batched inference scenarios |

### llama-cli

Direct, interactive CLI for completion or chat. Suitable for quick tests and scripted pipelines.

```bash
# Single-shot completion
./build/bin/llama-cli -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -p "Explain Metal GPU acceleration in two sentences" \
    -n 256

# Interactive conversation mode
./build/bin/llama-cli -m models/llama-3.1-8b-instruct-Q4_K_M.gguf -cnv

# With explicit GPU offload and a system prompt
./build/bin/llama-cli -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -ngl 99 \
    -cnv -sys "You are a helpful assistant"
```

### llama-server

Full HTTP server that exposes OpenAI-compatible `/v1/chat/completions`,
`/v1/embeddings`, and other endpoints.

```bash
# Start on default port 8080
./build/bin/llama-server -m models/llama-3.1-8b-instruct-Q4_K_M.gguf

# Production-style: expose on all interfaces, large context, GPU offload
./build/bin/llama-server \
    -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    --host 0.0.0.0 \
    --port 8080 \
    -c 8192 \
    -ngl 99 \
    -fa on \
    -np 4
```

---

## Key Command-Line Parameters

Parameters are shared across `llama-cli`, `llama-server`, and most other tools.

### Model loading

| Parameter | Env var | Description |
|---|---|---|
| `-m, --model FNAME` | `LLAMA_ARG_MODEL` | Path to GGUF model file |
| `-hf <user>/<repo>[:quant]` | `LLAMA_ARG_HF_REPO` | Download and use a model from Hugging Face |
| `-mu MODEL_URL` | `LLAMA_ARG_MODEL_URL` | Download model from a direct URL |

### GPU offloading

| Parameter | Env var | Description |
|---|---|---|
| `-ngl N, --n-gpu-layers N` | `LLAMA_ARG_N_GPU_LAYERS` | Number of transformer layers to offload to Metal GPU. Use `99` or `all` to offload everything. Use `0` to force CPU-only. Default: `auto` |
| `-dev <dev1,dev2,...>` | `LLAMA_ARG_DEVICE` | Comma-separated list of devices for offloading. Use `--list-devices` to see available devices |

### Context and memory

| Parameter | Env var | Description |
|---|---|---|
| `-c N, --ctx-size N` | `LLAMA_ARG_CTX_SIZE` | Context window size in tokens. `0` = use model default. Larger values use more memory. |
| `-b N, --batch-size N` | `LLAMA_ARG_BATCH` | Logical max batch size (default: 2048). Affects prompt processing speed. |
| `-ub N, --ubatch-size N` | `LLAMA_ARG_UBATCH` | Physical micro-batch size (default: 512). |
| `--mlock` | `LLAMA_ARG_MLOCK` | Lock model in RAM (prevents swapping). Useful on systems with memory pressure. |
| `--mmap / --no-mmap` | `LLAMA_ARG_MMAP` | Memory-map the model file (default: enabled). Faster loads; disable to reduce page-outs. |
| `-ctk TYPE` | `LLAMA_ARG_CACHE_TYPE_K` | KV-cache K data type: `f32`, `f16` (default), `q8_0`, `q4_0`, etc. |
| `-ctv TYPE` | `LLAMA_ARG_CACHE_TYPE_V` | KV-cache V data type (same options as `-ctk`). |

### CPU threading

| Parameter | Env var | Description |
|---|---|---|
| `-t N, --threads N` | `LLAMA_ARG_THREADS` | CPU threads for generation. Default: `-1` (auto). For M4 Max, start with 14 and experiment. |
| `-tb N, --threads-batch N` | — | CPU threads for prompt processing (batch). Defaults to `--threads`. |

### Performance features

| Parameter | Env var | Description |
|---|---|---|
| `-fa [on\|off\|auto], --flash-attn` | `LLAMA_ARG_FLASH_ATTN` | Flash Attention. Default: `auto`. Recommended: `on` for Metal. Reduces memory use and often improves speed. |
| `-kvo / -nkvo` | `LLAMA_ARG_KV_OFFLOAD` | Offload KV-cache to GPU memory (default: enabled). |

### Generation / sampling

| Parameter | Env var | Description |
|---|---|---|
| `-n N, --predict N` | `LLAMA_ARG_N_PREDICT` | Max tokens to generate. `-1` = infinite. |
| `-p TEXT, --prompt TEXT` | — | Input prompt (llama-cli). |
| `--temp N` | — | Sampling temperature (default: 0.80). Lower = more deterministic. |
| `--top-k N` | `LLAMA_ARG_TOP_K` | Top-K sampling (default: 40). |
| `--top-p N` | — | Top-P / nucleus sampling (default: 0.95). |
| `--repeat-penalty N` | — | Penalty for repeating tokens (default: 1.00). |
| `-s N, --seed N` | — | RNG seed for reproducible output. `-1` = random. |

### Server-specific

| Parameter | Env var | Description |
|---|---|---|
| `--host ADDR` | — | Bind address (default: `127.0.0.1`). Use `0.0.0.0` to expose on LAN. |
| `--port N` | — | Listen port (default: `8080`). |
| `-np N, --parallel N` | `LLAMA_ARG_N_PARALLEL` | Number of parallel request slots (default: auto). |
| `--embedding` | — | Enable the `/v1/embeddings` endpoint. |
| `--pooling {none,mean,cls,last,rank}` | — | Pooling strategy for embeddings. |
| `-cb / -nocb` | `LLAMA_ARG_CONT_BATCHING` | Continuous batching for multi-user throughput (default: enabled). |

---

## Apple Silicon — Specific Considerations and Optimisations

### Unified Memory

Apple Silicon has a single unified memory pool shared by the CPU and GPU. This means:

- There is **no separate VRAM limit** — model size is limited only by total system RAM.
- On a system with 128 GB RAM, a fully quantised 70B model (~40 GB at Q4) fits entirely in
  memory and can be offloaded fully to Metal with `-ngl 99`.
- Memory bandwidth — not compute cores — is the primary bottleneck for inference speed.

### Memory Bandwidth as the Performance Ceiling

Every generated token requires reading the entire model weights from memory once. The theoretical
ceiling in tokens/second is:

```
Max tok/s ≈ Memory Bandwidth (GB/s) ÷ Model Size in Memory (GB)
```

M4 Max bandwidth is ~546 GB/s, giving approximate ceilings:

| Model (Q4) | Size | Theoretical ceiling |
|---|---|---|
| 7B Q4_K_M | ~4 GB | ~136 tok/s |
| 14B Q4_K_M | ~8 GB | ~68 tok/s |
| 32B Q4_K_M | ~18 GB | ~30 tok/s |
| 70B Q4_K_M | ~40 GB | ~14 tok/s |

Real-world numbers run at 60–80% of theoretical due to KV-cache reads, attention overhead, and
Metal kernel launch costs.

### Recommended Quantisation Levels

| Quantisation | Bits/weight | Quality delta vs FP16 | Recommendation |
|---|---|---|---|
| `Q8_0` | 8.5 | +0.14% (essentially lossless) | When RAM is plentiful |
| `Q6_K` | 6.6 | +0.41% | Near-lossless, good balance |
| `Q5_K_M` | 5.7 | +1.09% | Quality sweet spot |
| **`Q4_K_M`** | **4.9** | **+3.28%** | **Best size/quality tradeoff — start here** |
| `Q3_K_M` | 3.9 | +8.74% | Meaningful degradation; avoid unless severely RAM-constrained |

K-quants (`Q4_K_M`, `Q5_K_M`, etc.) deliver 3–4x better quality at the same file size compared
to legacy formats (`Q4_0`). The llama.cpp maintainers now recommend `Q3_K_M` over `Q4_0` —
the 3-bit K-quant outperforms the legacy 4-bit format.

### Thread Tuning on M4 Max

The M4 Max has a mix of performance and efficiency cores. Rules of thumb:

- Start with `-t 14` (targeting the P-cores on M4 Max).
- For some K-quants (e.g. Q4_K), performance can actually improve with more threads (up to 32);
  experiment per model.
- When offloading all layers with `-ngl 99`, CPU threads are used mainly for token sampling and
  layer normalisations — the impact is smaller than in CPU-only runs.

### Flash Attention

Enabling Flash Attention with `-fa on` reduces KV-cache memory consumption and often improves
throughput on Metal. Enable it explicitly:

```bash
-fa on
```

### KV-Cache Quantisation

Quantising the KV cache reduces memory pressure at the cost of minor quality loss. A commonly
used setting:

```bash
-ctk q8_0 -ctv q8_0
```

For tighter memory budgets:

```bash
-ctk q4_0 -ctv q4_0
```

### Neural Engine (ANE) — Not Used

The Neural Engine is designed for vision and speech workloads and is not applicable to LLM matrix
operations. Neither llama.cpp nor MLX uses the ANE. All LLM computation runs on the GPU via
Metal.

### Metal Shader Compilation at First Run

On the first launch with a new build, Metal shaders are compiled Just-In-Time and cached. There
will be a noticeable pause (a few seconds) on first run. Subsequent runs use the cached shaders
and start immediately.

---

## Homebrew Pre-built Alternative

If building from source is not required, llama.cpp is available in Homebrew with Metal support
already compiled in:

```bash
brew install llama.cpp
```

The formula tracks official releases automatically. Pre-built binaries are also available on the
[GitHub releases page](https://github.com/ggml-org/llama.cpp/releases).

---

## Obtaining GGUF Models

### From Hugging Face (built-in download)

```bash
# Download and run directly — llama-cli will fetch the model automatically
./build/bin/llama-cli -hf ggml-org/Llama-3.2-1B-Instruct-GGUF

# Specify quant explicitly
./build/bin/llama-cli -hf bartowski/Meta-Llama-3.1-8B-Instruct-GGUF:Q4_K_M
```

### Manual download with huggingface-cli

```bash
pip install huggingface-hub
huggingface-cli download bartowski/Meta-Llama-3.1-8B-Instruct-GGUF \
    --include "Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" \
    --local-dir models/
```

---

## Example Run Commands

### Minimal test (CPU only)

```bash
./build/bin/llama-cli \
    -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -p "Hello, world" \
    -n 64
```

### Full GPU offload, recommended settings for M4 Max

```bash
./build/bin/llama-cli \
    -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -ngl 99 \
    -c 8192 \
    -t 14 \
    -fa on \
    -cnv \
    -sys "You are a helpful assistant"
```

### HTTP server for API access

```bash
./build/bin/llama-server \
    -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -ngl 99 \
    -c 16384 \
    -fa on \
    --host 0.0.0.0 \
    --port 8080 \
    -np 4
```

Access the built-in web UI at `http://localhost:8080`.

### Benchmark to verify Metal acceleration

```bash
./build/bin/llama-bench \
    -m models/llama-3.1-8b-instruct-Q4_K_M.gguf \
    -ngl 99
```

Expected output columns:
- `pp N` — prompt processing speed (tokens/s) for a prompt of N tokens
- `tg N` — text generation speed (tokens/s) for N tokens

---

## Common Pitfalls

| Pitfall | Cause | Fix |
|---|---|---|
| Metal shaders compile every run | `default.metallib` not in working directory | Run from `build/bin/` or set `GGML_METAL_PATH_RESOURCES` |
| "model file does not exist" | Wrong path or file not downloaded | Check path; use `-hf` to auto-download |
| Slow first token | Metal JIT shader compilation | Expected on first run; subsequent runs use cached shaders |
| Out of memory / crash | Context size too large for available RAM | Reduce `-c`; use KV-cache quantisation (`-ctk q8_0`) |
| Low GPU utilisation | Insufficient `-ngl` value | Set `-ngl 99` to offload all layers |
| No speedup from more threads | Memory bandwidth is bottleneck, not compute | Normal for large models; reduce model size or quantisation level |
| Wrong architecture binary | macOS running Rosetta emulation | Confirm `arch` returns `arm64`; rebuild natively |

---

## Checking the Build

Verify Metal is active:

```bash
# Should list a Metal device
./build/bin/llama-server --list-devices
```

Verify the binary architecture:

```bash
file build/bin/llama-cli
# Expected: Mach-O 64-bit executable arm64
```

---

## Assumptions & Scope

| Assumption | Confidence | Impact if Wrong |
|---|---|---|
| Metal is the optimal GPU backend on macOS (vs Vulkan) | HIGH | MLX may offer higher raw throughput for small models; llama.cpp + Metal remains best for large models and split CPU/GPU operation |
| M4 Max has ~546 GB/s memory bandwidth | HIGH | Theoretical tok/s ceilings in this document would be incorrect |
| Thread recommendation of 14 for M4 Max | MEDIUM | Optimal thread count is model and quantisation dependent; always benchmark |
| Neural Engine is not used by llama.cpp | HIGH | Unlikely to change without a significant architecture shift |
| Quantisation quality numbers are for Llama-3.1-8B-Instruct | MEDIUM | Numbers will differ across model families |

**Explicitly out of scope:**
- MLX inference framework (separate project, not llama.cpp)
- Ollama (uses llama.cpp internally but abstracts it)
- CUDA / ROCm / Vulkan backends (not applicable on macOS Apple Silicon)
- Model fine-tuning or training

---

## References

| Source | URL | Notes |
|---|---|---|
| llama.cpp official build guide | https://raw.githubusercontent.com/ggml-org/llama.cpp/master/docs/build.md | Primary source for CMake flags and Metal build steps |
| llama.cpp README | https://raw.githubusercontent.com/ggml-org/llama.cpp/master/README.md | Overview, model list, quick-start |
| llama.cpp install guide | https://raw.githubusercontent.com/ggml-org/llama.cpp/master/docs/install.md | Homebrew / pre-built options |
| llama-server README | https://raw.githubusercontent.com/ggml-org/llama.cpp/master/tools/server/README.md | Full CLI parameter reference |
| Context7 — llama.cpp docs | https://context7.com/ggml-org/llama.cpp | llama-cli and llama-server usage examples |
| Starmorph inference guide | https://blog.starmorph.com/blog/apple-silicon-llm-inference-optimization-guide | M4 Max bandwidth benchmarks, quantisation quality table |
| llama.cpp M-series discussion | https://github.com/ggml-org/llama.cpp/discussions/4167 | Community performance data on Apple Silicon |
| Metal CMakeLists.txt | https://github.com/ggml-org/llama.cpp/blob/master/ggml/src/ggml-metal/CMakeLists.txt | Internal Metal shader compilation details |
