#!/bin/bash
# Start a GGUF model as an OpenAI-compatible API server
# Usage: ./start-api.sh [--model PATH] [--port N] [--host ADDR] [--ctx SIZE] [--no-think] [--list]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_SERVER="${PROJECT_DIR}/llama.cpp/build/bin/llama-server"
MODELS_DIR="${PROJECT_DIR}/models"
MODEL=""
PORT="8080"
HOST="127.0.0.1"
CTX="4096"
CTX_SET="no"   # becomes "yes" when --ctx is passed explicitly
THINK="auto"   # auto = let the model's chat template decide; off = no thinking
THINK_SET="no" # becomes "yes" when --think/--no-think is passed explicitly

source "${PROJECT_DIR}/lib/model-select.sh"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --port)  PORT="$2"; shift 2 ;;
        --host)  HOST="$2"; shift 2 ;;
        --ctx)   CTX="$2"; CTX_SET="yes"; shift 2 ;;
        --no-think) THINK="off";  THINK_SET="yes"; shift ;;
        --think)    THINK="auto"; THINK_SET="yes"; shift ;;
        --list)
            echo "Downloaded models in ${MODELS_DIR}:"
            list_models "$MODELS_DIR"
            exit 0
            ;;
        -h|--help)
            echo "Usage: ./start-api.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH   Path to GGUF model (skip interactive menu)"
            echo "  --port N       Server port (default: 8080)"
            echo "  --host ADDR    Bind address (default: 127.0.0.1)"
            echo "  --ctx SIZE     Context size in tokens (default: 4096). Without the flag, the"
            echo "                 interactive picker asks for it (4K … 256K presets or a custom value)."
            echo "  --no-think     Run the model without thinking/reasoning (no <think> blocks)."
            echo "                 Sets enable_thinking=false in the chat template (Gemma 4, Qwen 3.x,"
            echo "                 Ornith) and force-closes the think block for models whose template"
            echo "                 cannot switch it off (MiniMax-M2.7). A request can still opt back"
            echo "                 in per call by sending BOTH chat_template_kwargs:{\"enable_thinking\":true}"
            echo "                 and thinking_budget_tokens:N (e.g. 4096) in the request body."
            echo "  --think        Let the chat template decide (default; thinking on for reasoning models)"
            echo "                 Without either flag, the interactive picker also asks for the thinking mode."
            echo "  --list         List downloaded models and exit"
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
            echo ""
            echo "If --model is not provided, an interactive picker is shown."
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ ! -f "$LLAMA_SERVER" ]; then
    echo "ERROR: llama-server not found at $LLAMA_SERVER"
    exit 1
fi

INTERACTIVE="no"
if [ -z "$MODEL" ]; then
    MODEL=$(select_model "$MODELS_DIR") || exit 1
    INTERACTIVE="yes"
fi

if [ ! -f "$MODEL" ]; then
    echo "ERROR: Model not found at $MODEL"
    exit 1
fi

# Context size and thinking mode: ask when the interactive picker was used and the
# flag was not given; otherwise remind the user that the flag exists.
if [ "$CTX_SET" = "no" ]; then
    if [ "$INTERACTIVE" = "yes" ]; then
        CTX=$(select_ctx "$CTX") || exit 1
    else
        echo "Context size: ${CTX} tokens (no flag given; use --ctx SIZE to change it, e.g. --ctx 32768)" >&2
    fi
fi
if [ "$THINK_SET" = "no" ]; then
    if [ "$INTERACTIVE" = "yes" ]; then
        THINK=$(select_thinking) || exit 1
    else
        echo "Thinking mode: ${THINK} (no flag given; use --no-think to disable reasoning, --think to keep the template default)" >&2
    fi
fi

# --no-think: `--reasoning off` sets enable_thinking=false in the jinja chat template
# (Gemma 4, Qwen 3.x, Ornith). `--reasoning-budget 0` additionally forces the end-of-thinking
# tag as soon as a think block opens, covering templates that ignore enable_thinking
# (MiniMax-M2.7). The budget message is a single newline on purpose: templates that
# pre-open the block as "<think>\n" prefill that newline into the budget sampler, which
# would otherwise consume the forced "</think>" (llama.cpp b9835 behaviour); with the
# newline in front, the prefilled "\n" absorbs it and "</think>" is still forced.
THINK_ARGS=()
if [ "$THINK" = "off" ]; then
    THINK_ARGS=(--reasoning off --reasoning-budget 0 --reasoning-budget-message $'\n')
fi

echo "Starting llama-server..."
echo "  Model: ${MODEL#$PROJECT_DIR/}"
echo "  Endpoint: http://${HOST}:${PORT}"
echo "  Context: ${CTX} tokens  (change with --ctx SIZE)"
if [ "$THINK" = "off" ]; then
    echo "  Thinking: off   (--no-think; drop the flag or pass --think to restore reasoning)"
else
    echo "  Thinking: auto  (chat-template default; pass --no-think to run without reasoning)"
fi
echo ""

exec "$LLAMA_SERVER" \
    -m "$MODEL" \
    -ngl 99 \
    --host "$HOST" \
    --port "$PORT" \
    -c "$CTX" \
    ${THINK_ARGS[@]+"${THINK_ARGS[@]}"}
