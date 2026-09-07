#!/bin/bash
# download-models.sh — Download all llama.cpp models from HuggingFace
#
# Usage:
#   ./scripts/download-models.sh [MODEL_NAME]
#
# If MODEL_NAME is provided, only that model is downloaded.
# Otherwise, all models are downloaded.
#
# Models available:
#   gemma-4-E2B      - Gemma 4 E2B (2.3B, Q8_0, 4.7 GB)      [DEFAULT]
#   gemma-4-E4B      - Gemma 4 E4B (4.5B, Q8_0, 7.6 GB)      [DEFAULT]
#   gemma-4-26B      - Gemma 4 26B (A4B, Q8_0, 25 GB)        [DEFAULT]
#   gemma-4-31B      - Gemma 4 31B (dense, Q8_0, 30 GB)      [DEFAULT]
#   MiniMax-M2.7     - MiniMax-M2.7 (229B MoE, ~101 GB, 4 shards)
#   Ornith-1.0-35B   - Ornith-1.0-35B (35B MoE, Q8_0, 34 GB)  [superseded by 1.5]
#   Ornith-1.5-35B   - Ornith-1.5-35B-A3B (35B MoE, Q8_0, 35 GB + mmproj)
#   qwen-3.6-35B     - Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)
#   qwen-3.8-27B     - Qwen3.8-27B (dense, Q8_K_XL, 29 GB + mmproj)
#   Qwen3-Coder-Next - Qwen3-Coder-Next (80B MoE, ~68 GB, 3 shards)
#
# Requirements:
#   - HF CLI with hf_transfer: uv tool install --with hf_transfer huggingface_hub
#   - At least 300 GB free disk space for all models

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODELS_DIR="${PROJECT_DIR}/models"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

show_help() {
    echo "Usage: $0 [MODEL_NAME]"
    echo ""
    echo "Download llama.cpp models from HuggingFace"
    echo ""
    echo "Arguments:"
    echo "  MODEL_NAME    Model to download (default: all)"
    echo ""
    echo "Available models:"
    printf "  %-20s %s\n" "gemma-4-E2B" "Gemma 4 E2B (2.3B, Q8_0, 4.7 GB)"
    printf "  %-20s %s\n" "gemma-4-E4B" "Gemma 4 E4B (4.5B, Q8_0, 7.6 GB)"
    printf "  %-20s %s\n" "gemma-4-26B" "Gemma 4 26B (A4B, Q8_0, 25 GB)"
    printf "  %-20s %s\n" "gemma-4-31B" "Gemma 4 31B (dense, Q8_0, 30 GB)"
    printf "  %-20s %s\n" "MiniMax-M2.7" "MiniMax-M2.7 (229B MoE, ~101 GB, 4 shards)"
    printf "  %-20s %s\n" "Ornith-1.0-35B" "Ornith-1.0-35B (35B MoE, Q8_0, 34 GB) [superseded by 1.5]"
    printf "  %-20s %s\n" "Ornith-1.5-35B" "Ornith-1.5-35B-A3B (35B MoE, Q8_0, 35 GB + mmproj)"
    printf "  %-20s %s\n" "qwen-3.6-35B" "Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)"
    printf "  %-20s %s\n" "qwen-3.8-27B" "Qwen3.8-27B (dense, Q8_K_XL, 29 GB + mmproj)"
    printf "  %-20s %s\n" "Qwen3-Coder-Next" "Qwen3-Coder-Next (80B MoE, ~68 GB, 3 shards)"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Download all default models"
    echo "  $0 MiniMax-M2.7       # Download only MiniMax-M2.7"
    echo "  $0 Ornith-1.5         # Download only Ornith-1.5-35B"
    echo "  $0 gemma              # Download all Gemma models"
}

check_dependencies() {
    if ! command -v hf &> /dev/null; then
        echo -e "${RED}ERROR: hf CLI not found${NC}"
        echo ""
        echo "Install it with:"
        echo "  uv tool install --with hf_transfer huggingface_hub"
        echo ""
        exit 1
    fi
}

