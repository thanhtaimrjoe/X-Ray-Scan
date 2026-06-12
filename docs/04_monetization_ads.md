# Monetization and Ads

## Monetization Strategy

Primary: free app with AdMob ads.

MVP ad formats:

- Banner ads on main menu and game-over screen.
- Interstitial ads after a controlled number of completed rounds.
- Rewarded ad for one continue per round.

## Ad Placement Rules

### Banner

Allowed:

- Main menu bottom.
- Game-over screen bottom.

Avoid:

- Active gameplay screen, unless later testing shows it does not harm usability.
- Locations near primary gameplay taps.

### Interstitial

Allowed:

- After game over, only after the player has completed several rounds.
- Before returning to menu, if frequency cap allows.

Rules:

- Do not show on first app launch.
- Do not show immediately after pressing Play.
- Do not show after every round.
- Recommended frequency: every 3 to 5 game overs.

### Rewarded

Allowed:

- Optional continue after game over.
- Optional score bonus mode in later versions.

Rules:

- User must clearly opt in.
- Reward must only be granted after ad completion callback.
- One continue per round.

## Development IDs

Use Google test ad unit IDs during development. Production ad unit IDs must be stored outside Git and injected through environment/config.

## Policy Notes

- Do not click live ads during development or QA.
- Do not ask users to click ads.
- Do not incentivize banner or interstitial clicks.
- Do not place ads where accidental clicks are likely.
- Do not market the game as child-directed.
- If target age includes children later, re-check Google Play Families and AdMob policy before release.

## Play Console Declarations

Expected MVP answers:

- Contains ads: Yes.
- Data Safety: must include data collection/sharing performed by Google Mobile Ads SDK.
- Target audience: not child-directed.
- Privacy Policy: required before production release.

## Future Monetization

Potential next step:

- One-time remove ads purchase.
- Cosmetic themes unlocked through gameplay.
- Rewarded ads for temporary visual themes or continues.

