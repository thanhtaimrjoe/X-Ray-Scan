# Changelog

**Project**: X-Ray Scan
**Purpose**: Development change history for AI assistants and future contributors

---

## [2026-06-13 23:47] - Cut item asset candidate sheet

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-002, US-010
**Impact Scope**: Assets, Docs, Gameplay, UX

### Changes
- Added the first generated x-ray item sprite sheet candidate.
- Cut the sheet into 11 transparent PNG candidate assets for all MVP danger and safe items.
- Added a review preview image for quickly checking the extracted candidates.

### Implementation Details
- File: `docs/assets/asset_candidates/item_sheet_batch_01.png`
- File: `docs/assets/asset_candidates/item_sheet_batch_01_cut_preview.png`
- File: `docs/assets/asset_candidates/item_danger_knife_candidate_01.png`
- File: `docs/assets/asset_candidates/item_danger_scissors_candidate_01.png`
- File: `docs/assets/asset_candidates/item_danger_lighter_candidate_01.png`
- File: `docs/assets/asset_candidates/item_danger_razor_candidate_01.png`
- File: `docs/assets/asset_candidates/item_danger_battery_pack_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_phone_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_laptop_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_bottle_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_sandwich_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_keys_candidate_01.png`
- File: `docs/assets/asset_candidates/item_safe_headphones_candidate_01.png`
- Reason: Tai generated the first item sheet on mobile, and the assets needed to be separated for review before runtime integration.
- Technical decision: Keep extracted files in `docs/assets/asset_candidates/` until they are approved and promoted into `app/assets/images/items/`.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- The source sheet had an opaque checkerboard background, so candidates were extracted with a cyan mask and converted to transparent PNGs.
- No runtime app assets were integrated in this change.

---

## [2026-06-13 23:16] - Add item asset prompt batch 01

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-002, US-010
**Impact Scope**: Docs, Assets, Gameplay, UX

### Changes
- Added Gemini-ready prompts for all 11 MVP x-ray item assets.
- Included suggested candidate filenames for danger and safe item outputs.
- Added review checklist for validating the first item asset batch before promotion.
- Linked the prompt batch from the asset pipeline and progress tracking.

### Implementation Details
- File: `docs/assets/item_asset_prompt_batch_01.md`
- File: `docs/08_asset_pipeline.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai is ready to start the real asset pipeline, beginning with production candidate item assets.
- Technical decision: Keep prompts and candidate filenames in docs so generated outputs can be reviewed before runtime integration.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- This is documentation/prompt work only; no runtime assets were generated or integrated.

---

## [2026-06-13 23:11] - Define asset pipeline

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-001, US-002, US-010
**Impact Scope**: Docs, Assets, Gameplay, UX

### Changes
- Added a staged AI-assisted asset pipeline for generating, reviewing, naming, storing, and integrating production visual assets.
- Defined MVP asset inventory for backgrounds, danger items, safe items, and optional UI/map accents.
- Added Gemini-ready prompt templates for main menu, gameplay, level map, result backgrounds, and individual x-ray item assets.
- Added folder structure and naming rules for candidate assets versus approved runtime assets.
- Recorded a durable decision to keep raw generator output out of app runtime folders until approved.
- Updated game design, technical spec, and progress tracking to link the asset pipeline.

### Implementation Details
- File: `docs/08_asset_pipeline.md`
- File: `docs/03_game_design.md`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: The playable core is ready for production visual assets, and the project needs a consistent workflow before generating asset batches.
- Technical decision: Use `docs/assets/asset_candidates/` for review candidates and promote only approved runtime assets into structured `app/assets/images/` folders.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- This is documentation/workflow only; no runtime assets were integrated in this change.

---

## [2026-06-13 22:53] - Improve gameplay scanner feel

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-002, US-003
**Impact Scope**: Gameplay, UX

### Changes
- Enlarged in-bag item silhouettes and increased tap hit radius for more comfortable phone play.
- Expanded and enriched the scanner frame with inner glass, corner guides, a brighter scan beam, and a conveyor/belt hint.
- Added success/perfect screen flash feedback in addition to existing mistake feedback.
- Slightly reduced random object rotation so mock objects stay more readable while real assets are pending.

### Implementation Details
- File: `app/lib/game/xray_inspector_game.dart`
- Reason: Galaxy S24 evidence showed the gameplay screen was readable but still felt too wireframe and could use stronger scanner framing and tap comfort.
- Technical decision: Improve the current Flame/Canvas gameplay surface with lightweight painting changes before introducing real background and object assets.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [ ] Policy/ad placement checked
- [x] `flutter test`
- [x] `flutter analyze`
- [x] `flutter build apk --debug`

### Notes
- Mock item silhouettes remain temporary and should be replaced by production assets later.

---

## [2026-06-13 22:30] - Polish S24 evidence issues

**Owner**: AI Assistant
**Type**: Bugfix
**Related US**: US-001, US-004, US-010
**Impact Scope**: Gameplay, Docs, UX

### Changes
- Reduced main menu and level map text truncation by allowing key labels to wrap instead of ellipsizing important world/level names.
- Improved Item Database header sizing, grid spacing, bottom scroll padding, and helper text readability on phone screens.
- Replaced misleading database Material icons with lightweight custom x-ray silhouette painters for current MVP items.
- Updated the failed warning panel to show a knife-like silhouette instead of the fork/knife restaurant icon.
- Fixed result wording so one-star best results read `1 star` instead of `1 stars`.
- Updated progress tracking to remove stale gaps that were completed by the approved UI implementation pass.

### Implementation Details
- File: `app/lib/main.dart`
- File: `docs/07_tracking/progress.md`
- Reason: Galaxy S24 evidence showed text truncation, cramped database layout, and misleading item icons.
- Technical decision: Use Flutter `CustomPainter` silhouettes as an interim asset-light bridge until production item assets are extracted or redrawn.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked
- [x] `flutter test`
- [x] `flutter analyze`
- [x] `flutter build apk --debug`

### Notes
- This pass intentionally avoids large background/art changes; background asset polish and real item assets remain follow-ups.

---

## [2026-06-13 22:11] - Implement approved anime airport UI pass

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-001, US-004, US-005, US-010
**Impact Scope**: Gameplay, Ads, Docs, UX, Test

### Changes
- Reworked the main menu around the approved International Terminal scanner concept with Play, Level Map, Item Database, Settings, progress stats, and banner placement.
- Added a 10-node International Terminal level map with completed/current/locked states, replay selection, best stars, and level launch controls.
- Changed gameplay from moving suitcase pressure to paused suitcase inspection where the bag waits in the scanner until the player marks threats and presses Clear.
- Added an in-game Marked counter so players can compare marked threats against the current bag's danger count.
- Replaced the old two-card encyclopedia entry flow with a tabbed Item Database for Danger Items and Safe Items.
- Restyled Level Clear and Level Failed screens against the approved references while preserving rewarded continue and banner separation.
- Updated widget coverage for the new menu, database, and rewarded continue labels.
- Updated progress tracking to reflect the implemented visual/UI pass.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/lib/game/xray_inspector_game.dart`
- File: `app/test/widget_test.dart`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Gemini-generated core screen concepts and asked to implement the new direction.
- Technical decision: Keep final UI code asset-light by using shared Flutter-painted airport/scanner panels and reusable action buttons, while preserving the approved layouts as the product reference.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked
- [x] `flutter test`
- [x] `flutter analyze`
- [x] `flutter build apk --debug`

