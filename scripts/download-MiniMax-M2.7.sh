#!/bin/bash
# download-MiniMax-M2.7.sh — Download MiniMax-M2.7 model
#
# MiniMax-M2.7 (229B params MoE, ~10B active, UD-IQ4_XS ~101 GB, 4 shards)
# Performance: ~34 t/s prompt, ~5 t/s generation (cold) on Apple M-series with 128 GB unified memory
# 200K context; load the first shard only — llama.cpp auto-loads the rest
#
# Usage: ./scripts/download-MiniMax-M2.7.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/MiniMax-M2.7"
HF_REPO="unsloth/MiniMax-M2.7-GGUF"
INCLUDE="UD-IQ4_XS/*"
SIZE="101 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading MiniMax-M2.7 (${SIZE}, 4 shards)"
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
echo "Note: This is a sharded model with 4 shards (~101 GB total)."
echo "      Only the first shard (00001) needs to be loaded manually."
echo "      llama.cpp will auto-load the remaining shards."
echo ""

mkdir -p "$TARGET_DIR"

# Download with HF_TRANSFER for faster downloads
HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$HF_REPO" \
    --include "$INCLUDE" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded MiniMax-M2.7"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/UD-IQ4_XS/"
echo ""
echo "Usage example:"
echo "  ./llama.cpp/build/bin/llama-cli -m ${TARGET_DIR}/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf -ngl 99 --temp 1.0 --top-p 0.95 --top-k 40"
echo ""
echo "For optimal performance on Apple silicon with 128 GB:"
echo "  - Set GPU memory ceiling: sudo sysctl -w iogpu.wired_limit_mb=122880"
echo "  - Use the pi-minimax wrapper script for automatic setup"
echo ""
