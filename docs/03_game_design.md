# Game Design

## Game Mode

Endless score attack.

## Current Direction: X-Ray Scan

The current playable MVP uses an x-ray suitcase inspection loop. Players tap dangerous objects, avoid safe objects, and clear suitcases when no dangerous objects remain.

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

- Dangerous object tapped: 100 points times the current combo multiplier.
- Safe object tapped: -50 points and combo reset.
- Safe suitcase cleared: 50 points times the current combo multiplier.
- Perfect suitcase clear: flat 100 point bonus when the player clears a bag without false taps, missed danger items, or false clears.
- Combo multiplier starts at 1.0.
- Every 5 combo increases multiplier by 0.5.
- Combo multiplier is capped at 3.0.

Example:

- Combo 0-4: 100 points per dangerous object.
- Combo 5-9: 150 points per dangerous object.
- Combo 10-14: 200 points per dangerous object.
- Combo 20+: 300 points per dangerous object.

## Lives and Mistakes

- Start with 3 lives.
- Missed dangerous object: -1 life and combo reset.
- Safe object tapped: score penalty and combo reset.
- Game over at 0 lives.
- Pressing Clear before a suitcase reaches the scanner does nothing.

## Difficulty Curve

Difficulty increases through:

- Suitcase movement speed.
- Number of objects in a suitcase.
- Chance of multiple dangerous objects.
- Visual clutter from overlapping safe and dangerous silhouettes.

MVP tuning:

- First 15 seconds: forgiving suitcase speed and usually one dangerous object.
- 15-45 seconds: gradual suitcase speed increase.
- 35+ seconds: occasional suitcases with two dangerous objects.
- Cap suitcase speed to avoid unfair taps on phone screens.

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
- Portrait orientation locked.
- HUD scales down on narrow/high-density phone screens to avoid overflow.
- HUD shows score, combo, multiplier, and lives.
- Momentary feedback labels such as MARKED, FALSE TAP, BAG CLEAR, PERFECT, MISS, and THREAT LEFT appear as scanner/playfield pulses instead of occupying persistent HUD space.
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

- Correct detection sound.
- Mistake sound.
- New high score sound.

Audio may be deferred if asset sourcing slows release.
