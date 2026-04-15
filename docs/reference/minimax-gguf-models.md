# MiniMax Models: GGUF Availability and llama.cpp Support

**Research Date:** 2026-04-13  
**Target Hardware:** Apple M4 Max, 128 GB unified RAM

---

## Overview

MiniMax has released multiple generations of large language models since 2024. This document covers the full
family tree from MiniMax-Text-01 through MiniMax-M2.7, with a focus on GGUF availability, file sizes for
every quantization level, llama.cpp compatibility status, and hardware recommendations for an Apple M4 Max
with 128 GB unified RAM.

---

## 1. MiniMax Model Family Tree

### 1.1 MiniMax-Text-01 / MiniMax-01 Series (January 2025)

**HuggingFace:** [MiniMaxAI/MiniMax-Text-01](https://huggingface.co/MiniMaxAI/MiniMax-Text-01)  
**Paper:** [arXiv:2501.08313](https://arxiv.org/abs/2501.08313)  
**GitHub:** [MiniMax-AI/MiniMax-01](https://github.com/MiniMax-AI/MiniMax-01)

| Property | Value |
|---|---|
| Architecture | Hybrid: Lightning Attention (linear) + SoftMax Attention + MoE |
| Total Parameters | 456 B |
| Active Parameters / Token | 45.9 B |
| Number of Experts | 32 |
| Attention Ratio | 7 Lightning layers : 1 SoftMax layer per 8-layer block |
| Context Window | Up to 4 million tokens (training: 1 M) |
| GGUF Available | No (no official release; community WIP branch only) |
| llama.cpp Support | Not supported — `MiniMaxText01ForCausalLM` not recognized |

**Key innovation:** First commercial-grade deployment of linear (Lightning) attention. The Lightning Attention
mechanism splits attention into intra-block and inter-block computations to maintain linear complexity, enabling
the unprecedented 4 M token context window.

**GGUF status:** A community member created a work-in-progress llama.cpp fork at
`https://github.com/fairydreaming/llama.cpp/tree/minimax-text-01` but it never merged into main and the model
was never officially quantized. Conversion using `convert_hf_to_gguf.py` fails with an unsupported architecture
error.

---

### 1.2 MiniMax-M1 (June 2025)

**HuggingFace:** [MiniMaxAI/MiniMax-M1-80k](https://huggingface.co/MiniMaxAI/MiniMax-M1-80k)  
**Paper:** [arXiv:2506.13585](https://arxiv.org/abs/2506.13585)  
**GitHub:** [MiniMax-AI/MiniMax-M1](https://github.com/MiniMax-AI/MiniMax-M1)

| Property | Value |
|---|---|
| Architecture | Hybrid: Lightning Attention + SoftMax Attention + MoE (reasoning model) |
| Total Parameters | 456 B |
| Active Parameters / Token | 45.9 B |
| Number of Experts | 32 |
| Context Window (input) | 1 million tokens |
| Output Context | 80,000 tokens |
| GGUF Available | No |
| llama.cpp Support | Not supported — `MiniMaxM1ForCausalLM` not recognized |

**Key innovation:** Described as the world's first open-weight, large-scale hybrid-attention *reasoning* model.
Extends MiniMax-Text-01 with test-time compute scaling. At 100K generation length it uses only 25% of the
FLOPs of DeepSeek R1.

**GGUF status:** Users reported that `convert_hf_to_gguf.py` throws `ERROR:hf-to-gguf:Model
MiniMaxM1ForCausalLM is not supported`. No GGUF weights have been published. As of April 2026, the model
remains outside the scope of llama.cpp's main branch. Community requests are open but unresolved.

---

### 1.3 MiniMax-M2 (October 2025)

**HuggingFace:** [MiniMaxAI/MiniMax-M2](https://huggingface.co/MiniMaxAI/MiniMax-M2)  
**GitHub:** [MiniMax-AI/MiniMax-M2](https://github.com/MiniMax-AI/MiniMax-M2)

| Property | Value |
|---|---|
| Architecture | Sparse MoE Transformer |
| Total Parameters | 230 B |
| Active Parameters / Token | 10 B |
| Total Experts | 256 |
| Experts Activated / Token | 8 |
| Layers | 62 |
| Hidden Size | 3,072 |
| Attention | Multi-head + RoPE + QK RMSNorm |
| Context Window | 128,000 tokens |
| BF16 Unquantized Size | ~230 GB |
| GGUF Available | Yes (bartowski, unsloth) |
| llama.cpp Support | Yes — merged via PR #16831 |

**Key shift:** MiniMax switched from the Lightning Attention / hybrid architecture used in M1 to a pure
standard sparse MoE transformer architecture. This made llama.cpp support achievable. The much higher
sparsity (10 B active out of 230 B total) means the active compute footprint resembles a ~10 B dense model
while the knowledge capacity is that of a ~230 B model.

---

### 1.4 MiniMax-M2.1 (December 2025)

**HuggingFace:** [MiniMaxAI/MiniMax-M2.1](https://huggingface.co/MiniMaxAI/MiniMax-M2.1)

| Property | Value |
|---|---|
| Architecture | Same as M2 (sparse MoE) |
| Total Parameters | 230 B |
| Active Parameters / Token | 10 B |
| Context Window | 128,000 tokens |
| GGUF Available | Yes (bartowski, unsloth, AaryanK) |
| llama.cpp Support | Yes |

Incremental improvement over M2. Bartowski quantized using llama.cpp release b7545. A pre-tokenizer hash fix
for M2.1 was merged into llama.cpp via PR #18399.

---

### 1.5 MiniMax-M2.5 (March 2026)

**HuggingFace:** [MiniMaxAI/MiniMax-M2.5](https://huggingface.co/MiniMaxAI/MiniMax-M2.5)

| Property | Value |
|---|---|
| Architecture | Sparse MoE Transformer (same as M2) |
| Total Parameters | 230 B |
| Active Parameters / Token | 10 B |
| Context Window | 200,000 tokens (extended from M2/M2.1) |
| BF16 Unquantized Size | 457 GB |
| GGUF Available | Yes (unsloth, AesSedai) |
| llama.cpp Support | Yes |

Notable benchmark scores: SWE-Bench Verified 80.2%, Multi-SWE-Bench 51.3%, BrowseComp 76.3%.
Introduces parallel tool calling and 37% faster task completion vs M2.1.

---

### 1.6 MiniMax-M2.7 (April 2026)

**HuggingFace:** [MiniMaxAI/MiniMax-M2.7](https://huggingface.co/MiniMaxAI/MiniMax-M2.7)  
**Blog:** [MiniMax M2.7 announcement](https://www.minimax.io/news/minimax-m27-en)

| Property | Value |
|---|---|
| Architecture | Sparse MoE Transformer (same as M2) |
| Total Parameters | 230 B |
| Active Parameters / Token | 10 B |
| Context Window | 200,000 tokens (196,608 max in GGUF) |
| BF16 Unquantized Size | 457 GB |
| GGUF Available | Yes (bartowski, unsloth) |
| llama.cpp Support | Yes |

Notable benchmark scores: SWE-Pro 56.22% (matching GPT-5.3-Codex), Terminal Bench 2 57.0%, MLE Bench Lite
66.6% medal rate. First model to participate in its own training evolution (self-evolution loop).

---

## 2. Architecture Deep Dive: The M2 Series MoE

All M2.x models share a core architecture distinct from the M1/Text-01 series:

```
MoE Configuration:
  - Total parameters:       230 B
  - Active per forward:      10 B  (~4.3% of total)
  - Expert pool:            256 local experts
  - Experts activated:        8 per token (top-k routing)
  - Layers:                  62
  - Hidden dimension:     3,072
  - Attention:    Multi-head causal with RoPE + QK RMSNorm
  - Activation:   SwiGLU (standard for modern MoE)
```

The sparsity design has a critical practical consequence for local inference: when loading a GGUF and
generating tokens, only the 8 active experts need their weights accessed per token, not all 256. This
significantly reduces the effective memory bandwidth required per token compared to a dense 230 B model,
which partially explains why MoE models at this scale are viable on consumer hardware.

---

## 3. GGUF Availability by Provider

### 3.1 Bartowski

Bartowski uses llama.cpp imatrix quantization (calibrated importance matrix for better quality). All
quantizations are split into multiple files for models over 50 GB.

**Download tool:**
```bash
pip install -U "huggingface_hub[cli]"
huggingface-cli download bartowski/MiniMaxAI_MiniMax-M2.7-GGUF \
  --include "MiniMaxAI_MiniMax-M2.7-Q4_K_M.gguf" \
  --local-dir ./
# For split models (>50 GB), download the whole folder:
huggingface-cli download bartowski/MiniMaxAI_MiniMax-M2.7-GGUF \
  --include "MiniMaxAI_MiniMax-M2.7-Q4_K_M/*" \
  --local-dir ./
```

#### MiniMax-M2 — Bartowski GGUF Sizes
**Repo:** [bartowski/MiniMaxAI_MiniMax-M2-GGUF](https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2-GGUF)  
**Built with:** llama.cpp b6907

| Quantization | File Size | Quality | Notes |
|---|---|---|---|
| Q8_0 | 243.14 GB | Extremely high | Near lossless |
| Q6_K | 187.81 GB | Very high | Near perfect |
| Q5_K_M | 162.38 GB | High | Recommended |
| Q5_K_S | 157.55 GB | High | Recommended |
| Q4_1 | 143.31 GB | Good | Legacy; better tokens/watt on Apple Silicon |
| Q4_K_M | 138.59 GB | Good | Default for most use cases |
| Q4_K_S | 133.75 GB | Good | Space savings |
| Q4_0 | 131.34 GB | Good | Legacy; ARM online repacking |
| IQ4_NL | 129.24 GB | Decent | ARM repacking support |
| IQ4_XS | 122.17 GB | Decent | Smaller than Q4_K_S, similar quality |
| Q3_K_XL | 108.74 GB | Lower | Q8_0 embed+output weights |
| Q3_K_L | 108.21 GB | Lower | Usable |
| Q3_K_M | 103.96 GB | Low | |
| IQ3_M | 103.95 GB | Medium-low | |
| Q3_K_S | 99.12 GB | Low | Not recommended |
| IQ3_XS | 93.76 GB | Lower | |
| IQ3_XXS | 90.10 GB | Lower | |
| Q2_K_L | 80.42 GB | Very low | Q8_0 embed+output weights |
| Q2_K | 79.82 GB | Very low | Surprisingly usable |
| IQ2_M | 72.00 GB | Low | |
| IQ2_S | 63.35 GB | Low | |
| IQ2_XS | 63.14 GB | Low | |
| IQ2_XXS | 54.73 GB | Very low | |
| IQ1_M | 49.02 GB | Extremely low | Not recommended |
| IQ1_S | 47.01 GB | Extremely low | Not recommended |

#### MiniMax-M2.1 — Bartowski GGUF Sizes
**Repo:** [bartowski/MiniMaxAI_MiniMax-M2.1-GGUF](https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2.1-GGUF)  
**Built with:** llama.cpp b7545

Sizes are identical to M2 at every quantization level because the architecture and parameter count did not change:

| Quantization | File Size | Notes |
|---|---|---|
| Q8_0 | 243.14 GB | |
| Q6_K | 187.81 GB | |
| Q5_K_M | 162.38 GB | |
| Q5_K_S | 157.55 GB | |
| Q4_1 | 143.31 GB | |
| Q4_K_L | 139.04 GB | Q8_0 embed+output weights |
| Q4_K_M | 138.59 GB | Default recommended |
| Q4_K_S | 133.75 GB | |
| Q4_0 | 131.34 GB | |
| IQ4_NL | 129.24 GB | |
| IQ4_XS | 122.17 GB | |
| Q3_K_XL | 108.74 GB | |
| Q3_K_L | 108.21 GB | |
| Q3_K_M | 103.96 GB | |
| IQ3_M | 103.95 GB | |
| Q3_K_S | 99.12 GB | |
| IQ3_XS | 93.76 GB | |
| IQ3_XXS | 90.10 GB | |
| Q2_K_L | 80.42 GB | |
| Q2_K | 79.82 GB | |
| IQ2_M | 72.00 GB | |
| IQ2_S | 63.35 GB | |
| IQ2_XS | 63.14 GB | |
| IQ2_XXS | 54.73 GB | |
| IQ1_M | 49.02 GB | Not recommended |
| IQ1_S | 47.01 GB | Not recommended |

#### MiniMax-M2.7 — Bartowski GGUF Sizes
**Repo:** [bartowski/MiniMaxAI_MiniMax-M2.7-GGUF](https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2.7-GGUF)  
**Built with:** llama.cpp b8746

| Quantization | File Size | Quality | Notes |
|---|---|---|---|
| Q8_0 | 243.14 GB | Extremely high | |
| Q6_K | 197.05 GB | Very high | (slightly larger than M2/M2.1) |
| Q5_K_M | 162.67 GB | High | |
| Q5_K_S | 157.70 GB | High | |
| Q4_1 | 143.51 GB | Good | Better tokens/watt on Apple Silicon |
| Q4_K_L | 139.26 GB | Good | Q8_0 embed+output |
| Q4_K_M | 138.81 GB | Good | Default recommended |
| Q4_K_S | 133.85 GB | Good | |
| Q4_0 | 129.84 GB | Good | ARM repacking |
| IQ4_NL | 129.46 GB | Decent | |
| IQ4_XS | 122.40 GB | Decent | |
| Q3_K_XL | 109.04 GB | Lower | Q8_0 embed+output |
| IQ3_M | 108.80 GB | Medium-low | |
| Q3_K_L | 108.50 GB | Lower | |
| Q3_K_M | 104.13 GB | Low | |
| IQ3_XS | 104.13 GB | Lower | |
| Q3_K_S | 99.31 GB | Low | |
| IQ3_XXS | 95.18 GB | Lower | |
| Q2_K_L | 80.65 GB | Very low | Q8_0 embed+output |
| Q2_K | 80.05 GB | Very low | |
| IQ2_M | 76.42 GB | Low | |
| IQ2_S | 69.13 GB | Low | |
| IQ2_XS | 67.87 GB | Low | |
| IQ2_XXS | 60.85 GB | Very low | |
| IQ1_M | 52.20 GB | Extremely low | Not recommended |
| IQ1_S | 46.67 GB | Extremely low | Not recommended |

---

### 3.2 Unsloth

Unsloth uses their proprietary "Dynamic 2.0" GGUF approach. The key distinction from standard quants is that
critical layers (typically embedding, output projection, and the most sensitive MoE layers) are upcasted to
Q8_0 or even BF16/F16, while the bulk of weights use the stated quantization bit-depth. This yields
measurably better accuracy at the same stated bit-depth and usually results in files 5–10 GB smaller than
standard equivalents.

Quantization names prefixed with `UD-` are Dynamic 2.0 quants. Unsloth also provides `MXFP4_MOE`, a new
format specifically designed for MoE models that quantizes experts to MXFP4 while keeping other weights at
higher precision.

**Download tool:**
```bash
pip install huggingface_hub hf_transfer
hf download unsloth/MiniMax-M2.7-GGUF \
    --local-dir unsloth/MiniMax-M2.7-GGUF \
    --include "*UD-IQ4_XS*"
```

#### MiniMax-M2.5 — Unsloth GGUF Key Sizes
**Repo:** [unsloth/MiniMax-M2.5-GGUF](https://huggingface.co/unsloth/MiniMax-M2.5-GGUF)

| Quantization | File Size | Notes |
|---|---|---|
| BF16 (reference) | 457 GB | Unquantized base |
| Q8_0 | 243 GB | Near full precision |
| UD-Q4_K_XL | 131 GB | Best accuracy/size tradeoff (only -6.0 points vs original) |
| UD-Q3_K_XL | 101 GB | Recommended by Unsloth; fits 128 GB Mac (~20+ tok/s) |
| UD-IQ2_XXS | ~80 GB | Fits 96 GB device |

Unsloth recommends **UD-Q3_K_XL** for M2.5 as the best balance of quality and size for 128 GB systems.

#### MiniMax-M2.7 — Unsloth GGUF Key Sizes
**Repo:** [unsloth/MiniMax-M2.7-GGUF](https://huggingface.co/unsloth/MiniMax-M2.7-GGUF)

| Quantization | File Size | Notes |
|---|---|---|
| BF16 (reference) | 457 GB | Unquantized base |
| Q8_0 | 243 GB | Near full precision; requires 256 GB RAM |
| UD-Q4_K_XL | 141 GB | Higher quality but exceeds 128 GB RAM alone |
| UD-IQ4_XS | 108 GB | **Primary recommendation for 128 GB Mac** (~15+ tok/s) |
| UD-Q3_K_XL | ~101 GB | 3-bit dynamic; fits 128 GB comfortably |
| UD-IQ2_XXS | ~80 GB | Fits 96 GB device |

Unsloth explicitly states that `UD-IQ4_XS` at **108 GB** "fits nicely on a 128 GB unified memory Mac for
~15+ tokens/s."

Note: A NaN PPL error was reported in the `UD-Q4_K_XL` quant for M2.7 (discussed in HuggingFace issue #5).
Use `UD-IQ4_XS` or the bartowski `Q4_K_M` as safer alternatives until this is resolved.

---

### 3.3 Other Community Providers

| Repo | Model | Status |
|---|---|---|
| [AaryanK/MiniMax-M2.1-GGUF](https://huggingface.co/AaryanK/MiniMax-M2.1-GGUF) | M2.1 | Community quant |
| [AesSedai/MiniMax-M2.5-GGUF](https://huggingface.co/AesSedai/MiniMax-M2.5-GGUF) | M2.5 | Community quant |
| [cturan/MiniMax-M2-GGUF](https://huggingface.co/cturan/MiniMax-M2-GGUF) | M2 | Community quant |

Prefer bartowski or unsloth for reliability and imatrix calibration quality.

---

## 4. llama.cpp Support Status Summary

| Model | Architecture ID | llama.cpp Support | GGUF on HuggingFace |
|---|---|---|---|
| MiniMax-Text-01 | MiniMaxText01ForCausalLM | No (unsupported) | No |
| MiniMax-VL-01 | (multimodal variant of Text-01) | No | No |
| MiniMax-M1 | MiniMaxM1ForCausalLM | No (unsupported) | No |
| MiniMax-M2 | minimax_m2 | Yes (PR #16831) | Yes |
| MiniMax-M2.1 | minimax_m2 | Yes (PR #18399 fix) | Yes |
| MiniMax-M2.5 | minimax_m2 | Yes | Yes |
| MiniMax-M2.7 | minimax_m2 | Yes | Yes |

The `minimax_m2` architecture identifier covers all M2.x variants. The M1/Text-01 series uses a fundamentally
different architecture (`MiniMaxM1ForCausalLM` / `MiniMaxText01ForCausalLM`) that relies on the Lightning
Attention mechanism, which has not been implemented in llama.cpp's main branch.

---

## 5. Memory Requirements for Apple M4 Max (128 GB)

On Apple Silicon, unified memory is shared between system RAM and GPU (Metal) compute. llama.cpp uses Metal
by default when compiled for macOS. The rule of thumb is: the model file must fit within available RAM,
leaving headroom for the KV cache, OS, and other processes.

Practical available RAM for model loading on a 128 GB M4 Max: approximately **110–118 GB** (allowing ~10–18 GB
for OS, KV cache, and overhead at short context lengths).

### Fits Comfortably in 128 GB RAM

These quantizations leave enough headroom for reasonable context lengths:

| Model | Quantization | File Size | Expected Speed (llama.cpp) | Recommendation |
|---|---|---|---|---|
| M2.7 (Unsloth) | UD-IQ4_XS | 108 GB | ~15 tok/s | **Primary recommendation** |
| M2.5 (Unsloth) | UD-Q3_K_XL | 101 GB | ~20 tok/s | Slightly faster, older model |
| M2.7 (Bartowski) | Q3_K_XL | 109 GB | ~12–15 tok/s | Good fallback |
| M2.7 (Bartowski) | IQ3_M | 108.80 GB | ~12–15 tok/s | Good fallback |
| M2.7 (Bartowski) | Q3_K_L | 108.50 GB | ~12–15 tok/s | Good fallback |
| M2.7 (Bartowski) | Q3_K_M | 104.13 GB | ~15 tok/s | Lower quality |
| M2.1 (Bartowski) | Q3_K_XL | 108.74 GB | ~12–15 tok/s | Older model |

### Tight Fit / Possible at 128 GB (Limited Context)

These models will load but leave minimal headroom. Large context windows will require offloading to SSD,
which will significantly reduce generation speed:

| Model | Quantization | File Size | Notes |
|---|---|---|---|
| M2.7 (Unsloth) | UD-Q4_K_XL | 141 GB | Exceeds RAM; SSD offload required |
| M2.7 (Bartowski) | Q4_K_M | 138.81 GB | Exceeds RAM; SSD offload required |
| M2.7 (Bartowski) | IQ4_XS | 122.40 GB | Tight; ~5–6 GB headroom only |
| M2.7 (Bartowski) | IQ4_NL | 129.46 GB | Exceeds practical limit |
| M2.7 (Bartowski) | Q4_0 | 129.84 GB | Exceeds practical limit |

### Do Not Attempt at 128 GB Without SSD Offload

| Quantization | File Size |
|---|---|
| Q5_K_S | 157.70 GB |
| Q5_K_M | 162.67 GB |
| Q6_K | 197.05 GB |
| Q8_0 | 243.14 GB |
| BF16 | 457 GB |

### Memory Bandwidth Note

The M4 Max has approximately 546 GB/s of unified memory bandwidth. Because MoE inference activates only
10 B parameters per forward pass (out of 230 B total), the effective bandwidth utilization per generated
token is proportionally lower than a dense 230 B model — it more closely resembles a 10 B dense model in
terms of memory bandwidth consumption per token. This is why the ~15–20 tok/s estimates from Unsloth are
achievable despite the large total model size.

For context size: with a context of 16,384 tokens, the KV cache for the M2.7 model is manageable (a few
GB). At the maximum 196,608 context, the KV cache grows substantially and will compete with model weights
for RAM. Keep context to 16K–32K for comfortable operation on 128 GB RAM.

---

## 6. Performance Estimates on Apple M4 Max (128 GB)

These figures are based on community benchmarks, Unsloth documentation, and comparisons with similar MoE
models on Apple Silicon. They are estimates, not measured benchmarks on this specific hardware.

| Quantization | Model Size | Generation Speed | Notes |
|---|---|---|---|
| UD-IQ4_XS (108 GB) | M2.7 | ~15 tok/s | Unsloth documented estimate for 128 GB Mac |
| UD-Q3_K_XL (101 GB) | M2.5 | ~20 tok/s | Unsloth documented estimate for 128 GB Mac |
| Q4_K_M (138.81 GB) | M2.7 | ~8–12 tok/s | With SSD offload; significantly slower |
| IQ4_XS (122.40 GB) | M2.7 | ~12–13 tok/s | Very tight RAM fit |

Note: MLX (Apple's native ML framework) is 20–87% faster than llama.cpp for generation on Apple Silicon.
If speed is the primary concern, consider using the MLX version of these models instead of GGUF/llama.cpp.
LM Studio supports both MLX and llama.cpp backends.

---

## 7. Recommended Configuration for Apple M4 Max (128 GB)

### Primary Recommendation: MiniMax-M2.7 (Unsloth UD-IQ4_XS)

This is the highest-capability model that fits reliably on 128 GB RAM.

```bash
# Install llama.cpp with Metal support
git clone https://github.com/ggml-org/llama.cpp
cmake llama.cpp -B llama.cpp/build \
    -DBUILD_SHARED_LIBS=OFF \
    -DGGML_CUDA=OFF
cmake --build llama.cpp/build --config Release -j \
    --target llama-cli llama-server

# Download the model
pip install huggingface_hub hf_transfer
hf download unsloth/MiniMax-M2.7-GGUF \
    --local-dir ./MiniMax-M2.7-GGUF \
    --include "*UD-IQ4_XS*"

# Run inference (keep ctx-size conservative to preserve RAM headroom)
./llama.cpp/build/bin/llama-cli \
    --model ./MiniMax-M2.7-GGUF/UD-IQ4_XS/MiniMax-M2.7-UD-IQ4_XS-00001-of-00004.gguf \
    --ctx-size 16384 \
    --flash-attn on \
    --temp 1.0 \
    --top-p 0.95 \
    --min-p 0.01 \
    --top-k 40 \
    --threads 16
```

Recommended inference parameters (per MiniMax):
- `temperature = 1.0`
- `top_p = 0.95`
- `top_k = 40`
- Default system prompt: `You are a helpful assistant. Your name is MiniMax-M2.7 and is built by MiniMax.`

### Alternative: MiniMax-M2.5 (Unsloth UD-Q3_K_XL)

If slightly faster generation is preferred and the M2.5 benchmark scores are sufficient, this fits more
comfortably in 128 GB with ~27 GB headroom, enabling longer context windows.

```bash
hf download unsloth/MiniMax-M2.5-GGUF \
    --local-dir ./MiniMax-M2.5-GGUF \
    --include "*UD-Q3_K_XL*"
```

### Alternative: MiniMax-M2.7 Bartowski Q3_K_XL or IQ3_M

For those who prefer standard imatrix quantizations without the Unsloth Dynamic 2.0 layer:

```bash
huggingface-cli download bartowski/MiniMaxAI_MiniMax-M2.7-GGUF \
    --include "MiniMaxAI_MiniMax-M2.7-Q3_K_XL/*" \
    --local-dir ./
```

### Avoid at 128 GB

- Q4_K_M and above (138+ GB) — will require SSD offloading which kills generation speed
- Q8_0 (243 GB) — requires 256 GB system
- UD-Q4_K_XL (141 GB) — too large AND has a known NaN/PPL issue in M2.7 release

---

## 8. Quantization Method Reference

| Prefix | Method | Characteristics |
|---|---|---|
| Q2_K | Standard 2-bit K-quant | Very low quality, small size |
| Q3_K_S/M/L/XL | Standard 3-bit K-quant | Low-medium quality; XL uses Q8_0 for embed/output |
| Q4_K_S/M/L | Standard 4-bit K-quant | Good quality; M is default recommendation |
| Q4_0 / Q4_1 | Legacy 4-bit | ARM/AVX online repacking; Q4_1 better on Apple Silicon |
| Q5_K_S/M | Standard 5-bit K-quant | High quality |
| Q6_K | Standard 6-bit K-quant | Near-perfect quality |
| Q8_0 | Standard 8-bit | Essentially lossless |
| IQ2/IQ3/IQ4 | Importance-aware quant | Uses imatrix for better weight selection; generally better than K-quants at same bit-depth |
| UD-* | Unsloth Dynamic 2.0 | Per-layer mixed precision; critical layers at Q8_0/BF16; best accuracy at stated bit-depth |
| MXFP4_MOE | Unsloth MoE-specific | MXFP4 for expert weights; experimental |

---

## 9. Known Issues and Caveats

1. **Do not use CUDA 13.2** for any GGUF model — reported to cause garbled/gibberish output. NVIDIA is
   working on a fix. This does not affect Apple Silicon (Metal) users.

2. **UD-Q4_K_XL for M2.7 has a known NaN error** in PPL measurement. Use `UD-IQ4_XS` instead.
   Source: [unsloth/MiniMax-M2.7-GGUF discussion #5](https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/discussions/5)

3. **All M2.x models are split files**. Quants above ~50 GB are stored as multi-part GGUF files.
   llama.cpp handles these automatically when you specify the first part (e.g., `-00001-of-00004.gguf`).

4. **Context window vs. RAM**: The 128 GB system can handle `--ctx-size` up to approximately 32,768 tokens
   with M2.7 UD-IQ4_XS before KV cache pressure becomes a concern. The model's maximum supported context
   is 196,608 tokens.

5. **MiniMax-Text-01 and MiniMax-M1 are NOT supported** in llama.cpp as of April 2026. Their Lightning
   Attention architecture has not been implemented. Running these models locally requires vLLM or SGLang
   on multi-GPU Linux hardware.

---

## Assumptions & Scope

| Assumption | Confidence | Impact if Wrong |
|---|---|---|
| M4 Max bandwidth ~546 GB/s | HIGH | Speed estimates would shift proportionally |
| ~10–18 GB OS + overhead on 128 GB Mac | MEDIUM | Lower overhead = more headroom for larger quants |
| UD-IQ4_XS token speed of ~15 tok/s | MEDIUM | Unsloth's estimate; real speed depends on llama.cpp build version and context length |
| M2.7 and M2.5 share the same base architecture | HIGH | Confirmed by Unsloth documentation |
| MiniMax-M1 support has not been added to llama.cpp main | HIGH | Verified from GitHub issues and conversion errors |
| UD-Q4_K_XL NaN issue is M2.7-specific | MEDIUM | May also affect M2.5; not confirmed |

### Out of Scope
- MLX quantization formats (a separate ecosystem; generally faster on Apple Silicon)
- vLLM / SGLang deployment (Linux/GPU-oriented)
- Fine-tuning or training configurations
- MiniMax-VL-01 (vision-language multimodal variant)
- MiniMax API pricing or cloud deployment

---

## References

| Source | URL | Information Gathered |
|---|---|---|
| Unsloth MiniMax-M2.7 Guide | https://unsloth.ai/docs/models/minimax-m27 | File sizes, RAM requirements, speed estimates, run commands |
| Unsloth MiniMax-M2.5 Guide | https://unsloth.ai/docs/models/tutorials/minimax-m25 | File sizes, quantization recommendations |
| unsloth/MiniMax-M2.7-GGUF | https://huggingface.co/unsloth/MiniMax-M2.7-GGUF | Model card, quantization types |
| unsloth/MiniMax-M2.5-GGUF | https://huggingface.co/unsloth/MiniMax-M2.5-GGUF | Architecture details, benchmark scores |
| bartowski/MiniMaxAI_MiniMax-M2-GGUF | https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2-GGUF | Complete quantization file size table |
| bartowski/MiniMaxAI_MiniMax-M2.1-GGUF | https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2.1-GGUF | Complete quantization file size table |
| bartowski/MiniMaxAI_MiniMax-M2.7-GGUF | https://huggingface.co/bartowski/MiniMaxAI_MiniMax-M2.7-GGUF | Complete quantization file size table |
| MiniMax-M2 GitHub | https://github.com/MiniMax-AI/MiniMax-M2 | Architecture specification |
| MiniMax-M1 GitHub | https://github.com/MiniMax-AI/MiniMax-M1 | Architecture, GGUF issue confirmation |
| MiniMax-01 Paper | https://arxiv.org/abs/2501.08313 | Text-01 architecture, Lightning Attention |
| MiniMax-M1 Paper | https://arxiv.org/abs/2506.13585 | M1 architecture and test-time compute |
| llama.cpp PR #16831 | https://github.com/ggml-org/llama.cpp/pull/16831 | MiniMax M2 initial support |
| llama.cpp PR #18399 | https://github.com/ggml-org/llama.cpp/pull/18399 | MiniMax M2.1 tokenizer fix |
| llama.cpp Issue #16798 | https://github.com/ggml-org/llama.cpp/issues/16798 | MiniMax M2 feature request history |
| MiniMax-M1 GGUF Discussion | https://huggingface.co/MiniMaxAI/MiniMax-M1-80k/discussions/1 | GGUF unavailability confirmed |
| NVIDIA NIM M2.7 | https://build.nvidia.com/minimaxai/minimax-m2.7/modelcard | Architecture specification cross-reference |
| MacRumors M4 Max 128GB LLM Testing | https://forums.macrumors.com/threads/m4-max-studio-128gb-llm-testing.2453816/ | Community benchmark context (403 access) |
| Apple Silicon LLM optimization | https://blog.starmorph.com/blog/apple-silicon-llm-inference-optimization-guide | Memory bandwidth and throughput guidance |
| unsloth M2.7 UD-Q4_K_XL NaN issue | https://huggingface.co/unsloth/MiniMax-M2.7-GGUF/discussions/5 | Known issue documentation |
| LM Studio MiniMax-M2 | https://lmstudio.ai/models/minimax-m2 | LM Studio compatibility confirmation |

---

## Clarifying Questions for Follow-up

1. Is the goal to use llama.cpp specifically, or is LM Studio / MLX also acceptable? MLX is 20–87% faster
   on Apple Silicon and the M2.x models have MLX variants available.

2. What is the primary use case — interactive chat, long-document analysis, coding agent, or API serving?
   This affects which context window size matters and therefore which quantization fits the RAM budget.

3. Is the 128 GB M4 Max a MacBook Pro or Mac Studio? (Both exist; the Studio has higher sustained
   thermal performance which may affect long-running inference.)

4. Is M2.7 specifically required, or is M2.5 acceptable? M2.5 at UD-Q3_K_XL (101 GB) fits more
   comfortably and runs ~20 tok/s vs ~15 tok/s for M2.7 UD-IQ4_XS.

5. Should the MiniMax-M1 (456 B, Lightning Attention) family be monitored for future llama.cpp support?
   If so, tracking the llama.cpp GitHub issues page would be the appropriate method.
