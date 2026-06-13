# Airport Basics Pack Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand the current 3-level vertical slice into a 10-level `Airport Basics` pack with persisted unlock progression and updated tests/docs.

**Architecture:** Keep the existing architecture intact: extend the pure Dart level catalog and progression rules first, then let existing Flutter/Flame UI consume the larger catalog with minimal UI copy changes. Follow TDD by updating rule tests and widget/persistence tests before touching production code, then finish with changelog and progress updates.

**Tech Stack:** Flutter, Flame, `shared_preferences`, Flutter test

---

### Task 1: Expand level progression rules

**Files:**
- Modify: `app/lib/game/systems/level_progression_rules.dart`
- Test: `app/test/game/level_progression_rules_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
test('level catalog exposes the full 10-level airport basics pack', () {
  expect(levelCatalog.length, 10);
  expect(LevelProgressionRules.maxLevelNumber, 10);
  expect(LevelProgressionRules.configForLevel(10).bagsToClear, 10);
});

test('level 5 introduces razor and level 8 introduces battery pack', () {
  expect(
    LevelProgressionRules.configForLevel(5).newlyUnlockedDanger,
    XrayObjectType.razor,
  );
  expect(
    LevelProgressionRules.configForLevel(8).newlyUnlockedDanger,
    XrayObjectType.batteryPack,
  );
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/game/level_progression_rules_test.dart`
Expected: FAIL because the catalog still contains only 3 levels.

- [ ] **Step 3: Write minimal implementation**

```dart
static const int maxLevelNumber = 10;

const List<LevelConfig> levelCatalog = [
  // existing levels 1-3 retained
  LevelConfig(levelNumber: 4, bagsToClear: 5, ...),
  LevelConfig(levelNumber: 5, bagsToClear: 6, dangerPool: [..., XrayObjectType.razor], ...),
  LevelConfig(levelNumber: 6, bagsToClear: 6, ...),
  LevelConfig(levelNumber: 7, bagsToClear: 7, ...),
  LevelConfig(levelNumber: 8, bagsToClear: 7, dangerPool: [..., XrayObjectType.batteryPack], ...),
  LevelConfig(levelNumber: 9, bagsToClear: 8, ...),
  LevelConfig(levelNumber: 10, bagsToClear: 10, ...),
];
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/game/level_progression_rules_test.dart`
Expected: PASS with updated pack coverage and unlock pacing assertions.

- [ ] **Step 5: Commit**

```bash
git add app/lib/game/systems/level_progression_rules.dart app/test/game/level_progression_rules_test.dart
git commit -m "feat: expand airport basics level pack"
```

### Task 2: Verify persistence and menu/gameplay flow against 10 levels

**Files:**
- Modify: `app/test/services/storage_service_test.dart`
- Modify: `app/test/widget_test.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: Write the failing tests**

```dart
test('highest unlocked level clamps to level 10', () async {
  SharedPreferences.setMockInitialValues({
    StorageService.highestUnlockedLevelKey: 99,
  });

  final storage = await StorageService.load();
  expect(storage.getHighestUnlockedLevel(), 10);
});

testWidgets('main menu can show the highest unlocked level in the full pack', (
  tester,
) async {
  SharedPreferences.setMockInitialValues({
    'high_score': 120,
    'highest_unlocked_level': 10,
  });

  await tester.pumpWidget(const XrayScanApp());
  await tester.pumpAndSettle();

  expect(find.text('PLAY LEVEL 10'), findsOneWidget);
  expect(find.text('Level 10 unlocked'), findsOneWidget);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/services/storage_service_test.dart test/widget_test.dart`
Expected: FAIL because progression currently clamps at level 3 and the UI has not been verified against level 10.

- [ ] **Step 3: Write minimal implementation**

```dart
Text('Level $highestUnlockedLevel unlocked');
Text('PLAY LEVEL $highestUnlockedLevel');

int getHighestUnlockedLevel() {
  final saved = _preferences.getInt(highestUnlockedLevelKey);
  return LevelProgressionRules.clampHighestUnlocked(saved ?? 1);
}
```

Keep the menu and next-level logic generic so no extra special cases are added for levels 4-10.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/services/storage_service_test.dart test/widget_test.dart`
Expected: PASS with persistence clamping and menu copy validated for the full pack.

- [ ] **Step 5: Commit**

```bash
git add app/lib/main.dart app/test/services/storage_service_test.dart app/test/widget_test.dart
git commit -m "test: cover 10-level progression flow"
```

### Task 3: Run regression checks

**Files:**
- No code changes required unless regressions appear

- [ ] **Step 1: Run focused gameplay and persistence tests**

Run: `flutter test test/game/level_progression_rules_test.dart test/services/storage_service_test.dart test/widget_test.dart`
Expected: PASS

- [ ] **Step 2: Run broader project checks**

Run: `flutter test ; flutter analyze`
Expected: PASS

- [ ] **Step 3: Fix any regressions minimally**

```dart
// Only adjust signatures, constants, or expectations that broke due to
// the 10-level pack expansion. Do not refactor unrelated gameplay systems.
```

- [ ] **Step 4: Re-run the failing command**

Run: repeat only the command that failed in Step 1 or Step 2
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add app
git commit -m "test: verify airport basics expansion"
```

### Task 4: Update project tracking docs

**Files:**
- Modify: `docs/07_tracking/progress.md`
- Modify: `docs/changelog/CHANGELOG.md`

- [ ] **Step 1: Add changelog entry at the top**

```markdown
## [2026-06-13 HH:MM] - Expand Airport Basics level pack

**Owner**: AI Assistant
**Type**: Feature
**Related US**: US-002, US-003, US-011
**Impact Scope**: Gameplay, Docs, Test

### Changes
- Expanded the level catalog from 3 levels to the full 10-level Airport Basics pack.
- Extended unlock pacing so razor and power bank arrive at later milestones.
- Updated tests and tracking docs to reflect the new progression baseline.
```

- [ ] **Step 2: Update progress tracking**

```markdown
## In Progress

- Wire interstitial and rewarded ads to level clear/fail breakpoints using the existing ad break rules.

## Next Steps

1. Implement interstitial and rewarded ads using Google test ad unit IDs after level clear/fail flow exists.
2. Extract or redraw production-ready individual object assets from the approved x-ray visual benchmark.
3. Tune object scale, suitcase speed, hit radius, clear timing, and encyclopedia readability based on further physical-device playtests.
```

- [ ] **Step 3: Sanity-check docs for consistency**

Verify that `progress.md` and `CHANGELOG.md` both say the 10-level pack is now the current progression baseline.

- [ ] **Step 4: Commit**

```bash
git add docs/07_tracking/progress.md docs/changelog/CHANGELOG.md
git commit -m "docs: record airport basics pack expansion"
```
