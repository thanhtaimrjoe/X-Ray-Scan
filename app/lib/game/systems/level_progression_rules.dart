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

  static const int maxLevelNumber = 30;

  static int clampHighestUnlocked(int value) {
    return value.clamp(1, maxLevelNumber);
  }

  static LevelConfig configForLevel(int levelNumber) {
    final index = levelNumber - 1;
    if (index < 0 || index >= levelCatalog.length) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Only levels 1-$maxLevelNumber are available in Airport Basics.',
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

/// Airport Basics level pack.
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
  LevelConfig(
    levelNumber: 4,
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
      XrayObjectType.laptop,
    ],
    twoStarScore: 900,
    threeStarScore: 1300,
    baseBagSpeed: 82,
    maxBagSpeed: 132,
    speedRampSeconds: 34,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 5,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
    ],
    twoStarScore: 1050,
    threeStarScore: 1500,
    baseBagSpeed: 86,
    maxBagSpeed: 138,
    speedRampSeconds: 32,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 6,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1150,
    threeStarScore: 1650,
    baseBagSpeed: 90,
    maxBagSpeed: 144,
    speedRampSeconds: 30,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 7,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1300,
    threeStarScore: 1850,
    baseBagSpeed: 94,
    maxBagSpeed: 150,
    speedRampSeconds: 28,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 8,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1450,
    threeStarScore: 2050,
    baseBagSpeed: 98,
    maxBagSpeed: 156,
    speedRampSeconds: 26,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 9,
    bagsToClear: 8,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1650,
    threeStarScore: 2300,
    baseBagSpeed: 104,
    maxBagSpeed: 164,
    speedRampSeconds: 24,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 10,
    bagsToClear: 10,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2000,
    threeStarScore: 2750,
    baseBagSpeed: 110,
    maxBagSpeed: 172,
    speedRampSeconds: 22,
    allowTwoDangerBags: true,
  ),
  LevelConfig(
    levelNumber: 11,
    bagsToClear: 5,
    dangerPool: [XrayObjectType.knife, XrayObjectType.batteryPack],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1000,
    threeStarScore: 1500,
    baseBagSpeed: 80,
    maxBagSpeed: 130,
    speedRampSeconds: 35,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 12,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1200,
    threeStarScore: 1750,
    baseBagSpeed: 84,
    maxBagSpeed: 134,
    speedRampSeconds: 32,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 13,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.laptop,
    ],
    twoStarScore: 1300,
    threeStarScore: 1900,
    baseBagSpeed: 88,
    maxBagSpeed: 138,
    speedRampSeconds: 30,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 14,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1450,
    threeStarScore: 2100,
    baseBagSpeed: 92,
    maxBagSpeed: 142,
    speedRampSeconds: 28,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 15,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.headphones,
      XrayObjectType.laptop,
    ],
    twoStarScore: 1600,
    threeStarScore: 2300,
    baseBagSpeed: 96,
    maxBagSpeed: 146,
    speedRampSeconds: 26,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 16,
    bagsToClear: 8,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1800,
    threeStarScore: 2600,
    baseBagSpeed: 100,
    maxBagSpeed: 152,
    speedRampSeconds: 25,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 17,
    bagsToClear: 8,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1900,
    threeStarScore: 2750,
    baseBagSpeed: 104,
    maxBagSpeed: 158,
    speedRampSeconds: 24,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 18,
    bagsToClear: 9,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2100,
    threeStarScore: 3000,
    baseBagSpeed: 108,
    maxBagSpeed: 164,
    speedRampSeconds: 23,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 19,
    bagsToClear: 9,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2200,
    threeStarScore: 3150,
    baseBagSpeed: 112,
    maxBagSpeed: 170,
    speedRampSeconds: 22,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 20,
    bagsToClear: 11,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2500,
    threeStarScore: 3600,
    baseBagSpeed: 116,
    maxBagSpeed: 176,
    speedRampSeconds: 20,
    allowTwoDangerBags: true,
    packName: 'Cargo Logistics',
  ),
  LevelConfig(
    levelNumber: 21,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1300,
    threeStarScore: 1800,
    baseBagSpeed: 110,
    maxBagSpeed: 160,
    speedRampSeconds: 30,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 22,
    bagsToClear: 6,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1400,
    threeStarScore: 2000,
    baseBagSpeed: 112,
    maxBagSpeed: 164,
    speedRampSeconds: 28,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 23,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1600,
    threeStarScore: 2250,
    baseBagSpeed: 114,
    maxBagSpeed: 168,
    speedRampSeconds: 26,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 24,
    bagsToClear: 7,
    dangerPool: [
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1700,
    threeStarScore: 2400,
    baseBagSpeed: 116,
    maxBagSpeed: 172,
    speedRampSeconds: 24,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 25,
    bagsToClear: 8,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 1900,
    threeStarScore: 2700,
    baseBagSpeed: 118,
    maxBagSpeed: 176,
    speedRampSeconds: 22,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 26,
    bagsToClear: 8,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2000,
    threeStarScore: 2850,
    baseBagSpeed: 120,
    maxBagSpeed: 180,
    speedRampSeconds: 20,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 27,
    bagsToClear: 9,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2300,
    threeStarScore: 3200,
    baseBagSpeed: 122,
    maxBagSpeed: 184,
    speedRampSeconds: 18,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 28,
    bagsToClear: 9,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2450,
    threeStarScore: 3400,
    baseBagSpeed: 124,
    maxBagSpeed: 188,
    speedRampSeconds: 17,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 29,
    bagsToClear: 10,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 2700,
    threeStarScore: 3800,
    baseBagSpeed: 126,
    maxBagSpeed: 192,
    speedRampSeconds: 16,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
  LevelConfig(
    levelNumber: 30,
    bagsToClear: 12,
    dangerPool: [
      XrayObjectType.knife,
      XrayObjectType.scissors,
      XrayObjectType.lighter,
      XrayObjectType.razor,
      XrayObjectType.batteryPack,
    ],
    safePool: [
      XrayObjectType.phone,
      XrayObjectType.bottle,
      XrayObjectType.keys,
      XrayObjectType.sandwich,
      XrayObjectType.laptop,
      XrayObjectType.headphones,
    ],
    twoStarScore: 3200,
    threeStarScore: 4500,
    baseBagSpeed: 130,
    maxBagSpeed: 200,
    speedRampSeconds: 15,
    allowTwoDangerBags: true,
    packName: 'Border Customs',
  ),
];
