#!/bin/bash
# download-Ornith-1.5-35B.sh — Download Ornith-1.5-35B-A3B model
#
# Ornith-1.5-35B-A3B (35B MoE, ~3B active, Q8_0 37.8 GB) — successor of Ornith-1.0-35B
# Agentic-coding model from Ornith AI (formerly published under deepreinforce-ai)
# - GGUF arch: qwen35moe (Qwen3.6-35B-A3B base) — runs on the existing b9835 llama.cpp build
# - Reasoning (<think>), OpenAI-style tool calling (qwen3 XML), 256K context (YaRN to ~1M)
# - Recommended sampling: temp 0.6, top-p 0.95, top-k 20  (temp 1.0 to reproduce benchmarks)
# - Ships an mmproj (vision projector) — downloaded too (0.9 GB) for optional image input
# - License: MIT
#
# Usage: ./scripts/download-Ornith-1.5-35B.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/Ornith-1.5-35B"
HF_REPO="ornith-ai/Ornith-1.5-35B-A3B-GGUF"
INCLUDE="Ornith-1.5-35B-Q8_0.gguf"
MMPROJ="mmproj-Ornith-1.5-35B-BF16.gguf"
SIZE="35 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Ornith-1.5-35B-A3B (${SIZE} + 0.9 GB mmproj)"
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
if [[ -f "${TARGET_DIR}/${INCLUDE}" ]]; then
    echo "WARNING: ${TARGET_DIR}/${INCLUDE} already exists, skipping"
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
    --include "$MMPROJ" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded Ornith-1.5-35B-A3B"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/${INCLUDE}"
echo "Vision projector: ${TARGET_DIR}/${MMPROJ}"
echo ""
echo "Usage examples (run-ornith.sh defaults to Ornith 1.5):"
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
echo "  Previous generation (Ornith 1.0):"
echo "    ./run-ornith.sh chat --version 1.0"
echo ""
echo "Raw command (what run-ornith.sh uses):"
echo "  ./llama.cpp/build/bin/llama-cli \\"
echo "    -m ${TARGET_DIR}/${INCLUDE} \\"
echo "    -ngl 99 -fa on -c 32768 --jinja \\"
echo "    --temp 0.6 --top-p 0.95 --top-k 20"
echo ""
