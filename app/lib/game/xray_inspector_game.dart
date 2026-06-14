import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'systems/level_progression_rules.dart';
import 'systems/xray_inspector_rules.dart';

typedef GameSnapshotChanged = void Function(XrayInspectorSnapshot snapshot);

typedef LevelComplete =
    Future<void> Function({
      required XrayInspectorSnapshot snapshot,
      required int bagsCleared,
    });

typedef LevelFailed =
    Future<void> Function({
      required XrayInspectorSnapshot snapshot,
      required int bagsCleared,
    });

typedef ItemDiscovered = void Function(XrayObjectType type);

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
  double age = 0;
  bool hadMistake = false;

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
    required this.levelConfig,
    required this.onSnapshotChanged,
    required this.onLevelComplete,
    required this.onLevelFailed,
    required this.onItemDiscovered,
    Random? random,
  }) : _random = random ?? Random();

  static const _cyan = Color(0xFF38F6FF);
  static const _cyanSoft = Color(0xFF67E8F9);
  static const _danger = Color(0xFFFF3B5C);
  static const _success = Color(0xFF37FFB5);
  static const _perfect = Color(0xFFFFD166);

  final LevelConfig levelConfig;
  final GameSnapshotChanged onSnapshotChanged;
  final LevelComplete onLevelComplete;
  final LevelFailed onLevelFailed;
  final ItemDiscovered onItemDiscovered;
  final Random _random;
  final XrayInspectorRules _rules = XrayInspectorRules();
  final List<XrayPulse> _pulses = [];
  final Map<XrayObjectType, ui.Image> _itemSprites = {};
  ui.Image? _gameplayBackground;
  ui.Image? _suitcaseSprite;

  XrayBag? _bag;
  double _elapsed = 0;
  double _screenFlash = 0;
  Color _screenFlashColor = _danger;
  bool _finished = false;
  int _bagsCleared = 0;

  XrayInspectorSnapshot get snapshot => _rules.snapshot;
  int get bagsCleared => _bagsCleared;
  int get bagsToClear => levelConfig.bagsToClear;
  int get currentDangerCount {
    return _bag?.objects.where((object) => object.type.isDangerous).length ?? 0;
  }

  int get currentMarkedDangerCount {
    return _bag?.objects
            .where((object) => object.type.isDangerous && object.found)
            .length ??
        0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadGameplayBackground();
    await _loadSuitcaseSprite();
    await _loadItemSprites();
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
      bag.age += dt;
      for (final object in bag.objects) {
        object.flashAge += dt;
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
    if (_bagRevealProgress(bag) < 1) {
      return;
    }

    final hit = _hitTestObject(position, bag);
    if (hit == null || hit.found) {
      return;
    }

    final center = _objectCenter(hit, _objectAreaRect(_bagRect(bag)));
    if (hit.type.isDangerous) {
      final previousCombo = _rules.combo;
      final points = _rules.pointsForNextDangerTap();
      hit.found = true;
      final snapshot = _rules.resolveDangerTap();
      onItemDiscovered(hit.type);
      _pulses.add(
        XrayPulse(
          center: center,
          color: _success,
          label: 'MARKED +$points',
          age: 0,
        ),
      );
      _addComboMilestonePulse(previousCombo, snapshot);
    } else {
      bag.hadMistake = true;
      hit.flashAge = 0;
      _rules.resolveSafeTap();
      _flashScreen(_danger, 0.18);
      _pulses.add(
        XrayPulse(
          center: center,
          color: _danger,
          label: 'FALSE TAP -${XrayInspectorRules.safeTapPenalty}',
          age: 0,
        ),
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
    if (_bagRevealProgress(bag) < 1) {
      return;
    }

    if (bag.hasDangerRemaining) {
      bag.hadMistake = true;
      _rules.resolveFalseClear();
      _flashScreen(_danger, 0.3);
      _pulses.add(
        XrayPulse(
          center: _bagRect(bag).center,
          color: _danger,
          label: 'THREAT LEFT!',
          age: 0,
        ),
      );
      onSnapshotChanged(snapshot);
      _finishIfNeeded();
      if (!_rules.isGameOver) {
        _spawnBag();
        onSnapshotChanged(snapshot);
      }
      return;
    }

    for (final object in bag.objects) {
      if (!object.type.isDangerous) {
        onItemDiscovered(object.type);
      }
    }
    final previousCombo = _rules.combo;
    final clearPoints = _rules.pointsForNextSafeBagClear();
    final isPerfect = !bag.hadMistake;
    final clearSnapshot = _rules.resolveSafeBagClear(isPerfect: isPerfect);
    _pulses.add(
      XrayPulse(
        center: _bagRect(bag).center,
        color: _success,
        label: 'BAG CLEAR +$clearPoints',
        age: 0,
      ),
    );
    _flashScreen(isPerfect ? _perfect : _success, 0.18);
    if (isPerfect) {
      _pulses.add(
        XrayPulse(
          center: _bagRect(bag).center.translate(0, -34),
          color: _perfect,
          label: 'PERFECT +${XrayInspectorRules.perfectBagBonus}',
          age: 0,
        ),
      );
    }
    _addComboMilestonePulse(previousCombo, clearSnapshot);
    _bagsCleared += 1;
    onSnapshotChanged(clearSnapshot);
    if (_bagsCleared >= levelConfig.bagsToClear) {
      _finishLevelComplete(clearSnapshot);
      return;
    }
    _spawnBag();
  }

  void _spawnBag() {
    if (size.x <= 0 || size.y <= 0) {
      return;
    }

    final objectCount = 4 + _random.nextInt(3);
    final maxDangerCount = levelConfig.allowTwoDangerBags && _elapsed > 35
        ? 2
        : 1;
    final dangerousCount = _random.nextDouble() < 0.78
        ? 1 + _random.nextInt(maxDangerCount)
        : 0;
    final objects = <XrayObjectInstance>[];
    final dangerTypes = levelConfig.dangerPool;
    final safeTypes = levelConfig.safePool;
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

    _bag = XrayBag(objects: objects, x: size.x / 2, yFactor: 0.52, speed: 0);
  }

  XrayObjectInstance _buildObject(XrayObjectType type, Offset slot) {
    return XrayObjectInstance(
      type: type,
      relativePosition: slot,
      scale: 0.94 + (_random.nextDouble() * 0.32),
      rotation: (_random.nextDouble() - 0.5) * 0.58,
    );
  }

  XrayObjectInstance? _hitTestObject(Offset position, XrayBag bag) {
    final rect = _objectAreaRect(_bagRect(bag));
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
    return max(34, 32 * object.scale * _objectScaleBase);
  }

  Size get _bagSize {
    return Size(min(size.x * 0.72, 340), min(size.y * 0.48, 430));
  }

  double get _objectScaleBase => min(size.x, size.y) / 360;

  Rect get _scannerRect {
    final top = size.y * 0.15;
    final height = size.y * 0.66;
    return Rect.fromLTWH(16, top, size.x - 32, height);
  }

  Rect _bagRect(XrayBag bag) {
    final target = _targetBagRect(bag);
    final progress = _bagRevealProgress(bag);
    final eased = 1 - pow(1 - progress, 3).toDouble();
    final start = Rect.fromCenter(
      center: Offset(
        target.center.dx,
        _scannerRect.top + _scannerRect.height * 0.32,
      ),
      width: target.width * 0.44,
      height: target.height * 0.44,
    );
    return Rect.lerp(start, target, eased)!;
  }

  Rect _targetBagRect(XrayBag bag) {
    final bagSize = _bagSize;
    final scanner = _scannerRect;
    final centerY = scanner.top + (scanner.height * 0.5);
    return Rect.fromCenter(
      center: Offset(bag.x, centerY),
      width: bagSize.width,
      height: bagSize.height,
    );
  }

  Rect _objectAreaRect(Rect bagRect) {
    return Rect.fromLTRB(
      bagRect.left + bagRect.width * 0.15,
      bagRect.top + bagRect.height * 0.27,
      bagRect.right - bagRect.width * 0.15,
      bagRect.bottom - bagRect.height * 0.18,
    );
  }

  double _bagRevealProgress(XrayBag bag) {
    return (bag.age / 0.68).clamp(0, 1).toDouble();
  }

  double _itemRevealProgress(XrayBag bag) {
    return ((bag.age - 0.54) / 0.24).clamp(0, 1).toDouble();
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
      onLevelFailed(snapshot: snapshot, bagsCleared: _bagsCleared);
    }
  }

  /// Called when the player earns a rewarded continue. Restores 1 life
  /// and resumes the game so the player can keep playing the current level.
  void grantContinue() {
    if (!_rules.isGameOver) return;
    _rules.grantContinueLife();
    _finished = false;
    onSnapshotChanged(snapshot);
    resumeEngine();
  }

  void _finishLevelComplete(XrayInspectorSnapshot snapshot) {
    if (_finished) {
      return;
    }
    _finished = true;
    onLevelComplete(snapshot: snapshot, bagsCleared: _bagsCleared);
  }

  void _addComboMilestonePulse(
    int previousCombo,
    XrayInspectorSnapshot snapshot,
  ) {
    if (snapshot.combo <= previousCombo ||
        snapshot.combo % XrayInspectorRules.comboStep != 0 ||
        snapshot.comboMultiplier <= 1) {
      return;
    }

    _pulses.add(
      XrayPulse(
        center: _scannerRect.topCenter.translate(0, 34),
        color: _perfect,
        label: 'COMBO x${_formatMultiplier(snapshot.comboMultiplier)}!',
        age: 0,
      ),
    );
  }

  Future<void> _loadItemSprites() async {
    for (final type in XrayObjectType.values) {
      try {
        _itemSprites[type] = await images.load(_itemSpritePath(type));
      } catch (_) {
        // Keep the Canvas fallback available if an asset is missing.
      }
    }
  }

  Future<void> _loadGameplayBackground() async {
    try {
      _gameplayBackground = await images.load(
        'backgrounds/bg_gameplay_scanner.png',
      );
    } catch (_) {
      _gameplayBackground = null;
    }
  }

  Future<void> _loadSuitcaseSprite() async {
    try {
      _suitcaseSprite = await images.load('ui/ui_suitcase_xray_empty.png');
    } catch (_) {
      _suitcaseSprite = null;
    }
  }

  String _itemSpritePath(XrayObjectType type) {
    return switch (type) {
      XrayObjectType.knife => 'items/danger/item_danger_knife.png',
      XrayObjectType.scissors => 'items/danger/item_danger_scissors.png',
      XrayObjectType.lighter => 'items/danger/item_danger_lighter.png',
      XrayObjectType.razor => 'items/danger/item_danger_razor.png',
      XrayObjectType.batteryPack => 'items/danger/item_danger_battery_pack.png',
      XrayObjectType.phone => 'items/safe/item_safe_phone.png',
      XrayObjectType.laptop => 'items/safe/item_safe_laptop.png',
      XrayObjectType.bottle => 'items/safe/item_safe_bottle.png',
      XrayObjectType.sandwich => 'items/safe/item_safe_sandwich.png',
      XrayObjectType.keys => 'items/safe/item_safe_keys.png',
      XrayObjectType.headphones => 'items/safe/item_safe_headphones.png',
    };
  }

  void _flashScreen(Color color, double duration) {
    _screenFlashColor = color;
    _screenFlash = duration;
  }

  String _formatMultiplier(double multiplier) {
    if (multiplier == multiplier.roundToDouble()) {
      return multiplier.toStringAsFixed(0);
    }
    return multiplier.toStringAsFixed(1);
  }

  void _paintBackground(Canvas canvas) {
    final bounds = Offset.zero & Size(size.x, size.y);
    final background = _gameplayBackground;
    if (background != null) {
      _drawCoverImage(canvas, background, bounds);
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x99030912), Color(0x26030912), Color(0x66030912)],
            stops: [0, 0.48, 1],
          ).createShader(bounds),
      );
    } else {
      canvas.drawRect(bounds, Paint()..color = const Color(0xFF030912));
    }

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
      ..color = _cyan.withValues(alpha: background == null ? 0.055 : 0.035)
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

  void _drawCoverImage(Canvas canvas, ui.Image image, Rect destination) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final sourceAspect = imageSize.width / imageSize.height;
    final destinationAspect = destination.width / destination.height;
    late final Rect source;

    if (sourceAspect > destinationAspect) {
      final sourceWidth = imageSize.height * destinationAspect;
      source = Rect.fromLTWH(
        (imageSize.width - sourceWidth) / 2,
        0,
        sourceWidth,
        imageSize.height,
      );
    } else {
      final sourceHeight = imageSize.width / destinationAspect;
      source = Rect.fromLTWH(
        0,
        (imageSize.height - sourceHeight) / 2,
        imageSize.width,
        sourceHeight,
      );
    }

    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );
  }

  void _paintScanner(Canvas canvas) {
    final scanner = _scannerRect;
    final hasBackground = _gameplayBackground != null;
    final outer = RRect.fromRectAndRadius(scanner, const Radius.circular(18));
    final inner = RRect.fromRectAndRadius(
      scanner.deflate(12),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      outer.inflate(8),
      Paint()
        ..color = _cyan.withValues(alpha: hasBackground ? 0.07 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = const Color(
          0xFF03151C,
        ).withValues(alpha: hasBackground ? 0.58 : 0.92),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _cyan.withValues(alpha: hasBackground ? 0.34 : 0.48),
    );
    canvas.drawRRect(
      inner,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _cyan.withValues(alpha: 0.07),
            const Color(0xFF03151C).withValues(alpha: 0.1),
            _cyan.withValues(alpha: 0.04),
          ],
        ).createShader(scanner),
    );

    final beamY =
        scanner.top + scanner.height * (0.34 + sin(_elapsed * 1.4) * 0.22);
    final beam = Rect.fromLTWH(
      scanner.left + 12,
      beamY,
      scanner.width - 24,
      62,
    );
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
    canvas.drawLine(
      Offset(beam.left + 10, beam.center.dy),
      Offset(beam.right - 10, beam.center.dy),
      Paint()
        ..color = _cyanSoft.withValues(alpha: 0.5)
        ..strokeWidth = 2.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final linePaint = Paint()
      ..color = _cyan.withValues(alpha: 0.09)
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

    final cornerPaint = Paint()
      ..color = _cyanSoft.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    const corner = 34.0;
    final guide = scanner.deflate(14);
    for (final point in [
      guide.topLeft,
      guide.topRight,
      guide.bottomLeft,
      guide.bottomRight,
    ]) {
      final sx = point.dx < guide.center.dx ? 1.0 : -1.0;
      final sy = point.dy < guide.center.dy ? 1.0 : -1.0;
      canvas.drawLine(point, point.translate(corner * sx, 0), cornerPaint);
      canvas.drawLine(point, point.translate(0, corner * sy), cornerPaint);
    }

    final beltPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final belt = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        scanner.left + 26,
        scanner.bottom - 42,
        scanner.width - 52,
        24,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(belt, beltPaint);
    canvas.drawLine(
      Offset(scanner.left + 38, scanner.bottom - 30),
      Offset(scanner.right - 38, scanner.bottom - 30),
      Paint()
        ..color = _cyan.withValues(alpha: 0.28)
        ..strokeWidth = 2,
    );
  }

  void _paintBag(Canvas canvas) {
    final bag = _bag;
    if (bag == null) {
      return;
    }

    final rect = _bagRect(bag);
    final reveal = _bagRevealProgress(bag);
    final itemReveal = _itemRevealProgress(bag);
    final objectArea = _objectAreaRect(rect);
    final suitcase = _suitcaseSprite;
    if (suitcase != null) {
      canvas.saveLayer(
        rect.inflate(20),
        Paint()..color = Colors.white.withValues(alpha: reveal),
      );
      _drawContainImage(canvas, suitcase, rect);
      canvas.restore();
    } else {
      _paintFallbackBag(canvas, rect);
    }

    if (itemReveal <= 0) {
      return;
    }

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(objectArea, const Radius.circular(20)),
    );
    canvas.saveLayer(
      objectArea,
      Paint()..color = Colors.white.withValues(alpha: itemReveal),
    );
    for (final object in bag.objects) {
      _paintObject(canvas, object, objectArea);
    }
    canvas.restore();
    canvas.restore();
  }

  void _paintFallbackBag(Canvas canvas, Rect rect) {
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
        ..color = _cyan.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      bagRRect,
      Paint()..color = const Color(0xFF062330).withValues(alpha: 0.3),
    );
    canvas.drawRRect(
      bagRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..color = _cyan.withValues(alpha: 0.78),
    );
    canvas.drawRRect(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _cyanSoft.withValues(alpha: 0.52),
    );
  }

  void _drawContainImage(Canvas canvas, ui.Image image, Rect destination) {
    final imageAspect = image.width / image.height;
    final destinationAspect = destination.width / destination.height;
    late final Rect fitted;
    if (imageAspect > destinationAspect) {
      final height = destination.width / imageAspect;
      fitted = Rect.fromCenter(
        center: destination.center,
        width: destination.width,
        height: height,
      );
    } else {
      final width = destination.height * imageAspect;
      fitted = Rect.fromCenter(
        center: destination.center,
        width: width,
        height: destination.height,
      );
    }

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fitted,
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );
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
      ..strokeWidth = 2.45
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(object.rotation);
    final sprite = _itemSprites[object.type];
    if (sprite != null) {
      _drawObjectSprite(canvas, object, sprite, alpha, flash);
    } else {
      canvas.scale(scale);
      _drawObjectShape(canvas, object.type, fill, stroke);
    }
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

  void _drawObjectSprite(
    Canvas canvas,
    XrayObjectInstance object,
    ui.Image sprite,
    double alpha,
    double flash,
  ) {
    final side = _hitRadius(object) * 2.18;
    final source = Rect.fromLTWH(
      0,
      0,
      sprite.width.toDouble(),
      sprite.height.toDouble(),
    );
    final destination = Rect.fromCenter(
      center: Offset.zero,
      width: side,
      height: side,
    );
    final tint = Color.lerp(Colors.white, _danger, flash)!;
    canvas.drawImageRect(
      sprite,
      source,
      destination,
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          tint.withValues(alpha: alpha),
          BlendMode.modulate,
        ),
    );
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
      Paint()
        ..color = _screenFlashColor.withValues(
          alpha: min(0.2, _screenFlash * 0.72),
        ),
    );
  }
}
