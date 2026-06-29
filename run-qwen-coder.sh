#!/bin/bash
# run-qwen-coder.sh — Run Qwen3-Coder-Next locally with its recommended ("optimal") settings.
#
# Qwen3-Coder-Next is an agentic-coding model from the Qwen team (Alibaba):
#   * Architecture : Qwen3-Next hybrid (gated delta-net + MoE) — 80B total, ~3B active
#   * Context      : up to 262144 tokens (256K) native
#   * Reasoning    : NONE — this is a non-reasoning model, it does NOT emit <think> blocks
#   * Tools        : OpenAI-style tool calling (qwen3_coder format), enabled via --jinja
#   * Sampling     : temperature 1.0, top-p 0.95, top-k 40, min-p 0.01, repeat-penalty off
#                    (Qwen / Unsloth recommendation)
#   * License      : Apache-2.0
#
# Because it is an MoE with only ~3B active parameters, generation stays fast even at Q6/Q8
# on Apple-silicon unified memory.
#
# Usage:
#   ./run-qwen-coder.sh chat                 # interactive REPL (default mode)
#   ./run-qwen-coder.sh serve                # OpenAI-compatible API server (tool calling on)
#   ./run-qwen-coder.sh ask "your prompt"    # one-shot prompt, prints the answer and exits
#
# Common options (place after the mode):
#   --quant TAG    quant to load: UD-Q6_K_XL (default) | UD-Q8_K_XL | UD-Q4_K_XL | ...
#                  (must match a subfolder under models/Qwen3-Coder-Next/)
#   --model PATH   explicit GGUF path / first shard (overrides --quant)
#   --ctx N        context window in tokens (default 65536; max 262144)
#   --ngl N        GPU layers to offload (default 99 = all → Metal)
#   --fa MODE      flash attention: on (default) | off | auto
#   --temp F       sampling temperature (default 1.0)
#   --top-p F      nucleus sampling (default 0.95)
#   --top-k N      top-k sampling (default 40)
#   --min-p F      min-p sampling (default 0.01)
#   --port N       server port           (serve mode, default 8080)
#   --host ADDR    bind address          (serve mode, default 127.0.0.1)
#   --tokens N     max tokens to generate (ask mode, default 2048)
#   -- ARGS...     everything after a literal "--" is passed straight to llama.cpp
#   -h | --help    show this help
#
# Examples:
#   ./run-qwen-coder.sh chat --ctx 131072
#   ./run-qwen-coder.sh serve --port 9090 --ctx 262144
#   ./run-qwen-coder.sh ask "Refactor this Python function for readability: ..." --tokens 4096

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
LLAMA_SERVER="${PROJECT_DIR}/llama.cpp/build/bin/llama-server"
MODEL_DIR="${PROJECT_DIR}/models/Qwen3-Coder-Next"

# ---- Qwen3-Coder-Next defaults (the "optimal" settings) --------------------
QUANT="UD-Q6_K_XL"
MODEL=""
CTX="65536"
NGL="99"
FA="on"
TEMP="1.0"
TOP_P="0.95"
TOP_K="40"
MIN_P="0.01"
PORT="8080"
HOST="127.0.0.1"
TOKENS="2048"
PASSTHRU=()

MODE="${1:-chat}"
case "$MODE" in
    chat|serve|ask) shift ;;
    -h|--help)
        sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'
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
        --min-p)  MIN_P="$2"; shift 2 ;;
        --port)   PORT="$2";  shift 2 ;;
        --host)   HOST="$2";  shift 2 ;;
        --tokens) TOKENS="$2";shift 2 ;;
        -h|--help)
            sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'
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
# Unsloth lays each quant out as a subfolder, sharded or single-file:
#   models/Qwen3-Coder-Next/<QUANT>/Qwen3-Coder-Next-<QUANT>-00001-of-000NN.gguf
#   models/Qwen3-Coder-Next/<QUANT>/Qwen3-Coder-Next-<QUANT>.gguf
# We load the first shard; llama.cpp auto-loads the rest.
if [[ -z "$MODEL" ]]; then
    QUANT_DIR="${MODEL_DIR}/${QUANT}"
    # Prefer the first shard, fall back to a lone single-file quant.
    MODEL=$(ls "${QUANT_DIR}"/*-00001-of-*.gguf 2>/dev/null | head -1 || true)
    if [[ -z "$MODEL" ]]; then
        MODEL=$(ls "${QUANT_DIR}"/*.gguf 2>/dev/null | head -1 || true)
    fi
fi

if [[ -z "$MODEL" || ! -f "$MODEL" ]]; then
    echo "ERROR: model not found for quant '${QUANT}' under ${MODEL_DIR}/${QUANT}/" >&2
    echo "" >&2
    echo "Download it with:" >&2
    echo "  HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/Qwen3-Coder-Next-GGUF \\" >&2
    echo "    --include \"${QUANT}/*\" --local-dir models/Qwen3-Coder-Next" >&2
    exit 1
fi

# ---- Dispatch ---------------------------------------------------------------
echo "Qwen3-Coder-Next  |  mode=${MODE}  quant=${QUANT}  ctx=${CTX}  ngl=${NGL}  fa=${FA}" >&2
echo "Sampling: temp=${TEMP} top-p=${TOP_P} top-k=${TOP_K} min-p=${MIN_P} (non-reasoning, tool calling on)" >&2
echo "Model: ${MODEL}" >&2
echo "" >&2

case "$MODE" in
    chat)
        [[ -x "$LLAMA_CLI" ]] || { echo "ERROR: llama-cli not found at $LLAMA_CLI" >&2; exit 1; }
        exec "$LLAMA_CLI" \
            -m "$MODEL" \
            -ngl "$NGL" -fa "$FA" -c "$CTX" --no-context-shift \
            --jinja \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
    ask)
        [[ -x "$LLAMA_CLI" ]] || { echo "ERROR: llama-cli not found at $LLAMA_CLI" >&2; exit 1; }
        [[ -n "$PROMPT" ]] || { echo "ERROR: ask mode needs a prompt" >&2; exit 1; }
        exec "$LLAMA_CLI" \
            -m "$MODEL" \
            -ngl "$NGL" -fa "$FA" -c "$CTX" --no-context-shift \
            --jinja -st \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" \
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
            -ngl "$NGL" -fa "$FA" -c "$CTX" --no-context-shift \
            --jinja \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" --min-p "$MIN_P" \
            --host "$HOST" --port "$PORT" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
esac