download_model() {
    local model_name="$1"
    local repo="$2"
    local include="$3"
    local size="$4"
    local target_dir="${MODELS_DIR}/${model_name}"

    print_header "Downloading ${model_name} (${size})"

    if [[ -d "$target_dir" ]]; then
        print_warning "Directory ${target_dir} already exists, skipping"
        return 0
    fi

    print_info "Downloading from ${repo}..."
    print_info "Target: ${target_dir}"

    mkdir -p "$target_dir"

    # "include" may be a comma-separated list of patterns (e.g. model + mmproj)
    local include_args=()
    IFS=',' read -ra include_list <<< "$include"
    for pat in "${include_list[@]}"; do include_args+=(--include "$pat"); done

    # Use HF_TRANSFER for faster downloads
    HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$repo" \
        "${include_args[@]}" \
        --local-dir "$target_dir"

    print_success "Downloaded ${model_name}"
}

get_model_spec() {
    local name="$1"
    case "$name" in
        gemma-4-E2B)
            echo "gemma-4-E2B|unsloth/gemma-4-E2B-it-GGUF|gemma-4-E2B-it-Q8_0.gguf|Gemma 4 E2B (2.3B, Q8_0)|4.7 GB"
            ;;
        gemma-4-E4B)
            echo "gemma-4-E4B|unsloth/gemma-4-E4B-it-GGUF|gemma-4-E4B-it-Q8_0.gguf|Gemma 4 E4B (4.5B, Q8_0)|7.6 GB"
            ;;
        gemma-4-26B)
            echo "gemma-4-26B|unsloth/gemma-4-26B-A4B-it-GGUF|gemma-4-26B-A4B-it-Q8_0.gguf|Gemma 4 26B (A4B, Q8_0)|25 GB"
            ;;
        gemma-4-31B)
            echo "gemma-4-31B|unsloth/gemma-4-31B-it-GGUF|gemma-4-31B-it-Q8_0.gguf|Gemma 4 31B (dense, Q8_0)|30 GB"
            ;;
        MiniMax-M2.7)
            echo "MiniMax-M2.7|unsloth/MiniMax-M2.7-GGUF|UD-IQ4_XS/*|MiniMax-M2.7 (229B MoE, ~101 GB)|101 GB"
            ;;
        Ornith-1.0-35B)
            echo "Ornith-1.0-35B|ornith-ai/Ornith-1.0-35B-GGUF|ornith-1.0-35b-Q8_0.gguf|Ornith-1.0-35B (35B MoE, Q8_0)|34 GB"
            ;;
        Ornith-1.5-35B)
            echo "Ornith-1.5-35B|ornith-ai/Ornith-1.5-35B-A3B-GGUF|Ornith-1.5-35B-Q8_0.gguf,mmproj-Ornith-1.5-35B-BF16.gguf|Ornith-1.5-35B-A3B (35B MoE, Q8_0)|36 GB"
            ;;
        qwen-3.6-35B)
            echo "qwen-3.6-35B|unsloth/Qwen3.6-35B-A3B-GGUF|Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf|Qwen3.6-35B (A3B, Q8_K_XL)|36 GB"
            ;;
        qwen-3.8-27B)
            echo "qwen-3.8-27B|unsloth/Qwen3.8-27B-GGUF|Qwen3.8-27B-UD-Q8_K_XL.gguf,mmproj-BF16.gguf|Qwen3.8-27B (dense, Q8_K_XL)|30 GB"
            ;;
        Qwen3-Coder-Next)
            echo "Qwen3-Coder-Next|unsloth/Qwen3-Coder-Next-GGUF|UD-Q6_K_XL/*|Qwen3-Coder-Next (80B MoE, ~68 GB)|68 GB"
            ;;
        *)
            echo ""
            ;;
    esac
}

