#!/bin/bash
# Send a single prompt to a GGUF model and get a response
# Usage: ./ask.sh "Your question here" [--model PATH] [--temp FLOAT] [--tokens N] [--ctx SIZE] [--no-think] [--list]

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
MODELS_DIR="${PROJECT_DIR}/models"
MODEL=""
TEMP="0.7"
TOKENS="512"
CTX="4096"
CTX_SET="no"   # becomes "yes" when --ctx is passed explicitly
THINK="auto"   # auto = let the model's chat template decide; off = no thinking
THINK_SET="no" # becomes "yes" when --think/--no-think is passed explicitly
PROMPT=""

source "${PROJECT_DIR}/lib/model-select.sh"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model)  MODEL="$2"; shift 2 ;;
        --temp)   TEMP="$2"; shift 2 ;;
        --tokens) TOKENS="$2"; shift 2 ;;
        --ctx)    CTX="$2"; CTX_SET="yes"; shift 2 ;;
        --no-think) THINK="off";  THINK_SET="yes"; shift ;;
        --think)    THINK="auto"; THINK_SET="yes"; shift ;;
        --list)
            echo "Downloaded models in ${MODELS_DIR}:"
            list_models "$MODELS_DIR"
            exit 0
            ;;
        -h|--help)
            echo "Usage: ./ask.sh \"Your question\" [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --model PATH    Path to GGUF model (skip interactive menu)"
            echo "  --temp FLOAT    Sampling temperature (default: 0.7)"
            echo "  --tokens N      Max tokens to generate (default: 512)"
            echo "  --ctx SIZE      Context size in tokens (default: 4096). Without the flag, the"
            echo "                  interactive picker asks for it (4K … 256K presets or a custom value)."
            echo "  --no-think      Run the model without thinking/reasoning (no <think> blocks)."
            echo "                  Sets enable_thinking=false in the chat template (Gemma 4, Qwen 3.x,"
            echo "                  Ornith) and force-closes the think block for models whose template"
            echo "                  cannot switch it off (MiniMax-M2.7)."
            echo "  --think         Let the chat template decide (default; thinking on for reasoning models)"
            echo "                  Without either flag, the interactive picker also asks for the thinking mode."
            echo "  --list          List downloaded models and exit"
            echo "  -h, --help      Show this help"
            echo ""
            echo "Examples:"
            echo "  ./ask.sh \"What is the capital of France?\""
            echo "  ./ask.sh \"Explain quicksort\" --tokens 1024 --no-think"
            echo "  ./ask.sh \"Write a haiku\" --model ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf --ctx 8192"
            echo ""
            echo "If --model is not provided, an interactive picker is shown."
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

echo "Using model: ${MODEL#$PROJECT_DIR/}" >&2
echo "Context: ${CTX} tokens  (change with --ctx SIZE)" >&2
if [ "$THINK" = "off" ]; then
    echo "Thinking: off   (--no-think; drop the flag or pass --think to restore reasoning)" >&2
else
    echo "Thinking: auto  (chat-template default; pass --no-think to run without reasoning)" >&2
fi
echo "" >&2

"$LLAMA_CLI" \
    -m "$MODEL" \
    -p "$PROMPT" \
    -n "$TOKENS" \
    -c "$CTX" \
    -ngl 99 \
    --temp "$TEMP" \
    ${THINK_ARGS[@]+"${THINK_ARGS[@]}"} \
    -st 2>/dev/null
