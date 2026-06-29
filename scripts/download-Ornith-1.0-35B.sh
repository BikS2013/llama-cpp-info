#!/bin/bash
# download-Ornith-1.0-35B.sh — Download Ornith-1.0-35B model
#
# Ornith-1.0-35B (35B MoE, ~3B active, Q8_0 36.9 GB)
# Agentic-coding model from DeepReinforce
# - Reasoning (<think>), OpenAI-style tool calling (qwen3 XML), 256K context
# - Recommended sampling: temp 0.6, top-p 0.95, top-k 20
# - Performance: ~99 t/s prompt, ~93 t/s generation at Q8_0 on Apple M5 Max
# - License: MIT
#
# Usage: ./scripts/download-Ornith-1.0-35B.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/Ornith-1.0-35B"
HF_REPO="deepreinforce-ai/Ornith-1.0-35B-GGUF"
INCLUDE="ornith-1.0-35b-Q8_0.gguf"
SIZE="34 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Ornith-1.0-35B (${SIZE})"
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
echo "Note: This is an agentic-coding model with:"
echo "  - Reasoning (<think> ... </think>)"
echo "  - OpenAI-style tool calling (qwen3 XML)"
echo "  - 256K context window"
echo "  - Recommended sampling: temp 0.6, top-p 0.95, top-k 20"
echo ""

mkdir -p "$TARGET_DIR"

# Download with HF_TRANSFER for faster downloads
HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$HF_REPO" \
    --include "$INCLUDE" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded Ornith-1.0-35B"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/${INCLUDE}"
echo ""
echo "Usage examples:"
echo ""
echo "  Interactive chat:"
echo "    ./run-ornith.sh chat"
echo ""
echo "  API server (OpenAI-compatible):"
echo "    ./run-ornith.sh serve --ctx 65536"
echo ""
echo "  Single prompt:"
echo "    ./run-ornith.sh ask \"Explain this stack trace ...\" --tokens 2048"
echo ""
echo "Raw command (what run-ornith.sh uses):"
echo "  ./llama.cpp/build/bin/llama-cli \\"
echo "    -m ${TARGET_DIR}/${INCLUDE} \\"
echo "    -ngl 99 -fa on -c 32768 --jinja \\"
echo "    --temp 0.6 --top-p 0.95 --top-k 20"
echo ""
