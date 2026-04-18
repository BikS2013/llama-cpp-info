#!/bin/bash
# Start a GGUF model in interactive conversation (REPL) mode
# Usage: ./start-repl.sh [--model PATH] [--temp FLOAT] [--ctx SIZE] [--list]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
MODELS_DIR="${PROJECT_DIR}/models"
MODEL=""
TEMP="0.7"
CTX="4096"

source "${PROJECT_DIR}/lib/model-select.sh"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --temp)  TEMP="$2"; shift 2 ;;
        --ctx)   CTX="$2"; shift 2 ;;
        --list)
            echo "Downloaded models in ${MODELS_DIR}:"
            list_models "$MODELS_DIR"
            exit 0
            ;;
        -h|--help)
            echo "Usage: ./start-repl.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH   Path to GGUF model (skip interactive menu)"
            echo "  --temp FLOAT   Sampling temperature (default: 0.7)"
            echo "  --ctx SIZE     Context size in tokens (default: 4096)"
            echo "  --list         List downloaded models and exit"
            echo "  -h, --help     Show this help"
            echo ""
            echo "If --model is not provided, an interactive picker is shown."
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ ! -f "$LLAMA_CLI" ]; then
    echo "ERROR: llama-cli not found at $LLAMA_CLI"
    exit 1
fi

if [ -z "$MODEL" ]; then
    MODEL=$(select_model "$MODELS_DIR") || exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    exit 1
fi

echo "Using model: ${MODEL#$PROJECT_DIR/}"

exec "$LLAMA_CLI" \
    -m "$MODEL" \
    -ngl 99 \
    --temp "$TEMP" \
    -c "$CTX"
