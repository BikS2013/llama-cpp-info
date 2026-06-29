#!/bin/bash
# download-qwen-3.6-35B.sh — Download Qwen3.6-35B model
#
# Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)
# Qwen3-Next delta-net hybrid MoE — 35B total, ~3B active
#
# Usage: ./scripts/download-qwen-3.6-35B.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/qwen-3.6-35B"
HF_REPO="unsloth/Qwen3.6-35B-A3B-GGUF"
INCLUDE="Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf"
SIZE="36 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Qwen3.6-35B (${SIZE})"
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

mkdir -p "$TARGET_DIR"

# Download with HF_TRANSFER for faster downloads
HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$HF_REPO" \
    --include "$INCLUDE" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded Qwen3.6-35B"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/${INCLUDE}"
echo ""
echo "Usage example:"
echo "  ./llama.cpp/build/bin/llama-cli -m ${TARGET_DIR}/${INCLUDE} -ngl 99 --temp 0.7"
echo ""