list_models() {
    echo -e "${BLUE}Available models:${NC}"
    echo ""
    echo "  gemma-4-E2B          Gemma 4 E2B (2.3B, Q8_0, 4.7 GB)"
    echo "  gemma-4-E4B          Gemma 4 E4B (4.5B, Q8_0, 7.6 GB)"
    echo "  gemma-4-26B          Gemma 4 26B (A4B, Q8_0, 25 GB)"
    echo "  gemma-4-31B          Gemma 4 31B (dense, Q8_0, 30 GB)"
    echo "  MiniMax-M2.7         MiniMax-M2.7 (229B MoE, ~101 GB, 4 shards)"
    echo "  Ornith-1.0-35B       Ornith-1.0-35B (35B MoE, Q8_0, 34 GB) [superseded by 1.5]"
    echo "  Ornith-1.5-35B       Ornith-1.5-35B-A3B (35B MoE, Q8_0, 35 GB + mmproj)"
    echo "  qwen-3.6-35B         Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)"
    echo "  qwen-3.8-27B         Qwen3.8-27B (dense, Q8_K_XL, 29 GB + mmproj)"
    echo "  Qwen3-Coder-Next     Qwen3-Coder-Next (80B MoE, ~68 GB, 3 shards)"
}

# Parse arguments
if [[ $# -eq 0 ]]; then
    MODELS_TO_DOWNLOAD="gemma-4-E2B,gemma-4-E4B,gemma-4-26B,gemma-4-31B"
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
else
    MODEL_ARG="$1"
    # Check if it matches a model name (exact or prefix)
    MATCHED=""
    for key in "gemma-4-E2B" "gemma-4-E4B" "gemma-4-26B" "gemma-4-31B" "MiniMax-M2.7" "Ornith-1.0-35B" "Ornith-1.5-35B" "qwen-3.6-35B" "qwen-3.8-27B" "Qwen3-Coder-Next"; do
        if [[ "$key" == "$MODEL_ARG" || "$key" == *"$MODEL_ARG"* ]]; then
            if [[ -n "$MATCHED" ]]; then
                echo -e "${RED}ERROR: '$MODEL_ARG' matches multiple models: $MATCHED and $key${NC}"
                exit 1
            fi
            MATCHED="$key"
        fi
    done
    if [[ -z "$MATCHED" ]]; then
        echo -e "${RED}ERROR: Model '$MODEL_ARG' not found${NC}"
        list_models
        exit 1
    fi
    MODELS_TO_DOWNLOAD="$MATCHED"
fi

# Check dependencies
check_dependencies

# Parse comma-separated model list
IFS=',' read -ra MODEL_ARRAY <<< "$MODELS_TO_DOWNLOAD"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}llama.cpp Model Downloader${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

total_size=0
for model_name in "${MODEL_ARRAY[@]}"; do
    spec=$(get_model_spec "$model_name")
    if [[ -n "$spec" ]]; then
        IFS='|' read -r name repo include desc size <<< "$spec"
        # Extract numeric size for calculation
        size_num=$(echo "$size" | grep -oE '[0-9.]+')
        size_unit=$(echo "$size" | grep -oE '[A-Za-z]+')
        if [[ "$size_unit" == "GB" ]]; then
            total_size=$(echo "$total_size + $size_num" | bc 2>/dev/null || echo "$total_size")
        fi
    fi
done

print_info "Downloading ${#MODEL_ARRAY[@]} model(s)..."
print_info "Total size: ${total_size} GB"
echo ""

# Download each model
for model_name in "${MODEL_ARRAY[@]}"; do
    spec=$(get_model_spec "$model_name")
    if [[ -n "$spec" ]]; then
        IFS='|' read -r name repo include desc size <<< "$spec"
        download_model "$name" "$repo" "$include" "$size"
        echo ""
    else
        print_warning "Unknown model: $model_name"
    fi
done

print_header "Download Complete!"
echo -e "${GREEN}All models have been downloaded successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Build llama.cpp: ./scripts/setup-llama-cpp.sh"
echo "  2. Run a model:       ./run-ornith.sh chat"
echo "  3. Run a model:       ./run-qwen-coder.sh chat"
echo ""
echo "Available models:"
for model_name in "${MODEL_ARRAY[@]}"; do
    spec=$(get_model_spec "$model_name")
    if [[ -n "$spec" ]]; then
        IFS='|' read -r name repo include desc size <<< "$spec"
        printf "  • %-20s → %s\n" "$name" "models/${name}/"
    fi
done
