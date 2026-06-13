# Technical Spec

## Platform

Android first.

## Product Name

`X-Ray Scan`

## Framework

Planned:

- Flutter stable 3.44.2.
- Flame for the game loop and rendering.
- google_mobile_ads for AdMob.
- shared_preferences for local settings and high score.

Flutter is installed at `C:\Users\hanak\development\flutter`, and the initial Flutter project is scaffolded under `app/`.

## Android Package

`com.auren.tapsortrush`

This package name is intentionally preserved after the product rename. It can be changed before first Play Console upload only with a release-critical decision. After release, package name should be treated as permanent.

## Project Layout

After Flutter setup:

```text
app/
├── android/
├── lib/
│   ├── main.dart
│   ├── game/
│   │   ├── xray_inspector_game.dart
│   │   ├── components/
│   │   └── systems/
│   ├── screens/
│   ├── services/
│   │   ├── ads_service.dart
│   │   └── storage_service.dart
│   └── config/
├── web/
└── test/
```

## Asset Pipeline

Production visual assets should follow `docs/08_asset_pipeline.md`.

App-integrated image assets should live under:

```text
app/assets/images/
  backgrounds/
  items/danger/
  items/safe/
  ui/
```

Design references and generator candidates should live under `docs/assets/`, not directly in app runtime folders, until they are approved for integration.

## Architecture

### Game Layer

Responsibilities:

- Spawn items.
- Update positions.
- Detect action-zone timing.
- Resolve player input.
- Track score, combo, lives.
- Emit game state changes.

Current implementation note:

- `xray_inspector_game.dart` renders the scanner, suitcase, object silhouettes, tap feedback, and clear action.
- `xray_inspector_rules.dart` keeps danger taps, safe tap penalties, missed danger life loss, false clear, clear bonus, perfect clear bonus, combo multiplier, and game-over behavior testable outside Flame.
- `level_progression_rules.dart` keeps level configs, bag-clear objectives, star thresholds, unlock rules, and best-score/star updates testable outside Flame.
- `ad_break_rules.dart` keeps interstitial frequency and rewarded-continue eligibility testable outside the Google Mobile Ads SDK.

### UI Layer

Responsibilities:

- Main menu.
- Pause overlay.
- Game over overlay.
- Settings controls.
- Ad containers.

### Services

Responsibilities:

- `AdsService`: initialize ads, load/show banners, interstitials, rewarded ads.
- `StorageService`: save high score, settings, item discovery, and level progression.

## Game State

States:

- `menu`
- `playing`
- `paused`
- `levelClear`
- `levelFailed`
- `adShowing`

## Local Storage

Keys:

- `high_score`
- `sound_enabled`
- `rounds_since_interstitial`
- `unlocked_xray_items`
- `highest_unlocked_level`
- `level_best_scores`
- `level_best_stars`

`unlocked_xray_items` stores discovered item IDs as a string list so the item encyclopedia can persist progress locally without a backend.

`level_best_scores` and `level_best_stars` store JSON maps keyed by level number.

## Ads Configuration

Use test IDs by default in debug builds.

Production IDs should be injected with build-time config or a local file excluded from Git.

## Testing Strategy

### Unit Tests

- Score calculation.
- Combo multiplier.
- Lives and game-over transition.
- Interstitial frequency cap.
- Rewarded continue eligibility.

### Manual Tests

- First launch.
- Play, pause, resume.
- Game over and retry.
- High score persistence.
- Item discovery persistence.
- Test banner loads.
- Test interstitial frequency.
- Test rewarded continue.
- Offline behavior.

## Build Commands

Expected commands after Flutter install:

```bash
cd app
flutter pub get
flutter test
flutter build appbundle --release
```

## Release Artifact

Google Play upload artifact:

```text
app/build/app/outputs/bundle/release/app-release.aab
```

## Secrets and Signing

Do not commit:

- Android keystore files.
- `key.properties`
- Production AdMob IDs if they are kept in local config.
- Any API keys not intended for public client use.
