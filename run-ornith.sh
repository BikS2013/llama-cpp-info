#!/bin/bash
# run-ornith.sh — Run Ornith-1.5-35B-A3B (or Ornith-1.0-35B) locally with its recommended settings.
#
# Ornith is an agentic-coding model family from Ornith AI (formerly DeepReinforce):
#   * Architecture : qwen35moe (Qwen3-Next / delta-net hybrid MoE) — 35B total, ~3B active
#   * Context      : up to 262144 tokens (256K)
#   * Reasoning    : emits <think> … </think> before the final answer
#   * Tools        : OpenAI-style tool calling (qwen3 XML), enabled via the embedded chat template
#   * Sampling     : temperature 0.6, top-p 0.95, top-k 20   (Ornith AI recommendation)
#   * License      : MIT
#
# Two generations are supported; 1.5 (2026-08) is the default, 1.0 stays selectable:
#   1.5  models/Ornith-1.5-35B/Ornith-1.5-35B-<QUANT>.gguf   (+ optional mmproj for vision)
#   1.0  models/Ornith-1.0-35B/ornith-1.0-35b-<QUANT>.gguf
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
#   --version V    Ornith generation: 1.5 (default) | 1.0
#   --quant TAG    quant to load: Q8_0 (default) | Q6_K | Q5_K_M | Q4_K_M | bf16
#   --model PATH   explicit GGUF path (overrides --version/--quant)
#   --vision       also load the mmproj (1.5 only) so images can be passed in
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
#   ./run-ornith.sh chat --version 1.0
#   ./run-ornith.sh serve --port 9090 --ctx 131072
#   ./run-ornith.sh ask "Refactor this Python function for readability: ..." --tokens 2048

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_CLI="${PROJECT_DIR}/llama.cpp/build/bin/llama-cli"
LLAMA_SERVER="${PROJECT_DIR}/llama.cpp/build/bin/llama-server"

# ---- Ornith defaults (the "optimal" settings) ------------------------------
VERSION="1.5"
QUANT="Q8_0"
MODEL=""
VISION="no"
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

show_help() { sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'; }

MODE="${1:-chat}"
case "$MODE" in
    chat|serve|ask) shift ;;
    -h|--help) show_help; exit 0 ;;
    *)  # No explicit mode given; default to chat and keep the arg for parsing.
        MODE="chat"
        ;;
esac

PROMPT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version) VERSION="$2"; shift 2 ;;
        --quant)  QUANT="$2"; shift 2 ;;
        --model)  MODEL="$2"; shift 2 ;;
        --vision) VISION="yes"; shift ;;
        --ctx)    CTX="$2";   shift 2 ;;
        --ngl)    NGL="$2";   shift 2 ;;
        --fa)     FA="$2";    shift 2 ;;
        --temp)   TEMP="$2";  shift 2 ;;
        --top-p)  TOP_P="$2"; shift 2 ;;
        --top-k)  TOP_K="$2"; shift 2 ;;
        --port)   PORT="$2";  shift 2 ;;
        --host)   HOST="$2";  shift 2 ;;
        --tokens) TOKENS="$2";shift 2 ;;
        -h|--help) show_help; exit 0 ;;
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
case "$VERSION" in
    1.5)
        MODEL_DIR="${PROJECT_DIR}/models/Ornith-1.5-35B"
        HF_REPO="ornith-ai/Ornith-1.5-35B-A3B-GGUF"
        [[ "$QUANT" =~ ^[bB][fF]16$ ]] && QUANT="BF16"
        MODEL_FILE="Ornith-1.5-35B-${QUANT}.gguf"
        MMPROJ="${MODEL_DIR}/mmproj-Ornith-1.5-35B-BF16.gguf"
        MODEL_LABEL="Ornith-1.5-35B-A3B"
        ;;
    1.0)
        MODEL_DIR="${PROJECT_DIR}/models/Ornith-1.0-35B"
        HF_REPO="ornith-ai/Ornith-1.0-35B-GGUF"
        [[ "$QUANT" =~ ^[bB][fF]16$ ]] && QUANT="bf16"
        MODEL_FILE="ornith-1.0-35b-${QUANT}.gguf"
        MMPROJ=""
        MODEL_LABEL="Ornith-1.0-35B"
        ;;
    *)
        echo "ERROR: unknown --version '$VERSION' (expected 1.5 or 1.0)" >&2; exit 1
        ;;
esac

if [[ -z "$MODEL" ]]; then
    MODEL="${MODEL_DIR}/${MODEL_FILE}"
fi

if [[ ! -f "$MODEL" ]]; then
    echo "ERROR: model not found: $MODEL" >&2
    echo "" >&2
    echo "Download it with:" >&2
    echo "  HF_HUB_ENABLE_HF_TRANSFER=1 hf download ${HF_REPO} \\" >&2
    echo "    --include \"${MODEL_FILE}\" --local-dir ${MODEL_DIR#${PROJECT_DIR}/}" >&2
    echo "or run: ./scripts/download-Ornith-${VERSION}-35B.sh" >&2
    exit 1
fi

VISION_ARGS=()
if [[ "$VISION" == "yes" ]]; then
    if [[ -n "$MMPROJ" && -f "$MMPROJ" ]]; then
        VISION_ARGS=(--mmproj "$MMPROJ")
    else
        echo "ERROR: --vision requested but no mmproj available for Ornith ${VERSION} (expected: ${MMPROJ:-n/a})" >&2
        exit 1
    fi
fi

# ---- Dispatch ---------------------------------------------------------------
echo "${MODEL_LABEL}  |  mode=${MODE}  quant=${QUANT}  ctx=${CTX}  ngl=${NGL}  fa=${FA}  vision=${VISION}" >&2
echo "Sampling: temp=${TEMP} top-p=${TOP_P} top-k=${TOP_K}" >&2
echo "" >&2

case "$MODE" in
    chat)
        [[ -x "$LLAMA_CLI" ]] || { echo "ERROR: llama-cli not found at $LLAMA_CLI" >&2; exit 1; }
        exec "$LLAMA_CLI" \
            -m "$MODEL" \
            ${VISION_ARGS[@]+"${VISION_ARGS[@]}"} \
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
            ${VISION_ARGS[@]+"${VISION_ARGS[@]}"} \
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
            ${VISION_ARGS[@]+"${VISION_ARGS[@]}"} \
            -ngl "$NGL" -fa "$FA" -c "$CTX" \
            --jinja \
            --temp "$TEMP" --top-p "$TOP_P" --top-k "$TOP_K" \
            --host "$HOST" --port "$PORT" \
            ${PASSTHRU[@]+"${PASSTHRU[@]}"}
        ;;
esac
