# Game Design

## Game Mode

Endless score attack.

## Approved Pivot: X-Ray Scan

The next gameplay direction replaces color-lane sorting with an x-ray suitcase inspection loop. The existing lane-sort MVP remains a prototype baseline, but new design work should prioritize the inspection mechanic.

## Board Layout

- Portrait orientation.
- Top area: HUD with score, combo, lives, and pause.
- Center area: x-ray scanner field showing suitcase contents.
- Bottom area: explicit action buttons such as Clear/Hold when needed.
- HUD: score, combo, lives, pause.

## Controls

Approved pivot control model:

- Player taps dangerous objects inside the x-ray suitcase.
- Player avoids tapping safe objects.
- Player can clear a suitcase when no dangerous object remains.

Alternative for later:

- Drag, swipe, or hold-to-inspect individual objects if tap-only inspection is not expressive enough.

The tap-inspection model is preferred for the next MVP because it is more distinct from rhythm/tile games and creates a stronger visual hook.

## Colors

Use a monochrome cyan/teal x-ray scanner palette with danger/safe readability driven by object shape, silhouette, glow, and feedback states rather than text labels or color alone.

## Scoring

Base score:

- Dangerous object tapped: 10 points.
- Safe object tapped: -5 points and combo reset.
- Safe suitcase cleared: small bonus after tuning.
- Combo multiplier starts at 1.0.
- Every 10 combo increases multiplier by 0.25.

Example:

- Combo 0-9: 10 points.
- Combo 10-19: 12 or 13 points.
- Combo 20-29: 15 points.

## Lives and Mistakes

- Start with 3 lives.
- Missed dangerous object: -1 life and combo reset.
- Safe object tapped: score penalty and combo reset.
- Game over at 0 lives.

## Difficulty Curve

Difficulty increases through:

- Falling speed.
- Spawn interval.
- Color variety.
- Occasional near-back-to-back items.

MVP tuning:

- First 15 seconds: forgiving speed.
- 15-45 seconds: gradual speed increase.
- 45+ seconds: faster spawn interval.
- Cap speed to avoid unfair gameplay.

## Screens

### Main Menu

- App title.
- Play button.
- Item database button.
- High score.
- Sound toggle.
- Banner ad area.

### Gameplay

- Full-screen play field.
- Score, combo, lives.
- Pause button.
- No banner ad during active gameplay for MVP.

### Pause

- Resume.
- Restart.
- Menu.
- Sound toggle.

### Game Over

- Score.
- High score.
- Rewarded continue, if eligible and loaded.
- Retry.
- Menu.
- Banner ad area.

### Item Encyclopedia

- Opened from the main menu.
- First screen has two large choices only:
  - Danger Items
  - Safe Items
- Tapping either choice opens that category database.
- No All tab for MVP.
- Every category database shows all item slots so players can see future mystery items.
- Locked items appear as dark silhouettes with unknown labels.
- Unlocked items show name, category color, and a short discovery note.

Unlock rules:

- Danger item unlocks when the player taps it correctly during gameplay.
- Safe item unlocks when the player correctly clears a suitcase containing it.
- Wrong safe taps and missed danger items do not unlock entries.

## Visual Style

Arcade x-ray scanner visuals with realistic but readable object silhouettes. Approved visual benchmark is stored at `docs/assets/xray_asset_sheet_approved.png` and in the Figma visual bible.

Prioritize:

- Recognizable real-world objects.
- Clear danger/safe detection by object form.
- Strong scanner glow and feedback.
- Mobile readability and frame rate.

## Audio

MVP can ship with minimal audio:

- Correct sort sound.
- Mistake sound.
- New high score sound.

Audio may be deferred if asset sourcing slows release.
