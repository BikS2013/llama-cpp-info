#!/bin/bash
# llama-setup.sh — Unified llama.cpp setup and model management
#
# This script provides a single interface for:
#   - Setting up/building llama.cpp
#   - Downloading models from HuggingFace
#   - Listing available models
#   - Getting model-specific usage information
#
# Usage: ./scripts/llama-setup.sh <command> [options]
#
# Commands:
#   setup       Clone and build llama.cpp with Metal GPU support
#   download    Download models from HuggingFace
#   list        List available models
#   help        Show this help message
#
# Examples:
#   ./scripts/llama-setup.sh setup                    # Build llama.cpp
#   ./scripts/llama-setup.sh download all             # Download all default models
#   ./scripts/llama-setup.sh download MiniMax-M2.7    # Download specific model
#   ./scripts/llama-setup.sh list                     # List all models
#   ./scripts/llama-setup.sh help                     # Show this help

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LLAMA_CPP_DIR="${PROJECT_DIR}/llama.cpp"
BUILD_DIR="${LLAMA_CPP_DIR}/build"
MODELS_DIR="${PROJECT_DIR}/models"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# Model Database (using functions for bash 3 compatibility)
# =============================================================================

get_model_repo() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B) echo "unsloth/gemma-4-E2B-it-GGUF" ;;
        gemma-4-E4B) echo "unsloth/gemma-4-E4B-it-GGUF" ;;
        gemma-4-26B) echo "unsloth/gemma-4-26B-A4B-it-GGUF" ;;
        gemma-4-31B) echo "unsloth/gemma-4-31B-it-GGUF" ;;
        MiniMax-M2.7) echo "unsloth/MiniMax-M2.7-GGUF" ;;
        Ornith-1.0-35B) echo "deepreinforce-ai/Ornith-1.0-35B-GGUF" ;;
        qwen-3.6-35B) echo "unsloth/Qwen3.6-35B-A3B-GGUF" ;;
        Qwen3-Coder-Next) echo "unsloth/Qwen3-Coder-Next-GGUF" ;;
        *) echo "" ;;
    esac
}

get_model_include() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B) echo "gemma-4-E2B-it-Q8_0.gguf" ;;
        gemma-4-E4B) echo "gemma-4-E4B-it-Q8_0.gguf" ;;
        gemma-4-26B) echo "gemma-4-26B-A4B-it-Q8_0.gguf" ;;
        gemma-4-31B) echo "gemma-4-31B-it-Q8_0.gguf" ;;
        MiniMax-M2.7) echo "UD-IQ4_XS/*" ;;
        Ornith-1.0-35B) echo "ornith-1.0-35b-Q8_0.gguf" ;;
        qwen-3.6-35B) echo "Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf" ;;
        Qwen3-Coder-Next) echo "UD-Q6_K_XL/*" ;;
        *) echo "" ;;
    esac
}

get_model_size() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B) echo "4.7 GB" ;;
        gemma-4-E4B) echo "7.6 GB" ;;
        gemma-4-26B) echo "25 GB" ;;
        gemma-4-31B) echo "30 GB" ;;
        MiniMax-M2.7) echo "101 GB" ;;
        Ornith-1.0-35B) echo "34 GB" ;;
        qwen-3.6-35B) echo "36 GB" ;;
        Qwen3-Coder-Next) echo "68 GB" ;;
        *) echo "" ;;
    esac
}

get_model_desc() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B) echo "Gemma 4 E2B (2.3B, Q8_0, 4.7 GB)" ;;
        gemma-4-E4B) echo "Gemma 4 E4B (4.5B, Q8_0, 7.6 GB)" ;;
        gemma-4-26B) echo "Gemma 4 26B (A4B, Q8_0, 25 GB)" ;;
        gemma-4-31B) echo "Gemma 4 31B (dense, Q8_0, 30 GB)" ;;
        MiniMax-M2.7) echo "MiniMax-M2.7 (229B MoE, ~101 GB, 4 shards)" ;;
        Ornith-1.0-35B) echo "Ornith-1.0-35B (35B MoE, Q8_0, 34 GB)" ;;
        qwen-3.6-35B) echo "Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)" ;;
        Qwen3-Coder-Next) echo "Qwen3-Coder-Next (80B MoE, ~68 GB, 3 shards)" ;;
        *) echo "" ;;
    esac
}

get_model_default() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B|gemma-4-E4B|gemma-4-26B|gemma-4-31B) echo "yes" ;;
        *) echo "no" ;;
    esac
}

get_model_sharded() {
    local model_name="$1"
    case "$model_name" in
        MiniMax-M2.7|Qwen3-Coder-Next) echo "yes" ;;
        *) echo "no" ;;
    esac
}

