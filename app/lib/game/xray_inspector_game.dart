import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'systems/xray_inspector_rules.dart';

typedef GameSnapshotChanged = void Function(XrayInspectorSnapshot snapshot);

typedef GameFinished = void Function(XrayInspectorSnapshot snapshot);

class XrayObjectInstance {
  XrayObjectInstance({
    required this.type,
    required this.relativePosition,
    required this.scale,
    required this.rotation,
  });

  final XrayObjectType type;
  final Offset relativePosition;
  final double scale;
  final double rotation;
  bool found = false;
  double flashAge = 99;
}

class XrayBag {
  XrayBag({
    required this.objects,
    required this.x,
    required this.yFactor,
    required this.speed,
  });

  final List<XrayObjectInstance> objects;
  final double yFactor;
  double x;
  double speed;

  bool get hasDangerRemaining {
    return objects.any((object) => object.type.isDangerous && !object.found);
  }
}

class XrayPulse {
  XrayPulse({
    required this.center,
    required this.color,
    required this.label,
    required this.age,
  });

  final Offset center;
  final Color color;
  final String label;
  double age;
}

class XrayInspectorGame extends FlameGame {
  XrayInspectorGame({
    required this.onSnapshotChanged,
    required this.onGameFinished,
    Random? random,
  }) : _random = random ?? Random();

  static const _cyan = Color(0xFF38F6FF);
  static const _cyanSoft = Color(0xFF67E8F9);
  static const _danger = Color(0xFFFF3B5C);
  static const _success = Color(0xFF37FFB5);

  final GameSnapshotChanged onSnapshotChanged;
  final GameFinished onGameFinished;
  final Random _random;
  final XrayInspectorRules _rules = XrayInspectorRules();
  final List<XrayPulse> _pulses = [];

  XrayBag? _bag;
  double _elapsed = 0;
  double _screenFlash = 0;
  bool _finished = false;

