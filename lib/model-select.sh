#!/bin/bash
# Shared helper: scan and select GGUF models from the models/ directory.
# Source this file, then call: select_model "<models_dir>"
#
# The selected absolute path is written to stdout; prompts/menus go to stderr
# so `MODEL=$(select_model ...)` captures only the path.

scan_models() {
    local models_dir="$1"
    find "$models_dir" -maxdepth 3 -type f -name "*.gguf" 2>/dev/null | sort
}

list_models() {
    local models_dir="$1"
    local i=1
    local path rel size
    while IFS= read -r path; do
        rel="${path#$models_dir/}"
        size=$(du -h "$path" 2>/dev/null | cut -f1)
        printf "  %2d) %-60s  %s\n" "$i" "$rel" "$size"
        i=$((i + 1))
    done < <(scan_models "$models_dir")
    if [ "$i" -eq 1 ]; then
        echo "  (no .gguf files found in $models_dir)"
    fi
}

select_model() {
    local models_dir="$1"
    local models=()
    local path
    while IFS= read -r path; do
        models+=("$path")
    done < <(scan_models "$models_dir")

    if [ ${#models[@]} -eq 0 ]; then
        echo "ERROR: No GGUF models found in $models_dir" >&2
        return 1
    fi

    echo "" >&2
    echo "Available models:" >&2
    local i=1 rel size
    for path in "${models[@]}"; do
        rel="${path#$models_dir/}"
        size=$(du -h "$path" 2>/dev/null | cut -f1)
        printf "  %2d) %-60s  %s\n" "$i" "$rel" "$size" >&2
        i=$((i + 1))
    done
    echo "" >&2

    local choice
    if ! read -r -p "Select model [1-${#models[@]}]: " choice </dev/tty 2>/dev/tty; then
        echo "ERROR: Could not read selection (is stdin a terminal?)" >&2
        return 1
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#models[@]} ]; then
        echo "ERROR: Invalid selection: '$choice'" >&2
        return 1
    fi

    echo "${models[$((choice - 1))]}"
}
