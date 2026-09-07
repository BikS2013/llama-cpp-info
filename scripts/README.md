# Setup Scripts

This folder contains scripts to set up and manage the llama.cpp environment.

## Quick Start

### 1. Clone and Build llama.cpp
```bash
./scripts/llama-setup.sh setup
```

This will:
- Clone/update llama.cpp from GitHub
- Build with Metal GPU support
- Verify the build succeeded

### 2. Download Models
Download specific models or all default models:

```bash
# Download all default models
./scripts/llama-setup.sh download all

# Download a specific model
./scripts/llama-setup.sh download MiniMax-M2.7

# Download all models (including non-default)
./scripts/llama-setup.sh download all-non-default

# List available models
./scripts/llama-setup.sh list
```

### 3. Run a Model
```bash
# Interactive chat with Ornith
./run-ornith.sh chat

# Interactive chat with Qwen3-Coder-Next
./run-qwen-coder.sh chat

# Single prompt
./ask.sh "What is the capital of France?"

# API server
./start-api.sh

# Interactive REPL / API server / single prompt with thinking disabled (no <think> blocks)
./start-repl.sh --no-think
./start-api.sh --no-think
./ask.sh "Explain quicksort" --no-think --ctx 8192
```

When `--ctx` is not given, the interactive model picker asks for the context window size (4K … 256K
presets or a custom token count; default 4096), and when neither `--think` nor `--no-think` is given
it also asks for the thinking mode. A `--model` run prints a one-line reminder for each missing flag.

`--no-think` (in `start-repl.sh`, `start-api.sh` and `ask.sh`) passes llama.cpp's `--reasoning off`
(sets `enable_thinking=false` in the chat template — Gemma 4, Qwen 3.x, Ornith) plus
`--reasoning-budget 0 --reasoning-budget-message $'\n'` (force-closes a think block as soon
as it opens, for templates that ignore `enable_thinking`, e.g. MiniMax-M2.7; the newline
message is required on b9835 because those templates pre-open `<think>\n` — see item 7 in
`Issues - Pending Items.md`). With the API server, a single request can opt back into
thinking by sending both `"chat_template_kwargs": {"enable_thinking": true}` and
`"thinking_budget_tokens": 4096` (any value > 0). Verified 2026-09-07 on Gemma 4 E2B,
Qwen3.6-35B, Ornith-1.0-35B and MiniMax-M2.7.

## Available Scripts

### llama-setup.sh (Unified)
The main consolidated script that provides a single interface for all setup and model management tasks.

**Usage:**
```bash
./scripts/llama-setup.sh <command> [options]

Commands:
  setup                              Clone and build llama.cpp with Metal GPU support
  download [all|model-name]          Download models from HuggingFace
  list                               List available models
  help                               Show this help message
```

**Examples:**
```bash
./scripts/llama-setup.sh setup                    # Build llama.cpp
./scripts/llama-setup.sh download all             # Download all default models
./scripts/llama-setup.sh download MiniMax-M2.7    # Download specific model
./scripts/llama-setup.sh list                     # List all models
```

**Requirements:**
- Xcode Command Line Tools: `xcode-select --install`
- CMake: `brew install cmake`
- Git: `brew install git`
- HF CLI: `uv tool install --with hf_transfer huggingface_hub`

### Individual Download Scripts (Deprecated)
Individual scripts are still available but deprecated in favor of the unified `llama-setup.sh`:

| Script | Model | Size | Status |
|--------|-------|------|--------|
| `download-gemma-4-E2B.sh` | Gemma 4 E2B | 4.7 GB | Deprecated |
| `download-gemma-4-E4B.sh` | Gemma 4 E4B | 7.6 GB | Deprecated |
| `download-gemma-4-26B.sh` | Gemma 4 26B | 25 GB | Deprecated |
| `download-gemma-4-31B.sh` | Gemma 4 31B | 30 GB | Deprecated |
| `download-MiniMax-M2.7.sh` | MiniMax-M2.7 | 101 GB | Deprecated |
| `download-Ornith-1.0-35B.sh` | Ornith-1.0-35B | 34 GB | Deprecated |
| `download-qwen-3.6-35B.sh` | Qwen3.6-35B | 36 GB | Deprecated |
| `download-Qwen3-Coder-Next.sh` | Qwen3-Coder-Next | 68 GB | Deprecated |

### setup-llama-cpp.sh (Legacy)
Legacy script for building llama.cpp. Use `llama-setup.sh setup` instead.

**Usage:**
```bash
./scripts/setup-llama-cpp.sh
```

**Requirements:**
- Xcode Command Line Tools: `xcode-select --install`
- CMake: `brew install cmake`
- Git: `brew install git`
- At least 10 GB free disk space

### download-models.sh (Legacy)
Legacy script for downloading models. Use `llama-setup.sh download` instead.

**Usage:**
```bash
./scripts/download-models.sh                    # Download all default models
./scripts/download-models.sh MiniMax-M2.7       # Download specific model
./scripts/download-models.sh --help             # Show help
```

## Available Models

### Default Models (Downloaded with `download all`)
- **gemma-4-E2B** (2.3B, Q8_0, 4.7 GB) - Fast, good for testing
- **gemma-4-E4B** (4.5B, Q8_0, 7.6 GB) - Slightly larger
- **gemma-4-26B** (A4B, Q8_0, 25 GB) - A4B quantized
- **gemma-4-31B** (dense, Q8_0, 30 GB) - Dense model

