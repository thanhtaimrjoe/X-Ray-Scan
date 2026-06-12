import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'systems/tap_sort_rules.dart';

typedef GameSnapshotChanged = void Function(TapSortSnapshot snapshot);

typedef GameFinished = void Function(TapSortSnapshot snapshot);

class FallingSortItem {
  FallingSortItem({
    required this.lane,
    required this.xFactor,
    required this.y,
    required this.speed,
    required this.phase,
  });

  final SortLane lane;
  final double xFactor;
  final double phase;
  double y;
  double speed;
  final List<Offset> trail = [];
}

class SortBurst {
  SortBurst({
    required this.center,
    required this.color,
    required this.age,
    required this.isMistake,
  });

  final Offset center;
  final Color color;
  final bool isMistake;
  double age;
}

class LaneFeedback {
  LaneFeedback({
    required this.lane,
    required this.age,
    required this.isMistake,
  });

  final SortLane lane;
  final bool isMistake;
  double age;
}

class TapSortGame extends FlameGame {
  TapSortGame({
    required this.onSnapshotChanged,
    required this.onGameFinished,
    Random? random,
  }) : _random = random ?? Random();

  final GameSnapshotChanged onSnapshotChanged;
  final GameFinished onGameFinished;
  final Random _random;
  final TapSortRules _rules = TapSortRules();
  final List<FallingSortItem> _items = [];
  final List<SortBurst> _bursts = [];
  final List<LaneFeedback> _laneFeedback = [];

  double _elapsed = 0;
  double _spawnTimer = 0;
  double _dangerFlash = 0;
  bool _finished = false;

