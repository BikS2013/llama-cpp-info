# Qwen3-Coder-Next — Reference

Source repo (GGUF): <https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF>
Studied / installed: 2026-06-29

## What it is

**Qwen3-Coder-Next** is an open-weight **agentic-coding** model from the **Qwen team
(Alibaba)**. Unlike Ornith, it is a **non-reasoning** model — it does **not** emit
`<think> … </think>` blocks; it answers directly. It is tuned for software engineering and
tool-augmented agent workflows, and emits OpenAI-style tool calls in the **`qwen3_coder`**
format (surfaced as `tool_calls` by llama-server). Apache-2.0 licensed.

## Architecture

- **Family:** Qwen3-Next **hybrid** — gated **delta-net** (linear-attention) layers interleaved
  with periodic full-attention layers, plus a fine-grained **MoE** FFN. Same lineage as the
  `qwen35moe` arch already running in this project (Ornith / `Qwen3.6-35B-A3B`).
- **Total / active params:** **80B total, ~3B active** per token (MoE). Generation speed tracks
  the ~3B active count, so it stays fast even at Q6/Q8 on unified memory. The delta-net layers
  keep a fixed-size recurrent state instead of a growing KV cache, so KV memory at long context
  is far smaller than a pure-attention 80B model.
- **Context length:** **262144 (256K)** native.
- **Reasoning:** none (non-reasoning / instruct-style coder).

### llama.cpp support

The Qwen3-Next hybrid arch must be present in the llama.cpp build. This project is built on
**b9835** (rebuilt 2026-06-28), which already runs the sibling `qwen35moe` arch (Ornith), so the
model loads natively. If a future model reports `unknown model architecture`, rebuild llama.cpp
to latest. Unsloth notes a chat-template/tokenizer fix early 2026 — these GGUFs are the
re-converted, fixed builds.

## Recommended inference settings (Qwen / Unsloth)

| Setting | Value |
|---------|-------|
| temperature | **1.0** |
| top-p | **0.95** |
| top-k | **40** |
| min-p | **0.01** |
| repeat penalty | **off (1.0)** |
| reasoning | none — model answers directly |
| chat template | use `--jinja` so llama.cpp applies the embedded template |
| tool calling | `qwen3_coder` format; auto-enabled by `--jinja` on llama-server |

On other runtimes the equivalent parser is `--tool-call-parser qwen3_coder`
`--enable-auto-tool-choice` (vLLM/SGLang). With llama.cpp, `--jinja` covers it because the
template ships in the GGUF.

## GGUF quants (unsloth/Qwen3-Coder-Next-GGUF)

Selected sizes (Unsloth Dynamic "UD" quants are accuracy-optimized):

| Quant | Size | Notes |
|-------|------|-------|
| UD-Q2_K_XL | 26.8 GB | 2-bit, leanest sensible |
| UD-Q3_K_XL | 36.3 GB | 3-bit |
| UD-Q4_K_XL | 49.6 GB | 4-bit, strong for coding |
| UD-Q5_K_XL | 59.5 GB | 5-bit |
| **UD-Q6_K_XL** | **73.1 GB** | **near-lossless — downloaded here (3 shards)** |
| UD-Q8_K_XL | 86.3 GB | essentially lossless |
| BF16 | 159 GB | full precision (4 shards; no practical inference gain over Q8) |

The UD-Q6_K_XL edition is **sharded into 3 files**
(`UD-Q6_K_XL/Qwen3-Coder-Next-UD-Q6_K_XL-00001-of-00003.gguf` …). llama.cpp auto-loads shards 2–3
from the first; the project's `lib/model-select.sh` and `run-qwen-coder.sh` both load the first
shard only.

### Why UD-Q6_K_XL on this machine

Apple **M5 Max, 128 GB unified memory, ~870 GB free disk**. Q6_K_XL (73 GB) is near-lossless
versus BF16 yet leaves **~55 GB** free for the KV cache — comfortable for 128K+ coding contexts —
and downloads faster than Q8. Because only ~3B params are active, Q6 does not meaningfully slow
generation versus a smaller quant; the trade-off across quants on this MoE is essentially
quality-vs-context-headroom, not speed. (Q8_K_XL at 86 GB is available if maximum quality is
preferred; it leaves ~42 GB and may need a wired-memory-limit bump for very large contexts.)

### Measured performance (UD-Q6_K_XL, M5 Max, build b9835)

| Phase | Throughput |
|-------|-----------|
| Prompt eval | ~99 t/s |
| Generation | ~73 t/s |

Verified 2026-06-29 with `-fa on -c 8192 --jinja` and the recommended sampling (smoke test:
iterative-Fibonacci code generation). The model loaded all 3 shards from the first shard with no
arch warnings, and produced a direct answer with **no `<think>` block** — confirming non-reasoning
behavior. Generation tracks the ~3B active count, so it stays fast despite the 80B total / Q6
weights.

## Running it

Use the dedicated wrapper, which bakes in the recommended sampling, `--jinja`, and
`--no-context-shift`:

```bash
./run-qwen-coder.sh chat                  # interactive REPL
./run-qwen-coder.sh serve --ctx 131072    # OpenAI-compatible API on :8080, tool calling enabled
./run-qwen-coder.sh ask "your prompt"     # one-shot
```

Raw equivalent:

```bash
./llama.cpp/build/bin/llama-cli \
  -m ./models/Qwen3-Coder-Next/UD-Q6_K_XL/Qwen3-Coder-Next-UD-Q6_K_XL-00001-of-00003.gguf \
  -ngl 99 -fa on -c 65536 --no-context-shift --jinja \
  --temp 1.0 --top-p 0.95 --top-k 40 --min-p 0.01
```

### Tuning notes

- **Context:** default 65536. Raise with `--ctx` up to 262144. The delta-net hybrid keeps KV
  growth modest, but very large contexts still cost memory and prompt-eval time.
- **Flash attention:** `-fa on` by default (applies to the full-attention layers). Use `--fa auto`
  if a future build reports an FA incompatibility for this arch.
- **No context shift:** `--no-context-shift` is baked in (Qwen's recommendation for this model) so
  a full context errors loudly instead of silently dropping the oldest tokens mid-task.
- **Quant switch:** `--quant UD-Q8_K_XL` (after downloading it) loads a different quant subfolder.
- **Tool calling (server):** `--jinja` makes llama-server expose the model's tool calls as OpenAI
  `tool_calls`, so agent frameworks pointed at `http://127.0.0.1:8080/v1` work.

## Downloading

```bash
HF_HUB_ENABLE_HF_TRANSFER=1 hf download unsloth/Qwen3-Coder-Next-GGUF \
  --include "UD-Q6_K_XL/*" --local-dir models/Qwen3-Coder-Next
```

Swap the `--include` glob for another quant subfolder (e.g. `"UD-Q8_K_XL/*"`).

## Sources

- GGUF (Unsloth): <https://huggingface.co/unsloth/Qwen3-Coder-Next-GGUF>
- GGUF (Qwen official): <https://huggingface.co/Qwen/Qwen3-Coder-Next-GGUF>
- Run guide: <https://unsloth.ai/docs/models/qwen3-coder-next>