get_model_shard_count() {
    local model_name="$1"
    case "$model_name" in
        MiniMax-M2.7) echo "4" ;;
        Qwen3-Coder-Next) echo "3" ;;
        *) echo "0" ;;
    esac
}

get_model_notes() {
    local model_name="$1"
    case "$model_name" in
        gemma-4-E2B) echo "Performance: ~67 t/s prompt, ~120 t/s generation on Apple M4 Max" ;;
        MiniMax-M2.7) echo "200K context. For Apple silicon with 128 GB: sudo sysctl -w iogpu.wired_limit_mb=122880" ;;
        Ornith-1.0-35B) echo "Agentic coding model. Reasoning (<think>), tool calling (qwen3 XML). Use run-ornith.sh wrapper." ;;
        qwen-3.6-35B) echo "Qwen3-Next delta-net hybrid MoE" ;;
        Qwen3-Coder-Next) echo "NON-reasoning (no <think>). Tool calling (qwen3_coder). Use run-qwen-coder.sh wrapper." ;;
        *) echo "" ;;
    esac
}

get_all_models() {
    echo "gemma-4-E2B gemma-4-E4B gemma-4-26B gemma-4-31B MiniMax-M2.7 Ornith-1.0-35B qwen-3.6-35B Qwen3-Coder-Next"
}

# =============================================================================
# Helper Functions
# =============================================================================

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

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_model_header() {
    local model_name="$1"
    local size
    size=$(get_model_size "$model_name")
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Downloading ${model_name} (${size})${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_model_info() {
    local model_name="$1"
    local include
    include=$(get_model_include "$model_name")
    
    echo ""
    echo "Model location: ${MODELS_DIR}/${model_name}/"
    if [[ "$include" == *"*"* ]]; then
        local subdir
        subdir=$(basename "${include%%/*}")
        echo "Model location: ${MODELS_DIR}/${model_name}/${subdir}/"
    fi
    echo ""
}

print_usage_example() {
    local model_name="$1"
    local include
    include=$(get_model_include "$model_name")
    
    if [[ "$include" == *"*"* ]]; then
        include="*"
    fi
    
    echo "Usage example:"
    echo "  ./llama.cpp/build/bin/llama-cli -m ${MODELS_DIR}/${model_name}/${include} -ngl 99 --temp 0.7"
    echo ""
}

check_dependencies() {
    local missing=()
    
    if ! command -v hf &> /dev/null; then
        missing+=("hf CLI")
    fi
    
    if ! command -v cmake &> /dev/null; then
        missing+=("cmake")
    fi
    
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    if ! command -v xcodebuild &> /dev/null; then
        missing+=("Xcode Command Line Tools")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}ERROR: Missing dependencies:${NC}"
        for dep in "${missing[@]}"; do
            echo "  - $dep"
        done
        echo ""
        return 1
    fi
    
    return 0
}

# =============================================================================
# Setup Command (builds llama.cpp)
# =============================================================================

run_setup() {
    echo ""
    print_header "llama.cpp Setup"
    echo ""
    
    # Check dependencies
    check_dependencies || {
        echo ""
        echo "Install missing dependencies:"
        echo "  # Install Xcode Command Line Tools"
        echo "  xcode-select --install"
        echo ""
        echo "  # Install CMake (with Homebrew)"
        echo "  brew install cmake"
        echo ""
        echo "  # Install Git (with Homebrew)"
        echo "  brew install git"
        echo ""
        echo "  # Install HF CLI (for model downloads)"
        echo "  uv tool install --with hf_transfer huggingface_hub"
        echo ""
        exit 1
    }
    
    print_info "All dependencies satisfied"
    
    # Clone or update llama.cpp
    if [[ ! -d "$LLAMA_CPP_DIR" ]]; then
        print_header "Cloning llama.cpp..."
        print_info "Destination: ${LLAMA_CPP_DIR}"
        
        git clone https://github.com/ggerganov/llama.cpp.git "$LLAMA_CPP_DIR"
        print_success "Cloned llama.cpp"
    else
        print_header "Updating llama.cpp..."
        print_info "Current directory: ${LLAMA_CPP_DIR}"
        
        cd "$LLAMA_CPP_DIR"
        git fetch origin main
        git checkout main
        git pull origin main
        print_success "Updated llama.cpp to latest main"
    fi
    
    # Build llama.cpp
    print_header "Building llama.cpp with Metal GPU support..."
    
    mkdir -p "$BUILD_DIR"
    cd "$LLAMA_CPP_DIR"
    
    print_info "Configuring CMake build..."
    
    cmake -B "$BUILD_DIR" \
        -DGGML_METAL=ON \
        -DCMAKE_BUILD_TYPE=Release
    
    local num_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "4")
    print_info "Building with ${num_cores} cores..."
    
    cmake --build "$BUILD_DIR" --config Release -j"$num_cores"
    
    print_success "Built llama.cpp successfully"
    
    # Verify build
    print_header "Verifying build..."
    
    local llama_cli="${BUILD_DIR}/bin/llama-cli"
    local llama_server="${BUILD_DIR}/bin/llama-server"
    
    if [[ -f "$llama_cli" && -f "$llama_server" ]]; then
        print_success "Verified llama-cli and llama-server"
        
        echo ""
        print_info "llama-cli version:"
        "$llama_cli" --version 2>&1 | head -1 || echo "(version info not available)"
        echo ""
    else
        echo -e "${RED}ERROR: Build verification failed${NC}"
        echo "  llama-cli: $llama_cli"
        echo "  llama-server: $llama_server"
        exit 1
    fi
    
    print_header "Setup Complete!"
    echo ""
    echo "llama.cpp is now ready to use!"
    echo ""
    echo "Quick start examples:"
    echo ""
    echo "1. Interactive chat (Gemma 4 E2B):"
    echo "   ./llama.cpp/build/bin/llama-cli -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf -ngl 99 --temp 0.7"
    echo ""
    echo "2. API server:"
    echo "   ./llama.cpp/build/bin/llama-server -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf -ngl 99 --port 8080"
    echo ""
    echo "3. Download models:"
    echo "   ./scripts/llama-setup.sh download all"
    echo ""
    echo "4. Use wrapper scripts (after downloading models):"
    echo "   ./run-ornith.sh chat"
    echo "   ./run-qwen-coder.sh serve"
    echo ""
}

