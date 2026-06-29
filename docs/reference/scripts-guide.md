# Scripts Guide

This document provides comprehensive documentation for all llama.cpp setup and model management scripts.

## Scripts Overview

| Script | Purpose | Size |
|--------|---------|------|
| `scripts/setup-llama-cpp.sh` | Clone and build llama.cpp | ~6.2 KB |
| `scripts/download-models.sh` | Download all/default models | ~7.6 KB |
| `scripts/download-gemma-4-E2B.sh` | Download Gemma 4 E2B | ~1.6 KB |
| `scripts/download-gemma-4-E4B.sh` | Download Gemma 4 E4B | ~1.6 KB |
| `scripts/download-gemma-4-26B.sh` | Download Gemma 4 26B | ~1.6 KB |
| `scripts/download-gemma-4-31B.sh` | Download Gemma 4 31B | ~1.6 KB |
| `scripts/download-MiniMax-M2.7.sh` | Download MiniMax-M2.7 | ~2.3 KB |
| `scripts/download-Ornith-1.0-35B.sh` | Download Ornith-1.0-35B | ~2.5 KB |
| `scripts/download-qwen-3.6-35B.sh` | Download Qwen3.6-35B | ~1.6 KB |
| `scripts/download-Qwen3-Coder-Next.sh` | Download Qwen3-Coder-Next | ~2.7 KB |

## Detailed Script Reference

### setup-llama-cpp.sh

**Purpose:** Clone and build llama.cpp with Metal GPU support.

**Features:**
- Checks for required dependencies (cmake, git, Xcode CLI tools)
- Clones llama.cpp if not present, or updates to latest main
- Configures build with `GGML_METAL=ON`
- Builds with all available CPU cores
- Verifies Metal support and build success

**Usage:**
```bash
./scripts/setup-llama-cpp.sh
```

**Output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
llama.cpp Setup Script
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Checking dependencies...
ℹ Cloning llama.cpp...
✓ Cloned llama.cpp
ℹ Building with 8 cores...
✓ Built llama.cpp successfully
✓ Verified llama-cli and llama-server
```

**Requirements:**
- Xcode Command Line Tools (`xcode-select --install`)
- CMake (`brew install cmake`)
- Git (`brew install git`)
- At least 10 GB free disk space

**Error Handling:**
- Exits with helpful messages if dependencies are missing
- Verifies Metal GPU support (optional, non-blocking)
- Confirms build artifacts exist before completing

---

### download-models.sh

**Purpose:** Download one or more models from HuggingFace with a single command.

**Usage:**
```bash
# Download all default models
./scripts/download-models.sh

# Download a specific model
./scripts/download-models.sh MiniMax-M2.7

# Download by prefix match
./scripts/download-models.sh ornith

# Show help
./scripts/download-models.sh --help
```

**Available Models:**
| Model Name | Description | Size | Repo |
|------------|-------------|------|------|
| gemma-4-E2B | Gemma 4 E2B (2.3B, Q8_0) | 4.7 GB | unsloth/gemma-4-E2B-it-GGUF |
| gemma-4-E4B | Gemma 4 E4B (4.5B, Q8_0) | 7.6 GB | unsloth/gemma-4-E4B-it-GGUF |
| gemma-4-26B | Gemma 4 26B (A4B, Q8_0) | 25 GB | unsloth/gemma-4-26B-A4B-it-GGUF |
| gemma-4-31B | Gemma 4 31B (dense, Q8_0) | 30 GB | unsloth/gemma-4-31B-it-GGUF |
| MiniMax-M2.7 | MiniMax-M2.7 (229B MoE) | 101 GB | unsloth/MiniMax-M2.7-GGUF |
| Ornith-1.0-35B | Ornith-1.0-35B (35B MoE) | 34 GB | deepreinforce-ai/Ornith-1.0-35B-GGUF |
| qwen-3.6-35B | Qwen3.6-35B (A3B, Q8_K_XL) | 36 GB | unsloth/Qwen3.6-35B-A3B-GGUF |
| Qwen3-Coder-Next | Qwen3-Coder-Next (80B MoE) | 68 GB | unsloth/Qwen3-Coder-Next-GGUF |

**Features:**
- Support for comma-separated model lists
- Prefix matching for model names
- Progress indication with colors
- Total size calculation
- Post-download usage examples

**Default Models:**
If no model is specified, downloads these 4 models:
- gemma-4-E2B
- gemma-4-E4B
- gemma-4-26B
- gemma-4-31B

**Output Example:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
llama.cpp Model Downloader
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Downloading 4 model(s)...
ℹ Total size: 67.3 GB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Downloading Gemma 4 E2B (4.7 GB)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Downloaded Gemma 4 E2B
```

---

### download-gemma-4-E2B.sh

**Purpose:** Download only the Gemma 4 E2B model.

**Features:**
- Single-model focus
- Performance info embedded in script
- Usage examples in output

**Usage:**
```bash
./scripts/download-gemma-4-E2B.sh
```

**Output includes:**
- Model size (4.7 GB)
- Performance info (~67 t/s prompt, ~120 t/s generation on Apple M4 Max)
- Quick usage example

