# Gemma 4 Model Family — Reference for llama.cpp

**Research date:** 2026-04-13
**Model release date:** 2026-04-02

---

## Overview

Gemma 4 is Google DeepMind's latest generation of open-weight models, released on April 2, 2026. It is a multimodal family supporting text, image, audio (small models), and video (large models), licensed under Apache 2.0. The family spans four variants from a ~2B effective-parameter edge model to a 31B dense server model.

Gemma 4 is confirmed supported in llama.cpp as of its launch date, with all four sizes having public GGUF builds available from multiple quantizers (Unsloth, Bartowski, and ggml-org).

---

## Model Variants

### Architecture Overview

Gemma 4 ships in two architectures:

- **Dense + PLE (Per-Layer Embeddings):** Used by E2B, E4B, and 31B. PLE gives each decoder layer its own small embedding per token — the tables are large but fast (lookup only), which is why effective parameter count is much smaller than raw count.
- **Mixture-of-Experts (MoE):** Used by 26B A4B. Only 4B of 25.2B parameters are active per forward pass, making it nearly as fast as a 4B model.

### Parameter Sizes Table

| Variant | Architecture | Total Params | Effective/Active | Layers | Context | Modalities | VRAM (4-bit) | VRAM (8-bit) | VRAM (BF16) |
|---|---|---|---|---|---|---|---|---|---|
| **E2B** | Dense + PLE | 5.1B (with embeddings) | 2.3B effective | 35 | 128K | Text, Image, Audio | ~4 GB | ~5–8 GB | ~10 GB |
| **E4B** | Dense + PLE | 8B (with embeddings) | 4.5B effective | 42 | 128K | Text, Image, Audio | ~5.5–6 GB | ~9–12 GB | ~16 GB |
| **26B A4B** | MoE | 25.2B total | 3.8B active | 30 | 256K | Text, Image | ~16–18 GB | ~28–30 GB | ~52 GB |
| **31B** | Dense | 30.7B | 30.7B | 60 | 256K | Text, Image | ~17–20 GB | ~34–38 GB | ~62 GB |

**Notes:**
- The "E" prefix (E2B, E4B) stands for "effective parameters."
- The "A" in 26B A4B stands for "active parameters."
- All variants share vocabulary size 262K and support 140+ languages.
- Audio support (E2B, E4B only): up to 30 seconds of input.
- Video support (26B, 31B only): up to 60 seconds at 1 frame per second.
- Both E2B and E4B use a 512-token sliding window; 26B uses 1024.

---

## Smallest Available Model

**The smallest Gemma 4 model is the E2B (Effective 2B).**

- 2.3 billion effective parameters
- 5.1B raw parameters (including Per-Layer Embeddings)
- Runs in approximately 4 GB RAM at 4-bit quantization
- Supports text, image, and audio input
- 128K token context window
- Designed for phones, edge devices, and low-memory laptops

---

## GGUF Availability on Hugging Face

### Unsloth (Primary recommended source)

Unsloth uses their **Dynamic GGUF 2.0** quantization method, which achieves state-of-the-art accuracy at each bit level. They also include the multimodal projector file (`mmproj-BF16.gguf`) needed for image inference.

| Model | Hugging Face Repository |
|---|---|
| Gemma 4 E2B (smallest) | `unsloth/gemma-4-E2B-it-GGUF` |
| Gemma 4 E4B | `unsloth/gemma-4-E4B-it-GGUF` |
| Gemma 4 26B A4B (MoE) | `unsloth/gemma-4-26B-A4B-it-GGUF` |
| Gemma 4 31B | `unsloth/gemma-4-31B-it-GGUF` |

**Important:** On April 11, 2026 all Unsloth Gemma 4 GGUFs were updated with Google's revised chat template and llama.cpp bug fixes. Re-download if you pulled before that date.

### Bartowski

Bartowski provides imatrix quantizations (built with llama.cpp release b8746). Available for 31B and E4B; check the hub for E2B.

| Model | Hugging Face Repository |
|---|---|
| Gemma 4 31B | `bartowski/google_gemma-4-31B-it-GGUF` |
| Gemma 4 E4B | `bartowski/google_gemma-4-E4B-it-GGUF` |

Bartowski's `*_L` variants (e.g., `Q4_K_L`, `Q6_K_L`) quantize the embedding and output weights to Q8_0 instead of the default, improving quality at a slight size cost.

### ggml-org (Official llama.cpp org)

The llama.cpp organization publishes official GGUFs for all four sizes:

