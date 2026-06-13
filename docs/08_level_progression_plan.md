# Level Progression Plan

## Context

Physical playtesting after five rounds showed that the core x-ray inspection loop is understandable and the revised scoring feels better, but excitement drops because the game currently behaves like a pure endless score attack.

Current player feeling:

- The player is only increasing their own score.
- There is no strong sense of walking through stages or completing content.
- The game needs a short-session journey similar to casual level games such as Candy Crush Saga: clear a level, move to the next level, and periodically unlock something new.

## Product Direction

Add a level-based progression layer as the next product slice. Keep endless score attack as a future or secondary mode, but make the MVP journey level-based so players have clear short-term goals.

The core x-ray mechanic remains unchanged:

- Scan moving suitcases.
- Tap dangerous objects.
- Avoid safe objects.
- Press Clear when no dangerous object remains.
- Preserve score, combo, lives, item discovery, and AdMob policy rules.

## Why This Matters

Endless score attack is good for prototyping, but it depends heavily on players caring about high score. For a casual mobile MVP, levels create stronger retention because they give players:

- A clear start and finish.
- A visible next goal.
- A reason to replay for stars or better score.
- A reason to keep going because new items or difficulty appear soon.
- More natural breakpoints for game-over, retry, level-clear, and ads.

## MVP Proposal

### Mode Structure

Replace the default Play flow with a first level flow:

- Main menu primary button: `PLAY LEVEL 1` or `PLAY`.
- Start the highest unlocked level by default.
- Keep an `Endless Shift` mode for later, or unlock it after the first level pack.

### First Level Pack

Working title: `Airport Basics`

Start with 10 levels.

Each level should be short:

- Target duration: 30-60 seconds.
- Objective should be obvious.
- Fail state should be fast to retry.

### Level Objectives

Start simple:

- Clear a target number of bags.
- Keep lives above zero.
- Use score thresholds for 1/2/3 stars.

Later objective variants can include:

- Find a target number of dangerous items.
- Avoid any false taps.
- Clear within a time limit.
- Reach a combo target.

### Level Completion

Show a `Level Clear` screen with:

- Level number.
- Score.
- Stars earned.
- Best stars for that level.
- Newly discovered or unlocked item, when applicable.
- Buttons: Next, Retry, Menu.

Failure screen:

- Level failed when lives reach zero.
- Show score and objective progress.
- Buttons: Retry, Menu.
- Rewarded continue can later appear here, limited to one per attempt.

### Stars

Use score thresholds per level:

- 1 star: objective completed.
- 2 stars: medium score threshold.
- 3 stars: high score threshold.

Example:

```text
Level 1 objective: Clear 3 bags.
1 star: Clear 3 bags.
2 stars: 500 score.
3 stars: 800 score.
```

Stars should persist locally.

### Item Unlock Pacing

Tie item discovery/progression to levels so the item database feels intentional.

Suggested danger unlock pacing:

- Level 1: Knife.
- Level 2: Scissors.
- Level 3: Lighter.
- Level 5: Razor.
- Level 8: Power Bank.

Safe items can be available earlier as clutter, but the database can still reveal them through correct clears.

Important: each new danger item should be introduced by level constraints or object pool changes, not only by encyclopedia text.

### Difficulty Curve

Progress difficulty through:

- Target bags to clear.
- Suitcase speed.
- Object count per bag.
- Number of safe clutter objects.
- Chance of two dangerous objects in one bag.
- Unlocking new danger silhouettes.

Avoid using ads or monetization as difficulty pressure.

## Suggested First 10 Levels

| Level | Objective | Danger Pool | Safe Pool | Notes |
| --- | --- | --- | --- | --- |
| 1 | Clear 3 bags | Knife | Phone, Bottle | Tutorial-like, very slow |
| 2 | Clear 4 bags | Knife, Scissors | Phone, Bottle, Keys | Unlock scissors |
| 3 | Clear 5 bags | Knife, Scissors, Lighter | Phone, Bottle, Sandwich | Unlock lighter |
| 4 | Clear 5 bags, score 700+ for 3 stars | Knife, Scissors, Lighter | Add Laptop | More safe clutter |
| 5 | Clear 6 bags | Add Razor | Phone, Bottle, Keys, Sandwich | Unlock razor |
| 6 | Clear 6 bags with 3 lives | Knife, Scissors, Lighter, Razor | Add Headphones | Accuracy focus |
| 7 | Clear 7 bags | Same | Full safe pool | Faster bags |
| 8 | Clear 7 bags | Add Power Bank | Full safe pool | Unlock power bank |
| 9 | Clear 8 bags, avoid false clear | Full danger pool | Full safe pool | Decision pressure |
| 10 | Clear 10 bags | Full danger pool | Full safe pool | Pack capstone |

## Implementation Plan For Next AI

### Step 1 - Add Level Rules

Create a pure Dart level rules/model layer, for example:

- `app/lib/game/systems/level_progression_rules.dart`
- `app/test/game/level_progression_rules_test.dart`

It should define:

- Level config.
- Objective progress.
- Star thresholds.
- Unlock conditions.
- Next-level availability.

Keep it independent from Flame so it can be unit tested.

### Step 2 - Persist Progress

Extend `StorageService` with:

- highest unlocked level.
- best score per level.
- best stars per level.

Suggested keys:

- `highest_unlocked_level`
- `level_best_scores`
- `level_best_stars`

Use simple JSON or string-list storage through `shared_preferences`.

### Step 3 - Connect Gameplay

Extend `XrayInspectorGame` or its parent screen so it can run either:

- endless mode later, or
- a level attempt with a `LevelConfig`.

For the first implementation, only level mode is necessary.

Game should report:

- bags cleared.
- score.
- lives.
- whether the level objective is completed.
- whether the player failed.

### Step 4 - Add Level UI

Minimum screens:

- Main menu: show current level and Play button.
- Level clear screen.
- Level failed screen.

Avoid building a large map UI at first. A simple current-level card is enough for MVP.

### Step 5 - Update Item Database Integration

When a level introduces a new danger item:

- Make sure the gameplay pool includes it.
- Make sure correct detection unlocks its database entry.
- Optionally show a small `New threat profile` message on the level clear screen.

## Acceptance Criteria

- Player can start Level 1 from the main menu.
- Level 1 completes after its bag-clear objective.
- Level clear screen shows score and stars.
- Progress unlocks Level 2.
- Best stars persist after app restart.
- Failing a level allows retry.
- Existing scoring, combo, lives, and item discovery tests still pass.
- No ads appear during active gameplay.
- Changelog is updated for every implementation step.

## Open Questions

- Should endless mode remain visible from the start, or unlock after Level 10?
- Should level completion require pressing Clear on a final bag, or complete immediately after objective progress reaches the target?
- Should perfect bag bonuses affect star ratings strongly, or remain an extra optimization?
- Should early levels restrict safe items too, or should safe clutter use the full pool from Level 1?

## Recommendation

Implement the first version as a small 3-level vertical slice before building all 10 levels:

- Level 1: basic clear objective.
- Level 2: new danger item.
- Level 3: more speed or clutter.

If the level clear/retry/unlock loop feels good, expand to the 10-level Airport Basics pack.