---

### download-MiniMax-M2.7.sh

**Purpose:** Download the MiniMax-M2.7 model (sharded).

**Features:**
- Handles sharded model (4 shards, ~101 GB total)
- Notes about first-shard loading
- Memory tip for Apple Silicon

**Memory Configuration:**
```bash
# Required for ~108 GB working set
sudo sysctl -w iogpu.wired_limit_mb=122880
```

---

### download-Ornith-1.0-35B.sh

**Purpose:** Download the Ornith-1.0-35B agentic coding model.

**Features:**
- Highlights agentic coding features
- Includes reasoning (<think>) and tool calling info
- Shows recommended sampling parameters
- Multiple usage examples

**Features:**
- Reasoning (<think> ... </think>)
- OpenAI-style tool calling (qwen3 XML)
- 256K context window
- Recommended sampling: temp 0.6, top-p 0.95, top-k 20
- License: MIT

---

### download-Qwen3-Coder-Next.sh

**Purpose:** Download the Qwen3-Coder-Next agentic coding model.

**Features:**
- Notes NON-reasoning (no <think> blocks)
- OpenAI-style tool calling (qwen3_coder format)
- Multiple usage examples

**Features:**
- NON-reasoning (no <think> blocks)
- OpenAI-style tool calling (qwen3_coder)
- 256K context window
- Recommended sampling: temp 1.0, top-p 0.95, top-k 40, min-p 0.01
- License: Apache-2.0

---

### Individual Model Scripts (gemma-4-E4B, gemma-4-26B, gemma-4-31B, qwen-3.6-35B)

**Pattern:** Each follows the same structure:
- Single model download
- Error checking for hf CLI
- Skip if model already exists
- Usage example in output

## Common Patterns

### Dependency Checking
All download scripts check for the hf CLI:
```bash
if ! command -v hf &> /dev/null; then
    echo "ERROR: hf CLI not found"
    echo "Install it with: uv tool install --with hf_transfer huggingface_hub"
    exit 1
fi
```

### Skip If Exists
Download scripts skip if model already exists:
```bash
if [[ -d "$TARGET_DIR" ]]; then
    echo "WARNING: ${TARGET_DIR} already exists, skipping"
    exit 0
fi
```

### HF_TRANSFER Optimization
All downloads use `HF_HUB_ENABLE_HF_TRANSFER=1` for faster downloads.

### Directory Structure
Models are downloaded to `models/` at project root:
```
models/
├── gemma-4-E2B/
│   └── gemma-4-E2B-it-Q8_0.gguf
├── MiniMax-M2.7/
│   └── UD-IQ4_XS/
│       ├── MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf
│       └── ...
```

## Usage Workflow

### Fresh Setup
```bash
# 1. Clone and build llama.cpp
./scripts/setup-llama-cpp.sh

# 2. Download models
./scripts/download-models.sh

# 3. Run a model
./run-ornith.sh chat
```

### Download Additional Model Later
```bash
# Download only the new model
./scripts/download-MiniMax-M2.7.sh

# Run it
./run-qwen-coder.sh chat
```

### Rebuild llama.cpp
```bash
# Run setup script (updates and rebuilds)
./scripts/setup-llama-cpp.sh
```

## Error Messages and Solutions

### "hf CLI not found"
```bash
uv tool install --with hf_transfer huggingface_hub
```

### "Missing dependencies"
```bash
xcode-select --install  # Xcode CLI tools
brew install cmake      # CMake
brew install git        # Git
```

### "Out of memory"
For large models (~100+ GB):
```bash
sudo sysctl -w iogpu.wired_limit_mb=122880
```

### "Directory already exists"
This is expected behavior. The script skips existing models.

## Performance Notes

### Build Time
- Initial build: 5-15 minutes (depends on CPU)
- Rebuild: 1-3 minutes (incremental)

### Download Time
Depends on internet speed:
- Small models (4-7 GB): 5-15 minutes
- Large models (30-68 GB): 15-45 minutes
- Sharded models (101 GB): 30-60 minutes

### Disk Space
- llama.cpp: ~10 GB
- All models: ~306 GB
- Recommended: 500+ GB free

## Troubleshooting

### Build Fails
1. Check dependencies: `cmake --version`, `git --version`, `xcodebuild -version`
2. Clean build: `rm -rf llama.cpp/build && ./scripts/setup-llama-cpp.sh`

### Download Fails
1. Check internet connection
2. Verify hf CLI: `hf --version`
3. Try manual download: `hf download <repo> --include <pattern> --local-dir models/<name>`

### Out of Memory
1. Use smaller models (E2B, E4B)
2. Reduce context window: `--ctx 16384`
3. Raise GPU ceiling (Apple Silicon): `sudo sysctl -w iogpu.wired_limit_mb=122880`

## See Also

- `scripts/README.md` — Quick start guide
- `docs/reference/gemma4-models.md` — Gemma model details
- `docs/reference/minimax-gguf-models.md` — MiniMax model details
- `docs/reference/ornith-models.md` — Ornith model details
- `docs/reference/qwen-coder-next.md` — Qwen3-Coder-Next details
