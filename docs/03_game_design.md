# Game Design

## Game Mode

Level-based progression is the default MVP journey. The current build uses a 10-level `Airport Basics` pack with bag-clear objectives, star ratings, and local unlock persistence. Endless score attack remains a future secondary mode.

## Current Direction: X-Ray Scan

The current playable MVP uses an x-ray suitcase inspection loop. Players tap dangerous objects, avoid safe objects, and clear suitcases when no dangerous objects remain.

Approved next visual direction: anime airport inspection with a paused suitcase centered in the x-ray scanner. The player should get time to inspect the bag, mark dangerous items, then press Clear to resolve the bag.

## Board Layout

- Portrait orientation.
- Top area: HUD with score, combo, lives, and pause.
- Center area: large x-ray scanner field with a paused suitcase and readable item silhouettes.
- Bottom area: explicit Clear action button with marked-threat feedback above it.
- HUD: score, combo, lives, pause.

## Controls

Approved pivot control model:

- Player taps dangerous objects inside the x-ray suitcase.
- Player avoids tapping safe objects.
- Player can clear a suitcase when no dangerous object remains.
- Target interaction direction: each suitcase pauses in the scanner during inspection; after the player clears or fails the bag, the next suitcase enters.

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

- Time pressure or inspection allowances after the paused-bag version is implemented.
- Number of objects in a suitcase.
- Chance of multiple dangerous objects.
- Visual clutter from overlapping safe and dangerous silhouettes.

MVP tuning:

- Early levels should show 4-6 large readable items and usually one dangerous object.
- Later levels can add more items, more dangerous objects, and tighter clear requirements.
- The paused-bag flow should avoid unfair taps and emphasize inspection clarity on phone screens.

## Screens

### Main Menu

- Approved main menu layout/art reference is stored at `docs/assets/main_menu_visual_reference_approved.jpg`.
- App title.
- Subtitle: `World Customs Adventure`.
- Scanner and glowing x-ray suitcase hero art should be the first visual hook.
- Play button opens the level map or starts the selected/highest unlocked level.
- Current/highest unlocked level label.
- Level map button.
- Item database button.
- High score.
- Sound toggle.
- Banner ad area.
- The approved image is a layout/art reference; final button styling should be normalized with shared UI components across Play, Clear, Next, Continue, Retry, Map, Database, and Settings.

### Level Map

- Approved level map visual reference is stored at `docs/assets/level_map_visual_reference_approved.jpg`.
- World title and economy/status bar at the top.
- World 1 is `International Terminal`.
- A glowing cyan route connects 10 checkpoint nodes.
- Completed nodes use checkmarks plus star ratings and remain replayable.
- Current node uses the brightest cyan glow and drives the selected-level panel.
- Future unlocked nodes are dark numbered nodes without locks.
- Locked nodes are dim numbered nodes with small lock icons.
- Level 10 is a larger final scanner-gate milestone.
- Bottom selected-level panel shows level number, level name, best stars, Play, Database, and Back.
- The map should feel like an airport/customs journey, not a generic fantasy island path.

### Level Clear

- Approved level clear visual reference is stored at `docs/assets/level_clear_visual_reference_approved.jpg`.
- Level number.
- Score.
- Stars earned and best stars for that level.
- Bags cleared objective summary.
- New threat profile message when a level introduces a new danger item.
- Next, Retry, Menu buttons.
- Banner ad area.
- Result card should sit over a softly blurred airport scanner/checkpoint background.
- The reward/unlock panel can show a cyan x-ray profile icon for the newly introduced danger item.
- Button styling in the approved image is a concept reference; final styling should use shared primary/secondary UI components.

### Level Failed

- Approved level failed/rewarded continue visual reference is stored at `docs/assets/level_failed_visual_reference_approved.jpg`.
- Level number.
- Score and bag objective progress.
- Missed threats or `Threat left in bag` warning when applicable.
- Optional rewarded continue button when eligible and loaded.
- Retry and Map buttons.
- Banner ad area.
- Failed screen should keep the airport scanner background visible but dimmed, with soft warning accents instead of harsh alarm visuals.
- Rewarded continue must read as optional and should be separated from retry/map and banner ad placement.
- Button styling in the approved image is a concept reference; final styling should use shared primary/secondary UI components.

### Gameplay

- Full-screen play field.
- Score, combo, lives.
- Pause button.
- Portrait orientation locked.
- HUD scales down on narrow/high-density phone screens to avoid overflow.
- HUD shows score, combo, multiplier, and lives.
- A marked-threat counter such as `MARKED: 0/3` may sit above the Clear button.
- Momentary feedback labels such as FALSE TAP, BAG CLEAR, PERFECT, MISS, and THREAT LEFT appear as scanner/playfield pulses without blocking item inspection.
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
- Approved item database visual reference is stored at `docs/assets/item_database_visual_reference_approved.jpg`.
- Opens directly into a tabbed collection screen.
- Danger Items and Safe Items are the only category tabs for MVP.
- Danger Items is the default tab.
- Each tab shows category progress, such as `3/5 discovered`.
- The category grid is scrollable and shows all item slots so players can see future mystery items.
- Unlocked cards show a detailed cyan x-ray silhouette, item name, and short discovery note.
- Locked cards show a dark cyan silhouette, lock icon, `???`, and may show the locked item name in a dim style to give casual players a clear collection goal.

Unlock rules:

- Danger item unlocks when the player taps it correctly during gameplay.
- Safe item unlocks when the player correctly clears a suitcase containing it.
- Wrong safe taps and missed danger items do not unlock entries.

## Visual Style

Approved gameplay visual reference is stored at `docs/assets/gameplay_visual_reference_approved.jpg`.

The target gameplay screen combines an anime airport/customs environment with a large paused suitcase inside a cyan x-ray scanner. Outside the scanner uses polished anime airport art; inside the scanner uses detailed translucent cyan x-ray item art.

The approved x-ray object benchmark is stored at `docs/assets/xray_asset_sheet_approved.png` and in the Figma visual bible.

Prioritize:

- Recognizable real-world objects.
- Clear danger/safe detection by object form.
- Strong scanner glow and feedback.
- Mobile readability and frame rate.
- Large tappable item silhouettes; items are gameplay objects, not decoration.
- Cyan/default x-ray items that do not reveal danger status before player interaction.

## Audio

MVP can ship with minimal audio:

- Correct detection sound.
- Mistake sound.
- New high score sound.

Audio may be deferred if asset sourcing slows release.
