# Sub-Agent Model Assignment Strategy for X-Ray Scan

## Principal Philosophy: Token-Efficient Game Coding

Do not default to the most expensive reasoning model for every step of game development. Instead, assign model tiers based on task complexity. This is highly critical in Flutter/Flame game development, where classes can grow large and assets are numerous.

---

## Model Tiers & Game Dev Use Cases

### 1. Reasoning Tier (e.g., Gemini Pro, GPT-o1, Claude Opus)
Use this tier **only** for high-complexity, logic-heavy, or critical architectural tasks.

* **When to use:**
  * **Core Game Mechanics Math:** Designing the speed acceleration curve of suitcases, calculating score penalties, combo multipliers, or progressive difficulty scaling.
  * **Flame Engine Life Cycle Decisions:** Designing how components load, mount, and clean up to prevent memory leaks in Flutter.
  * **AdMob Policy & Safe Zone Calculations:** Reviewing ad placements to guarantee they do not overlap game taps (avoiding policy violation and accidental clicks).
  * **Complex State Management:** Integrating `Riverpod`, `Provider`, or `Bloc` to sync high scores, sound settings, and game state.
* **Examples:**
  * Determining the exact formula for suitcase spawn frequency: $f(t) = \min(f_{max}, f_0 + k \cdot t^{0.5})$.
  * Debugging a tricky collision overlap issue where taps are registered multiple times on safe objects.

---

### 2. Balanced Tier (e.g., Claude Sonnet, GPT-4o, Gemini Flash for Coding)
Use this tier for standard feature development, refactoring, and code generation.

* **When to use:**
  * **Writing UI Screens:** Coding the Main Menu, Settings Screen, or Game Over Overlay using Flutter Widgets.
  * **Flame Component Implementation:** Writing standard Sprite components, position elements, and simple movement modifiers.
  * **Writing Unit/Widget Tests:** Implementing the test files under `app/test/` to mock scores and high-score saving.
  * **Documenting & Reviewing:** Writing technical changelogs, markdown specs, and code refactor outlines.
* **Examples:**
  * Implementing a sliding Volume controller in Flutter settings.
  * Adding a standard high-score persistence system using `shared_preferences`.
  * Constructing Flame sprite loads for suitcases and dangerous items.

---

### 3. Lightweight Tier (e.g., Gemini Flash, Claude Haiku, GPT-4o-mini)
Use this tier for data extraction, searches, compilation checks, and formatting.

* **When to use:**
  * **Searching the Codebase:** Finding where a specific class (e.g., `SuitcaseComponent`) is referenced.
  * **Asset Audit & Checking:** Matching assets in `pubspec.yaml` with physical files under `assets/images/` or `assets/audio/`.
  * **Running local tests & compilers:** Triggering `flutter analyze`, `flutter test`, and running the build commands.
  * **Template and Changelog Formatting:** Ensuring the changelog in `docs/changelog/CHANGELOG.md` exactly conforms to the required markdown structure.
* **Examples:**
  * Finding all occurrences of `Flame.images.load` in the codebase.
  * Generating a list of missing assets from `docs/08_asset_pipeline.md`.
  * Verifying if a pull request has a correctly formatted changelog entry.

---

## Game Dev Cost-Efficiency Examples

### ❌ Inefficient Approach (Heavy Model for Everything)
An AI agent reads a full Flutter project, searches for an asset path, formats a changelog, and runs tests, all within the same reasoning session.
* *Process:* 5 calls to a reasoning model @ ~100k tokens context (as it re-reads files repeatedly) = **500k reasoning tokens**.
* *Cost:* Very high, slow execution, and prone to losing focus on small layout bugs.

### ✅ Efficient Approach (Mixed-Tier Pipelines)
An AI agent uses cheap/fast tools for exploration, uses reasoning for designing the core algorithm, and offloads implementation to balanced models.
1. **Lightweight** model runs `grep` to find where assets are loaded (~5k tokens).
2. **Reasoning** model reads only the isolated `suitcase_spawner.dart` and designs a speed curve mathematical formula (~20k tokens).
3. **Balanced** model implements the Dart code based on that spec (~30k tokens).
4. **Lightweight** model runs `flutter test` and logs success in `CHANGELOG.md` (~10k tokens).
* *Total:* **~65k tokens** (over **85% savings** in token costs and execution time).

---

## Implementation Rules for Game Dev Agents

1. **Grep Before Loading:** Never open a file unless you are certain you need to edit or deeply analyze its contents. Use lightweight grep searches to locate references first.
2. **Context Isolation:** Keep files decoupled. Do not mix Game UI layout code with core Flame physics logic. Decoupling makes it possible to modify UI without loading heavy Game Engine code, saving thousands of tokens.
3. **Draft Small PRs:** Smaller commits mean smaller context windows, leading to massive token savings. 
4. **Strict Asset Tracking:** Rely on `docs/08_asset_pipeline.md` as the source of truth for assets instead of listing files in memory.