# =============================================================================
# Download Command (downloads models)
# =============================================================================

download_model() {
    local model_name="$1"
    local repo
    local include
    local size
    local target_dir
    
    repo=$(get_model_repo "$model_name")
    include=$(get_model_include "$model_name")
    size=$(get_model_size "$model_name")
    target_dir="${MODELS_DIR}/${model_name}"
    
    print_model_header "$model_name"
    
    if [[ -d "$target_dir" ]]; then
        print_warning "Directory ${target_dir} already exists, skipping"
        return 0
    fi
    
    print_info "Downloading from ${repo}..."
    print_info "Target: ${target_dir}"
    
    local sharded
    sharded=$(get_model_sharded "$model_name")
    if [[ "$sharded" == "yes" ]]; then
        local shard_count
        shard_count=$(get_model_shard_count "$model_name")
        print_info "Note: This is a sharded model with ${shard_count} shards (${size} total)."
        print_info "Only the first shard needs to be loaded manually; llama.cpp auto-loads the rest."
        echo ""
    fi
    
    local notes
    notes=$(get_model_notes "$model_name")
    if [[ -n "$notes" ]]; then
        print_info "$notes"
        echo ""
    fi
    
    mkdir -p "$target_dir"
    
    # Use HF_TRANSFER for faster downloads
    HF_HUB_ENABLE_HF_TRANSFER=1 hf download "$repo" \
        --include "$include" \
        --local-dir "$target_dir"
    
    print_success "Downloaded ${model_name}"
    print_model_info "$model_name"
    print_usage_example "$model_name"
    
    # Special notes for agentic models
    if [[ "$model_name" == "Ornith-1.0-35B" ]]; then
        echo "For optimal usage, see the dedicated wrapper:"
        echo "  ./run-ornith.sh chat                      # Interactive REPL"
        echo "  ./run-ornith.sh serve --ctx 65536         # API server"
        echo ""
    elif [[ "$model_name" == "Qwen3-Coder-Next" ]]; then
        echo "For optimal usage, see the dedicated wrapper:"
        echo "  ./run-qwen-coder.sh chat                  # Interactive REPL"
        echo "  ./run-qwen-coder.sh serve --ctx 131072    # API server"
        echo ""
    fi
}