### Notes
- Button visual polish remains a follow-up; the current pass focuses on implementing the approved flow, layout, and gameplay behavior.
- Physical-device ad flow validation is still pending.

---

## [2026-06-13 21:50] - Approve level result screen concepts

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-004, US-005
**Impact Scope**: Gameplay, Ads, Docs, Assets, UX

### Changes
- Saved the approved Level Clear and Level Failed/rewarded continue visual references.
- Updated game design notes with result screen content, reward panel, warning panel, optional rewarded continue, and ad placement requirements.
- Recorded a durable decision to use the generated result screens as layout/content references while normalizing final buttons in shared UI components.
- Updated progress tracking so the approved core screen set can move toward implementation.

### Implementation Details
- File: `docs/assets/level_clear_visual_reference_approved.jpg`
- File: `docs/assets/level_failed_visual_reference_approved.jpg`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Level Clear and Level Failed concepts and noted button styling will be adjusted during implementation.
- Technical decision: Treat result screens as layout/content references and preserve policy-safe ad separation, with shared button styling applied in Flutter.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Implementation is pending; rewarded continue must remain optional and separated from banner ad placement.

---

## [2026-06-13 21:45] - Approve Main Menu layout direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-001, US-010
**Impact Scope**: Gameplay, Docs, Assets, UX

### Changes
- Saved the approved Main Menu layout/art visual reference.
- Updated game design notes with main menu composition, scanner/suitcase hero art, subtitle, and shared button normalization guidance.
- Recorded a durable decision to use the approved main menu as layout/art reference while implementing final buttons through shared UI components.
- Updated progress tracking with the Main Menu reference and shared button normalization next step.

### Implementation Details
- File: `docs/assets/main_menu_visual_reference_approved.jpg`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Gemini-generated Main Menu composition while noting generated button styling should be normalized in code.
- Technical decision: Treat generated screens as art/layout references and control final button styling through shared primary/secondary components.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Implementation is pending; button visuals should be consistent across Play, Clear, Next, Continue, Retry, Map, Database, and Settings.

---

## [2026-06-13 21:36] - Approve tabbed Item Database direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-010
**Impact Scope**: Gameplay, Docs, Assets, Collection, UX

### Changes
- Saved the approved tabbed Item Database visual reference.
- Updated US-010 to replace the old two-choice encyclopedia entry with a direct tabbed collection screen.
- Updated game design notes for Danger/Safe tabs, category progress, scrollable item grids, unlocked cards, and locked cards.
- Recorded a durable decision for the tabbed Item Database flow.
- Updated progress tracking so implementation replaces the old two-card entry flow.

### Implementation Details
- File: `docs/assets/item_database_visual_reference_approved.jpg`
- File: `docs/02_user_stories.md`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Gemini-generated Item Database concept and preferred the faster tabbed collection UX over the current two-card entry flow.
- Technical decision: Default to Danger Items, keep Safe Items as the second tab, and allow locked cards to show a dim item name with lock/`???` for casual collection clarity.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Implementation is pending; the current app still uses the old two-card encyclopedia entry flow.

---

## [2026-06-13 21:11] - Approve International Terminal level map direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-001, US-004, US-010
**Impact Scope**: Gameplay, Docs, Assets, Progression, UX

### Changes
- Saved the approved International Terminal level map visual reference.
- Updated game design notes with level map node states, final-gate milestone behavior, and selected-level panel requirements.
- Recorded a durable decision for the 10-node airport terminal progression map.
- Updated progress tracking so the remaining concept work starts with Level Clear and Level Failed/rewarded continue screens.

### Implementation Details
- File: `docs/assets/level_map_visual_reference_approved.jpg`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Gemini-generated level map as the World 1 progression reference.
- Technical decision: Use completed checkmark nodes, bright current node, unlocked future numbered nodes, locked numbered nodes, and a final scanner-gate milestone for level 10.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Implementation is pending; completed map nodes should remain replayable even when represented by checkmarks.

---

## [2026-06-13 20:58] - Approve anime airport gameplay visual direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-002, US-008, US-012
**Impact Scope**: Gameplay, Docs, Assets, UX

