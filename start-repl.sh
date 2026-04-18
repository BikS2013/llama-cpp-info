#!/bin/bash
# Start Qwen 3.6 35B-A3B in interactive conversation (REPL) mode
# Usage: ./start-repl.sh [--model PATH] [--temp FLOAT] [--ctx SIZE]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
MODEL="${PROJECT_DIR}/models/qwen-3.6-35B/Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf"
TEMP="0.7"
CTX="4096"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --temp)  TEMP="$2"; shift 2 ;;
        --ctx)   CTX="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: ./start-repl.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH   Path to GGUF model (default: Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf)"
            echo "  --temp FLOAT   Sampling temperature (default: 0.7)"
            echo "  --ctx SIZE     Context size in tokens (default: 4096)"
            echo "  -h, --help     Show this help"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ ! -f "$LLAMA_CLI" ]; then
    echo "ERROR: llama-cli not found at $LLAMA_CLI"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    exit 1
fi

exec "$LLAMA_CLI" \
    -m "$MODEL" \
    -ngl 99 \
    --temp "$TEMP" \
    -c "$CTX"
