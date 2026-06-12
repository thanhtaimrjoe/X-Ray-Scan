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
- Rebuilt the playable Flutter app around the X-Ray Inspector loop.
- Added x-ray suitcase gameplay with tappable dangerous/safe objects, safe tap score penalties, missed danger life loss, false-clear punishment, clear bonus, score, combo, lives, and high score persistence.
- Added the approved x-ray asset sheet to the app menu art direction.
- Added unit tests for X-Ray Inspector scoring, combo, safe tap penalty, missed danger, false clear, and clear bonus.
- Verified:
  - `flutter doctor -v`
  - `flutter test`
  - `flutter analyze`
  - `flutter build apk --debug`

## In Progress

- Manual playtest the X-Ray Inspector loop on an Android device or emulator.

## Next Steps

1. Launch the debug APK on an emulator/device and tune object scale, suitcase speed, hit radius, and clear timing.
2. Extract or redraw production-ready individual object assets from the approved x-ray visual benchmark.
3. Add pause and sound toggle UI.
4. Integrate AdMob test ads on menu and game-over screens.
5. Add interstitial frequency and rewarded-continue rule tests before enabling those ad formats.

## Known Gaps

- X-ray objects need production-ready in-game assets extracted or redrawn from the approved visual benchmark.
- Gameplay will need device playtesting and tuning after the pivot is implemented.
- No Android device/emulator was attached during the rebuild pass, so install/launch smoke testing is still pending.
- Banner areas are placeholders; AdMob test ads are not integrated yet.
- No production AdMob IDs yet.
- No release signing config yet.
- No privacy policy URL yet.
- `flutter doctor` reports Visual Studio missing, but this only affects Windows desktop builds and is not required for Android MVP.
