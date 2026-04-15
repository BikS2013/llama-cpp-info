#!/bin/bash
# Test script: Verify Gemma 4 E2B inference via llama-cli
# Usage: ./test_scripts/test-gemma4-inference.sh [prompt]

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
MODEL="${PROJECT_DIR}/models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf"

# Check prerequisites
if [ ! -f "$LLAMA_CLI" ]; then
    echo "ERROR: llama-cli not found at $LLAMA_CLI"
    echo "Run: cd llama.cpp && cmake -B build -DGGML_METAL=ON && cmake --build build --config Release -j\$(sysctl -n hw.ncpu)"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    echo "Run: huggingface-cli download unsloth/gemma-4-E2B-it-GGUF --include 'gemma-4-E2B-it-Q8_0.gguf' --local-dir models/gemma-4-E2B"
    exit 1
fi

PROMPT="${1:-What is 2+2? Answer in one sentence.}"

echo "=== Gemma 4 E2B Inference Test ==="
echo "Model: $MODEL"
echo "Prompt: $PROMPT"
echo "=================================="
echo ""

"$LLAMA_CLI" \
    -m "$MODEL" \
    -p "$PROMPT" \
    -n 200 \
    -ngl 99 \
    --temp 0.7 \
    -no-cnv -st

echo ""
echo "=== Test Complete ==="
