# Qwen3.8-27B — Reference

Studied: 2026-09-07. Downloaded as the upgrade path for the `qwen-3.6-35B` model in this project.

## What it is

**Qwen3.8** (2026-08-14) is the Qwen team's newest open generation, built on the Qwen3.5
architectural foundation. **Qwen3.8-27B** is the compact dense member: a native vision-language
model (images and video) with flexible thinking control, aimed at coding, professional work,
research and long-horizon agentic tasks. Apache-2.0.

Sibling releases at the same time: **Qwen3.8-Flash-Next** (125B / 6B active + 51B n-gram
embedding, new `qwen4exp` arch — needs a llama.cpp newer than b9835) and **Qwen3.8-2.4T-A95B**
(not runnable locally). There is no Qwen3.8 35B-A3B MoE.

| Item | Value |
|------|-------|
| GGUF repo | `unsloth/Qwen3.8-27B-GGUF` |
| GGUF arch | `qwen35` (verified from the file header) — **runs on the existing b9835 build** |
| Downloaded here | `models/qwen-3.8-27B/Qwen3.8-27B-UD-Q8_K_XL.gguf` (31.5 GB) + `mmproj-BF16.gguf` (0.9 GB) |
| Other quants | Q8_0 29.0 GB, UD-Q6_K_XL 25.3 GB, UD-Q4_K_XL 17.6 GB, UD-IQ4_XS 14.3 GB, … |
| Context | 262144 native; extensible to 1M with YaRN |
| Thinking | **on by default** (`<think>\n…</think>\n\n`); disable per request via the chat template's `enable_thinking`; depth via `reasoning_effort` = xhigh (default) / medium / low; `preserve_thinking` keeps prior-turn reasoning |
| License | Apache-2.0 |

## Recommended sampling (Qwen)

| Mode | temp | top-p | top-k | min-p | presence penalty |
|------|------|-------|-------|-------|------------------|
| Thinking (default) | **1.0** | **0.95** | **20** | 0 | 0 |
| Instruct / non-thinking | 0.7 | 0.80 | 20 | 0 | 1.5 |

Repetition penalty 1.0 in both modes.

## Running it

```bash
# REPL, thinking mode
./llama.cpp/build/bin/llama-cli -m models/qwen-3.8-27B/Qwen3.8-27B-UD-Q8_K_XL.gguf \
  -ngl 99 -fa on -c 32768 --jinja --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0

# OpenAI-compatible server with vision (mmproj) and tool calling
./llama.cpp/build/bin/llama-server -m models/qwen-3.8-27B/Qwen3.8-27B-UD-Q8_K_XL.gguf \
  --mmproj models/qwen-3.8-27B/mmproj-BF16.gguf \
  -ngl 99 -fa on -c 65536 --jinja --temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --port 8080
```

`--jinja` applies the embedded chat template, which handles `<think>` parsing, tool calls and the
`enable_thinking` / `reasoning_effort` request fields. For instruct-mode sampling pass
`--temp 0.7 --top-p 0.8 --presence-penalty 1.5` instead.

## Download

```bash
./scripts/download-qwen-3.8-27B.sh
# or
./scripts/llama-setup.sh download qwen-3.8-27B
```

## Sources

- Model card: <https://huggingface.co/Qwen/Qwen3.8-27B>
- GGUF (Unsloth): <https://huggingface.co/unsloth/Qwen3.8-27B-GGUF>
- Hosted overview: <https://www.qwencloud.com/models/qwen3.8-27b>
