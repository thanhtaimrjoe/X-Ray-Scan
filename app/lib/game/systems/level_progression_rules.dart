import 'xray_inspector_rules.dart';

/// Configuration for a single level attempt.
class LevelConfig {
  const LevelConfig({
    required this.levelNumber,
    required this.bagsToClear,
    required this.dangerPool,
    required this.safePool,
    required this.twoStarScore,
    required this.threeStarScore,
    this.baseBagSpeed = 72,
    this.maxBagSpeed = 132,
    this.speedRampSeconds = 35,
    this.allowTwoDangerBags = false,
    this.packName = 'Airport Basics',
  });

  final int levelNumber;
  final int bagsToClear;
  final List<XrayObjectType> dangerPool;
  final List<XrayObjectType> safePool;
  final int twoStarScore;
  final int threeStarScore;
  final double baseBagSpeed;
  final double maxBagSpeed;
  final double speedRampSeconds;
  final bool allowTwoDangerBags;
  final String packName;

  /// New danger item introduced on this level, if any.
  XrayObjectType? get newlyUnlockedDanger {
    if (levelNumber <= 1) {
      return null;
    }
    final previous = levelCatalog[levelNumber - 2].dangerPool.toSet();
    for (final type in dangerPool) {
      if (!previous.contains(type)) {
        return type;
      }
    }
    return null;
  }
}

/// Tracks objective progress during a level attempt.
class LevelAttemptProgress {
  const LevelAttemptProgress({
    required this.levelNumber,
    required this.bagsCleared,
    required this.bagsToClear,
    required this.score,
    required this.lives,
  });

  final int levelNumber;
  final int bagsCleared;
  final int bagsToClear;
  final int score;
  final int lives;

  bool get isObjectiveComplete => bagsCleared >= bagsToClear;
  bool get isFailed => lives <= 0;
}

/// Outcome of a finished level attempt before persistence is applied.
class LevelAttemptOutcome {
  const LevelAttemptOutcome({
    required this.levelNumber,
    required this.score,
    required this.bagsCleared,
    required this.bagsToClear,
    required this.starsEarned,
    required this.didCompleteObjective,
    required this.didFail,
  });

  final int levelNumber;
  final int score;
  final int bagsCleared;
  final int bagsToClear;
  final int starsEarned;
  final bool didCompleteObjective;
  final bool didFail;
}

/// Persisted progress snapshot for level unlocks and bests.
class LevelProgressSnapshot {
  const LevelProgressSnapshot({
    required this.highestUnlockedLevel,
    required this.bestScores,
    required this.bestStars,
  });

  final int highestUnlockedLevel;
  final Map<int, int> bestScores;
  final Map<int, int> bestStars;

  int bestScoreFor(int levelNumber) => bestScores[levelNumber] ?? 0;

  int bestStarsFor(int levelNumber) => bestStars[levelNumber] ?? 0;
}

/// Result after merging an attempt outcome into persisted progress.
class LevelProgressUpdate {
  const LevelProgressUpdate({
    required this.previous,
    required this.updated,
    required this.outcome,
    required this.didUnlockNextLevel,
    required this.didImproveScore,
    required this.didImproveStars,
  });

  final LevelProgressSnapshot previous;
  final LevelProgressSnapshot updated;
  final LevelAttemptOutcome outcome;
  final bool didUnlockNextLevel;
  final bool didImproveScore;
  final bool didImproveStars;

  int? get nextLevelNumber {
    if (!outcome.didCompleteObjective) {
      return null;
    }
    final next = outcome.levelNumber + 1;
    return next <= LevelProgressionRules.maxLevelNumber ? next : null;
  }

  bool get canPlayNext =>
      outcome.didCompleteObjective &&
      nextLevelNumber != null &&
      updated.highestUnlockedLevel >= nextLevelNumber!;
}

class LevelProgressionRules {
  LevelProgressionRules._();

  static const int maxLevelNumber = 3;

  static int clampHighestUnlocked(int value) {
    return value.clamp(1, maxLevelNumber);
  }

