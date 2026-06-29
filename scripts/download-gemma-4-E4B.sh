#!/bin/bash
# download-gemma-4-E4B.sh — Download Gemma 4 E4B model
#
# Gemma 4 E4B (4.5B params, Q8_0, 7.6 GB)
#
# Usage: ./scripts/download-gemma-4-E4B.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/gemma-4-E4B"
HF_REPO="unsloth/gemma-4-E4B-it-GGUF"
INCLUDE="gemma-4-E4B-it-Q8_0.gguf"
SIZE="7.6 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Gemma 4 E4B (${SIZE})"
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
echo "✓ Downloaded Gemma 4 E4B"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/${INCLUDE}"
echo ""
echo "Usage example:"
echo "  ./llama.cpp/build/bin/llama-cli -m ${TARGET_DIR}/${INCLUDE} -ngl 99 --temp 0.7"
echo ""
