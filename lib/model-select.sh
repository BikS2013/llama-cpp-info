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

# Ask interactively whether the model should run with thinking/reasoning.
# Usage: THINK=$(select_thinking)   -> prints "auto" or "off" to stdout
# Prompts/menus go to stderr, like select_model.
select_thinking() {
    echo "" >&2
    echo "Thinking / reasoning mode:" >&2
    echo "   1) auto  - chat-template default (reasoning models emit <think> blocks first)" >&2
    echo "   2) off   - no thinking, answers come back directly (faster, cheaper)" >&2
    echo "   (skip this prompt next time with --think or --no-think)" >&2
    echo "" >&2

    local choice
    if ! read -r -p "Select thinking mode [1-2] (default 1): " choice </dev/tty 2>/dev/tty; then
        echo "ERROR: Could not read selection (is stdin a terminal?)" >&2
        return 1
    fi

    case "$choice" in
        ""|1) echo "auto" ;;
        2)    echo "off" ;;
        *)    echo "ERROR: Invalid selection: '$choice'" >&2; return 1 ;;
    esac
}

# Ask interactively for the context window size.
# Usage: CTX=$(select_ctx "<default>")   -> prints the chosen token count to stdout
# Prompts/menus go to stderr, like select_model.
select_ctx() {
    local default="$1"
    local sizes=(4096 8192 16384 32768 65536 131072 262144)
    local labels=("4K" "8K" "16K" "32K" "64K" "128K" "256K")

    echo "" >&2
    echo "Context window size (tokens) — larger = longer prompts/history, more memory for the KV cache:" >&2
    local i
    for i in "${!sizes[@]}"; do
        local mark=""
        [ "${sizes[$i]}" = "$default" ] && mark="   (default)"
        printf "  %2d) %6s  %-7s%s\n" "$((i + 1))" "${labels[$i]}" "${sizes[$i]}" "$mark" >&2
    done
    echo "   c) custom - type any token count" >&2
    echo "   (skip this prompt next time with --ctx SIZE)" >&2
    echo "" >&2

    local choice
    if ! read -r -p "Select context size [1-${#sizes[@]}, c] (default ${default}): " choice </dev/tty 2>/dev/tty; then
        echo "ERROR: Could not read selection (is stdin a terminal?)" >&2
        return 1
    fi

    case "$choice" in
        "") echo "$default" ;;
        c|C)
            local custom
            if ! read -r -p "Context size in tokens: " custom </dev/tty 2>/dev/tty; then
                echo "ERROR: Could not read selection (is stdin a terminal?)" >&2
                return 1
            fi
            if ! [[ "$custom" =~ ^[0-9]+$ ]] || [ "$custom" -lt 1 ]; then
                echo "ERROR: Invalid context size: '$custom'" >&2
                return 1
            fi
            echo "$custom"
            ;;
        *)
            if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#sizes[@]} ]; then
                echo "ERROR: Invalid selection: '$choice'" >&2
                return 1
            fi
            echo "${sizes[$((choice - 1))]}"
            ;;
    esac
}
