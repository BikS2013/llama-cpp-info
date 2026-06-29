#!/bin/bash
# download-Qwen3-Coder-Next.sh — Download Qwen3-Coder-Next model
#
# Qwen3-Coder-Next (80B MoE, ~3B active, UD-Q6_K_XL ~73 GB, 3 shards)
# Agentic-coding model from the Qwen team (Alibaba)
# - NON-reasoning (no <think> blocks)
# - OpenAI-style tool calling (qwen3_coder), 256K context
# - Recommended sampling: temp 1.0, top-p 0.95, top-k 40, min-p 0.01
# - License: Apache-2.0
#
# Usage: ./scripts/download-Qwen3-Coder-Next.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/Qwen3-Coder-Next"
HF_REPO="unsloth/Qwen3-Coder-Next-GGUF"
INCLUDE="UD-Q6_K_XL/*"
SIZE="68 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Qwen3-Coder-Next (${SIZE}, 3 shards)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if hf CLI is installed
if ! command -v hf &> /dev/null; then
    echo "ERROR: hf CLI not found"
    echo ""
    echo "Install it with:"
    echo "  uv tool install --with hf_transfer huggingface_hub"
    echo ""
    exit 1
fi

# Check if model already exists
if [[ -d "$TARGET_DIR" ]]; then
    echo "WARNING: ${TARGET_DIR} already exists, skipping"
    exit 0
fi

echo "Downloading from ${HF_REPO}..."
echo "Target: ${TARGET_DIR}"
echo ""
echo "Note: This is a sharded model with 3 shards (~68 GB total)."
echo "      Only the first shard (00001) needs to be loaded manually."
echo "      llama.cpp will auto-load the remaining shards."
echo ""
echo "Note: This is a NON-reasoning model (no <think> blocks)."
echo "      It uses OpenAI-style tool calling (qwen3_coder format)."
echo ""

mkdir -p "$TARGET_DIR"

# Download with HF_TRANSFER for faster downloads
HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$HF_REPO" \
    --include "$INCLUDE" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded Qwen3-Coder-Next"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/UD-Q6_K_XL/"
echo ""
echo "Usage examples:"
echo ""
echo "  Interactive chat:"
echo "    ./run-qwen-coder.sh chat"
echo ""
echo "  API server (OpenAI-compatible):"
echo "    ./run-qwen-coder.sh serve --ctx 131072"
echo ""
echo "  Single prompt:"
echo "    ./run-qwen-coder.sh ask \"Refactor this function ...\" --tokens 4096"
echo ""
echo "Raw command (what run-qwen-coder.sh uses):"
echo "  ./llama.cpp/build/bin/llama-cli \\"
echo "    -m ${TARGET_DIR}/UD-Q6_K_XL/Qwen3-Coder-Next-UD-Q6_K_XL-00001-of-00003.gguf \\"
echo "    -ngl 99 -fa on -c 65536 --no-context-shift --jinja \\"
echo "    --temp 1.0 --top-p 0.95 --top-k 40 --min-p 0.01"
echo ""
