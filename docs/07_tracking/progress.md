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
- Added a 3-level progression vertical slice with objectives, stars, unlock persistence, and level clear/fail screens.
- Added pure Dart level progression rules and storage persistence for highest unlocked level, best scores, and best stars.
- Connected gameplay spawning to per-level danger/safe pools and speed tuning.
- Expanded `Airport Basics` from the 3-level slice to a full 10-level pack with late-pack danger introductions and broader safe-item clutter.
- Updated progression tests and persistence coverage so level unlocks clamp and render correctly across the full 10-level pack.
- Wired interstitial and rewarded ads using Google Mobile Ads SDK to level clear/fail breakpoints, implementing rewarded continues.
- Approved the anime airport paused-suitcase gameplay visual direction and saved the reference at `docs/assets/gameplay_visual_reference_approved.jpg`.
- Approved the International Terminal level map visual direction and saved the reference at `docs/assets/level_map_visual_reference_approved.jpg`.
- Approved the tabbed Item Database visual direction and saved the reference at `docs/assets/item_database_visual_reference_approved.jpg`.
- Approved the Main Menu layout/art direction and saved the reference at `docs/assets/main_menu_visual_reference_approved.jpg`.
- Approved the Level Clear and Level Failed/rewarded continue result screen concepts and saved references at `docs/assets/level_clear_visual_reference_approved.jpg` and `docs/assets/level_failed_visual_reference_approved.jpg`.
- Verified:
  - `flutter test` (34 tests)
  - `flutter analyze`
  - `flutter build apk --debug`
  - Samsung device install/launch through ADB (`RFCX80NW55E`)

## In Progress

- Normalize generated button treatments into shared primary/secondary UI components during implementation.
- Convert approved visual references into Flutter UI: main menu, level map, paused gameplay, result screens, and tabbed item database.
- Update the playable item database from the old two-card entry flow to the approved tabbed collection flow.
- Convert the playable loop from moving suitcases to paused suitcase inspection.
- Level select screen (allow replaying any unlocked level from main menu).
- Sound engine integration using `_soundEnabled` flag.

## Handoff Notes

- Active branch: `main`.
- Remote repository: `https://github.com/thanhtaimrjoe/X-Ray-Scan.git`.
- Current product/app name: `X-Ray Scan`, not the original color lane-sort prototype name.
- Android package/application ID remains `com.auren.tapsortrush`.
- Do not rename the package or add production AdMob IDs without a release-critical decision and changelog entry.
- Approved visual benchmark:
  - Figma visual bible: `https://www.figma.com/design/oKUWVtHFIJPNJ2n5vJsBU7`
  - Gameplay screen reference: `docs/assets/gameplay_visual_reference_approved.jpg`
  - Level map reference: `docs/assets/level_map_visual_reference_approved.jpg`
  - Item database reference: `docs/assets/item_database_visual_reference_approved.jpg`
  - Main menu reference: `docs/assets/main_menu_visual_reference_approved.jpg`
  - Level clear reference: `docs/assets/level_clear_visual_reference_approved.jpg`
  - Level failed/rewarded continue reference: `docs/assets/level_failed_visual_reference_approved.jpg`
  - Repo asset: `docs/assets/xray_asset_sheet_approved.png`
  - App asset: `app/assets/images/xray_asset_sheet_approved.png`
- Core gameplay files:
  - `app/lib/main.dart`
  - `app/lib/game/xray_inspector_game.dart`
  - `app/lib/game/systems/xray_inspector_rules.dart`
  - `app/lib/game/systems/level_progression_rules.dart`
  - `app/lib/services/storage_service.dart`
- Core tests:
  - `app/test/game/xray_inspector_rules_test.dart`
  - `app/test/game/level_progression_rules_test.dart`
  - `app/test/services/storage_service_test.dart`
  - `app/test/widget_test.dart`
- Latest debug APK path: `app/build/app/outputs/flutter-apk/app-debug.apk`.
- ADB direct path on this machine: `C:\Users\hanak\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
- AVD name available on this machine: `TapSortRush_Test`.
- Git recovery note: a previous agent renamed valid metadata to `.git-old` and left an invalid `.git` without `HEAD`/`config`; the valid metadata was restored, and the broken directory was preserved as `.git-broken-20260612-2344`.
- Current renamed workspace path: `C:\Users\hanak\Documents\X-Ray-Scan`.
- The old active Codex session folder may remain at `C:\Users\hanak\Documents\Tap-Sort-Rush` until the session releases its Windows file lock.
- A temporary clone exists at `C:\Users\hanak\Documents\Tap-Sort-Rush-Temp`; it has no known unique changes beyond the pushed pause commit, but verify before deleting.
- Next agent should continue polish/tuning on the 10-level pack and validate the integrated interstitial/rewarded test-ad flows on device.

## Next Steps

1. Define shared primary/secondary button components so generated references use one implementation style.
2. Implement paused-suitcase inspection so bags stop in the scanner until the player marks items and presses Clear.
3. Implement the International Terminal level map with replayable nodes.
4. Replace the old two-card item encyclopedia entry with the tabbed Item Database.
5. Restyle Main Menu and result screens against the approved references.
6. Validate interstitial and rewarded test-ad flows on a physical device or emulator.
7. Extract or redraw production-ready individual object assets from the approved x-ray visual benchmark.
8. Tune object scale, hit radius, clear timing, and encyclopedia readability based on further physical-device playtests.

## Known Gaps

- X-ray objects need production-ready in-game assets extracted or redrawn from the approved visual benchmark.
- The current playable build still uses moving suitcases; the approved next design uses paused suitcase inspection.
- The current playable item encyclopedia still uses the older two-card entry flow; the approved next design uses direct Danger/Safe tabs.
- Gameplay can still benefit from additional tuning passes after more physical-device playtests.
- The game now has a 10-level journey, but it still needs tuning passes to validate pacing and clarity on physical devices.
- Interstitial and rewarded ads are integrated with Google test IDs, but still need physical-device flow validation.
- No production AdMob IDs yet.
- No release signing config yet.
- No privacy policy URL yet.
- `flutter doctor` reports Visual Studio missing, but this only affects Windows desktop builds and is not required for Android MVP.