| Model | Hugging Face Repository |
|---|---|
| Gemma 4 E2B | `ggml-org/gemma-4-E2B-it-GGUF` |
| Gemma 4 E4B | `ggml-org/gemma-4-E4B-it-GGUF` |
| Gemma 4 26B A4B | `ggml-org/gemma-4-26B-A4B-it-GGUF` |
| Gemma 4 31B | `ggml-org/gemma-4-31B-it-GGUF` |

---

## Quantization Levels and File Sizes

### Gemma 4 E2B (Smallest Model) — Unsloth

Full file listing from `unsloth/gemma-4-E2B-it-GGUF` (as of 2026-04-13):

| Filename | Quantization | File Size | Notes |
|---|---|---|---|
| `gemma-4-E2B-it-BF16.gguf` | BF16 | 9.31 GB | Full precision, highest quality |
| `gemma-4-E2B-it-Q8_0.gguf` | Q8_0 | 5.05 GB | Near-FP16 quality, recommended for E2B |
| `gemma-4-E2B-it-UD-Q8_K_XL.gguf` | UD-Q8_K_XL | 5.27 GB | Dynamic 2.0, high quality |
| `gemma-4-E2B-it-Q6_K.gguf` | Q6_K | 4.50 GB | Very high quality |
| `gemma-4-E2B-it-UD-Q6_K_XL.gguf` | UD-Q6_K_XL | 4.71 GB | Dynamic 2.0 version |
| `gemma-4-E2B-it-UD-Q5_K_XL.gguf` | UD-Q5_K_XL | 4.29 GB | Dynamic 2.0, good quality |
| `gemma-4-E2B-it-Q5_K_M.gguf` | Q5_K_M | 3.36 GB | High quality |
| `gemma-4-E2B-it-Q5_K_S.gguf` | Q5_K_S | 3.32 GB | High quality, slightly smaller |
| `gemma-4-E2B-it-UD-Q4_K_XL.gguf` | UD-Q4_K_XL | 3.17 GB | Dynamic 2.0, recommended for limited RAM |
| `gemma-4-E2B-it-Q4_K_M.gguf` | Q4_K_M | 3.11 GB | Good quality, standard 4-bit |
| `gemma-4-E2B-it-Q4_1.gguf` | Q4_1 | 3.15 GB | Better tokens/watt on Apple Silicon |
| `gemma-4-E2B-it-Q4_K_S.gguf` | Q4_K_S | 3.04 GB | Slightly lower quality, more compact |
| `gemma-4-E2B-it-Q4_0.gguf` | Q4_0 | 3.04 GB | Legacy format, ARM/AVX repacking |
| `gemma-4-E2B-it-IQ4_NL.gguf` | IQ4_NL | 3.04 GB | Good for ARM CPU inference |
| `gemma-4-E2B-it-IQ4_XS.gguf` | IQ4_XS | 2.98 GB | Smaller than Q4_K_S, similar quality |
| `gemma-4-E2B-it-UD-Q3_K_XL.gguf` | UD-Q3_K_XL | 2.92 GB | Dynamic 2.0, lower quality |
| `gemma-4-E2B-it-Q3_K_M.gguf` | Q3_K_M | 2.54 GB | Noticeable quality drop |
| `gemma-4-E2B-it-Q3_K_S.gguf` | Q3_K_S | 2.45 GB | Compact, quality compromised |
| `gemma-4-E2B-it-UD-Q2_K_XL.gguf` | UD-Q2_K_XL | 2.40 GB | Very low quality, last resort |
| `gemma-4-E2B-it-UD-IQ3_XXS.gguf` | UD-IQ3_XXS | 2.37 GB | Very low quality |
| `gemma-4-E2B-it-UD-IQ2_M.gguf` | UD-IQ2_M | 2.29 GB | Minimum viable, lowest quality |
| `mmproj-BF16.gguf` | BF16 projector | 987 MB | Required for image/multimodal inference |

**Recommendation for E2B:** Use `Q8_0` (5.05 GB) if you have 8+ GB available. Use `Q4_K_M` (3.11 GB) or `UD-Q4_K_XL` (3.17 GB) for systems with 4–6 GB available.

### Gemma 4 E4B — Bartowski (complete quantization table)

