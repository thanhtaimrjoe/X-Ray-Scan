# Workflows - Token-Efficient Game Development

This directory defines reusable, token-efficient workflow patterns for the **X-Ray Scan** repository. 
When building a game with Flutter & Flame, AI assistants (PM, Copilot, Codex, Claude Code, ChatGPT, etc.) can easily consume millions of tokens by repeatedly reading large codebases, game assets, and documentation. 

By applying the **Extract → Analyze → Format/Code** pipeline, agents can cut token costs by **60% to 80%** while improving code quality and keeping execution fast.

---

## The Core Rule: Model Assignment by Capability Tier

Configure and trigger AI sub-tasks by capability tier, not by a specific pinned model name (as vendor versions change rapidly). 

| Tier | Purpose in Game Dev | Target Model Families | Cost/Speed |
| --- | --- | --- | --- |
| **Lightweight** | File listing, codebase grep search, parsing asset names, basic UI layout tweaks, running compilation/tests. | `gemini-2.5-flash`, `claude-3-haiku`, `gpt-4o-mini` | Extremely Cheap & Fast |
| **Balanced** | Writing Flutter Widgets, Flame Components, Dart Unit Tests, translating files, formatting markdown logs. | `claude-3.5-sonnet`, `gemini-2.5-flash` (for code), `gpt-4o` | Mid-tier & Versatile |
| **Reasoning** | Core game math (speed curves, combo logic), AdMob policy-compliance review, complex bug debugging, architectural system design. | `gemini-2.5-pro`, `o1`/`o3-mini`, `claude-3-opus` | Premium & Deep Reasoning |

---

## Token-Efficient Development Pipeline

```text
1. Explore & Isolate ──► 2. Design/Reason ──► 3. Generate Code ──► 4. Run & Verify
       │                     │                    │                    │
  (Lightweight)         (Reasoning)          (Balanced)          (Lightweight)
  Grep search & find     Think through math   Write Dart classes   Run local tests & 
  only relevant files    & design spec only   and Flame code.      analyze compiler logs.
```

### Phase 1: Explore & Isolate (Lightweight)
* **Goal:** Locate targets without loading massive files.
* **Action:** Use fast grep search (`grep_search` or `ripgrep`) to find exact file paths and class structures (e.g., searching for `PositionComponent` or `AdWidget` references). 
* **Token Saving:** Saves **thousands of context tokens** by avoiding loading whole files into the chat context window until you know exactly which ones need edits.

### Phase 2: Design & Reason (Reasoning)
* **Goal:** Figure out the "how" for complex features (e.g., how to scale suitcase scanning speeds safely over time, or where to position ads without overlapping gameplay taps).
* **Action:** Pass only the isolated code signature and the user story/spec to the **Reasoning** tier to generate a concise design specification.
* **Token Saving:** Because the reasoning model only reads a small, isolated context rather than the whole codebase, its high token cost is minimized.

### Phase 3: Generate Code & Implement (Balanced)
* **Goal:** Implement the approved design spec.
* **Action:** Feed the design spec and target files to the **Balanced** tier (e.g., Sonnet or Flash) to produce the clean, well-commented Dart files. 
* **Token Saving:** Saves up to **80% of costs** because the heavy task of generating lines of code is handled by a cheaper, highly efficient model.

### Phase 4: Run & Verify (Lightweight)
* **Goal:** Lint and test the game.
* **Action:** Run local commands (`flutter test`, `flutter analyze`) in the terminal. If errors occur, extract only the specific compiler error lines or stack traces instead of dumping the whole console history.

---

## Best Practices for Game Dev Agents

1. **Avoid Whole-file Reloads:** Do not read full Flame game loops or rendering classes unless you are directly modifying them. If you only need to change a speed multiplier, target only that specific line or variable.
2. **Do Not Invent Assets:** Do not guess asset paths. If you need to reference sprites, search `docs/08_asset_pipeline.md` or look up files under the `assets/` directory using lightweight tools first.
3. **Keep Context Clean:** Before starting a new task, archive old chat history or summarize previous steps in `docs/changelog/CHANGELOG.md` and start fresh.
4. **Delegate Heavy Tasks:** If a task requires reading multiple spec files, spawn a temporary subagent to research and return a compact 1-page summary.

---

## References

* [Sub-Agent Model Assignment Strategy](sub-agent-model-strategy.md) - Detailed breakdown for game roles.
* [AGENTS.md](../AGENTS.md) - Repository operating guidelines.