### Changes
- Saved the approved gameplay visual reference for the anime airport paused-suitcase screen.
- Updated game design notes to define the target layout: compact HUD, large centered scanner/suitcase, marked counter, and large Clear button.
- Recorded a durable decision for the paused-suitcase anime airport gameplay direction.
- Updated progress tracking so the next work focuses on approving the remaining screens and implementing paused-bag inspection.

### Implementation Details
- File: `docs/assets/gameplay_visual_reference_approved.jpg`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Tai approved the Stitch-generated gameplay screen as the new visual reference for X-Ray Scan.
- Technical decision: Keep the anime airport environment outside the scanner and detailed cyan x-ray item art inside the scanner so gameplay remains readable and on-theme.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- The playable build still needs implementation work to match this approved paused-suitcase design.
- Next design targets: level map, level clear, item database, main menu, and level failed/rewarded continue screens.

---

## [2026-06-13 15:14] - Review ad continue flow before main merge

**Owner**: AI Assistant
**Type**: Bugfix/Test/Docs
**Related US**: US-004, US-005
**Impact Scope**: Ads, Gameplay, Docs, Policy

### Changes
- Fixed rewarded-continue eligibility so it resets only when a new level attempt starts, preventing repeat continues in the same attempt after a second failure.
- Cleared consumed rewarded ads before showing them and guarded ad load failure callbacks after widget disposal.
- Updated ad break tests and progress notes to reflect integrated interstitial/rewarded test-ad flows.

### Implementation Details
- File: `app/lib/game/systems/ad_break_rules.dart`
- File: `app/lib/main.dart`
- File: `app/test/game/ad_break_rules_test.dart`
- File: `docs/07_tracking/progress.md`
- Reason: Code review found that `onRoundCompleted()` reset rewarded continue state too early for a resumed level attempt.
- Technical decision: Treat rewarded continue eligibility as level-attempt state, while keeping interstitial counters as completed-break counters.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Physical-device validation of the new rewarded/interstitial SDK flow is still recommended before release.

---

## [2026-06-13 14:40] - Wire interstitial and rewarded ads to level clear/fail breakpoints

**Owner**: Copilot
**Type**: Feature
**Related US**: N/A
**Impact Scope**: Ads, Gameplay, Policy

### Changes
- Added `androidTestInterstitialAdUnitId` and `androidTestRewardedAdUnitId` to `AdsService`.
- Added `loadInterstitial()` and `loadRewarded()` static helpers to `AdsService`.
- Added `grantContinueLife()` to `XrayInspectorRules` to restore 1 life for rewarded continue.
- Added `grantContinue()` to `XrayInspectorGame` to restore life and resume engine.
- Wired `AdBreakState` and `AdBreakRules` into `_AppShellState` with preloading on init and reload after each show.
- Interstitial shown (if loaded) after level clear or fail when `shouldShowInterstitial` returns true.
- Rewarded continue button shown on `LevelFailedScreen` when `canOfferRewardedContinue` is true.
- On reward granted: restores 1 life, marks `rewardedContinueUsed`, resumes gameplay screen.
- Added two widget tests for `LevelFailedScreen` continue button visibility.
- Added two unit tests for `grantContinueLife()` behavior.

### Implementation Details
- File: `app/lib/services/ads_service.dart` — added interstitial/rewarded test unit IDs and load helpers
- File: `app/lib/game/systems/xray_inspector_rules.dart` — added `grantContinueLife()`
- File: `app/lib/game/xray_inspector_game.dart` — added `grantContinue()`
- File: `app/lib/main.dart` — ads state, load/show, rewarded continue flow, `LevelFailedScreen` new params
- File: `app/test/game/xray_inspector_rules_test.dart` — two new `grantContinueLife` tests
- File: `app/test/widget_test.dart` — two new `LevelFailedScreen` widget tests
- Technical decision: Use Google test ad unit IDs only. Live IDs must be added by owner before release.
- Policy: Rewarded continue limited to once per level attempt via `rewardedContinueUsed`. Interstitial blocked until minimum 3 rounds.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked

### Notes
- Live interstitial and rewarded ad unit IDs must replace test IDs in production release before publishing.
- Sound engine still not wired — `_soundEnabled` toggle is persisted but unused by audio.
- Level select screen (replay any level) still not implemented.

---

## [2026-06-13 14:30] - Update branch names and setup copilot branch

**Owner**: Copilot
**Type**: Chore
**Related US**: N/A
**Impact Scope**: Docs, Android, Gameplay

### Changes
- Updated `AGENTS.md` to reflect `main` branch (renamed from `codex/neon-arcade-visuals`) and `copilot` development branch.
- Committed all current changes to `copilot` branch.
- Cleaned up local tracking branches.

### Implementation Details
- File: `AGENTS.md`
- Reason: Branch renamed on origin, local branch needs aligning.

### Tests
- [x] Branch setup tested
- [x] Remote updated

---

## [2026-06-13 13:52] - Expand Airport Basics level pack

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-001, US-004, US-008, US-010
**Impact Scope**: Gameplay, Docs, Test, Progression

### Changes
- Expanded `Airport Basics` from the shipped 3-level slice to a full 10-level pack.
- Added later-pack danger introductions for `Razor` at level 5 and `Power Bank` at level 8 while broadening safe-item clutter and speed pressure across levels 4-10.
- Updated progression, persistence, and widget tests so the app clamps and displays unlock progress correctly across the full pack.
- Updated game design and tracking docs so the next implementation slice starts from the 10-level baseline instead of the old vertical-slice handoff.

### Implementation Details
- File: `app/lib/game/systems/level_progression_rules.dart`
- File: `app/test/game/level_progression_rules_test.dart`
- File: `app/test/services/storage_service_test.dart`
- File: `app/test/widget_test.dart`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The current branch already proved the level-clear loop; the next product milestone was to expand the first pack before wiring interstitial/rewarded ads.
- Technical decision: Keep the existing bag-clear objective model and generic UI flow, and scale content by extending the level catalog rather than adding a new map or objective system in the same change.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked
- [x] Policy/ad placement checked (no active gameplay ad placement changed)