| Filename | Quantization | File Size | Notes |
|---|---|---|---|
| `google_gemma-4-E4B-it-bf16.gguf` | BF16 | 15.05 GB | Full precision |
| `google_gemma-4-E4B-it-Q8_0.gguf` | Q8_0 | 8.03 GB | Near-FP16 quality |
| `google_gemma-4-E4B-it-Q6_K_L.gguf` | Q6_K_L | 7.18 GB | Q8_0 embed/output, recommended |
| `google_gemma-4-E4B-it-Q5_K_L.gguf` | Q5_K_L | 6.67 GB | Q8_0 embed/output, recommended |
| `google_gemma-4-E4B-it-Q6_K.gguf` | Q6_K | 6.33 GB | Near perfect quality |
| `google_gemma-4-E4B-it-Q4_K_L.gguf` | Q4_K_L | 6.25 GB | Q8_0 embed/output, recommended |
| `google_gemma-4-E4B-it-Q3_K_XL.gguf` | Q3_K_XL | 5.88 GB | Q8_0 embed/output, low RAM option |
| `google_gemma-4-E4B-it-Q5_K_M.gguf` | Q5_K_M | 5.82 GB | High quality, recommended |
| `google_gemma-4-E4B-it-Q5_K_S.gguf` | Q5_K_S | 5.70 GB | High quality |
| `google_gemma-4-E4B-it-Q4_1.gguf` | Q4_1 | 5.46 GB | Better on Apple Silicon |
| `google_gemma-4-E4B-it-Q4_K_M.gguf` | Q4_K_M | 5.41 GB | Good quality, default choice |
| `google_gemma-4-E4B-it-Q2_K_L.gguf` | Q2_K_L | 5.30 GB | Q8_0 embed, usable minimum |
| `google_gemma-4-E4B-it-Q4_K_S.gguf` | Q4_K_S | 5.24 GB | More compact than Q4_K_M |
| `google_gemma-4-E4B-it-IQ4_NL.gguf` | IQ4_NL | 5.23 GB | Good for ARM |
| `google_gemma-4-E4B-it-Q4_0.gguf` | Q4_0 | 5.22 GB | Legacy, ARM/AVX repacking |
| `google_gemma-4-E4B-it-IQ4_XS.gguf` | IQ4_XS | 5.11 GB | Recommended compact option |

---

## Download Commands

### Recommended: Download Smallest Model (E2B, Q8_0) via huggingface-cli

```bash
# Install the CLI if not already installed
pip install huggingface_hub hf_transfer

# Download E2B Q8_0 — best quality for the smallest model (~5 GB)
huggingface-cli download unsloth/gemma-4-E2B-it-GGUF \
  --include "gemma-4-E2B-it-Q8_0.gguf" \
  --local-dir ./models/gemma-4-E2B

# Download E2B Q4_K_M — good balance of quality and size (~3 GB)
huggingface-cli download unsloth/gemma-4-E2B-it-GGUF \
  --include "gemma-4-E2B-it-Q4_K_M.gguf" \
  --local-dir ./models/gemma-4-E2B

# Download E2B with multimodal projector (for image inference)
huggingface-cli download unsloth/gemma-4-E2B-it-GGUF \
  --include "gemma-4-E2B-it-Q8_0.gguf" "mmproj-BF16.gguf" \
  --local-dir ./models/gemma-4-E2B
```

### Alternative: Direct download via llama-cli (no separate download step)

```bash
# llama.cpp can stream directly from Hugging Face
export LLAMA_CACHE="./models/gemma-4-E2B"

./llama-cli \
  -hf unsloth/gemma-4-E2B-it-GGUF:Q8_0 \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  -cnv
```

### Download via ggml-org (official llama.cpp org builds)

```bash
# E2B from official llama.cpp org
huggingface-cli download ggml-org/gemma-4-E2B-it-GGUF \
  --local-dir ./models/gemma-4-E2B-ggml
```

---

## Running in llama.cpp

### Basic Text Inference (llama-cli)

```bash
# E2B — interactive chat
./llama-cli \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  -cnv

# E4B — interactive chat
./llama-cli \
  -m ./models/gemma-4-E4B/gemma-4-E4B-it-Q8_0.gguf \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  -cnv
```

### OpenAI-Compatible Server (llama-server)

```bash
./llama-server \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64 \
  --port 8080
```

Test the server:

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Multimodal / Image Inference (llama-mtmd-cli)

```bash
# Requires both the model GGUF and the mmproj file
./llama-mtmd-cli \
  --model ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  --mmproj ./models/gemma-4-E2B/mmproj-BF16.gguf \
  --temp 1.0 \
  --top-p 0.95 \
  --top-k 64
```

### GPU Offload

```bash
# Offload all layers to GPU (CUDA or Metal)
./llama-cli \
  -m ./models/gemma-4-E2B/gemma-4-E2B-it-Q8_0.gguf \
  --n-gpu-layers 99 \
  --temp 1.0 --top-p 0.95 --top-k 64 \
  -cnv
```

