# Changelog

**Project**: Tap Sort Rush
**Purpose**: Development change history for AI assistants and future contributors

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
