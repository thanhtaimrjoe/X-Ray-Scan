# Progress

This file tracks the current project state so future AI assistants and contributors can resume work without re-discovering context.

---

## Current Phase

**Phase**: Concept pivot and visual direction
**Status**: In progress
**Last updated**: 2026-06-12

## Completed

- Created the Tap Sort Rush repository.
- Added product specs, user stories, game design, monetization notes, technical spec, and release checklist.
- Installed Flutter stable 3.44.2 at `C:\Users\hanak\development\flutter`.
- Accepted Android SDK licenses.
- Scaffolded the Flutter app under `app/`.
- Added dependencies:
  - `flame`
  - `google_mobile_ads`
  - `shared_preferences`
- Set Android package/application ID to `com.auren.tapsortrush`.
- Set Android display label to `Tap Sort Rush`.
- Replaced the default Flutter counter app with the first playable Tap Sort Rush loop.
- Added main menu, gameplay, and game-over screens.
- Added four tap lanes, falling colored items, score, combo, lives, and local high score persistence.
- Added unit tests for score, combo multiplier, life loss, and game-over rules.
- Adopted a neon arcade MVP visual direction for the gameplay screen.
- Added glow, trails, lane glyphs, tap pulse feedback, success bursts, miss flashes, and a subtle moving grid background.
- Researched the casual mini-game direction and selected the X-Ray Inspector pivot over the lane-sort concept.
- Created the Figma visual bible for the x-ray scanner direction.
- Approved the x-ray object asset sheet as the visual benchmark and saved it at `docs/assets/xray_asset_sheet_approved.png`.
- Verified:
  - `flutter doctor -v`
  - `flutter test`
  - `flutter build apk --debug`

## In Progress

- Define the X-Ray Inspector MVP gameplay spec before changing code.

## Next Steps

1. Update implementation plan for the X-Ray Inspector pivot.
2. Replace lane-sort rules with x-ray bag inspection rules: danger tap, safe tap penalty, missed danger life loss, clear safe bag.
3. Implement scanner screen using the approved asset sheet as art direction.
4. Add or update unit tests for safe-tap penalty, combo reset, missed danger life loss, and clear-bag scoring.
5. Run `flutter test`, `flutter analyze`, and a debug APK build after gameplay code changes.

## Known Gaps

- Current code still implements the lane-sort prototype, not the approved X-Ray Inspector pivot.
- X-ray objects need production-ready in-game assets extracted or redrawn from the approved visual benchmark.
- Gameplay will need device playtesting and tuning after the pivot is implemented.
- Banner areas are placeholders; AdMob test ads are not integrated yet.
- No production AdMob IDs yet.
- No release signing config yet.
- No privacy policy URL yet.
- `flutter doctor` reports Visual Studio missing, but this only affects Windows desktop builds and is not required for Android MVP.
