enum SortLane { blue, green, yellow, red }

class TapSortSnapshot {
  const TapSortSnapshot({
    required this.score,
    required this.combo,
    required this.lives,
    required this.isGameOver,
  });

  final int score;
  final int combo;
  final int lives;
  final bool isGameOver;
}

class TapSortRules {
  TapSortRules({this.startingLives = 3});

  final int startingLives;

  int _score = 0;
  int _combo = 0;
  late int _lives = startingLives;

  int get score => _score;
  int get combo => _combo;
  int get lives => _lives;
  bool get isGameOver => _lives <= 0;

  TapSortSnapshot get snapshot => TapSortSnapshot(
    score: _score,
    combo: _combo,
    lives: _lives,
    isGameOver: isGameOver,
  );

  int pointsForNextCorrectSort() => (10 * comboMultiplierFor(_combo)).round();

  double comboMultiplierFor(int combo) {
    final bonusSteps = combo ~/ 10;
    return 1 + (bonusSteps * 0.25);
  }

  TapSortSnapshot resolveSort({
    required SortLane itemLane,
    required SortLane tappedLane,
  }) {
    if (isGameOver) {
      return snapshot;
    }

    if (itemLane == tappedLane) {
      _score += pointsForNextCorrectSort();
      _combo += 1;
    } else {
      _applyMistake();
    }

    return snapshot;
  }

  TapSortSnapshot resolveMiss() {
    if (!isGameOver) {
      _applyMistake();
    }
    return snapshot;
  }

  TapSortSnapshot reset() {
    _score = 0;
    _combo = 0;
    _lives = startingLives;
    return snapshot;
  }

  void _applyMistake() {
    _combo = 0;
    _lives -= 1;
  }
}