### Notes
- The next implementation milestone is SDK wiring for interstitial and rewarded ads at level clear/fail breakpoints.
- Physical-device tuning is still needed now that the pack extends to 10 levels.

---

## [2026-06-13 14:30] - 3-level progression vertical slice

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-001, US-004, US-008, US-010
**Impact Scope**: Gameplay, Docs, Test, Progression

### Changes
- Added pure Dart level progression rules with a 3-level `Airport Basics` catalog, bag-clear objectives, star thresholds, unlock logic, and best score/star updates.
- Extended `StorageService` to persist `highest_unlocked_level`, `level_best_scores`, and `level_best_stars`.
- Connected gameplay to level configs with per-level danger/safe pools, bag objective tracking, level clear on objective completion, and level failed on zero lives.
- Updated main menu, gameplay HUD, level clear, and level failed screens for the default level-based play flow.
- Updated game design and technical spec docs to reflect level mode as the default MVP journey.

### Implementation Details
- File: `app/lib/game/systems/level_progression_rules.dart`
- File: `app/test/game/level_progression_rules_test.dart`
- File: `app/lib/services/storage_service.dart`
- File: `app/test/services/storage_service_test.dart`
- File: `app/lib/game/xray_inspector_game.dart`
- File: `app/lib/main.dart`
- File: `app/test/widget_test.dart`
- File: `docs/03_game_design.md`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/progress.md`
- Reason: Physical playtesting showed endless score attack loses excitement; levels add short goals, completion feedback, and unlock pacing.
- Technical decision: Keep level rules independent from Flame and store per-level bests as JSON maps in `shared_preferences`.

### Tests
- [x] Unit tests added/updated
- [x] Manual playtest completed (installed and launched debug APK on Samsung device `RFCX80NW55E`)
- [x] Error handling checked
- [x] Policy/ad placement checked (banner remains on menu/level clear/fail only; no ads during active gameplay)

### Notes
- Vertical slice covers levels 1-3 only; expand to the full 10-level pack after playtest confirmation.
- Endless mode and interstitial/rewarded SDK integration remain future work.

---

## [2026-06-13 12:53] - Document level progression direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-001, US-004, US-008, US-010
**Impact Scope**: Gameplay, Docs, Progression, Monetization

### Changes
- Added a level progression plan based on physical playtest feedback that endless score attack loses excitement after several rounds.
- Recorded a durable decision to make level-based progression the next product slice.
- Updated progress tracking so the next AI agent can implement a 3-level vertical slice before expanding content or monetization.

### Implementation Details
- File: `docs/08_level_progression_plan.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The product owner wants another AI agent to continue from the current playtest insight without rediscovering the progression gap.
- Technical decision: Document the next slice as a small, testable level progression layer first, not a full map UI or large content expansion.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (documentation-only change)
- [x] Policy/ad placement checked (level clear/fail are natural ad breakpoints; active gameplay remains ad-free)

### Notes
- Implementation is pending; this change only records the handoff plan.

---

## [2026-06-13 12:33] - Simplify gameplay HUD feedback

**Owner**: AI Assistant
**Type**: Bugfix
**Related US**: US-008, US-012
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Removed persistent action feedback text from the gameplay HUD.
- Kept action feedback as scanner/playfield pulses so Score, Combo, and Lives remain easier to read during active play.
- Updated game design notes to clarify that momentary feedback labels should not occupy HUD space.

