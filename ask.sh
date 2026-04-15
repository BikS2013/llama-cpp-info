#!/bin/bash
# Send a single prompt to Gemma 4 31B and get a response
# Usage: ./ask.sh "Your question here" [--model PATH] [--temp FLOAT] [--tokens N]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
MODEL="${PROJECT_DIR}/models/gemma-4-31B/gemma-4-31B-it-Q8_0.gguf"
TEMP="0.7"
TOKENS="512"
PROMPT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --model)  MODEL="$2"; shift 2 ;;
        --temp)   TEMP="$2"; shift 2 ;;
        --tokens) TOKENS="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: ./ask.sh \"Your question\" [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH    Path to GGUF model (default: gemma-4-31B-it-Q8_0.gguf)"
            echo "  --temp FLOAT    Sampling temperature (default: 0.7)"
            echo "  --tokens N      Max tokens to generate (default: 512)"
            echo "  -h, --help      Show this help"
            echo ""
            echo "Examples:"
            echo "  ./ask.sh \"What is the capital of France?\""
            echo "  ./ask.sh \"Explain quicksort\" --tokens 1024"
            echo "  ./ask.sh \"Write a haiku\" --temp 1.0"
            exit 0
            ;;
        *)
            if [ -z "$PROMPT" ]; then
                PROMPT="$1"
            else
                echo "ERROR: Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$PROMPT" ]; then
    echo "ERROR: No prompt provided"
    echo "Usage: ./ask.sh \"Your question here\""
    exit 1
fi

if [ ! -f "$LLAMA_CLI" ]; then
    echo "ERROR: llama-cli not found at $LLAMA_CLI"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    exit 1
fi

"$LLAMA_CLI" \
    -m "$MODEL" \
    -p "$PROMPT" \
    -n "$TOKENS" \
    -ngl 99 \
    --temp "$TEMP" \
    -no-cnv -st 2>/dev/null
