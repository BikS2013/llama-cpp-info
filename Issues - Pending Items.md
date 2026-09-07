# Issues - Pending Items

## Pending Items

1. **Gemini File API - API Endpoint Clarification**
   - Status: Pending investigation
   - Priority: High
   - Details: Need to clarify if there's a dedicated Gemini File API or if this is built on Google Drive API with Gemini-specific metadata. This will determine the implementation approach.
   - Related: Open Questions 1, 2 in refined-request-gemini-file-api-cli.md

2. **Gemini File API - Authentication Scopes**
   - Status: Pending investigation
   - Priority: High
   - Details: Need to determine what scopes are needed beyond existing Drive API scopes in `~/.google-skills/drive/token.json`.
   - Related: Open Question 2

3. **Gemini File API - Actual Gemini API Integration**
   - Status: Pending investigation
   - Priority: High
   - Details: The current implementation is a placeholder. Need to research the actual Gemini File API endpoints and authentication scopes.
   - Related: Open Questions 1, 2 in refined-request-gemini-file-api-cli.md

4. **Gemini File API - Dependency Updates**
   - Status: Pending
   - Priority: Low
   - Details: `npm audit` shows 4 moderate severity vulnerabilities in `uuid` dependency. Consider updating `googleapis` when a stable version is available.
   - Related: Dependency audit completed, accepted risk

5. **Gemma 4 GGUFs predate Google's July 2026 chat-template fix**
   - Status: Pending
   - Priority: Medium
   - Details: The four local Gemma 4 files (`models/gemma-4-{E2B,E4B,26B,31B}`, downloaded 2026-04-13) were re-uploaded by Unsloth on 2026-07-17 with Google's official chat-template update (null handling, reasoning preservation, turn-tag balance, input validation). Weights are unchanged; the update is GGUF metadata only (~2.5 KB size delta). Re-download the four files with `./scripts/llama-setup.sh download gemma` after removing the old directories to pick up the fix.
   - Related: model version check of 2026-09-07

6. **Qwen3.8-Flash-Next and MiniMax-M3 need a newer llama.cpp**
   - Status: Pending decision
   - Priority: Low
   - Details: Both use architectures absent from the local b9835 build (`qwen4exp`, `minimax-m3`); upstream master has them. Upstream also switched to semantic-version release tags (latest v0.4.0, 2026-09-04). Qwen3.8-Flash-Next UD-IQ4_XS (93.7 GB) fits this machine; MiniMax-M3 does not (smallest sane quant UD-IQ2_M is 134 GB).
   - Related: model version check of 2026-09-07

7. **llama.cpp `--reasoning-budget 0` is a no-op for templates that pre-open `<think>\n`**
   - Status: Worked around locally (upstream bug not yet reported)
   - Priority: Low
   - Details: On b9835 the reasoning-budget sampler is prefilled with the generation prompt. For Qwen3.6 / MiniMax-M2.7 the template ends with `<think>\n`; the prefilled `<think>` arms the sampler (budget 0 → FORCING) but the following prefilled `\n` is counted as the forced `</think>` token, so the sampler goes DONE before generation starts and the model thinks freely. Gemma 4 is unaffected (the model emits its own start tag). Workaround used by `start-repl.sh` / `start-api.sh --no-think`: `--reasoning-budget-message $'\n'` makes the forced sequence `\n</think>` so the prefilled newline absorbs the first token. Re-check after the next llama.cpp rebuild (`common/reasoning-budget.cpp`, `common/sampling.cpp` prefill loop).
   - Related: F013 in `docs/design/project-functions.md`

## Completed Items

1. **`docs/design/project-functions.md` line breaks restored**
   - Date: 2026-09-07
   - Details: The working copy had F001–F011 collapsed onto a single line (detected while adding the `--no-think` entry). It was re-flowed the same day (now 200+ properly formatted lines, entries renumbered so the thinking-free-runs entry is F013). Nothing further to do.

1. **Superseded models removed from disk**
   - Date: 2026-09-07
   - Issue: After adding Ornith-1.5-35B-A3B and Qwen3.8-27B, the previous generations (`models/Ornith-1.0-35B`, 34 GiB, and `models/qwen-3.6-35B`, 36 GiB) were still occupying disk.
   - Resolution: Both directories deleted (~70 GiB freed). Download scripts and `llama-setup.sh` entries are kept so they can be re-fetched; `run-ornith.sh --version 1.0` now requires a re-download. Docs updated (`CLAUDE.md`, `docs/reference/ornith-models.md`, `scripts/README.md`, `docs/design/project-functions.md`).
   - Status: Complete