run_download() {
    local model_arg="${1:-all}"
    
    echo ""
    print_header "Model Downloader"
    echo ""
    
    # Check dependencies
    if ! command -v hf &> /dev/null; then
        echo -e "${RED}ERROR: hf CLI not found${NC}"
        echo ""
        echo "Install it with:"
        echo "  uv tool install --with hf_transfer huggingface_hub"
        echo ""
        exit 1
    fi
    
    # Determine which models to download
    local models_to_download=()
    
    if [[ "$model_arg" == "all" ]]; then
        # Download all default models
        for model in $(get_all_models); do
            if [[ $(get_model_default "$model") == "yes" ]]; then
                models_to_download+=("$model")
            fi
        done
    elif [[ "$model_arg" == "all-non-default" ]]; then
        # Download all non-default models
        for model in $(get_all_models); do
            if [[ $(get_model_default "$model") == "no" ]]; then
                models_to_download+=("$model")
            fi
        done
    else
        # Find matching model(s)
        local found=0
        for model in $(get_all_models); do
            if [[ "$model" == "$model_arg" || "$model" == *"$model_arg"* ]]; then
                models_to_download+=("$model")
                ((found++))
            fi
        done
        
        if [[ $found -eq 0 ]]; then
            print_error "Model '$model_arg' not found"
            echo ""
            echo "Available models:"
            list_models
            exit 1
        fi
        
        if [[ $found -gt 1 ]]; then
            print_error "'$model_arg' matches multiple models:"
            for model in "${models_to_download[@]}"; do
                echo "  - $model"
            done
            echo ""
            echo "Please be more specific."
            exit 1
        fi
    fi
    
    # Calculate total size
    local total_size=0
    for model in "${models_to_download[@]}"; do
        local size_num
        size_num=$(get_model_size "$model")
        if [[ "$size_num" == *" GB"* ]]; then
            size_val="${size_num% *}"
            total_size=$(echo "$total_size + $size_val" | bc 2>/dev/null || echo "$total_size")
        fi
    done
    
    print_info "Downloading ${#models_to_download[@]} model(s)..."
    print_info "Total size: ${total_size} GB"
    echo ""
    
    # Download each model
    for model in "${models_to_download[@]}"; do
        download_model "$model"
        echo ""
    done
    
    print_header "Download Complete!"
    echo -e "${GREEN}All models have been downloaded successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Build llama.cpp: ./scripts/llama-setup.sh setup"
    echo "  2. Run a model:       ./run-ornith.sh chat"
    echo "  3. Run a model:       ./run-qwen-coder.sh chat"
    echo ""
}

# =============================================================================
# List Command (shows available models)
# =============================================================================

list_models() {
    echo "Available models:"
    echo ""
    
    printf "%-20s %-45s %s\n" "NAME" "DESCRIPTION" "SIZE"
    printf "%-20s %-45s %s\n" "----" "-----------" "----"
    
    for model in $(get_all_models); do
        local default_marker=""
        [[ $(get_model_default "$model") == "yes" ]] && default_marker="*"
        printf "%-20s %-45s %s\n" "${model}${default_marker}" "$(get_model_desc "$model")" "$(get_model_size "$model")"
    done
    
    echo ""
    echo "* = Default model (included in 'download all')"
}

# =============================================================================
# Help Command
# =============================================================================

show_help() {
    cat << 'HELP'
llama-setup.sh — Unified llama.cpp setup and model management

Usage: ./scripts/llama-setup.sh <command> [options]

Commands:
  setup                              Clone and build llama.cpp with Metal GPU support
  download [all|model-name]          Download models from HuggingFace
  list                               List available models
  help                               Show this help message

Examples:
  ./scripts/llama-setup.sh setup                    # Build llama.cpp
  ./scripts/llama-setup.sh download all             # Download all default models
  ./scripts/llama-setup.sh download MiniMax-M2.7    # Download specific model
  ./scripts/llama-setup.sh list                     # List all models
  ./scripts/llama-setup.sh help                     # Show this help

Available Models:
  gemma-4-E2B          Gemma 4 E2B (2.3B, Q8_0, 4.7 GB)
  gemma-4-E4B          Gemma 4 E4B (4.5B, Q8_0, 7.6 GB)
  gemma-4-26B          Gemma 4 26B (A4B, Q8_0, 25 GB)
  gemma-4-31B          Gemma 4 31B (dense, Q8_0, 30 GB)
  MiniMax-M2.7         MiniMax-M2.7 (229B MoE, ~101 GB, 4 shards)
  Ornith-1.0-35B       Ornith-1.0-35B (35B MoE, Q8_0, 34 GB)
  qwen-3.6-35B         Qwen3.6-35B (A3B, Q8_K_XL, 36 GB)
  Qwen3-Coder-Next     Qwen3-Coder-Next (80B MoE, ~68 GB, 3 shards)

Requirements:
  - Xcode Command Line Tools: xcode-select --install
  - CMake: brew install cmake
  - Git: brew install git
  - HF CLI: uv tool install --with hf_transfer huggingface_hub

Storage Requirements:
  Total for all default models: ~67.3 GB
  Total for all models: ~306 GB

HELP
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        setup)
            run_setup
            ;;
        download)
            run_download "${1:-all}"
            ;;
        list)
            list_models
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}ERROR: Unknown command '$command'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