### Implementation Details
- File: `app/lib/main.dart`
- File: `docs/03_game_design.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Physical-device playtesting showed labels such as PERFECT and THREAT LEFT consumed too much top-HUD width and made score harder to scan.
- Technical decision: Keep HUD focused on persistent state and keep event feedback near the relevant suitcase/object interaction.

### Tests
- [ ] Unit tests added/updated
- [x] Manual playtest completed (installed and launched debug APK on Samsung device `RFCX80NW55E`)
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Product owner should confirm the simplified HUD is easier to scan during active play.

---

## [2026-06-13 12:25] - Revise arcade scoring and feedback

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-002, US-003, US-008, US-009, US-012
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Increased scoring scale to 100-point danger taps, 50-point clear bonuses, and 50-point safe-tap penalties.
- Changed combo multiplier progression to +0.5 every 5 combo, capped at x3.0.
- Added a flat 100-point perfect bag bonus for clean clears.
- Updated gameplay feedback labels from debug-style text to player-facing labels such as SCAN, MARKED, FALSE TAP, BAG CLEAR, PERFECT, and THREAT LEFT.
- Added a Clear guard so pressing Clear before the suitcase reaches the scanner does nothing.
- Added combo multiplier text to the HUD and combo milestone pulse feedback.

### Implementation Details
- File: `app/lib/game/systems/xray_inspector_rules.dart`
- File: `app/lib/game/xray_inspector_game.dart`
- File: `app/lib/main.dart`
- File: `app/test/game/xray_inspector_rules_test.dart`
- File: `docs/03_game_design.md`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Claude's game-design review and local brainstorming both identified low score scale and slow combo progression as the highest-impact game-feel issues.
- Technical decision: Keep perfect clear as a flat bonus outside the multiplier and keep false safe taps as score plus combo penalties without life loss.

### Tests
- [x] Unit tests added/updated
- [x] Manual playtest completed (installed and launched debug APK on Samsung device `RFCX80NW55E`)
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Revised scoring needs physical-device feel testing for readability, reward pacing, and random-tap resistance.

---

## [2026-06-13 11:55] - Add ad break rules tests

**Owner**: AI Assistant
**Type**: Test
**Related US**: US-004, US-005
**Impact Scope**: Ads, Gameplay, Docs, Test, Policy

### Changes
- Added testable rules for interstitial ad frequency.
- Added rewarded-continue eligibility rules that prevent chained continues in the same round.
- Added unit tests covering first-launch safety, frequency caps, counter reset, and rewarded availability.
- Updated technical spec and progress tracking for the new ad break rules layer.

### Implementation Details
- File: `app/lib/game/systems/ad_break_rules.dart`
- File: `app/test/game/ad_break_rules_test.dart`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Interstitial and rewarded ads should have test-covered policy/frequency behavior before SDK integration.
- Technical decision: Keep ad break decisions independent from Flame and Google Mobile Ads so they can be unit tested before being wired into game-over flows.

### Tests
- [x] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (rules prevent first-launch/every-round interstitials and chained rewarded continues)

### Notes
- SDK integration for interstitial and rewarded test ads remains pending.

---

## [2026-06-13 11:33] - Add AdMob test banners

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-004
**Impact Scope**: Ads, Gameplay, Android, Docs, Policy

### Changes
- Initialized the Google Mobile Ads SDK during app startup.
- Added AdMob test banner widgets on the main menu and game-over screens.
- Removed the banner placeholder from the item database so real ads stay limited to approved MVP placements.
- Updated release checklist and progress tracking for banner ad integration.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/lib/services/ads_service.dart`
- File: `docs/06_release_checklist.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Continue the MVP plan by replacing menu/game-over banner placeholders with AdMob test banners while avoiding active gameplay ad placement.
- Technical decision: Use Google's Android banner test ad unit ID and keep a local fallback placeholder for tests or unsupported plugin environments.

### Tests
- [ ] Unit tests added/updated
- [x] Manual playtest completed (installed on Samsung device `RFCX80NW55E`; test banner loaded on main menu)
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (test banner ID only; no active gameplay ads; no production IDs added)

### Notes
- Interstitial and rewarded ad formats remain pending and should get frequency/continue rule tests first.
- Game-over banner should be checked during the next gameplay smoke pass.

---

## [2026-06-13 11:30] - Sync plan and specs after device playtest

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-002, US-003, US-008, US-011, US-012
**Impact Scope**: Gameplay, Android, Docs, Release

### Changes
- Replaced stale lane-sort user stories with x-ray danger detection and inspection-combo requirements.
- Added user stories for portrait orientation lock and HUD overflow safety based on Galaxy S24 playtesting.
- Updated difficulty tuning notes from falling/color-lane language to suitcase speed, object count, and visual clutter.
- Marked Android manual playtest complete and refreshed progress next steps.

### Implementation Details
- File: `docs/02_user_stories.md`
- File: `docs/03_game_design.md`
- File: `docs/06_release_checklist.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The project plan called out stale lane-sort docs after the X-Ray Scan pivot, and physical-device testing has now validated the current gameplay baseline.
- Technical decision: Keep the existing story numbering stable for core MVP stories and add new US-011/US-012 for the concrete device issues found during manual playtest.

### Tests
- [ ] Unit tests added/updated
- [x] Manual playtest completed (Samsung device HUD/pause and portrait-lock checks)
- [x] Error handling checked (documentation-only change after prior `flutter test`, `flutter analyze`, and debug APK install)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Next implementation slice should focus on production-ready item visuals or AdMob test banner integration.

---

## [2026-06-13 11:28] - Lock app to portrait orientation

**Owner**: AI Assistant
**Type**: Bugfix
**Related US**: US-008
**Impact Scope**: Gameplay, Android, Docs, Test

### Changes
- Locked the Flutter app to portrait orientation before startup.
- Added an Android activity portrait orientation guard so the gameplay screen cannot rotate into landscape.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/android/app/src/main/AndroidManifest.xml`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The X-Ray Scan gameplay layout is designed for portrait phones and should not rotate sideways during physical-device playtesting.
- Technical decision: Use both Flutter `SystemChrome.setPreferredOrientations` and Android `screenOrientation="portrait"` so the orientation policy is enforced at the framework and activity levels.

### Tests
- [ ] Unit tests added/updated
- [x] Manual playtest completed (installed and launched debug APK on Samsung device `RFCX80NW55E`)
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Product owner should rotate the Galaxy S24 during gameplay to confirm the app remains portrait locked.

---

## [2026-06-13 11:05] - Fix gameplay HUD overflow on Galaxy S24

**Owner**: AI Assistant
**Type**: Bugfix
**Related US**: US-008
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Fixed the gameplay HUD and pause button row so it stays inside the safe area on narrow/high-density Android screens.
- Added scale-down behavior for HUD text to prevent right-side overflow when score, combo, lives, and status labels share the top row.

### Implementation Details
- File: `app/lib/main.dart`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Manual testing on a Samsung Galaxy S24 showed a Flutter right overflow beside the pause button.
- Technical decision: Keep the existing HUD content but give it bounded width with `Expanded`, a fixed pause button slot, and `FittedBox` scale-down for the HUD text row.

### Tests
- [ ] Unit tests added/updated
- [x] Manual playtest completed (emulator smoke check of gameplay HUD layout)
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Product owner should reinstall the updated debug APK on the Galaxy S24 to confirm the physical-device overflow is gone.

---

## [2026-06-13 00:20] - Create renamed local workspace folder

**Owner**: AI Assistant
**Type**: Chore/Docs
**Related US**: N/A
**Impact Scope**: Docs, Release

### Changes
- Created the renamed local workspace folder `C:\Users\hanak\Documents\X-Ray-Scan` from the pushed repository.
- Updated handoff notes so future local path references match the renamed repository folder.

### Implementation Details
- File: `docs/changelog/CHANGELOG.md`
- Reason: The product owner noticed the local folder still used the previous repository name after the GitHub repo rename.
- Technical decision: Create a fresh local folder from the pushed GitHub repository because Windows locks the active Codex workspace folder during this session; keep the Android package/application ID unchanged.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (`Test-Path`, `git status`, `git remote -v`, `git clone`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- No app code changed in this step.
- The old locked workspace folder can be removed after this Codex session releases it.

---

## [2026-06-13 00:15] - Update GitHub remote after repo rename

**Owner**: AI Assistant
**Type**: Chore/Docs
**Related US**: N/A
**Impact Scope**: Docs, Release

### Changes
- Updated the local `origin` remote to the renamed GitHub repository.
- Updated progress handoff notes to point to `https://github.com/thanhtaimrjoe/X-Ray-Scan.git`.

