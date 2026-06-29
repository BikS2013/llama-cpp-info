#!/bin/bash
# run-ornith.sh — Run Ornith-1.0-35B locally with its recommended ("optimal") settings.
#
# Ornith-1.0-35B is an agentic-coding model from DeepReinforce:
#   * Architecture : qwen35moe (Qwen3-Next / delta-net hybrid MoE) — 35B total, ~3B active
#   * Context      : up to 262144 tokens (256K)
#   * Reasoning    : emits <think> … </think> before the final answer
#   * Tools        : OpenAI-style tool calling (qwen3 XML), enabled via the embedded chat template
#   * Sampling     : temperature 0.6, top-p 0.95, top-k 20   (DeepReinforce recommendation)
#   * License      : MIT
#
# Because it is an MoE with only ~3B active parameters, generation stays fast even at Q8_0
# on Apple-silicon unified memory.
#
# Usage:
#   ./run-ornith.sh chat                 # interactive REPL (default mode)
#   ./run-ornith.sh serve                # OpenAI-compatible API server (tool calling on)
#   ./run-ornith.sh ask "your prompt"    # one-shot prompt, prints the answer and exits
#
# Common options (place after the mode):
#   --quant TAG    quant to load: Q8_0 (default) | Q6_K | Q5_K_M | Q4_K_M | bf16
#   --model PATH   explicit GGUF path (overrides --quant)
#   --ctx N        context window in tokens (default 32768; max 262144)
#   --ngl N        GPU layers to offload (default 99 = all → Metal)
#   --fa MODE      flash attention: on (default) | off | auto
#   --temp F       sampling temperature (default 0.6)
#   --top-p F      nucleus sampling (default 0.95)
#   --top-k N      top-k sampling (default 20)
#   --port N       server port           (serve mode, default 8080)
#   --host ADDR    bind address          (serve mode, default 127.0.0.1)
#   --tokens N     max tokens to generate (ask mode, default 1024)
#   -- ARGS...     everything after a literal "--" is passed straight to llama.cpp
#   -h | --help    show this help
#
# Examples:
#   ./run-ornith.sh chat --ctx 65536
#   ./run-ornith.sh serve --port 9090 --ctx 131072
#   ./run-ornith.sh ask "Refactor this Python function for readability: ..." --tokens 2048

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
LLAMA_SERVER="${PROJECT_DIR}/llama.cpp/build/bin/llama-server"
MODEL_DIR="${PROJECT_DIR}/models/Ornith-1.0-35B"

# ---- Ornith defaults (the "optimal" settings) ------------------------------
QUANT="Q8_0"
MODEL=""
CTX="32768"
NGL="99"
FA="on"
TEMP="0.6"
TOP_P="0.95"
TOP_K="20"
PORT="8080"
HOST="127.0.0.1"
TOKENS="1024"
PASSTHRU=()

MODE="${1:-chat}"
case "$MODE" in
    chat|serve|ask) shift ;;
    -h|--help)
        sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'
        exit 0
        ;;
    *)  # No explicit mode given; default to chat and keep the arg for parsing.
        MODE="chat"
        ;;
esac

PROMPT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --quant)  QUANT="$2"; shift 2 ;;
        --model)  MODEL="$2"; shift 2 ;;
        --ctx)    CTX="$2";   shift 2 ;;
        --ngl)    NGL="$2";   shift 2 ;;
        --fa)     FA="$2";    shift 2 ;;
        --temp)   TEMP="$2";  shift 2 ;;
        --top-p)  TOP_P="$2"; shift 2 ;;
        --top-k)  TOP_K="$2"; shift 2 ;;
        --port)   PORT="$2";  shift 2 ;;
        --host)   HOST="$2";  shift 2 ;;
        --tokens) TOKENS="$2";shift 2 ;;
        -h|--help)
            sed -n '2,38p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        --) shift; PASSTHRU+=("$@"); break ;;
        *)
            if [[ "$MODE" == "ask" && -z "$PROMPT" ]]; then
                PROMPT="$1"; shift
            else
                echo "ERROR: unexpected argument: $1" >&2; exit 1
            fi
            ;;
    esac
done

# ---- Resolve model path -----------------------------------------------------
if [[ -z "$MODEL" ]]; then
    MODEL="${MODEL_DIR}/ornith-1.0-35b-${QUANT}.gguf"
fi

if [[ ! -f "$MODEL" ]]; then
    echo "ERROR: model not found: $MODEL" >&2
    echo "" >&2
    echo "Download it with:" >&2
    echo "  HF_HUB_ENABLE_HF_TRANSFER=1 hf download deepreinforce-ai/Ornith-1.0-35B-GGUF \\" >&2
    echo "    --include \"ornith-1.0-35b-${QUANT}.gguf\" --local-dir models/Ornith-1.0-35B" >&2
    exit 1
fi

# ---- Dispatch ---------------------------------------------------------------
echo "Ornith-1.0-35B  |  mode=${MODE}  quant=${QUANT}  ctx=${CTX}  ngl=${NGL}  fa=${FA}" >&2
echo "Sampling: temp=${TEMP} top-p=${TOP_P} top-k=${TOP_K}" >&2
echo "" >&2

case "$MODE" in
    chat)
        [[ -x "$LLAMA_CLI" ]] || { echo "ERROR: llama-cli not found at $LLAMA_CLI" >&2; exit 1; }
        exec "$LLAMA_CLI" \
            -m "$MODEL" \
            -ngl "$NGL" -fa "$FA" -c "$CTX" \
            --jinja \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
    ask)
        [[ -x "$LLAMA_CLI" ]] || { echo "ERROR: llama-cli not found at $LLAMA_CLI" >&2; exit 1; }
        [[ -n "$PROMPT" ]] || { echo "ERROR: ask mode needs a prompt" >&2; exit 1; }
        exec "$LLAMA_CLI" \
            -m "$MODEL" \
            -ngl "$NGL" -fa "$FA" -c "$CTX" \
            --jinja -st \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" \
            -n "$TOKENS" \
            -p "$PROMPT" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
    serve)
        [[ -x "$LLAMA_SERVER" ]] || { echo "ERROR: llama-server not found at $LLAMA_SERVER" >&2; exit 1; }
        echo "  Endpoint : http://${HOST}:${PORT}/v1   (OpenAI-compatible, tool calling enabled)" >&2
        echo "  WebUI    : http://${HOST}:${PORT}" >&2
        echo "" >&2
        exec "$LLAMA_SERVER" \
            -m "$MODEL" \
            -ngl "$NGL" -fa "$FA" -c "$CTX" \
            --jinja \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" \
            --host "$HOST" --port "$PORT" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
esac
