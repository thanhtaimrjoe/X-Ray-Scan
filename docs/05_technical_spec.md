# Technical Spec

## Platform

Android first.

## Framework

Planned:

- Flutter stable 3.44.2.
- Flame for the game loop and rendering.
- google_mobile_ads for AdMob.
- shared_preferences for local settings and high score.

Flutter is installed at `C:\Users\hanak\development\flutter`, and the initial Flutter project is scaffolded under `app/`.

## Proposed App Package

`com.auren.tapsortrush`

This can be changed before first Play Console upload. After release, package name should be treated as permanent.

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
- `xray_inspector_rules.dart` keeps danger taps, safe tap penalties, missed danger life loss, false clear, clear bonus, combo, and game-over behavior testable outside Flame.

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
- `StorageService`: save high score and settings.

## Game State

States:

- `menu`
- `playing`
- `paused`
- `gameOver`
- `adShowing`

## Local Storage

Keys:

- `high_score`
- `sound_enabled`
- `rounds_since_interstitial`
- `unlocked_xray_items`

`unlocked_xray_items` stores discovered item IDs as a string list so the item encyclopedia can persist progress locally without a backend.

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