### Implementation Details
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The product owner renamed the GitHub repository after the product rename.
- Technical decision: Keep the active branch name unchanged and only update the repository remote URL.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (`git ls-remote`, `git remote -v`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Superseded by the later local workspace folder rename to `C:\Users\hanak\Documents\X-Ray-Scan`.

---

## [2026-06-13 00:08] - Rename product to X-Ray Scan

**Owner**: AI Assistant
**Type**: Chore/Docs
**Related US**: N/A
**Impact Scope**: Android, Docs, Release, Test

### Changes
- Renamed the product/app-facing name from Tap Sort Rush / X-Ray Inspector to X-Ray Scan.
- Renamed the Flutter package from `tap_sort_rush` to `xray_scan` and updated test imports.
- Updated Android display label, web metadata, README, concept, design, technical spec, release checklist, decision log, and progress tracking.
- Recorded the durable product naming decision while preserving the Android package/application ID.

### Implementation Details
- File: `README.md`
- File: `AGENTS.md`
- File: `docs/01_game_concept.md`
- File: `docs/03_game_design.md`
- File: `docs/05_technical_spec.md`
- File: `docs/06_release_checklist.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- File: `app/pubspec.yaml`
- File: `app/lib/main.dart`
- File: `app/android/app/src/main/AndroidManifest.xml`
- File: `app/test/widget_test.dart`
- File: `app/test/game/xray_inspector_rules_test.dart`
- File: `app/test/services/storage_service_test.dart`
- File: `app/web/index.html`
- File: `app/web/manifest.json`
- Reason: The product owner wanted a clearer repo/app name after the x-ray inspection pivot.
- Technical decision: Keep `com.auren.tapsortrush` unchanged because Android package changes are release-critical.

### Tests
- [x] Unit tests added/updated (imports and widget expectations updated)
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- GitHub repository rename is a separate step that depends on available repository permissions.

---

## [2026-06-12 23:55] - Repair Git metadata and pause compile error

**Owner**: AI Assistant
**Type**: Bugfix/Docs
**Related US**: US-007
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Restored the main repository Git metadata after a broken `.git` directory replaced the valid metadata.
- Fast-forwarded the main worktree to the already-pushed pause UI commit `495b733`.
- Fixed the pause/resume calls to use Flame `pauseEngine()` and `resumeEngine()`.
- Removed emoji prefixes from item database group titles to keep edited source text ASCII.
- Added handoff notes to progress tracking for future assistants.

### Implementation Details
- File: `app/lib/main.dart`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: The previous agent pushed a commit that did not compile locally and also left the main worktree with invalid Git metadata.
- Technical decision: Preserve the broken `.git` directory as `.git-broken-20260612-2344` and restore `.git-old` as the active Git metadata instead of deleting anything.

### Tests
- [x] Unit tests added/updated (no new tests needed; compile fix)
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- The temporary repo at `C:\Users\hanak\Documents\Tap-Sort-Rush-Temp` contains the same pushed pause commit and can be removed later after confirming no extra work is needed.

---

## [2026-06-12 16:45] - UI improvements and pause functionality

**Owner**: AI Assistant
**Type**: Feature, UI
**Related US**: US-007
**Impact Scope**: UI, Gameplay

### Changes
- Added pause button to HUD and pause screen with resume/menu options.
- Added sound toggle in pause screen with persistence.
- Fixed HUD spacing between score/combo/lives/event text for better readability.
- Fixed item database cards to expand fully to available width.

### Implementation Details
- File: `app/lib/main.dart`
- Reason: Improve user experience with pause functionality and better UI readability.
- Technical decision: Use built-in FlameGame pause/resume methods.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter analyze`)
- [x] Policy/ad placement checked (no ad behavior changed)

### Notes
- The original pause commit used invalid `pause()`/`resume()` calls and was fixed in a later bugfix entry.

---

## [2026-06-12 15:29] - Add item encyclopedia discovery loop

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-008, US-009, US-010
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Added a main-menu entry point for the item database.
- Added a two-choice encyclopedia index with Danger Items and Safe Items only.
- Added category database screens that show every item slot as locked or discovered.
- Added local unlock persistence for x-ray item discoveries.
- Connected gameplay discoveries so correct danger taps unlock danger items and correct safe-bag clears unlock safe items.
- Added tests for item discovery persistence and encyclopedia navigation.
- Updated concept, user stories, game design, technical spec, decision log, and progress tracking.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/lib/game/xray_inspector_game.dart`
- File: `app/lib/game/systems/xray_inspector_rules.dart`
- File: `app/lib/services/storage_service.dart`
- File: `app/test/services/storage_service_test.dart`
- File: `app/test/widget_test.dart`
- File: `docs/01_game_concept.md`
- File: `docs/02_user_stories.md`
- File: `docs/03_game_design.md`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Add a collection/progression hook that shows future mystery items and rewards correct inspection.
- Technical decision: Store discovered item IDs as a `shared_preferences` string list under `unlocked_xray_items`.

### Tests
- [x] Unit tests added/updated (`flutter test`)
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Database icons are still MVP placeholders; final item art should be replaced when individual x-ray sprites are extracted or redrawn.

---

## [2026-06-12 14:45] - Rebuild app as X-Ray Inspector MVP

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-001, US-003, US-004, US-006, US-008, US-009
**Impact Scope**: Gameplay, Android, Docs, Assets, Test, Policy

### Changes
- Replaced the lane-sort gameplay loop with an X-Ray Inspector suitcase scanning loop.
- Added tappable dangerous and safe x-ray object silhouettes based on the approved asset direction.
- Added direct scanner taps, safe-item score penalty, combo reset, missed-danger life loss, false-clear punishment, and safe-bag clear bonus.
- Updated the menu, HUD, gameplay screen, and game-over copy for the x-ray inspector direction.
- Added the approved x-ray asset sheet to Flutter assets for menu art direction.
- Replaced lane-sort unit tests with X-Ray Inspector rule tests.
- Updated README, technical spec, and progress tracking for the implemented pivot.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/lib/game/xray_inspector_game.dart`
- File: `app/lib/game/systems/xray_inspector_rules.dart`
- File: `app/assets/images/xray_asset_sheet_approved.png`
- File: `app/pubspec.yaml`
- File: `app/test/game/xray_inspector_rules_test.dart`
- File: `app/test/widget_test.dart`
- File: `README.md`
- File: `docs/05_technical_spec.md`
- File: `docs/07_tracking/progress.md`
- Reason: Implement the product-owner-approved Version B pivot using the approved x-ray visual benchmark.
- Technical decision: Use procedural Canvas/Flame x-ray silhouettes for the first rebuilt MVP and keep the approved PNG as app/menu art direction until production individual sprites are extracted or redrawn.

