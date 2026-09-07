#!/bin/bash
# download-qwen-3.8-27B.sh — Download Qwen3.8-27B model
#
# Qwen3.8-27B (27B dense, UD-Q8_K_XL, 31.5 GB) — successor of the Qwen3.6 series
# - GGUF arch: qwen35 (Qwen3.5 hybrid lineage) — runs on the existing b9835 llama.cpp build
# - Thinking mode ON by default (<think>), can be disabled per request; reasoning_effort
#   (xhigh/medium/low) and preserve_thinking supported by the chat template
# - Native vision-language model — the mmproj (0.9 GB) is downloaded too for image input
# - 256K native context (extensible to 1M with YaRN)
# - Recommended sampling (Qwen):
#     thinking mode : temp 1.0, top-p 0.95, top-k 20, min-p 0, presence-penalty 0
#     instruct mode : temp 0.7, top-p 0.80, top-k 20, min-p 0, presence-penalty 1.5
# - License: Apache-2.0
#
# Usage: ./scripts/download-qwen-3.8-27B.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"
TARGET_DIR="${MODELS_DIR}/qwen-3.8-27B"
HF_REPO="unsloth/Qwen3.8-27B-GGUF"
INCLUDE="Qwen3.8-27B-UD-Q8_K_XL.gguf"
MMPROJ="mmproj-BF16.gguf"
SIZE="29 GB"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Downloading Qwen3.8-27B (${SIZE} + 0.9 GB mmproj)"
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

mkdir -p "$TARGET_DIR"

# Download with HF_TRANSFER for faster downloads
HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$HF_REPO" \
    --include "$INCLUDE" \
    --include "$MMPROJ" \
    --local-dir "$TARGET_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Downloaded Qwen3.8-27B"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Model location: ${TARGET_DIR}/${INCLUDE}"
echo "Vision projector: ${TARGET_DIR}/${MMPROJ}"
echo ""
echo "Usage example (thinking mode, Qwen-recommended sampling):"
echo "  ./llama.cpp/build/bin/llama-cli -m ${TARGET_DIR}/${INCLUDE} \\"
echo "    -ngl 99 -fa on -c 32768 --jinja --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0"
echo ""
echo "API server (OpenAI-compatible, tool calling via --jinja):"
echo "  ./llama.cpp/build/bin/llama-server -m ${TARGET_DIR}/${INCLUDE} \\"
echo "    --mmproj ${TARGET_DIR}/${MMPROJ} \\"
echo "    -ngl 99 -fa on -c 65536 --jinja --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --port 8080"
echo ""