2. **Model upgrades: Ornith-1.5-35B-A3B and Qwen3.8-27B added**
   - Date: 2026-09-07
   - Issue: Version check found newer generations for Ornith-1.0-35B (Ornith-1.5, 2026-08-24) and the Qwen3.6 series (Qwen3.8-27B, 2026-08-14); the Ornith HF org had also moved from `deepreinforce-ai` to `ornith-ai`.
   - Resolution: Downloaded `Ornith-1.5-35B-Q8_0.gguf` + mmproj to `models/Ornith-1.5-35B/` and `Qwen3.8-27B-UD-Q8_K_XL.gguf` + mmproj to `models/qwen-3.8-27B/`. Added `scripts/download-Ornith-1.5-35B.sh` and `scripts/download-qwen-3.8-27B.sh`; registered both models in `scripts/llama-setup.sh` and `scripts/download-models.sh` (multi-`--include` support added); repointed all Ornith 1.0 references to `ornith-ai`; `run-ornith.sh` gained `--version 1.5|1.0` (default 1.5) and `--vision`; `pi-ornith` (`~/.zshrc.pi`, `~/.pi/agent/models.json`) now serves alias `ornith-1.5-35b`. Docs updated: `CLAUDE.md`, `scripts/README.md`, `docs/reference/scripts-guide.md`, `docs/reference/ornith-models.md`, new `docs/reference/qwen38-27b.md`, `docs/design/project-functions.md` (F004, F006).
   - Validation: both GGUF headers report architectures already in the b9835 build (`qwen35moe`, `qwen35`); no rebuild required.
   - Status: Complete

3. **Test Builder Subagent - MCP/LSP Hard Dependency Normalized**
   - Date: 2026-06-30
   - Issue: `test-builder-extension` persisted Serena/CClsp MCP tool names in its child tool allowlist and prompt, unlike the normalized Pi-native subagent pattern used by the newer extensions.
   - Resolution: Removed MCP/LSP tool names from `CHILD_TOOLS`, updated `test-builder-agent.md` to use Pi-native `read/write/edit/grep/find/ls/bash` with documented symbol-resolution/diagnostics limitations, and updated the extension README.
   - Validation: Pi dry-load check succeeded with `pi --no-extensions -e ~/ai-coding/pi-workdocs/extensions/test-builder-extension/index.ts --list-models __no_such_model_filter__`.
   - Status: Complete

4. **Gemini File API - Refinement Complete**
   - Date: 2026-06-29
   - Resolution: Refined request saved to `docs/reference/refined-request-gemini-file-api-cli.md`
   - Status: Complete

5. **Gemini File API - Initial Implementation**
   - Date: 2026-06-29
   - Resolution: Created TypeScript CLI implementation in `test/gemini-file-api-cli.ts`
   - Status: Complete
   - Note: Implementation is a placeholder requiring actual Gemini File API integration

6. **Gemini File API - Test Infrastructure**
   - Date: 2026-06-29
   - Resolution: Created `test/package.json`, `test/tsconfig.json`, and test scripts
   - Status: Complete

7. **Gemini File API - Dependency Audit**
   - Date: 2026-06-29
   - Resolution: `npm audit` shows 4 moderate severity vulnerabilities in `uuid` dependency. These affect `googleapis` which is used for Google API authentication. Since this is a CLI tool that runs locally with stored credentials and doesn't process untrusted input, the risk is minimal.
   - Status: Accepted risk - dependencies are stable, no immediate security issues for CLI usage pattern.

8. **Gemini File API - Test Scripts Created**
   - Date: 2026-06-29
   - Resolution: Created three test scripts:
     - `test_scripts/test-gemini-cli-list.sh` - Tests list command
     - `test_scripts/test-gemini-cli-get.sh` - Tests get command
     - `test_scripts/test-gemini-cli-help.sh` - Tests help commands
   - Status: Complete
   - Note: Tests show the CLI is functional and handles edge cases correctly

9. **Gemini File API - Documentation**
   - Date: 2026-06-29
   - Resolution: Created `test/README.md` with installation, usage, and development instructions
   - Status: Complete
