# Ornith-1.0 — Reference

Source collection: <https://huggingface.co/collections/deepreinforce-ai/ornith-10>
Studied: 2026-06-28

## What it is

**Ornith-1.0** is a family of open-source LLMs from **DeepReinforce**, specialized for
**agentic coding** (tool-calling, terminal-based coding agents). The models are reasoning
models: each assistant turn opens with a `<think> … </think>` block before the final answer,
and tool calls are emitted as `<tool_call>` XML blocks that servers surface as OpenAI-style
`tool_calls`. MIT licensed.

A notable training detail: during RL the *scaffold co-evolves with the policy* — the model
learns to propose its own orchestration framework and then solve tasks using it.

## Family

| Model | Params | Notes |
|-------|--------|-------|
| Ornith-1.0-9B | 9B dense | smallest |
| **Ornith-1.0-35B** | **35B MoE (~3B active)** | single-GPU / local target — **this is what we run** |
| Ornith-1.0-397B | 397B MoE | frontier tier |

Quantized editions are published as GGUF, FP8, and NVFP4 by DeepReinforce and the community
(e.g. `bartowski`).

## Ornith-1.0-35B architecture

- **GGUF arch string:** `qwen35moe` — the Qwen3-Next / **delta-net hybrid MoE** family
  (linear-attention layers + periodic full-attention layers). This is why it serves a 256K
  context efficiently: the linear layers keep a fixed-size recurrent state instead of a
  growing KV cache, so KV memory at long context is far smaller than a pure-attention model.
- **Total / active params:** 35B total, ~3B active per token (MoE). Generation speed tracks the
  ~3B active count, so it stays fast even at Q8_0. (Same family/size as the
  `Qwen3.6-35B-A3B` model already in this project — "A3B" = 3B active.)
- **Context length:** 262144 (256K).
- **Multimodal:** the base has a vision tower, but the **GGUF repo is text-only** (no `mmproj`
  shipped), so local llama.cpp inference is text-only. That is exactly what agentic coding needs.

### llama.cpp support

The `qwen35moe` architecture must be present in the llama.cpp build (`src/models/qwen35moe.cpp`,
`LLM_ARCH_QWEN35MOE`). It has been present since around **b8855**; this project is built on
**b9835** (rebuilt 2026-06-28). If you ever see `unknown model architecture: 'qwen35moe'`,
rebuild llama.cpp to latest.

## Recommended inference settings (DeepReinforce)

| Setting | Value |
|---------|-------|
| temperature | **0.6** |
| top-p | **0.95** |
| top-k | **20** |
| reasoning | `<think> … </think>` (keep enabled; the model reasons before answering) |
| chat template | Qwen3 conventions — use `--jinja` so llama.cpp applies the embedded template |
| tool calling | qwen3 XML (`<tool_call>`); auto-enabled by `--jinja` on llama-server |

On other runtimes the equivalent parsers are `--reasoning-parser qwen3`,
`--tool-call-parser qwen3_xml` (vLLM/SGLang). With llama.cpp, `--jinja` covers both because the
template ships in the GGUF.

## GGUF quants (deepreinforce-ai/Ornith-1.0-35B-GGUF)

| File | Size | Notes |
|------|------|-------|
| `ornith-1.0-35b-Q4_K_M.gguf` | 21.2 GB | smallest; slight quality drop |
| `ornith-1.0-35b-Q5_K_M.gguf` | 24.7 GB | good balance |
| `ornith-1.0-35b-Q6_K.gguf` | 28.5 GB | near-lossless |
| **`ornith-1.0-35b-Q8_0.gguf`** | **36.9 GB** | **essentially lossless — downloaded here** |
| `ornith-1.0-35b-bf16.gguf` | 69.4 GB | full precision (no practical gain over Q8 for inference) |

All quants are single-file (not sharded).

### Why Q8_0 on this machine

Apple **M5 Max, 128 GB unified memory, ~900 GB free disk**. Q8_0 (37 GB) leaves ample room for
the model + KV cache even at large context, matches the existing `Qwen3.6-35B-A3B-Q8` setup, and
gives the highest quality — which matters most for precision agentic coding. Because only ~3B
params are active, Q8 does not meaningfully slow generation versus a smaller quant.

### Measured performance (Q8_0, M5 Max, build b9835)

| Phase | Throughput |
|-------|-----------|
| Prompt eval | ~99 t/s |
| Generation | ~93 t/s |

Verified 2026-06-28 with `-fa on -c 8192 --jinja` (smoke test). The `<think>` reasoning block and
the qwen35moe arch loaded without warnings.

## Running it

Use the dedicated wrapper, which bakes in the recommended sampling and `--jinja`:

```bash
./run-ornith.sh chat                 # interactive REPL
./run-ornith.sh serve --ctx 65536    # OpenAI-compatible API on :8080, tool calling enabled
./run-ornith.sh ask "your prompt"    # one-shot
```

Raw equivalent:

```bash
./llama.cpp/build/bin/llama-cli -m ./models/Ornith-1.0-35B/ornith-1.0-35b-Q8_0.gguf \
  -ngl 99 -fa on -c 32768 --jinja --temp 0.6 --top-p 0.95 --top-k 20
```

### Tuning notes

- **Context:** default 32768. Raise with `--ctx` up to 262144. Thanks to the delta-net hybrid,
  KV growth with context is modest, but very large contexts still cost memory and prompt-eval time.
- **Flash attention:** `-fa on` by default (applies to the full-attention layers). Use `--fa auto`
  if a future build reports an FA incompatibility for this arch.
- **Tool calling (server):** `--jinja` makes llama-server expose the model's `<tool_call>` blocks
  as OpenAI `tool_calls`, so standard agent frameworks pointed at `http://127.0.0.1:8080/v1` work.

## Using it from the pi agent (`pi-ornith`)

A shell wrapper in `~/.zshrc` (alongside `pi5.5` / `pi-opus`) runs the **pi** coding agent
against this model, starting the server on demand:

```bash
pi-ornith "Refactor the auth module and add tests"   # starts server if needed, then runs pi
pi-ornith -p "Explain this stack trace ..."           # non-interactive
pi-ornith-stop                                         # stop the background server
```

How it is wired:

- **Dedicated port 8090** — Ornith's pi server runs on `:8090`, *not* the `run-ornith.sh` default
  `:8080`, because `:8080` is held by the AIHub Registry container. The wrapper starts
  `./run-ornith.sh serve --port 8090 --ctx 65536 -- --alias ornith-1.0-35b` in the background and
  waits until `/v1/models` reports the `ornith-1.0-35b` alias (an identity check, so it is never
  fooled by another service answering HTTP 200 on the port).
- **pi provider** — `~/.pi/agent/models.json` defines an `ornith` provider:
  `api: openai-completions`, `baseUrl: http://127.0.0.1:8090/v1`, model id `ornith-1.0-35b`.
  The wrapper calls `pi --provider ornith --model ornith-1.0-35b`.
- The server is left running after first use so later `pi-ornith` calls are instant; logs go to
  `~/.ornith-server.log`.

Verified 2026-06-28: `pi -p` round-trips correctly through the local server.

## Sources

- Collection: <https://huggingface.co/collections/deepreinforce-ai/ornith-10>
- Base card: <https://huggingface.co/deepreinforce-ai/Ornith-1.0-35B>
- GGUF: <https://huggingface.co/deepreinforce-ai/Ornith-1.0-35B-GGUF>
- Community GGUF: <https://huggingface.co/bartowski/deepreinforce-ai_Ornith-1.0-35B-GGUF>
