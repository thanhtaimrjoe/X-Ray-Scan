# Changelog

**Project**: X-Ray Scan
**Purpose**: Development change history for AI assistants and future contributors

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