  TapSortSnapshot get snapshot => _rules.snapshot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnItem();
    onSnapshotChanged(snapshot);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || size.x <= 0 || size.y <= 0) {
      return;
    }

    _elapsed += dt;
    _spawnTimer -= dt;
    _dangerFlash = max(0, _dangerFlash - dt);

    if (_spawnTimer <= 0) {
      _spawnItem();
      _spawnTimer = _spawnInterval;
    }

    final missedItems = <FallingSortItem>[];
    for (final item in _items) {
      item.trail.add(Offset(item.xFactor * size.x, item.y));
      if (item.trail.length > 10) {
        item.trail.removeAt(0);
      }
      item.y += item.speed * dt;
      if (item.y > _missLineY) {
        missedItems.add(item);
      }
    }

    for (final item in missedItems) {
      _items.remove(item);
      _rules.resolveMiss();
      _dangerFlash = 0.2;
      _bursts.add(
        SortBurst(
          center: Offset(item.xFactor * size.x, _missLineY),
          color: laneColor(item.lane),
          age: 0,
          isMistake: true,
        ),
      );
      onSnapshotChanged(snapshot);
      _finishIfNeeded();
    }

    for (final burst in _bursts) {
      burst.age += dt;
    }
    _bursts.removeWhere((burst) => burst.age > 0.42);

    for (final feedback in _laneFeedback) {
      feedback.age += dt;
    }
    _laneFeedback.removeWhere((feedback) => feedback.age > 0.22);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _paintBackground(canvas);
    _paintActionZone(canvas);
    _paintLanes(canvas);
    _paintLaneFeedback(canvas);
    _paintBursts(canvas);
    _paintItems(canvas);
    _paintDangerFlash(canvas);
  }

  void tapLane(SortLane tappedLane) {
    if (_finished) {
      return;
    }

    final target = _itemInActionZone ?? _bottomMostItem;
    if (target == null) {
      return;
    }

    final wasCorrect = target.lane == tappedLane;
    _items.remove(target);
    _rules.resolveSort(itemLane: target.lane, tappedLane: tappedLane);
    _laneFeedback.add(
      LaneFeedback(lane: tappedLane, age: 0, isMistake: !wasCorrect),
    );
    if (!wasCorrect) {
      _dangerFlash = 0.2;
    }
    _bursts.add(
      SortBurst(
        center: Offset(target.xFactor * size.x, target.y),
        color: laneColor(target.lane),
        age: 0,
        isMistake: !wasCorrect,
      ),
    );
    onSnapshotChanged(snapshot);
    _finishIfNeeded();
  }

  void _spawnItem() {
    final lane = SortLane.values[_random.nextInt(SortLane.values.length)];
    _items.add(
      FallingSortItem(
        lane: lane,
        xFactor: 0.15 + (_random.nextDouble() * 0.7),
        y: -28,
        speed: _fallSpeed,
        phase: _random.nextDouble() * pi * 2,
      ),
    );
  }

  FallingSortItem? get _itemInActionZone {
    final candidates = _items.where((item) {
      return item.y >= _actionZoneTop && item.y <= _actionZoneBottom;
    }).toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) => b.y.compareTo(a.y));
    return candidates.first;
  }

  FallingSortItem? get _bottomMostItem {
    if (_items.isEmpty) {
      return null;
    }
    return _items.reduce((a, b) => a.y > b.y ? a : b);
  }

  double get _fallSpeed => min(360, 115 + (_elapsed * 4.2));

  double get _spawnInterval => max(0.68, 1.35 - (_elapsed * 0.012));

  double get _actionZoneTop => size.y * 0.68;

  double get _actionZoneBottom => size.y * 0.82;

  double get _missLineY => size.y * 0.88;

  void _finishIfNeeded() {
    if (!_finished && _rules.isGameOver) {
      _finished = true;
      onGameFinished(snapshot);
    }
  }

  void _paintBackground(Canvas canvas) {
    final bounds = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(bounds, Paint()..color = const Color(0xFF08111F));

    final glowCenter = Offset(size.x * 0.5, size.y * 0.16);
    canvas.drawCircle(
      glowCenter,
      size.x * 0.58,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF155E75).withValues(alpha: 0.34),
                const Color(0xFF08111F).withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: glowCenter, radius: size.x * 0.58),
            ),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    const gridSize = 36.0;
    final yOffset = (_elapsed * 24) % gridSize;
    for (var x = 0.0; x <= size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (var y = -gridSize + yOffset; y <= size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }

  void _paintActionZone(Canvas canvas) {
    final zone = Rect.fromLTRB(0, _actionZoneTop, size.x, _actionZoneBottom);
    canvas.drawRect(zone, Paint()..color = const Color(0x1722D3EE));
    canvas.drawLine(
      Offset(0, _actionZoneBottom),
      Offset(size.x, _actionZoneBottom),
      Paint()
        ..color = const Color(0xAA67E8F9)
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      Offset(0, _actionZoneTop),
      Offset(size.x, _actionZoneTop),
      Paint()
        ..color = const Color(0x4467E8F9)
        ..strokeWidth = 1,
    );
  }

  void _paintLanes(Canvas canvas) {
    final laneWidth = size.x / SortLane.values.length;
    final laneTop = size.y * 0.84;

    for (var index = 0; index < SortLane.values.length; index++) {
      final lane = SortLane.values[index];
      final rect = Rect.fromLTWH(
        index * laneWidth,
        laneTop,
        laneWidth,
        size.y - laneTop,
      );
      final color = laneColor(lane);
      final glowRect = rect.deflate(5);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.72),
            ],
          ).createShader(rect),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, const Radius.circular(16)),
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(8), const Radius.circular(14)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withValues(alpha: 0.36),
      );
      _paintLaneGlyph(canvas, lane, rect.center.translate(0, 4), color);
    }
  }

  void _paintItems(Canvas canvas) {
    for (final item in _items) {
      final center = Offset(item.xFactor * size.x, item.y);
      final color = laneColor(item.lane);
      final bob = sin(_elapsed * 7 + item.phase) * 1.8;
      final shiftedCenter = center.translate(0, bob);

      for (var index = 0; index < item.trail.length; index++) {
        final point = item.trail[index];
        final alpha = (index + 1) / item.trail.length;
        canvas.drawCircle(
          point,
          5 + (alpha * 9),
          Paint()..color = color.withValues(alpha: 0.04 + (alpha * 0.11)),
        );
      }

      canvas.drawCircle(
        shiftedCenter,
        30,
        Paint()
          ..color = color.withValues(alpha: 0.32)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(shiftedCenter, 23, Paint()..color = color);

      final diamondPath = Path()
        ..moveTo(shiftedCenter.dx, shiftedCenter.dy - 18)
        ..lineTo(shiftedCenter.dx + 18, shiftedCenter.dy)
        ..lineTo(shiftedCenter.dx, shiftedCenter.dy + 18)
        ..lineTo(shiftedCenter.dx - 18, shiftedCenter.dy)
        ..close();
      canvas.drawPath(
        diamondPath,
        Paint()
          ..color = const Color(0xFFECFEFF).withValues(alpha: 0.26)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        diamondPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.86)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        shiftedCenter,
        7,
        Paint()..color = Colors.white.withValues(alpha: 0.86),
      );
    }
  }

  void _paintBursts(Canvas canvas) {
    for (final burst in _bursts) {
      final progress = (burst.age / 0.42).clamp(0.0, 1.0);
      final alpha = 1 - progress;
      final rayCount = burst.isMistake ? 6 : 10;
      final radius = 18 + (progress * 42);
      final paint = Paint()
        ..color = (burst.isMistake ? const Color(0xFFFF3B5C) : burst.color)
            .withValues(alpha: alpha * 0.72)
        ..strokeWidth = burst.isMistake ? 3 : 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      for (var i = 0; i < rayCount; i++) {
        final angle = ((pi * 2) / rayCount) * i + (_elapsed * 0.8);
        final start =
            burst.center + Offset(cos(angle), sin(angle)) * (radius * 0.28);
        final end = burst.center + Offset(cos(angle), sin(angle)) * radius;
        canvas.drawLine(start, end, paint);
      }
      canvas.drawCircle(
        burst.center,
        radius * 0.52,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = burst.color.withValues(alpha: alpha * 0.38),
      );
    }
  }

  void _paintLaneFeedback(Canvas canvas) {
    if (_laneFeedback.isEmpty) {
      return;
    }

    final laneWidth = size.x / SortLane.values.length;
    final laneTop = size.y * 0.84;
    for (final feedback in _laneFeedback) {
      final index = SortLane.values.indexOf(feedback.lane);
      final progress = (feedback.age / 0.22).clamp(0.0, 1.0);
      final rect = Rect.fromLTWH(
        index * laneWidth,
        laneTop,
        laneWidth,
        size.y - laneTop,
      ).deflate(6 - (progress * 6));
      final color = feedback.isMistake
          ? const Color(0xFFFF3B5C)
          : laneColor(feedback.lane);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 - (progress * 2)
          ..color = color.withValues(alpha: (1 - progress) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  void _paintDangerFlash(Canvas canvas) {
    if (_dangerFlash <= 0) {
      return;
    }

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: _dangerFlash * 0.6),
    );
  }

  void _paintLaneGlyph(
    Canvas canvas,
    SortLane lane,
    Offset center,
    Color color,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: laneGlyph(lane),
        style: TextStyle(
          color: lane == SortLane.yellow
              ? const Color(0xFF111827)
              : Colors.white.withValues(alpha: 0.92),
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.drawCircle(
      center,
      23,
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      center,
      20,
      Paint()..color = Colors.black.withValues(alpha: 0.28),
    );
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }
}

Color laneColor(SortLane lane) {
  return switch (lane) {
    SortLane.blue => const Color(0xFF38BDF8),
    SortLane.green => const Color(0xFF22C55E),
    SortLane.yellow => const Color(0xFFFACC15),
    SortLane.red => const Color(0xFFEF4444),
  };
}

String laneLabel(SortLane lane) {
  return switch (lane) {
    SortLane.blue => 'Blue',
    SortLane.green => 'Green',
    SortLane.yellow => 'Yellow',
    SortLane.red => 'Red',
  };
}

String laneGlyph(SortLane lane) {
  return switch (lane) {
    SortLane.blue => 'B',
    SortLane.green => 'G',
    SortLane.yellow => 'Y',
    SortLane.red => 'R',
  };
}