---

## Chat Template and Special Tokens

### Template Format

Gemma 4 uses a new chat template different from earlier Gemma versions. The standard format is:

```
<bos><|turn>system
{system_prompt}<turn|>
<|turn>user
{prompt}<turn|>
<|turn>model
```

**Important differences from Gemma 3:**
- Gemma 4 uses standard `system`, `assistant`, and `user` roles (Gemma 3 did not have a native system role).
- llama.cpp and Transformers handle the template automatically — you generally do not need to format it manually.

### Special Tokens

| Token | Purpose |
|---|---|
| `<bos>` | Beginning of sequence |
| `<\|turn>` | Opening of a turn |
| `<turn\|>` | Closing of a turn |
| `<\|think\|>` | Enable thinking/reasoning mode (placed at start of system prompt) |
| `<\|channel>thought\n` | Opening of internal reasoning block (generated by model) |
| `<channel\|>` | Closing of internal reasoning block |
| `<turn\|>` | End-of-sentence token (EOS) |

### Thinking / Reasoning Mode

Gemma 4 has a built-in configurable reasoning mode:

**Enable thinking:** Add `<|think|>` at the very start of the system prompt.

**Disable thinking (llama-server):**
```bash
./llama-server \
  -m your-model.gguf \
  --chat-template-kwargs '{"enable_thinking":false}'

# Windows PowerShell:
--chat-template-kwargs "{\"enable_thinking\":false}"
```

**Behavior when thinking is enabled:**
- Model outputs internal reasoning before the final answer
- Format: `<|channel>thought\n[internal reasoning]<channel|>[final answer]`

**Multi-turn conversations:** In multi-turn chat, never include previous thought blocks in history — only keep the final visible answer from each prior model turn.

### Recommended Inference Parameters

These are Google's official recommended defaults:

| Parameter | Value | Notes |
|---|---|---|
| `--temp` | 1.0 | Official default |
| `--top-p` | 0.95 | Official default |
| `--top-k` | 64 | Official default |
| `--repeat-penalty` | 1.0 (disabled) | Only enable if you observe looping |
| Context length | Auto | llama.cpp sets this automatically |

**Practical recommendation:** Start with 32K context for responsiveness; increase only if your use case requires long documents.

---

## llama.cpp Compatibility Notes

### Support Status: Fully Supported

Gemma 4 has been supported in llama.cpp since day one (April 2, 2026). All four variants (E2B, E4B, 26B A4B, 31B) have public GGUF paths and confirmed working text inference.

### Known Fixes (apply if using builds from before April 11, 2026)

| PR | Date | Fix |
|---|---|---|
| PR #21326 | 2026-04-02 | Chat template / parser fix — prevented garbage output with `<unused25>` token spam |
| PR #21343 | 2026-04-03 | Tokenizer fix — corrected tokenizer behavior at model boundaries |

**Action:** Always use a llama.cpp build from April 11, 2026 or later to get both fixes and the updated chat template.

### Multimodal Status

- Text inference: **Fully stable**
- Image inference (via `llama-mtmd-cli` + `mmproj-BF16.gguf`): **Fully stable**
- Audio inference (E2B and E4B only): **In active development** as of April 2026; not yet considered stable in llama.cpp

### Hardware Support

| Platform | Status | Notes |
|---|---|---|
| NVIDIA CUDA | Fully supported | Build with `-DGGML_CUDA=ON`; do NOT use CUDA 13.2 runtime |
| Apple Silicon (Metal) | Fully supported | Metal enabled by default; build with `-DGGML_CUDA=OFF` |
| AMD ROCm | Supported via llama.cpp | Works with Radeon/Ryzen AI via Adrenalin drivers |
| CPU only | Fully supported | Slower but functional; AVX2/AVX-512 auto-detected |

**CUDA 13.2 warning:** Do NOT run Gemma 4 GGUFs with CUDA 13.2 runtime — it causes poor/incorrect model outputs. Use CUDA 12.x.

### Apple Silicon Quick Reference

| Hardware | Recommended Model | Quantization |
|---|---|---|
| Mac mini M4 (16 GB) | E4B | Q8_0, or 26B-A4B at Q4 |
| MacBook Pro M4 Pro (24 GB) | 26B-A4B | Q8_0 |
| Mac Studio / M4 Max (48–128 GB) | 31B | Q8_0 or BF16 |
| 8 GB unified memory | E2B | Q4_K_M or Q8_0 |

---

## Benchmark Highlights

