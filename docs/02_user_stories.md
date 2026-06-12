# User Stories

## US-001 - Start a Game

As a player, I want to start a game from the main menu so that I can play immediately.

### Acceptance Criteria

- The main menu has a clear play action.
- Tapping play starts the game within one second on a typical Android device.
- The first game starts without showing an interstitial ad.

## US-002 - Sort Falling Items

As a player, I want to sort falling items into matching color lanes so that I can score points.

### Acceptance Criteria

- Items spawn with visible colors.
- Lanes have matching color indicators.
- Correct sort increases score.
- Incorrect sort reduces lives or breaks combo.
- Controls are responsive and usable with one hand.

## US-003 - Build Combo

As a player, I want correct streaks to increase my combo so that skilled play feels rewarding.

### Acceptance Criteria

- Consecutive correct sorts increase combo.
- Mistakes reset combo.
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