### Non-Default Models
- **MiniMax-M2.7** (229B MoE, ~101 GB, 4 shards) - Large MoE model
- **Ornith-1.0-35B** (35B MoE, Q8_0, 34 GB) - Agentic coding model
- **qwen-3.6-35B** (A3B, Q8_K_XL, 36 GB) - Qwen3-Next hybrid
- **Qwen3-Coder-Next** (80B MoE, ~68 GB, 3 shards) - Agentic coding model

## Model Details

### Gemma 4 Series
All Gemma 4 models are dense or quantized dense architectures optimized for efficiency.

| Model | Size | Performance | Notes |
|-------|------|-------------|-------|
| E2B | 4.7 GB | ~67 t/s prompt, ~120 t/s generation | Fastest, great for testing |
| E4B | 7.6 GB | Moderate | Good balance |
| 26B | 25 GB | Moderate | A4B quantized |
| 31B | 30 GB | Moderate | Dense model |

### MiniMax-M2.7
- **229B params MoE**, ~10B active
- **~101 GB total**, 4 shards
- 200K context window
- **Performance**: ~34 t/s prompt, ~5 t/s generation (cold) on Apple M-series with 128 GB unified memory
- **Memory requirement**: For Apple silicon with 128 GB, set GPU memory ceiling:
  ```bash
  sudo sysctl -w iogpu.wired_limit_mb=122880
  ```
- **Usage**: Load the **first shard only** — llama.cpp auto-loads the rest
- **Recommended sampling**: temp 1.0, top-p 0.95, top-k 40

### Ornith-1.0-35B
- **35B MoE**, ~3B active
- **Q8_0**, 34 GB
- Agentic-coding model from DeepReinforce
- **Features**:
  - Reasoning (<think> blocks)
  - OpenAI-style tool calling (qwen3 XML format)
  - 256K context window
  - License: MIT
- **Recommended sampling**: temp 0.6, top-p 0.95, top-k 20
- **Performance**: ~99 t/s prompt, ~93 t/s generation at Q8_0 on Apple M5 Max (128 GB unified memory)
- **Usage**: Use the dedicated wrapper:
  ```bash
  ./run-ornith.sh chat                      # Interactive REPL
  ./run-ornith.sh serve --ctx 65536         # API server (OpenAI-compatible)
  ./run-ornith.sh ask "Explain this..."     # Single prompt
  ```

### Qwen3-Coder-Next
- **80B MoE**, ~3B active
- **UD-Q6_K_XL**, ~68 GB, 3 shards
- Agentic-coding model from the Qwen team (Alibaba)
- **Features**:
  - **NON-reasoning** (no <think> blocks)
  - OpenAI-style tool calling (qwen3_coder format)
  - 256K context window
  - License: Apache-2.0
- **Recommended sampling**: temp 1.0, top-p 0.95, top-k 40, min-p 0.01
- **Usage**: Use the dedicated wrapper:
  ```bash
  ./run-qwen-coder.sh chat                      # Interactive REPL
  ./run-qwen-coder.sh serve --ctx 131072        # API server (OpenAI-compatible)
  ./run-qwen-coder.sh ask "Refactor this..."    # Single prompt
  ```

## Storage Requirements

| Model | Size | Notes |
|-------|------|-------|
| gemma-4-E2B | 4.7 GB | Default model, fast |
| gemma-4-E4B | 7.6 GB | Default model |
| gemma-4-26B | 25 GB | Default model |
| gemma-4-31B | 30 GB | Default model |
| MiniMax-M2.7 | 101 GB | 4 shards |
| Ornith-1.0-35B | 34 GB | Agentic coding |
| qwen-3.6-35B | 36 GB | Qwen3-Next hybrid |
| Qwen3-Coder-Next | 68 GB | 3 shards |

**Total for all default models: ~67.3 GB**
**Total for all models: ~306 GB**

## Requirements

### For All Scripts
- **HF CLI with hf_transfer**: `uv tool install --with hf_transfer huggingface_hub`

### For Setup Scripts
- Xcode Command Line Tools: `xcode-select --install`
- CMake: `brew install cmake`
- Git: `brew install git`
- At least 10 GB free disk space

### For Running Models
- Metal-compatible Apple Silicon (M1 or newer)
- Sufficient unified memory (at least 16 GB recommended)
- For large models (MiniMax-M2.7, Qwen3-Coder-Next), ensure adequate GPU memory ceiling

## Migrating from Legacy Scripts

### Old Command → New Command

| Old | New |
|-----|-----|
| `./scripts/download-models.sh` | `./scripts/llama-setup.sh download all` |
| `./scripts/download-models.sh MiniMax-M2.7` | `./scripts/llama-setup.sh download MiniMax-M2.7` |
| `./scripts/download-models.sh --help` | `./scripts/llama-setup.sh help` |
| `./scripts/download-gemma-4-E2B.sh` | `./scripts/llama-setup.sh download gemma-4-E2B` |
| `./scripts/setup-llama-cpp.sh` | `./scripts/llama-setup.sh setup` |

## Troubleshooting

### HF CLI not found
```bash
uv tool install --with hf_transfer huggingface_hub
```

### Build fails with Metal
Ensure Xcode Command Line Tools are installed:
```bash
xcode-select --install
```

### Out of memory on large models
For MiniMax-M2.7 (~108 GB working set), raise the GPU ceiling:
```bash
sudo sysctl -w iogpu.wired_limit_mb=122880
```

### Model already exists
If a model directory already exists, the download is skipped with a warning. Remove the directory first if you want to re-download:
```bash
rm -rf models/MiniMax-M2.7
```

## Additional Resources

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [GGUF Model Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)
- [HuggingFace Models](https://huggingface.co/models?search=gguf)
