# Tap Sort Rush

Tap Sort Rush is a small Android-first 2D reflex game designed for short play sessions and Google AdMob monetization. The current playable direction is **X-Ray Inspector**, an x-ray suitcase inspection game.

## Product Goal

Build a lightweight casual game that is easy to publish, easy to replay, and safe to monetize with ads without relying on child-directed positioning.

## Core Loop

1. Suitcases pass through an x-ray scanner.
2. The player taps hidden dangerous objects inside the suitcase.
3. Tapping safe objects applies a score penalty and resets combo.
4. Clearing a safe suitcase gives a small bonus.
5. Missed dangerous objects reduce lives until game over.

## Planned Tech Stack

- Flutter
- Flame game engine
- google_mobile_ads
- SharedPreferences for local high score/settings
- Android App Bundle release for Google Play

## Repository Structure

```text
Tap-Sort-Rush/
├── docs/
│   ├── 01_game_concept.md
│   ├── 02_user_stories.md
│   ├── 03_game_design.md
│   ├── 04_monetization_ads.md
│   ├── 05_technical_spec.md
│   ├── 06_release_checklist.md
│   ├── 07_tracking/
│   │   ├── decisions.md
│   │   └── progress.md
│   └── changelog/CHANGELOG.md
├── app/
│   └── Flutter project, created after Flutter is installed
└── AGENTS.md
```

## Current Status

Flutter 3.44.2 is installed locally at `C:\Users\hanak\development\flutter`, and the initial Flutter project has been scaffolded under `app/`.

Verified:

- `flutter doctor -v`
- `flutter test`
- `flutter analyze`
- `flutter build apk --debug`
