# Setup Scripts

This folder contains scripts to set up and manage the llama.cpp environment.

## Quick Start

### 1. Clone and Build llama.cpp
```bash
./scripts/setup-llama-cpp.sh
```

This will:
- Clone/update llama.cpp from GitHub
- Build with Metal GPU support
- Verify the build succeeded

### 2. Download Models
Download specific models or all default models:

```bash
# Download all default models
./scripts/download-models.sh

# Download a specific model
./scripts/download-models.sh Ornith-1.0-35B

# Download a single model script
./scripts/download-Ornith-1.0-35B.sh
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
```

## Available Scripts

### setup-llama-cpp.sh
Clone and build llama.cpp with Metal GPU support.

**Usage:**
```bash
./scripts/setup-llama-cpp.sh
```

**Requirements:**
- Xcode Command Line Tools
- CMake
- Git
- At least 10 GB free disk space

### download-models.sh
Download all models from HuggingFace with a single command.

**Usage:**
```bash
# Download all default models (gemma-4-E2B, gemma-4-E4B, gemma-4-26B, gemma-4-31B)
./scripts/download-models.sh

# Download a specific model
./scripts/download-models.sh MiniMax-M2.7

# List available models
./scripts/download-models.sh --help
```

**Models available:**
- **gemma-4-E2B** (2.3B, Q8_0, 4.7 GB)
- **gemma-4-E4B** (4.5B, Q8_0, 7.6 GB)
- **gemma-4-26B** (A4B, Q8_0, 25 GB)
- **gemma-4-31B** (dense, Q8_0, 30 GB)
- **MiniMax-M2.7** (229B MoE, ~101 GB, 4 shards)
- **Ornith-1.0-35B** (35B MoE, Q8_0, 34 GB)
- **qwen-3.6-35B** (A3B, Q8_K_XL, 36 GB)
- **Qwen3-Coder-Next** (80B MoE, ~68 GB, 3 shards)

### download-gemma-4-E2B.sh
Download Gemma 4 E2B model.

**Usage:**
```bash
./scripts/download-gemma-4-E2B.sh
```

**Performance:**
- ~67 t/s prompt, ~120 t/s generation on Apple M4 Max

### download-gemma-4-E4B.sh
Download Gemma 4 E4B model.

**Usage:**
```bash
./scripts/download-gemma-4-E4B.sh
```

### download-gemma-4-26B.sh
Download Gemma 4 26B model.

**Usage:**
```bash
./scripts/download-gemma-4-26B.sh
```

### download-gemma-4-31B.sh
Download Gemma 4 31B model.

**Usage:**
```bash
./scripts/download-gemma-4-31B.sh
```

### download-MiniMax-M2.7.sh
Download MiniMax-M2.7 model (sharded).

**Usage:**
```bash
./scripts/download-MiniMax-M2.7.sh
```

**Note:** This is a sharded model (~101 GB total, 4 shards). Only the first shard needs to be loaded manually; llama.cpp auto-loads the rest.

**Memory tip for Apple Silicon:**
```bash
# Set GPU memory ceiling (required for ~108 GB working set)
sudo sysctl -w iogpu.wired_limit_mb=122880
```

### download-Ornith-1.0-35B.sh
Download Ornith-1.0-35B model (agentic coding).

**Usage:**
```bash
./scripts/download-Ornith-1.0-35B.sh
```

**Features:**
- Reasoning (<think>)
- OpenAI-style tool calling (qwen3 XML)
- 256K context window
- Recommended sampling: temp 0.6, top-p 0.95, top-k 20

### download-qwen-3.6-35B.sh
Download Qwen3.6-35B model.

**Usage:**
```bash
./scripts/download-qwen-3.6-35B.sh
```

### download-Qwen3-Coder-Next.sh
Download Qwen3-Coder-Next model (sharded, agentic coding).

**Usage:**
```bash
./scripts/download-Qwen3-Coder-Next.sh
```

**Features:**
- NON-reasoning (no <think> blocks)
- OpenAI-style tool calling (qwen3_coder)
- 256K context window
- Recommended sampling: temp 1.0, top-p 0.95, top-k 40, min-p 0.01

## Requirements

### For All Scripts
- **HF CLI with hf_transfer**: `uv tool install --with hf_transfer huggingface_hub`

### For setup-llama-cpp.sh
- Xcode Command Line Tools: `xcode-select --install`
- CMake: `brew install cmake`
- Git: `brew install git`
- At least 10 GB free disk space

### For Running Models
- Metal-compatible Apple Silicon (M1 or newer)
- Sufficient unified memory (at least 16 GB recommended)
- For large models (MiniMax-M2.7, Qwen3-Coder-Next), ensure adequate GPU memory ceiling

## Storage Requirements

| Model | Size | Notes |
|-------|------|-------|
| gemma-4-E2B | 4.7 GB | Default model, fast |
| gemma-4-E4B | 7.6 GB | Slightly larger |
| gemma-4-26B | 25 GB | A4B quantized |
| gemma-4-31B | 30 GB | Dense model |
| MiniMax-M2.7 | 101 GB | 4 shards |
| Ornith-1.0-35B | 34 GB | Agentic coding |
| qwen-3.6-35B | 36 GB | Qwen3-Next hybrid |
| Qwen3-Coder-Next | 68 GB | 3 shards |

**Total for all models: ~306 GB**

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

## Additional Resources

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [GGUF Model Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)
- [HuggingFace Models](https://huggingface.co/models?search=gguf)
