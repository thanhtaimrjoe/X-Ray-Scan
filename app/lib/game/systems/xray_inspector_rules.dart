import 'dart:math';

enum XrayObjectType {
  knife,
  scissors,
  lighter,
  razor,
  batteryPack,
  phone,
  laptop,
  bottle,
  sandwich,
  keys,
  headphones,
}

extension XrayObjectTypeRules on XrayObjectType {
  bool get isDangerous {
    return switch (this) {
      XrayObjectType.knife ||
      XrayObjectType.scissors ||
      XrayObjectType.lighter ||
      XrayObjectType.razor ||
      XrayObjectType.batteryPack => true,
      XrayObjectType.phone ||
      XrayObjectType.laptop ||
      XrayObjectType.bottle ||
      XrayObjectType.sandwich ||
      XrayObjectType.keys ||
      XrayObjectType.headphones => false,
    };
  }
}

enum XrayFeedbackEvent {
  none,
  dangerFound,
  safeTapped,
  safeBagCleared,
  dangerMissed,
  falseClear,
}

class XrayInspectorSnapshot {
  const XrayInspectorSnapshot({
    required this.score,
    required this.combo,
    required this.lives,
    required this.isGameOver,
    this.lastEvent = XrayFeedbackEvent.none,
  });

  final int score;
  final int combo;
  final int lives;
  final bool isGameOver;
  final XrayFeedbackEvent lastEvent;
}

class XrayInspectorRules {
  XrayInspectorRules({this.startingLives = 3});

  static const dangerTapBasePoints = 10;
  static const safeTapPenalty = 5;
  static const safeBagClearBonus = 5;

  final int startingLives;

  int _score = 0;
  int _combo = 0;
  late int _lives = startingLives;
  XrayFeedbackEvent _lastEvent = XrayFeedbackEvent.none;

  int get score => _score;
  int get combo => _combo;
  int get lives => _lives;
  bool get isGameOver => _lives <= 0;

  XrayInspectorSnapshot get snapshot => XrayInspectorSnapshot(
    score: _score,
    combo: _combo,
    lives: _lives,
    isGameOver: isGameOver,
    lastEvent: _lastEvent,
  );

  int pointsForNextDangerTap() {
    return (dangerTapBasePoints * comboMultiplierFor(_combo)).round();
  }

  double comboMultiplierFor(int combo) {
    final bonusSteps = combo ~/ 10;
    return 1 + (bonusSteps * 0.25);
  }

  XrayInspectorSnapshot resolveDangerTap() {
    if (isGameOver) {
      return snapshot;
    }

    _score += pointsForNextDangerTap();
    _combo += 1;
    _lastEvent = XrayFeedbackEvent.dangerFound;
    return snapshot;
  }

  XrayInspectorSnapshot resolveSafeTap() {
    if (isGameOver) {
      return snapshot;
    }

    _score = max(0, _score - safeTapPenalty);
    _combo = 0;
    _lastEvent = XrayFeedbackEvent.safeTapped;
    return snapshot;
  }

  XrayInspectorSnapshot resolveSafeBagClear() {
    if (isGameOver) {
      return snapshot;
    }

    _score += safeBagClearBonus;
    _combo += 1;
    _lastEvent = XrayFeedbackEvent.safeBagCleared;
    return snapshot;
  }

  XrayInspectorSnapshot resolveMissedDanger() {
    if (!isGameOver) {
      _applyLifeMistake(XrayFeedbackEvent.dangerMissed);
    }
    return snapshot;
  }

  XrayInspectorSnapshot resolveFalseClear() {
    if (!isGameOver) {
      _applyLifeMistake(XrayFeedbackEvent.falseClear);
    }
    return snapshot;
  }

  XrayInspectorSnapshot reset() {
    _score = 0;
    _combo = 0;
    _lives = startingLives;
    _lastEvent = XrayFeedbackEvent.none;
    return snapshot;
  }

  void _applyLifeMistake(XrayFeedbackEvent event) {
    _combo = 0;
    _lives -= 1;
    _lastEvent = event;
  }
}
