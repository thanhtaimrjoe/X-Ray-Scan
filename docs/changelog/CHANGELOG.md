# Changelog

**Project**: Tap Sort Rush
**Purpose**: Development change history for AI assistants and future contributors

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