  static LevelConfig configForLevel(int levelNumber) {
    final index = levelNumber - 1;
    if (index < 0 || index >= levelCatalog.length) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Only levels 1-$maxLevelNumber are available in the vertical slice.',
      );
    }
    return levelCatalog[index];
  }

  static LevelAttemptProgress progressFor({
    required LevelConfig config,
    required int bagsCleared,
    required int score,
    required int lives,
  }) {
    return LevelAttemptProgress(
      levelNumber: config.levelNumber,
      bagsCleared: bagsCleared,
      bagsToClear: config.bagsToClear,
      score: score,
      lives: lives,
    );
  }

  static int starsForAttempt({
    required LevelConfig config,
    required int bagsCleared,
    required int score,
  }) {
    if (bagsCleared < config.bagsToClear) {
      return 0;
    }
    if (score >= config.threeStarScore) {
      return 3;
    }
    if (score >= config.twoStarScore) {
      return 2;
    }
    return 1;
  }

  static LevelAttemptOutcome outcomeFor({
    required LevelConfig config,
    required int bagsCleared,
    required int score,
    required int lives,
  }) {
    final didCompleteObjective = bagsCleared >= config.bagsToClear;
    final didFail = lives <= 0 && !didCompleteObjective;
    final stars = didCompleteObjective
        ? starsForAttempt(
            config: config,
            bagsCleared: bagsCleared,
            score: score,
          )
        : 0;

    return LevelAttemptOutcome(
      levelNumber: config.levelNumber,
      score: score,
      bagsCleared: bagsCleared,
      bagsToClear: config.bagsToClear,
      starsEarned: stars,
      didCompleteObjective: didCompleteObjective,
      didFail: didFail,
    );
  }

  static LevelProgressUpdate applyOutcome({
    required LevelProgressSnapshot current,
    required LevelAttemptOutcome outcome,
  }) {
    if (!outcome.didCompleteObjective && !outcome.didFail) {
      throw ArgumentError('Outcome must represent a completed or failed attempt.');
    }

    final updatedScores = Map<int, int>.from(current.bestScores);
    final updatedStars = Map<int, int>.from(current.bestStars);
    var highestUnlocked = current.highestUnlockedLevel;

    final previousScore = current.bestScoreFor(outcome.levelNumber);
    final previousStars = current.bestStarsFor(outcome.levelNumber);
    var didImproveScore = false;
    var didImproveStars = false;
    var didUnlockNextLevel = false;

    if (outcome.didCompleteObjective) {
      if (outcome.score > previousScore) {
        updatedScores[outcome.levelNumber] = outcome.score;
        didImproveScore = true;
      }

      if (outcome.starsEarned > previousStars) {
        updatedStars[outcome.levelNumber] = outcome.starsEarned;
        didImproveStars = true;
      }

      if (outcome.levelNumber >= highestUnlocked &&
          outcome.levelNumber < maxLevelNumber) {
        highestUnlocked = outcome.levelNumber + 1;
        didUnlockNextLevel = true;
      } else if (outcome.levelNumber > highestUnlocked) {
        highestUnlocked = outcome.levelNumber;
      }
    }

    final updated = LevelProgressSnapshot(
      highestUnlockedLevel: clampHighestUnlocked(highestUnlocked),
      bestScores: updatedScores,
      bestStars: updatedStars,
    );

    return LevelProgressUpdate(
      previous: current,
      updated: updated,
      outcome: outcome,
      didUnlockNextLevel: didUnlockNextLevel,
      didImproveScore: didImproveScore,
      didImproveStars: didImproveStars,
    );
  }
}

/// First 3-level vertical slice from the Airport Basics pack.
const List<LevelConfig> levelCatalog = [
  LevelConfig(
    levelNumber: 1,
    bagsToClear: 3,
    dangerPool: [XrayObjectType.knife],
    safePool: [XrayObjectType.phone, XrayObjectType.bottle],
    twoStarScore: 500,
    threeStarScore: 800,
    baseBagSpeed: 68,
    maxBagSpeed: 96,
    speedRampSeconds: 999,
    allowTwoDangerBags: false,
  ),
  LevelConfig(
    levelNumber: 2,
    bagsToClear: 4,
    dangerPool: [XrayObjectType.knife, XrayObjectType.scissors],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
    ],
    twoStarScore: 650,
    threeStarScore: 950,
    baseBagSpeed: 72,
    maxBagSpeed: 112,
    speedRampSeconds: 45,
    allowTwoDangerBags: false,
  ),
  LevelConfig(
    levelNumber: 3,
    bagsToClear: 5,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.sandwich,
    ],
    twoStarScore: 800,
    threeStarScore: 1200,
    baseBagSpeed: 78,
    maxBagSpeed: 128,
    speedRampSeconds: 35,
    allowTwoDangerBags: true,
  ),
];