| Benchmark | E2B | E4B | 26B A4B | 31B |
|---|---|---|---|---|
| MMLU Pro | 60.0% | 69.4% | 82.6% | 85.2% |
| AIME 2026 (no tools) | 37.5% | 42.5% | 88.3% | 89.2% |
| LiveCodeBench v6 | 44.0% | 52.0% | 77.1% | 80.0% |
| GPQA Diamond | 43.4% | 58.6% | 82.3% | 84.3% |
| MMMU Pro (vision) | 44.2% | 52.6% | 73.8% | 76.9% |

The 31B model ranks #3 among all open models on the Arena AI text leaderboard; the 26B A4B ranks #6.

---

## Assumptions & Scope

| Assumption | Confidence | Impact if Wrong |
|---|---|---|
| File sizes for E2B are from the unsloth HF tree page (scraped directly) | HIGH | Sizes may vary slightly for re-uploads |
| Audio inference in llama.cpp is not stable as of April 2026 | HIGH | Based on multiple independent sources noting "in active development" |
| CUDA 13.2 incompatibility applies to all Gemma 4 GGUFs, not just specific quantizations | MEDIUM | Could be limited to specific quant types; test before assuming |
| Bartowski has not yet published E2B GGUF (only E4B and 31B confirmed) | MEDIUM | May have published after research date; check HF hub |
| PR numbers (#21326, #21343) are in `ggml-org/llama.cpp`, not `ggerganov/llama.cpp` | HIGH | The repo was renamed; both URLs should resolve |

**Explicitly excluded from this research:**
- Gemma 4 pre-trained (non-instruct) variants
- Fine-tuning workflows
- Ollama, vLLM, or LM Studio setup (llama.cpp focus only)
- Gemma 3 or Gemma 3n (superseded by Gemma 4 for this use case)

---

## References

| # | Source | URL | Information Gathered |
|---|---|---|---|
| 1 | Google Blog — Gemma 4 launch | https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/ | Release date, model family overview |
| 2 | Google DeepMind — Gemma 4 | https://deepmind.google/models/gemma/gemma-4/ | Architecture details, capability claims |
| 3 | Google AI Developers — Gemma 4 docs | https://ai.google.dev/gemma/docs/core | Official API documentation |
| 4 | Hugging Face Blog — Gemma 4 | https://huggingface.co/blog/gemma4 | Hugging Face integration details |
| 5 | Unsloth HF — gemma-4-E2B-it-GGUF | https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF | E2B quantization options, file sizes, chat template, best practices |
| 6 | Unsloth HF tree — gemma-4-E2B-it-GGUF | https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/tree/main | Exact file names and sizes for all E2B quantizations |
| 7 | Unsloth HF — gemma-4-E4B-it-GGUF | https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF | E4B GGUF availability |
| 8 | Unsloth HF — gemma-4-26B-A4B-it-GGUF | https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF | MoE model GGUF |
| 9 | Unsloth HF — gemma-4-31B-it-GGUF | https://huggingface.co/unsloth/gemma-4-31B-it-GGUF | 31B GGUF availability |
| 10 | Unsloth Docs — Gemma 4 guide | https://unsloth.ai/docs/models/gemma-4 | Inference parameters, thinking mode, hardware requirements |
| 11 | Bartowski HF — google_gemma-4-E4B-it-GGUF | https://huggingface.co/bartowski/google_gemma-4-E4B-it-GGUF | Full E4B quantization table with file sizes, chat template |
| 12 | Bartowski HF — google_gemma-4-31B-it-GGUF | https://huggingface.co/bartowski/google_gemma-4-31B-it-GGUF | 31B Bartowski GGUF availability |
| 13 | ggml-org HF — gemma-4-E2B-it-GGUF | https://huggingface.co/ggml-org/gemma-4-E2B-it-GGUF | Official llama.cpp org GGUF for E2B |
| 14 | avenchat.com — Run Gemma 4 with llama.cpp | https://avenchat.com/blog/run-gemma-4-with-llama-cpp | Build instructions, download commands, inference commands, hardware tables |
| 15 | avenchat.com — llama.cpp Gemma 4 support | https://avenchat.com/blog/does-llama-cpp-support-gemma-4 | PR fix details, support status, FAQ |
| 16 | Google Developers Blog — Gemma 3n | https://developers.googleblog.com/en/introducing-gemma-3n-developer-guide/ | Context on predecessor Gemma 3n (for comparison) |
| 17 | AMD — Day 0 Gemma 4 support | https://www.amd.com/en/developer/resources/technical-articles/2026/day-0-support-for-gemma-4-on-amd-processors-and-gpus.html | AMD hardware support confirmation |
