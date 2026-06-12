# Game Design

## Game Mode

Endless score attack.

## Board Layout

- Portrait orientation.
- Top area: spawn zone.
- Center area: falling item field.
- Bottom area: three or four color lanes.
- HUD: score, combo, lives, pause.

## Controls

MVP control model:

- Player taps a target lane when an item reaches the action zone.
- The active falling item is sorted into the tapped lane.

Alternative for later:

- Drag or swipe individual items into lanes.

The tap-lane model is preferred for MVP because it is simpler, faster to tune, and easier to use on small screens.

## Colors

Use high-contrast, colorblind-friendlier combinations where possible. Each color should also have a shape or icon marker in later versions if accessibility issues appear.

Initial colors:

- Blue
- Green
- Yellow
- Red

## Scoring

Base score:

- Correct sort: 10 points.
- Combo multiplier starts at 1.0.
- Every 10 combo increases multiplier by 0.25.

Example:

- Combo 0-9: 10 points.
- Combo 10-19: 12 or 13 points.
- Combo 20-29: 15 points.

## Lives and Mistakes

- Start with 3 lives.
- Wrong lane: -1 life and combo reset.
- Missed item: -1 life and combo reset.
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

## Visual Style

Simple, crisp 2D shapes. Prioritize clarity and frame rate over detailed art.

## Audio

MVP can ship with minimal audio:

- Correct sort sound.
- Mistake sound.
- New high score sound.

Audio may be deferred if asset sourcing slows release.

