#!/bin/bash
# Start Qwen 3.6 35B-A3B as an OpenAI-compatible API server
# Usage: ./start-api.sh [--model PATH] [--port N] [--host ADDR] [--ctx SIZE]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_SERVER="${PROJECT_DIR}/llama.cpp/build/bin/llama-server"
MODEL="${PROJECT_DIR}/models/qwen-3.6-35B/Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf"
PORT="8080"
HOST="127.0.0.1"
CTX="4096"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --port)  PORT="$2"; shift 2 ;;
        --host)  HOST="$2"; shift 2 ;;
        --ctx)   CTX="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: ./start-api.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH   Path to GGUF model (default: Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf)"
            echo "  --port N       Server port (default: 8080)"
            echo "  --host ADDR    Bind address (default: 127.0.0.1)"
            echo "  --ctx SIZE     Context size in tokens (default: 4096)"
            echo "  -h, --help     Show this help"
            echo ""
            echo "API Endpoints:"
            echo "  POST /v1/chat/completions   Chat completions (OpenAI-compatible)"
            echo "  POST /v1/completions        Text completions"
            echo "  GET  /health                Health check"
            echo ""
            echo "Example curl:"
            echo "  curl http://localhost:8080/v1/chat/completions \\"
            echo "    -H 'Content-Type: application/json' \\"
            echo "    -d '{\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}'"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ ! -f "$LLAMA_SERVER" ]; then
    echo "ERROR: llama-server not found at $LLAMA_SERVER"
    exit 1
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    exit 1
fi

echo "Starting llama-server..."
echo "  Model: $MODEL"
echo "  Endpoint: http://${HOST}:${PORT}"
echo "  Context: ${CTX} tokens"
echo ""

exec "$LLAMA_SERVER" \
    -m "$MODEL" \
    -ngl 99 \
    --host "$HOST" \
    --port "$PORT" \
    -c "$CTX"
