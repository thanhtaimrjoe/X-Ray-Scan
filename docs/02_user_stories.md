# User Stories

## US-001 - Start a Game

As a player, I want to start a game from the main menu so that I can play immediately.

### Acceptance Criteria

- The main menu has a clear play action.
- Tapping play starts the game within one second on a typical Android device.
- The first game starts without showing an interstitial ad.

## US-002 - Detect Dangerous Objects

As a player, I want to tap dangerous objects inside x-ray suitcases so that careful inspection earns points.

### Acceptance Criteria

- Suitcases show a mix of safe and dangerous object silhouettes.
- Dangerous objects are recognizable by shape, not text labels.
- Correct danger taps increase score.
- Correct danger taps increase combo.
- Controls are responsive and usable with one hand.

## US-003 - Build Combo Through Inspection

As a player, I want correct inspection actions to increase my combo so that skilled play feels rewarding.

### Acceptance Criteria

- Consecutive danger detections or correct safe-bag clears increase combo.
- Safe-item taps, missed dangerous objects, and false clears reset combo.
- Score bonus increases at combo thresholds.
- Combo feedback is visible but does not block gameplay.

## US-004 - Lose and Retry

As a player, I want a clear game-over screen so that I can retry quickly.

### Acceptance Criteria

- Game over displays score and high score.
- Retry starts a new round.
- Return to menu is available.
- Interstitial ads only appear after configured frequency rules.

## US-005 - Continue With Rewarded Ad

As a player, I want one optional ad-based continue so that I can extend a good run.

### Acceptance Criteria

- Continue option appears only when rewarded ad is available.
- Player can decline and proceed to game over.
- Watching the ad grants one continue.
- Continue cannot be chained infinitely.

## US-006 - Persist High Score

As a player, I want my high score saved locally so that I can improve over time.

### Acceptance Criteria

- High score persists after app restart.
- New high score is clearly indicated.
- Storage failure does not crash the app.

## US-007 - Control Sound

As a player, I want to toggle sound so that I can play quietly.

### Acceptance Criteria

- Sound toggle is available from menu or settings.
- Preference persists locally.
- Muted state applies to future sessions.

## US-008 - Inspect X-Ray Bags

As a player, I want to scan suitcase contents and identify dangerous items so that each round feels like a quick visual challenge.

### Acceptance Criteria

- Each suitcase shows recognizable x-ray object silhouettes.
- Dangerous and safe objects are distinguishable by shape, not hidden text or color alone.
- Tapping a dangerous object increases score and combo.
- Letting a dangerous object pass reduces lives and resets combo.
- The scanner view remains readable on a typical Android phone screen.

## US-009 - Penalize Safe-Item Taps

As a player, I want mistakes to matter when I tap safe objects so that the game rewards careful inspection instead of random tapping.

### Acceptance Criteria

- Tapping a safe object applies a score penalty.
- Tapping a safe object resets combo.
- Wrong-tap feedback is visible without blocking the next action.
- The score penalty cannot reduce game clarity or trigger ads.

## US-010 - Discover Item Encyclopedia

As a player, I want a database of dangerous and safe x-ray items so that I can see what I have discovered and feel there are more hidden objects to find.

### Acceptance Criteria

- The encyclopedia entry point is available from the main menu.
- The item database opens directly into a tabbed collection screen.
- Danger Items and Safe Items are available as category tabs.
- Each category tab shows all item slots in that category.
- Undiscovered items appear as dark locked silhouettes or unknown profiles.
- Category progress shows discovered count and total count.
- Correctly detecting a dangerous item unlocks that danger item.
- Correctly clearing a safe bag unlocks the safe items inside it.
- Tapping a safe item by mistake does not unlock that safe item.
- Discovery progress persists locally after app restart.

## US-011 - Stay in Portrait Orientation

As a player, I want the game to stay in portrait orientation so that the scanner and controls remain readable during play.

### Acceptance Criteria

- The app launches in portrait orientation.
- Rotating the phone does not switch gameplay into landscape.
- HUD, scanner, and Clear action remain readable on a typical Android phone screen.

## US-012 - Avoid HUD Overflow

As a player, I want the HUD and pause button to fit on my phone screen so that I can read status and pause reliably.

### Acceptance Criteria

- Score, combo, lives, and feedback text stay inside the safe area.
- The pause button remains visible and tappable on Galaxy S24-class screens.
- HUD text scales down instead of overflowing horizontally.
