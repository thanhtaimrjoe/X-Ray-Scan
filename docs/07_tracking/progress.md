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
- Added a two-branch item encyclopedia with Danger and Safe databases.
- Added local item discovery persistence for correctly detected dangerous items and correctly cleared safe items.
- Verified:
  - `flutter doctor -v`
  - `flutter test`
  - `flutter analyze`
  - `flutter build apk --debug`

## In Progress

- Manual playtest the X-Ray Inspector loop on an Android device or emulator.

## Handoff Notes

- Active branch: `codex/neon-arcade-visuals`.
- Remote repository: `https://github.com/thanhtaimrjoe/Tap-Sort-Rush.git`.
- Current playable direction: `X-Ray Inspector`, not the original color lane-sort prototype.
- Android package/application ID remains `com.auren.tapsortrush`.
- Do not rename the package or add production AdMob IDs without a release-critical decision and changelog entry.
- Approved visual benchmark:
  - Figma visual bible: `https://www.figma.com/design/oKUWVtHFIJPNJ2n5vJsBU7`
  - Repo asset: `docs/assets/xray_asset_sheet_approved.png`
  - App asset: `app/assets/images/xray_asset_sheet_approved.png`
- Core gameplay files:
  - `app/lib/main.dart`
  - `app/lib/game/xray_inspector_game.dart`
  - `app/lib/game/systems/xray_inspector_rules.dart`
  - `app/lib/services/storage_service.dart`
- Core tests:
  - `app/test/game/xray_inspector_rules_test.dart`
  - `app/test/services/storage_service_test.dart`
  - `app/test/widget_test.dart`
- Latest debug APK path: `app/build/app/outputs/flutter-apk/app-debug.apk`.
- ADB direct path on this machine: `C:\Users\hanak\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
- AVD name available on this machine: `TapSortRush_Test`.
- Git recovery note: a previous agent renamed valid metadata to `.git-old` and left an invalid `.git` without `HEAD`/`config`; the valid metadata was restored, and the broken directory was preserved as `.git-broken-20260612-2344`.
- A temporary clone exists at `C:\Users\hanak\Documents\Tap-Sort-Rush-Temp`; it has no known unique changes beyond the pushed pause commit, but verify before deleting.
- Next agent should install the latest debug APK to `TapSortRush_Test`, manually playtest pause/resume, sound toggle, scanner loop, and item database, then tune object readability/hitboxes/timing.

## Next Steps

1. Launch the debug APK on an emulator/device and tune object scale, suitcase speed, hit radius, clear timing, and encyclopedia readability.
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
