# Progress

This file tracks the current project state so future AI assistants and contributors can resume work without re-discovering context.

---

## Current Phase

**Phase**: X-Ray Scan playable MVP
**Status**: In progress
**Last updated**: 2026-06-13

## Completed

- Created the original repository before the X-Ray Scan product rename.
- Added product specs, user stories, game design, monetization notes, technical spec, and release checklist.
- Installed Flutter stable 3.44.2 at `C:\Users\hanak\development\flutter`.
- Accepted Android SDK licenses.
- Scaffolded the Flutter app under `app/`.
- Added dependencies:
  - `flame`
  - `google_mobile_ads`
  - `shared_preferences`
- Set Android package/application ID to `com.auren.tapsortrush`.
- Set Android display label to `X-Ray Scan`.
- Replaced the default Flutter counter app with the first playable lane-sort prototype loop.
- Added main menu, gameplay, and game-over screens.
- Added four tap lanes, falling colored items, score, combo, lives, and local high score persistence.
- Added unit tests for score, combo multiplier, life loss, and game-over rules.
- Adopted a neon arcade MVP visual direction for the gameplay screen.
- Added glow, trails, lane glyphs, tap pulse feedback, success bursts, miss flashes, and a subtle moving grid background.
- Researched the casual mini-game direction and selected the x-ray inspection pivot over the lane-sort concept.
- Created the Figma visual bible for the x-ray scanner direction.
- Approved the x-ray object asset sheet as the visual benchmark and saved it at `docs/assets/xray_asset_sheet_approved.png`.
- Rebuilt the playable Flutter app around the x-ray suitcase inspection loop.
- Added x-ray suitcase gameplay with tappable dangerous/safe objects, safe tap score penalties, missed danger life loss, false-clear punishment, clear bonus, score, combo, lives, and high score persistence.
- Added the approved x-ray asset sheet to the app menu art direction.
- Added unit tests for x-ray inspection scoring, combo, safe tap penalty, missed danger, false clear, and clear bonus.
- Added a two-branch item encyclopedia with Danger and Safe databases.
- Added local item discovery persistence for correctly detected dangerous items and correctly cleared safe items.
- Renamed the GitHub repository and local `origin` remote to `X-Ray-Scan`.
- Completed physical-device playtesting on a Samsung Galaxy S24-class device and fixed the discovered HUD overflow and landscape rotation issues.
- Updated stale lane-sort user stories and difficulty tuning notes so the specs match the X-Ray Scan loop.
- Integrated AdMob test banner ads on the main menu and game-over screens.
- Added testable interstitial frequency and rewarded-continue eligibility rules.
- Revised scoring for stronger arcade feedback: 100-point danger taps, 50-point clear bonuses, 50-point safe-tap penalties, 100-point perfect clear bonuses, faster combo tiers, and player-facing feedback labels.
- Verified:
  - `flutter doctor -v`
  - `flutter test`
  - `flutter analyze`
  - `flutter build apk --debug`
  - Samsung device install/launch through ADB

## In Progress

- Prepare the next MVP slice: level-based progression vertical slice.

## Handoff Notes

- Active branch: `codex/neon-arcade-visuals`.
- Remote repository: `https://github.com/thanhtaimrjoe/X-Ray-Scan.git`.
- Current product/app name: `X-Ray Scan`, not the original color lane-sort prototype name.
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
- Current renamed workspace path: `C:\Users\hanak\Documents\X-Ray-Scan`.
- The old active Codex session folder may remain at `C:\Users\hanak\Documents\Tap-Sort-Rush` until the session releases its Windows file lock.
- A temporary clone exists at `C:\Users\hanak\Documents\Tap-Sort-Rush-Temp`; it has no known unique changes beyond the pushed pause commit, but verify before deleting.
- Next agent should read `docs/08_level_progression_plan.md` and implement a small level progression vertical slice before expanding content or monetization, then keep using the connected Samsung device for smoke checks when available.

## Next Steps

1. Implement a 3-level progression vertical slice with level objectives, level clear/fail screens, stars, and persisted unlock progress.
2. Expand the first level pack toward 10 `Airport Basics` levels if the vertical slice feels good.
3. Tie item unlock pacing to level progression, especially danger item introductions.
4. Extract or redraw production-ready individual object assets from the approved x-ray visual benchmark.
5. Implement interstitial and rewarded ads using Google test ad unit IDs after level clear/fail flow exists.
6. Tune object scale, suitcase speed, hit radius, clear timing, and encyclopedia readability based on further physical-device playtests.

## Known Gaps

- X-ray objects need production-ready in-game assets extracted or redrawn from the approved visual benchmark.
- Gameplay can still benefit from additional tuning passes after more physical-device playtests.
- The game needs a level-based journey because pure endless score attack lost excitement after several playtest rounds.
- Interstitial and rewarded ads have rules/tests but are not integrated with the SDK yet.
- No production AdMob IDs yet.
- No release signing config yet.
- No privacy policy URL yet.
- `flutter doctor` reports Visual Studio missing, but this only affects Windows desktop builds and is not required for Android MVP.