### Tests
- [x] Unit tests added/updated (`flutter test`)
- [ ] Manual playtest completed (no emulator/device attached to ADB during this pass)
- [x] Error handling checked (`flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no live ads, production IDs, package-name changes, or gameplay ad placement added)

### Notes
- Object scale, hit radius, suitcase speed, and clear timing still need device tuning.
- `adb` is available through the Android SDK path, but no running emulator/device was attached when checked.

---

## [2026-06-12 14:30] - Approve X-Ray Inspector visual direction

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-008, US-009
**Impact Scope**: Docs, Gameplay, Assets

### Changes
- Recorded the approved pivot from lane sorting toward an X-Ray Inspector suitcase inspection game.
- Added user stories for x-ray bag inspection and safe-item tap penalties.
- Updated game concept and game design notes with the danger tap, safe tap penalty, missed danger life loss, and clear safe bag loop.
- Added a durable decision for the X-Ray Inspector direction.
- Saved the approved x-ray object asset sheet at `docs/assets/xray_asset_sheet_approved.png`.
- Updated progress next steps to focus on the x-ray inspection MVP.

### Implementation Details
- File: `docs/01_game_concept.md`
- File: `docs/02_user_stories.md`
- File: `docs/03_game_design.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/assets/xray_asset_sheet_approved.png`
- Reason: The product owner approved the Version B x-ray inspector concept and the generated x-ray object visual benchmark.
- Technical decision: Keep the Android package name unchanged while treating X-Ray Inspector as the next product direction.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (documentation and asset-only change)
- [x] Policy/ad placement checked (no ad behavior changed; no live ads or production IDs added)

### Notes
- Current Flutter code still implements the lane-sort prototype and must be updated in a later gameplay implementation pass.
- Figma visual bible: `https://www.figma.com/design/oKUWVtHFIJPNJ2n5vJsBU7`

---

## [2026-06-12 12:48] - Neon arcade gameplay visuals

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-002, US-003
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Adopted a neon arcade visual direction for the MVP gameplay screen.
- Reworked falling items into glowing energy cores with diamond highlights and motion trails.
- Added a subtle moving grid background, stronger action-zone treatment, lane glyphs, and lane glow.
- Added success bursts, wrong-sort bursts, miss flash feedback, and tap lane pulse effects.
- Updated progress tracking and decision log for the new visual direction.

### Implementation Details
- File: `app/lib/game/tap_sort_game.dart`
- File: `app/lib/main.dart`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- Reason: Make the playable loop more visually appealing and easier to understand at a glance.
- Technical decision: Use Canvas/Flame-rendered procedural effects instead of external art assets so the MVP stays lightweight and license-safe.

### Tests
- [x] Unit tests added/updated (`flutter test`; no new rule tests needed because gameplay rules did not change)
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter analyze`, `flutter build apk --debug`, emulator install/launch with running PID and no fatal crash log)
- [x] Policy/ad placement checked (no ad placement changes; no live ads or production IDs added)

### Notes
- Visual intensity and lane readability should be reviewed during manual playtesting on device.

---

## [2026-06-12 12:45] - Fix debug crash from missing AdMob app ID

**Owner**: AI Assistant
**Type**: Bugfix
**Related US**: US-001
**Impact Scope**: Android, Ads, Policy

### Changes
- Added the Google Mobile Ads test application ID to the Android manifest.
- Fixed launch-time crash caused by `MobileAdsInitProvider` rejecting a missing AdMob app ID.

### Implementation Details
- File: `app/android/app/src/main/AndroidManifest.xml`
- Reason: `google_mobile_ads` initializes a native provider before Flutter starts, and Android requires the AdMob application ID metadata to be present.
- Technical decision: Use Google's sample/test AdMob app ID for development so no production ad ID or secret is committed.

### Tests
- [ ] Unit tests added/updated
- [ ] Manual playtest completed
- [x] Error handling checked (`adb logcat` crash diagnosis; rebuilt and reinstalled debug APK; confirmed running PID with no fatal crash log)
- [x] Policy/ad placement checked (test AdMob app ID only; no live ads or production IDs added)

### Notes
- This only unblocks app startup with the ads SDK dependency present; actual banner/interstitial/rewarded ad UI remains pending.

---

## [2026-06-12 12:30] - First playable gameplay loop

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-001, US-002, US-003, US-004, US-006
**Impact Scope**: Gameplay, Android, Docs, Test, Policy

### Changes
- Replaced the default Flutter counter app with the Tap Sort Rush shell.
- Added main menu, active gameplay, and game-over screens.
- Added a Flame-powered falling-item playfield with four colored tap lanes.
- Added score, combo, lives, game-over transition, and local high score persistence.
- Added unit/widget tests for core game rules and menu high score display.
- Updated release checklist and progress tracking for the first playable loop.

### Implementation Details
- File: `app/lib/main.dart`
- File: `app/lib/game/tap_sort_game.dart`
- File: `app/lib/game/systems/tap_sort_rules.dart`
- File: `app/lib/services/storage_service.dart`
- File: `app/test/game/tap_sort_rules_test.dart`
- File: `app/test/widget_test.dart`
- File: `docs/06_release_checklist.md`
- File: `docs/07_tracking/progress.md`
- Reason: Satisfy the MVP loop for starting a game, sorting falling items, building combo, losing/retrying, and persisting high score.
- Technical decision: Keep scoring, combo, lives, and game-over state in a pure Dart rules class so gameplay behavior can be unit tested separately from Flame rendering.

### Tests
- [x] Unit tests added/updated (`flutter test`)
- [ ] Manual playtest completed
- [x] Error handling checked (`flutter analyze`, `flutter build apk --debug`)
- [x] Policy/ad placement checked (no live ads added; gameplay screen has no ad placement; menu/game-over use placeholder banner areas only)

### Notes
- AdMob test ads, rewarded continue, pause, and sound toggle remain pending.
- Gameplay timing and action-zone tuning should be checked on an Android device or emulator.

---

## [2026-06-12 12:20] - Changelog Governance Alignment

**Owner**: AI Assistant
**Type**: Docs
**Related US**: N/A
**Impact Scope**: Docs, Release, Policy

### Changes
- Expanded `AGENTS.md` into a full development guideline modeled after the Shopping-Auren workflow.
- Made changelog recording mandatory for code, docs, specs, assets, release, and monetization changes.
- Added a stricter changelog template with related user stories, impact scope, implementation details, tests, and notes.
- Added Decision Log and Progress tracking documents.
- Updated README structure to include tracking docs.

### Implementation Details
- File: `AGENTS.md`
- File: `README.md`
- File: `docs/07_tracking/decisions.md`
- File: `docs/07_tracking/progress.md`
- File: `docs/changelog/CHANGELOG.md`
- Reason: Keep Tap Sort Rush reviewable as multiple AI assistants or contributors modify the repo over time.
- Technical decision: Track durable decisions separately from chronological changelog entries so future work can distinguish "what changed" from "why this direction is locked in."

### Tests
- [x] Unit tests added/updated (documentation-only change; no unit test needed)
- [x] Manual playtest completed (not applicable for documentation-only change)
- [x] Error handling checked (not applicable for documentation-only change)
- [x] Policy/ad placement checked (policy rules added to development workflow)

### Notes
- Future implementation work should update changelog first-class, not as an afterthought.

---

## [2026-06-12 11:58] - Flutter environment and app scaffold

**Owner**: AI Assistant
**Type**: Chore
**Related US**: N/A
**Impact Scope**: Android, Docs, Release

### Changes
- Installed Flutter stable 3.44.2 at `C:\Users\hanak\development\flutter`.
- Added Flutter SDK `bin` directory to the user PATH.
- Accepted Android SDK licenses through Flutter tooling.
- Scaffolded the initial Flutter app under `app/` with package namespace `com.auren.tapsortrush`.
- Added `flame`, `google_mobile_ads`, and `shared_preferences` dependencies.
- Normalized Android namespace and application ID to `com.auren.tapsortrush`.
- Set the Android display label to `Tap Sort Rush`.
- Updated README, technical spec, and release checklist with verified setup status.

### Implementation Details
- File: `app/pubspec.yaml`
- File: `app/android/`
- File: `app/lib/main.dart`
- File: `app/test/widget_test.dart`
- File: `README.md`
- File: `docs/05_technical_spec.md`
- File: `docs/06_release_checklist.md`
- Reason: Prepare the repository for Android mini game implementation and future AdMob integration.
- Technical decision: Keep Android and web platforms in the Flutter scaffold; Android remains the release target.

### Tests
- [x] Unit tests added/updated (`flutter test`)
- [x] Manual playtest completed (not applicable; scaffold only)
- [x] Error handling checked (`flutter build apk --debug`)
- [x] Policy/ad placement checked (AdMob dependency only; no ad placement yet)

### Notes
- Flutter doctor still reports Visual Studio missing for Windows desktop development. This is not required for Android builds.

---

## [2026-06-12 11:35] - Initial game repository specs

**Owner**: AI Assistant
**Type**: Docs
**Related US**: US-001, US-002, US-003, US-004, US-005, US-006, US-007
**Impact Scope**: Docs, Gameplay, Ads, Release

### Changes
- Created initial repository documentation for Tap Sort Rush.
- Defined MVP gameplay, screens, scoring, difficulty, and monetization approach.
- Added AdMob placement rules and Google Play release checklist.
- Added AI development guidelines and mandatory changelog format.
- Added initial Git ignore rules and app directory placeholder.

### Implementation Details
- File: `README.md`
- File: `AGENTS.md`
- File: `docs/01_game_concept.md`
- File: `docs/02_user_stories.md`
- File: `docs/03_game_design.md`
- File: `docs/04_monetization_ads.md`
- File: `docs/05_technical_spec.md`
- File: `docs/06_release_checklist.md`
- File: `.gitignore`
- File: `app/.gitkeep`
- Reason: Establish a clear spec-first foundation before implementing the mini game.
- Technical decision: Use Flutter + Flame + AdMob as the planned stack, with Android release as the first target.

### Tests
- [x] Unit tests added/updated (documentation-only change; no unit test needed)
- [x] Manual playtest completed (not applicable for documentation-only change)
- [x] Error handling checked (not applicable for documentation-only change)
- [x] Policy/ad placement checked (monetization policy notes included)

### Notes
- Flutter is not currently installed in PATH on this machine, so app scaffolding is pending.

---