  XrayInspectorSnapshot get snapshot => _rules.snapshot;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _spawnBag();
    onSnapshotChanged(snapshot);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished || size.x <= 0 || size.y <= 0) {
      return;
    }

    _elapsed += dt;
    _screenFlash = max(0, _screenFlash - dt);

    final bag = _bag;
    if (bag != null) {
      bag.x += bag.speed * dt;
      for (final object in bag.objects) {
        object.flashAge += dt;
      }
      if (bag.x - (_bagSize.width / 2) > size.x + 36) {
        if (bag.hasDangerRemaining) {
          _rules.resolveMissedDanger();
          _screenFlash = 0.25;
          _pulses.add(
            XrayPulse(
              center: _scannerRect.center,
              color: _danger,
              label: '-1 LIFE',
              age: 0,
            ),
          );
          onSnapshotChanged(snapshot);
          _finishIfNeeded();
        }
        _spawnBag();
      }
    }

    for (final pulse in _pulses) {
      pulse.age += dt;
    }
    _pulses.removeWhere((pulse) => pulse.age > 0.58);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _paintBackground(canvas);
    _paintScanner(canvas);
    _paintBag(canvas);
    _paintPulses(canvas);
    _paintScreenFlash(canvas);
  }

  void tapAt(Offset position) {
    if (_finished) {
      return;
    }

    final bag = _bag;
    if (bag == null) {
      return;
    }

    final hit = _hitTestObject(position, bag);
    if (hit == null || hit.found) {
      return;
    }

    final center = _objectCenter(hit, _bagRect(bag));
    if (hit.type.isDangerous) {
      hit.found = true;
      _rules.resolveDangerTap();
      _pulses.add(
        XrayPulse(center: center, color: _success, label: '+10', age: 0),
      );
    } else {
      hit.flashAge = 0;
      _rules.resolveSafeTap();
      _screenFlash = 0.18;
      _pulses.add(
        XrayPulse(center: center, color: _danger, label: '-5', age: 0),
      );
    }

    onSnapshotChanged(snapshot);
  }

  void clearBag() {
    if (_finished) {
      return;
    }

    final bag = _bag;
    if (bag == null) {
      return;
    }

    if (bag.hasDangerRemaining) {
      _rules.resolveFalseClear();
      _screenFlash = 0.28;
      _pulses.add(
        XrayPulse(
          center: _bagRect(bag).center,
          color: _danger,
          label: 'HOLD',
          age: 0,
        ),
      );
      onSnapshotChanged(snapshot);
      _finishIfNeeded();
      _spawnBag();
      return;
    }

    _rules.resolveSafeBagClear();
    _pulses.add(
      XrayPulse(
        center: _bagRect(bag).center,
        color: _success,
        label: '+5 CLEAR',
        age: 0,
      ),
    );
    onSnapshotChanged(snapshot);
    _spawnBag();
  }

  void _spawnBag() {
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final objectCount = 4 + _random.nextInt(3);
    final dangerousCount = _random.nextDouble() < 0.78
        ? 1 + _random.nextInt(_elapsed > 35 ? 2 : 1)
        : 0;
    final objects = <XrayObjectInstance>[];
    final dangerTypes = XrayObjectType.values
        .where((type) => type.isDangerous)
        .toList();
    final safeTypes = XrayObjectType.values
        .where((type) => !type.isDangerous)
        .toList();
    final slots = _bagSlots.toList()..shuffle(_random);

    for (var i = 0; i < dangerousCount; i++) {
      objects.add(
        _buildObject(
          dangerTypes[_random.nextInt(dangerTypes.length)],
          slots.removeLast(),
        ),
      );
    }
    while (objects.length < objectCount && slots.isNotEmpty) {
      objects.add(
        _buildObject(
          safeTypes[_random.nextInt(safeTypes.length)],
          slots.removeLast(),
        ),
      );
    }
    objects.shuffle(_random);

    _bag = XrayBag(
      objects: objects,
      x: -_bagSize.width * 0.62,
      yFactor: 0.52 + ((_random.nextDouble() - 0.5) * 0.08),
      speed: min(132, 72 + (_elapsed * 1.4)),
    );
  }

  XrayObjectInstance _buildObject(XrayObjectType type, Offset slot) {
    return XrayObjectInstance(
      type: type,
      relativePosition: slot,
      scale: 0.82 + (_random.nextDouble() * 0.28),
      rotation: (_random.nextDouble() - 0.5) * 0.7,
    );
  }

  XrayObjectInstance? _hitTestObject(Offset position, XrayBag bag) {
    final rect = _bagRect(bag);
    final candidates = bag.objects.where((object) {
      final center = _objectCenter(object, rect);
      return (position - center).distance <= _hitRadius(object);
    }).toList();
    if (candidates.isEmpty) {
      return null;
    }
    candidates.sort((a, b) {
      final distanceA = (position - _objectCenter(a, rect)).distance;
      final distanceB = (position - _objectCenter(b, rect)).distance;
      return distanceA.compareTo(distanceB);
    });
    return candidates.first;
  }

  Offset _objectCenter(XrayObjectInstance object, Rect bagRect) {
    return bagRect.center +
        Offset(
          object.relativePosition.dx * bagRect.width,
          object.relativePosition.dy * bagRect.height,
        );
  }

  double _hitRadius(XrayObjectInstance object) {
    return 28 * object.scale * _objectScaleBase;
  }

  Size get _bagSize {
    return Size(min(size.x * 0.82, 360), min(size.y * 0.36, 290));
  }

  double get _objectScaleBase => min(size.x, size.y) / 390;

  Rect get _scannerRect {
    final top = size.y * 0.16;
    final height = size.y * 0.65;
    return Rect.fromLTWH(16, top, size.x - 32, height);
  }

  Rect _bagRect(XrayBag bag) {
    final bagSize = _bagSize;
    final scanner = _scannerRect;
    final centerY = scanner.top + (scanner.height * bag.yFactor);
    return Rect.fromCenter(
      center: Offset(bag.x, centerY),
      width: bagSize.width,
      height: bagSize.height,
    );
  }

  List<Offset> get _bagSlots => const [
    Offset(-0.31, -0.23),
    Offset(-0.05, -0.25),
    Offset(0.23, -0.22),
    Offset(-0.28, 0.08),
    Offset(0.03, 0.08),
    Offset(0.29, 0.1),
    Offset(-0.12, 0.3),
    Offset(0.18, 0.31),
  ];

  void _finishIfNeeded() {
    if (!_finished && _rules.isGameOver) {
      _finished = true;
      onGameFinished(snapshot);
    }
  }

  void _paintBackground(Canvas canvas) {
    final bounds = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(bounds, Paint()..color = const Color(0xFF030912));

    final glowCenter = Offset(size.x * 0.5, size.y * 0.34);
    canvas.drawCircle(
      glowCenter,
      size.x * 0.72,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF0E7490).withValues(alpha: 0.34),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: glowCenter, radius: size.x * 0.72),
            ),
    );

    final gridPaint = Paint()
      ..color = _cyan.withValues(alpha: 0.055)
      ..strokeWidth = 1;
    const gridSize = 34.0;
    final xOffset = (_elapsed * 14) % gridSize;
    for (var x = -gridSize + xOffset; x <= size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (var y = 0.0; y <= size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }

  void _paintScanner(Canvas canvas) {
    final scanner = _scannerRect;
    final outer = RRect.fromRectAndRadius(scanner, const Radius.circular(18));
    canvas.drawRRect(
      outer,
      Paint()..color = const Color(0xFF03151C).withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _cyan.withValues(alpha: 0.48),
    );

    final beamY =
        scanner.top + scanner.height * (0.34 + sin(_elapsed * 1.4) * 0.22);
    final beam = Rect.fromLTWH(scanner.left + 8, beamY, scanner.width - 16, 54);
    canvas.drawRRect(
      RRect.fromRectAndRadius(beam, const Radius.circular(16)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            _cyan.withValues(alpha: 0.2),
            Colors.transparent,
          ],
        ).createShader(beam),
    );

    final linePaint = Paint()
      ..color = _cyan.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (var x = scanner.left + 24; x < scanner.right; x += 38) {
      canvas.drawLine(
        Offset(x, scanner.top),
        Offset(x, scanner.bottom),
        linePaint,
      );
    }
    for (var y = scanner.top + 28; y < scanner.bottom; y += 38) {
      canvas.drawLine(
        Offset(scanner.left, y),
        Offset(scanner.right, y),
        linePaint,
      );
    }
  }

  void _paintBag(Canvas canvas) {
    final bag = _bag;
    if (bag == null) {
      return;
    }

    final rect = _bagRect(bag);
    final bagRRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    final handleRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.top - 4),
      width: rect.width * 0.32,
      height: rect.height * 0.2,
    );
    final handle = RRect.fromRectAndRadius(
      handleRect,
      const Radius.circular(18),
    );

    canvas.drawRRect(
      bagRRect,
      Paint()
        ..color = _cyan.withValues(alpha: 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(
      bagRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _cyan.withValues(alpha: 0.68),
    );
    canvas.drawRRect(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _cyanSoft.withValues(alpha: 0.52),
    );

    canvas.save();
    canvas.clipRRect(bagRRect);
    for (final object in bag.objects) {
      _paintObject(canvas, object, rect);
    }
    canvas.restore();
  }

  void _paintObject(Canvas canvas, XrayObjectInstance object, Rect bagRect) {
    final center = _objectCenter(object, bagRect);
    final scale = object.scale * _objectScaleBase;
    final alpha = object.found ? 0.24 : 0.84;
    final flash = object.flashAge < 0.22 ? 1 - (object.flashAge / 0.22) : 0.0;
    final strokeColor = Color.lerp(
      _cyan,
      _danger,
      flash,
    )!.withValues(alpha: alpha);
    final fillColor = Color.lerp(
      _cyan,
      _danger,
      flash,
    )!.withValues(alpha: alpha * 0.22);

    canvas.drawCircle(
      center,
      _hitRadius(object) * 0.86,
      Paint()
        ..color = strokeColor.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(object.rotation);
    canvas.scale(scale);
    _drawObjectShape(canvas, object.type, fill, stroke);
    canvas.restore();

    if (object.found) {
      canvas.drawCircle(
        center,
        _hitRadius(object) * 0.72,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _success.withValues(alpha: 0.55),
      );
      canvas.drawLine(
        center.translate(-10, 0),
        center.translate(-2, 8),
        Paint()
          ..color = _success.withValues(alpha: 0.8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        center.translate(-2, 8),
        center.translate(13, -10),
        Paint()
          ..color = _success.withValues(alpha: 0.8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawObjectShape(
    Canvas canvas,
    XrayObjectType type,
    Paint fill,
    Paint stroke,
  ) {
    switch (type) {
      case XrayObjectType.knife:
        final blade = Path()
          ..moveTo(-26, -7)
          ..quadraticBezierTo(5, -29, 28, -31)
          ..quadraticBezierTo(20, -8, -7, 8)
          ..close();
        canvas.drawPath(blade, fill);
        canvas.drawPath(blade, stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-35, 5, 26, 11),
            const Radius.circular(5),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-35, 5, 26, 11),
            const Radius.circular(5),
          ),
          stroke,
        );
      case XrayObjectType.scissors:
        canvas.drawCircle(const Offset(-16, 14), 10, stroke);
        canvas.drawCircle(const Offset(8, 14), 10, stroke);
        canvas.drawLine(const Offset(-6, 6), const Offset(28, -24), stroke);
        canvas.drawLine(const Offset(2, 5), const Offset(-26, -24), stroke);
        canvas.drawCircle(Offset.zero, 3, fill);
      case XrayObjectType.lighter:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -24, 30, 48),
            const Radius.circular(7),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -24, 30, 48),
            const Radius.circular(7),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-11, -35, 22, 15),
            const Radius.circular(4),
          ),
          stroke,
        );
        canvas.drawCircle(const Offset(8, -27), 4, stroke);
      case XrayObjectType.razor:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-30, -13, 60, 26),
            const Radius.circular(5),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-30, -13, 60, 26),
            const Radius.circular(5),
          ),
          stroke,
        );
        for (var x = -20.0; x <= 20; x += 10) {
          canvas.drawLine(Offset(x - 5, -7), Offset(x + 5, 7), stroke);
        }
      case XrayObjectType.batteryPack:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-28, -18, 56, 36),
            const Radius.circular(8),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-28, -18, 56, 36),
            const Radius.circular(8),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-8, -25, 16, 7),
            const Radius.circular(3),
          ),
          stroke,
        );
        for (var x = -16.0; x <= 16; x += 16) {
          canvas.drawLine(Offset(x, -11), Offset(x, 11), stroke);
        }
      case XrayObjectType.phone:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -30, 30, 60),
            const Radius.circular(7),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-15, -30, 30, 60),
            const Radius.circular(7),
          ),
          stroke,
        );
        canvas.drawCircle(const Offset(0, 22), 2.5, stroke);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-10, -22, 20, 35),
            const Radius.circular(3),
          ),
          stroke,
        );
      case XrayObjectType.laptop:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-32, -22, 64, 38),
            const Radius.circular(4),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-32, -22, 64, 38),
            const Radius.circular(4),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-39, 17, 78, 8),
            const Radius.circular(3),
          ),
          stroke,
        );
        for (var x = -22.0; x <= 22; x += 11) {
          canvas.drawLine(Offset(x, -13), Offset(x, 8), stroke);
        }
      case XrayObjectType.bottle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-11, -23, 22, 47),
            const Radius.circular(10),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-11, -23, 22, 47),
            const Radius.circular(10),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-6, -35, 12, 16),
            const Radius.circular(3),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(-9, 4), const Offset(9, 4), stroke);
      case XrayObjectType.sandwich:
        final bread = Path()
          ..moveTo(-30, 18)
          ..lineTo(0, -24)
          ..lineTo(31, 18)
          ..close();
        canvas.drawPath(bread, fill);
        canvas.drawPath(bread, stroke);
        canvas.drawLine(const Offset(-20, 8), const Offset(20, 8), stroke);
        for (var i = -12.0; i <= 12; i += 12) {
          canvas.drawCircle(Offset(i, 3), 2, fill);
        }
      case XrayObjectType.keys:
        canvas.drawCircle(const Offset(-12, -4), 11, stroke);
        canvas.drawLine(const Offset(-1, 3), const Offset(28, 25), stroke);
        canvas.drawLine(const Offset(14, 15), const Offset(6, 23), stroke);
        canvas.drawLine(const Offset(22, 21), const Offset(14, 29), stroke);
        canvas.drawCircle(const Offset(8, -12), 8, stroke);
      case XrayObjectType.headphones:
        canvas.drawArc(
          const Rect.fromLTWH(-30, -32, 60, 56),
          pi,
          pi,
          false,
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-33, -1, 14, 29),
            const Radius.circular(7),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(19, -1, 14, 29),
            const Radius.circular(7),
          ),
          fill,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-33, -1, 14, 29),
            const Radius.circular(7),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(19, -1, 14, 29),
            const Radius.circular(7),
          ),
          stroke,
        );
    }
  }

  void _paintPulses(Canvas canvas) {
    for (final pulse in _pulses) {
      final progress = (pulse.age / 0.58).clamp(0.0, 1.0);
      final alpha = 1 - progress;
      final radius = 18 + (progress * 44);
      canvas.drawCircle(
        pulse.center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = pulse.color.withValues(alpha: alpha * 0.72)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: pulse.label,
          style: TextStyle(
            color: pulse.color.withValues(alpha: alpha),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        pulse.center.translate(-textPainter.width / 2, -42 - (progress * 22)),
      );
    }
  }

  void _paintScreenFlash(Canvas canvas) {
    if (_screenFlash <= 0) {
      return;
    }

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = _danger.withValues(alpha: min(0.2, _screenFlash * 0.72)),
    );
  }
}
