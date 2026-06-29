# Script Consolidation

## Overview

All scripts in the `scripts/` folder have been consolidated into a single, unified script: `llama-setup.sh`. This new script provides a single interface for all setup and model management tasks.

## What's New

### `llama-setup.sh` - Unified Script

**Location:** `scripts/llama-setup.sh`

**Features:**
- Single command-line interface for all operations
- Support for multiple commands (setup, download, list, help)
- Intelligent model matching and error handling
- Progress tracking and size calculations
- Comprehensive help and documentation

**Commands:**

| Command | Description |
|---------|-------------|
| `setup` | Clone and build llama.cpp with Metal GPU support |
| `download [all\|model-name]` | Download models from HuggingFace |
| `list` | List all available models |
| `help` | Show help message |

**Examples:**
```bash
./scripts/llama-setup.sh setup                    # Build llama.cpp
./scripts/llama-setup.sh download all             # Download all default models
./scripts/llama-setup.sh download MiniMax-M2.7    # Download specific model
./scripts/llama-setup.sh download all-non-default # Download all non-default models
./scripts/llama-setup.sh list                     # List all models
./scripts/llama-setup.sh help                     # Show help
```

## What's Changed

### Old Scripts (Still Available for Backward Compatibility)

The following scripts are still available and functional, but are now considered **deprecated**:

| Old Script | Function | Status |
|------------|----------|--------|
| `setup-llama-cpp.sh` | Build llama.cpp | Deprecated (use `llama-setup.sh setup`) |
| `download-models.sh` | Download all/default models | Deprecated (use `llama-setup.sh download`) |
| `download-gemma-4-E2B.sh` | Download Gemma 4 E2B | Deprecated |
| `download-gemma-4-E4B.sh` | Download Gemma 4 E4B | Deprecated |
| `download-gemma-4-26B.sh` | Download Gemma 4 26B | Deprecated |
| `download-gemma-4-31B.sh` | Download Gemma 4 31B | Deprecated |
| `download-MiniMax-M2.7.sh` | Download MiniMax-M2.7 | Deprecated |
| `download-Ornith-1.0-35B.sh` | Download Ornith-1.0-35B | Deprecated |
| `download-qwen-3.6-35B.sh` | Download Qwen3.6-35B | Deprecated |
| `download-Qwen3-Coder-Next.sh` | Download Qwen3-Coder-Next | Deprecated |

### Migration Guide

| Old Command | New Command |
|-------------|-------------|
| `./scripts/setup-llama-cpp.sh` | `./scripts/llama-setup.sh setup` |
| `./scripts/download-models.sh` | `./scripts/llama-setup.sh download all` |
| `./scripts/download-models.sh MiniMax-M2.7` | `./scripts/llama-setup.sh download MiniMax-M2.7` |
| `./scripts/download-gemma-4-E2B.sh` | `./scripts/llama-setup.sh download gemma-4-E2B` |
| `./scripts/download-models.sh --help` | `./scripts/llama-setup.sh help` |

### Improvements

The new `llama-setup.sh` provides several improvements:

1. **Single Interface**: One script instead of many
2. **Better Error Handling**: Clear error messages with helpful suggestions
3. **Model Matching**: Partial name matching with duplicate detection
4. **Progress Tracking**: Shows total download size and model count
5. **Smart Skipping**: Automatically skips already-downloaded models
6. **Comprehensive Documentation**: Built-in help with examples

## Why Consolidate?

The previous structure had several individual scripts that duplicated common functionality:
- Model metadata (repository URLs, include patterns, sizes)
- Progress display logic
- Error handling
- Dependency checking

The consolidated script:
- Reduces code duplication
- Easier to maintain and update
- Consistent user experience
- Less confusion about which script to use
- Better error messages and help documentation

## Future Maintenance

When adding new models:

1. Add the model to the `get_model_*()` functions in `llama-setup.sh`
2. Update `get_all_models()` to include the new model
3. Update model metadata in `get_model_desc()`, `get_model_size()`, etc.
4. Update the README if the model should be a default download

## Questions?

See `./scripts/llama-setup.sh help` for full usage documentation.
