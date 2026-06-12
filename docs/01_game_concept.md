# Game Concept

## Working Title

X-Ray Scan

## Approved Pivot Direction

The approved product direction is an x-ray inspection reflex game called **X-Ray Scan**. The Android package remains `com.auren.tapsortrush` for release safety until a release-critical package decision is made.

## Elevator Pitch

A fast x-ray inspection game where players scan moving suitcases, tap hidden dangerous objects, avoid tapping safe items, and chase high scores in short sessions.

## Target Audience

- Casual Android users.
- Players who enjoy short reflex games.
- Not designed, marketed, or declared as a children-focused app.

## Primary Goal

Create a simple game that can be completed, polished, monetized with AdMob, and released on Google Play with low operational complexity.

## Core Gameplay

Suitcases move through an x-ray scanner. Each suitcase contains recognizable real-world object silhouettes. The player taps dangerous objects before the suitcase clears the scanner. Tapping a dangerous object increases score and combo. Tapping a safe object applies a score penalty and breaks combo. Letting a dangerous object pass costs a life. The game ends when lives reach zero.

## Session Length

Target session length: 30 seconds to 3 minutes.

## Monetization Fit

Ads should appear at natural breaks:

- Banner on menu and game-over screen.
- Interstitial after every 3 to 5 completed rounds, never after every round.
- Rewarded ad for one continue after game over.

## MVP Scope

- Main menu.
- Single endless game mode.
- Score, combo, lives, high score.
- Game over screen.
- X-ray suitcase inspection screen.
- Dangerous and safe object sets using readable real-world silhouettes.
- Item encyclopedia with separate Danger and Safe databases.
- Locked item silhouettes that reveal details after correct discovery.
- Basic sound toggles.
- Local high score.
- AdMob test ads.
- Android release build configuration.

## Out of Scope for MVP

- Online leaderboard.
- Account login.
- Multiplayer.
- In-app purchases.
- Complex character progression.
- Child-directed app experience.
