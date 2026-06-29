#!/bin/bash
# Shared helper: scan and select GGUF models from the models/ directory.
# Source this file, then call: select_model "<models_dir>"
#
# The selected absolute path is written to stdout; prompts/menus go to stderr
# so `MODEL=$(select_model ...)` captures only the path.

scan_models() {
    local models_dir="$1"
    # List all GGUF files, but for sharded models (name ending in -NNNNN-of-MMMMM.gguf)
    # keep only the first shard — llama.cpp auto-loads the rest.
    find "$models_dir" -maxdepth 3 -type f -name "*.gguf" 2>/dev/null | awk '
        {
            if (match($0, /-[0-9]{5}-of-[0-9]{5}\.gguf$/)) {
                shard = substr($0, RSTART+1, 5)
                if (shard == "00001") print
            } else {
                print
            }
        }' | sort
}

# Print a human-readable size for a GGUF. For a sharded first-shard path
# (foo-00001-of-NNNNN.gguf), sums sizes of all shards.
gguf_size() {
    local path="$1"
    if [[ "$path" =~ -00001-of-([0-9]{5})\.gguf$ ]]; then
        local total="${BASH_REMATCH[1]}"
        local base="${path%-00001-of-*.gguf}"
        du -ch "$base"-[0-9][0-9][0-9][0-9][0-9]-of-"$total".gguf 2>/dev/null | tail -1 | cut -f1
    else
        du -h "$path" 2>/dev/null | cut -f1
    fi
}

list_models() {
    local models_dir="$1"
    local i=1
    local path rel size
    while IFS= read -r path; do
        rel="${path#$models_dir/}"
        size=$(gguf_size "$path")
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
        size=$(gguf_size "$path")
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
