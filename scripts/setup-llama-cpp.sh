#!/bin/bash
# setup-llama-cpp.sh — Clone and build llama.cpp with Metal GPU support
#
# This script:
#   1. Clones llama.cpp if not present
#   2. Updates to the latest main branch
#   3. Builds with Metal GPU support (GGML_METAL=ON)
#   4. Verifies the build completed successfully
#
# Usage: ./scripts/setup-llama-cpp.sh
#
# Requirements:
#   - Xcode Command Line Tools (xcode-select --install)
#   - CMake (cmake)
#   - Git (git)
#   - At least 10 GB free disk space for llama.cpp

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LLAMA_CPP_DIR="${PROJECT_DIR}/llama.cpp"
BUILD_DIR="${LLAMA_CPP_DIR}/build"

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

check_dependencies() {
    local missing=()

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
        echo "Install them with:"
        echo "  # Install Xcode Command Line Tools"
        echo "  xcode-select --install"
        echo ""
        echo "  # Install CMake (with Homebrew)"
        echo "  brew install cmake"
        echo ""
        echo "  # Install Git (with Homebrew)"
        echo "  brew install git"
        echo ""
        exit 1
    fi
}

verify_metal_support() {
    print_info "Verifying Metal GPU support..."
    
    # Create a simple test program
    local test_cpp="${BUILD_DIR}/test-metal.cpp"
    local test_bin="${BUILD_DIR}/test-metal"
    
    cat > "$test_cpp" << 'EOF'
#include <Metal/Metal.h>
#include <Foundation/Foundation.h>

int main() {
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    if (!device) {
        NSLog(@"Metal not available");
        return 1;
    }
    NSLog(@"Metal device: %@", device.name);
    NSLog(@"Metal is available!");
    return 0;
}
EOF

    # Compile and run
    if xcrun -sdk macosx clang -framework Metal -framework Foundation \
        "$test_cpp" -o "$test_bin" 2>/dev/null; then
        if "$test_bin" >/dev/null 2>&1; then
            print_success "Metal GPU support verified"
            return 0
        fi
    fi
    
    print_warning "Could not verify Metal GPU support"
    print_info "llama.cpp may still build successfully without this test"
    return 0
}

clone_or_update_llama_cpp() {
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
}

build_llama_cpp() {
    print_header "Building llama.cpp with Metal GPU support..."
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Configure with CMake
    print_info "Configuring CMake build..."
    cd "$LLAMA_CPP_DIR"
    
    cmake -B "$BUILD_DIR" \
        -DGGML_METAL=ON \
        -DCMAKE_BUILD_TYPE=Release
    
    # Build with all CPU cores
    local num_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "4")
    print_info "Building with ${num_cores} cores..."
    
    cmake --build "$BUILD_DIR" --config Release -j"$num_cores"
    
    print_success "Built llama.cpp successfully"
}

verify_build() {
    print_header "Verifying build..."
    
    local llama_cli="${BUILD_DIR}/bin/llama-cli"
    local llama_server="${BUILD_DIR}/bin/llama-server"
    
    if [[ -f "$llama_cli" && -f "$llama_server" ]]; then
        print_success "Verified llama-cli and llama-server"
        
        # Show versions
        echo ""
        print_info "llama-cli version:"
        "$llama_cli" --version 2>&1 | head -1 || echo "(version info not available)"
        
        echo ""
        print_info "Build info:"
        "$llama_cli" -n 1 -p "test" 2>&1 | head -5 || true
        
        return 0
    else
        echo -e "${RED}ERROR: Build verification failed${NC}"
        echo "  llama-cli: $llama_cli"
        echo "  llama-server: $llama_server"
        return 1
    fi
}

show_summary() {
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
    echo "3. Using wrapper scripts (if models are downloaded):"
    echo "   ./run-ornith.sh chat"
    echo "   ./run-qwen-coder.sh serve"
    echo ""
    echo "Download models with:"
    echo "   ./scripts/download-models.sh"
    echo ""
}

# Main execution
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}llama.cpp Setup Script${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check dependencies
check_dependencies

# Clone or update llama.cpp
clone_or_update_llama_cpp

# Verify Metal support (optional but helpful)
verify_metal_support

# Build llama.cpp
build_llama_cpp

# Verify build
verify_build

# Show summary
show_summary
