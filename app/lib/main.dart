import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'game/systems/ad_break_rules.dart';
import 'game/systems/level_progression_rules.dart';
import 'game/systems/xray_inspector_rules.dart';
import 'game/xray_inspector_game.dart';
import 'services/ads_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AdsService.initialize();
  runApp(const XrayScanApp());
}

class XrayScanApp extends StatelessWidget {
  const XrayScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-Ray Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38F6FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF030912),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

enum AppScreen {
  menu,
  levelMap,
  playing,
  paused,
  levelClear,
  levelFailed,
  itemDatabase,
}

enum EncyclopediaGroup { danger, safe }

class _XrayStyle {
  const _XrayStyle._();

  static const Color bg = Color(0xFF030912);
  static const Color panel = Color(0xDD071826);
  static const Color panelSoft = Color(0xCC0B2033);
  static const Color cyan = Color(0xFF38F6FF);
  static const Color cyanSoft = Color(0xFF67E8F9);
  static const Color success = Color(0xFF37FFB5);
  static const Color danger = Color(0xFFFF3B5C);
  static const Color gold = Color(0xFFFFD166);
  static const Color text = Color(0xFFE5FEFF);
  static const Color muted = Color(0xFFB7EFF4);
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _XrayStyle.panel,
        border: Border.all(
          color: borderColor ?? _XrayStyle.cyan.withValues(alpha: 0.5),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _XrayActionButton extends StatelessWidget {
  const _XrayActionButton._({
    required this.onPressed,
    required this.label,
    required this.isPrimary,
    this.icon,
    this.compact = false,
  });

  factory _XrayActionButton.primary({
    required VoidCallback onPressed,
    required String label,
    Widget? icon,
    bool compact = false,
  }) {
    return _XrayActionButton._(
      onPressed: onPressed,
      label: label,
      isPrimary: true,
      icon: icon,
      compact: compact,
    );
  }

  factory _XrayActionButton.secondary({
    required VoidCallback onPressed,
    required String label,
    Widget? icon,
    bool compact = false,
  }) {
    return _XrayActionButton._(
      onPressed: onPressed,
      label: label,
      isPrimary: false,
      icon: icon,
      compact: compact,
    );
  }

  final VoidCallback onPressed;
  final String label;
  final Widget? icon;
  final bool isPrimary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? Colors.black : _XrayStyle.text;
    final background = isPrimary ? _XrayStyle.success : _XrayStyle.panelSoft;
    final border = isPrimary
        ? _XrayStyle.success.withValues(alpha: 0.8)
        : _XrayStyle.cyan.withValues(alpha: 0.58);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foreground, size: compact ? 18 : 26),
            child: icon!,
          ),
          SizedBox(width: compact ? 6 : 10),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: compact ? 15 : 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: compact ? 42 : 58,
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border, width: 1.4),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (isPrimary)
                BoxShadow(
                  color: _XrayStyle.success.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

String _bestStarsLabel(int stars) {
  if (stars <= 0) {
    return 'No stars yet';
  }
  return '$stars ${stars == 1 ? 'star' : 'stars'}';
}

class _IconPanelButton extends StatelessWidget {
  const _IconPanelButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _XrayStyle.panel,
            border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _XrayStyle.cyanSoft),
        ),
      ),
    );
  }
}

class _AirportBackdrop extends StatelessWidget {
  const _AirportBackdrop({required this.child, this.imageAsset});

  final Widget child;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final imageAsset = this.imageAsset;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageAsset == null)
          const _AirportScene()
        else
          Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _AirportScene(),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.08),
                _XrayStyle.bg.withValues(alpha: 0.22),
                _XrayStyle.bg.withValues(alpha: 0.62),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ScannerGridBackdrop extends StatelessWidget {
  const _ScannerGridBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _XrayStyle.bg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ScannerGridPainter()),
          child,
        ],
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  StorageService? _storage;
  AppScreen _screen = AppScreen.menu;
  int _highScore = 0;
  int _lastScore = 0;
  int _lastBagsCleared = 0;
  int _lastBagsToClear = 0;
  int _lastStarsEarned = 0;
  int _lastBestStars = 0;
  bool _canPlayNextLevel = false;
  bool _didUnlockNextLevel = false;
  XrayObjectType? _lastUnlockedDanger;
  Set<XrayObjectType> _unlockedItems = {};
  EncyclopediaGroup _selectedGroup = EncyclopediaGroup.danger;
  bool _soundEnabled = true;
  LevelProgressSnapshot _levelProgress = const LevelProgressSnapshot(
    highestUnlockedLevel: 1,
    bestScores: {},
    bestStars: {},
  );
  int _activeLevelNumber = 1;
  int _selectedMapLevel = 1;
  XrayInspectorGame? _currentGame;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AdBreakState _adBreakState = const AdBreakState();
  final AdBreakRules _adBreakRules = const AdBreakRules();

  @override
  void initState() {
    super.initState();
    _loadStorage();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    AdsService.loadInterstitial(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
        });
      },
      onAdFailedToLoad: (error) {
        if (!mounted) {
          return;
        }
        setState(() => _interstitialAd = null);
      },
    );
  }

  void _loadRewardedAd() {
    AdsService.loadRewarded(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
        });
      },
      onAdFailedToLoad: (error) {
        if (!mounted) {
          return;
        }
        setState(() => _rewardedAd = null);
      },
    );
  }

  void _showInterstitialAd() {
    final ad = _interstitialAd;
    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (dismissedAd) {
          dismissedAd.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (failedAd, error) {
          failedAd.dispose();
          _loadInterstitialAd();
        },
      );
      ad.show();
      setState(() {
        _adBreakState = _adBreakRules.onInterstitialShown(_adBreakState);
        _interstitialAd = null;
      });
    }
  }

  Future<void> _loadStorage() async {
    final storage = await StorageService.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _storage = storage;
      _highScore = storage.getHighScore();
      _levelProgress = storage.getLevelProgressSnapshot();
      _unlockedItems = storage.getUnlockedXrayItems();
      _soundEnabled = storage.getSoundEnabled();
    });
  }

  void _startLevel(int levelNumber) {
    final clampedLevel = levelNumber.clamp(
      1,
      _levelProgress.highestUnlockedLevel,
    );
    setState(() {
      _adBreakState = _adBreakRules.onLevelAttemptStarted(_adBreakState);
      _activeLevelNumber = clampedLevel;
      _selectedMapLevel = clampedLevel;
      _screen = AppScreen.playing;
      _lastScore = 0;
      _lastBagsCleared = 0;
      _lastBagsToClear = LevelProgressionRules.configForLevel(
        clampedLevel,
      ).bagsToClear;
      _lastStarsEarned = 0;
      _lastBestStars = 0;
      _canPlayNextLevel = false;
      _didUnlockNextLevel = false;
      _lastUnlockedDanger = null;
    });
  }

  void _startHighestUnlockedLevel() {
    _showLevelMap();
  }

  void _pauseGame() {
    _currentGame?.pauseEngine();
    setState(() {
      _screen = AppScreen.paused;
    });
  }

  void _resumeGame() {
    _currentGame?.resumeEngine();
    setState(() {
      _screen = AppScreen.playing;
    });
  }

  Future<void> _toggleSound() async {
    final newValue = !_soundEnabled;
    setState(() {
      _soundEnabled = newValue;
    });
    await _storage?.saveSoundEnabled(enabled: newValue);
  }

  Future<void> _finishLevelComplete({
    required XrayInspectorSnapshot snapshot,
    required int bagsCleared,
  }) async {
    final storage = _storage;
    final config = LevelProgressionRules.configForLevel(_activeLevelNumber);
    final outcome = LevelProgressionRules.outcomeFor(
      config: config,
      bagsCleared: bagsCleared,
      score: snapshot.score,
      lives: snapshot.lives,
    );
    final update = await storage?.applyLevelOutcome(outcome);
    final newHighScore = snapshot.score > _highScore;

    if (newHighScore) {
      setState(() {
        _highScore = snapshot.score;
      });
      await storage?.saveHighScore(snapshot.score);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _adBreakState = _adBreakRules.onRoundCompleted(_adBreakState);
      if (update != null) {
        _levelProgress = update.updated;
      }
      _lastScore = snapshot.score;
      _lastBagsCleared = bagsCleared;
      _lastBagsToClear = config.bagsToClear;
      _lastStarsEarned = outcome.starsEarned;
      _lastBestStars = update?.updated.bestStarsFor(_activeLevelNumber) ?? 0;
      _canPlayNextLevel = update?.canPlayNext ?? false;
      _didUnlockNextLevel = update?.didUnlockNextLevel ?? false;
      _lastUnlockedDanger = config.newlyUnlockedDanger;
      _screen = AppScreen.levelClear;
    });

    if (_adBreakRules.shouldShowInterstitial(
      completedRounds: _adBreakState.completedRounds,
      roundsSinceInterstitial: _adBreakState.roundsSinceInterstitial,
    )) {
      _showInterstitialAd();
    }
  }

  Future<void> _finishLevelFailed({
    required XrayInspectorSnapshot snapshot,
    required int bagsCleared,
  }) async {
    final config = LevelProgressionRules.configForLevel(_activeLevelNumber);
    if (!mounted) {
      return;
    }

    setState(() {
      _adBreakState = _adBreakRules.onRoundCompleted(_adBreakState);
      _lastScore = snapshot.score;
      _lastBagsCleared = bagsCleared;
      _lastBagsToClear = config.bagsToClear;
      _screen = AppScreen.levelFailed;
    });

    if (_adBreakRules.shouldShowInterstitial(
      completedRounds: _adBreakState.completedRounds,
      roundsSinceInterstitial: _adBreakState.roundsSinceInterstitial,
    )) {
      _showInterstitialAd();
    }
  }

  void _handleRewardedContinue() {
    final ad = _rewardedAd;
    if (ad == null) return;

    setState(() => _rewardedAd = null);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        _loadRewardedAd();
      },
    );
    ad.show(
      onUserEarnedReward: (_, reward) {
        if (!mounted) return;
        setState(() {
          _adBreakState = _adBreakRules.onRewardedContinueGranted(
            _adBreakState,
          );
        });
        _currentGame?.grantContinue();
        setState(() {
          _screen = AppScreen.playing;
        });
      },
    );
  }

  void _showMenu() {
    setState(() {
      _screen = AppScreen.menu;
    });
  }

  void _showLevelMap() {
    setState(() {
      _selectedMapLevel = _levelProgress.highestUnlockedLevel;
      _screen = AppScreen.levelMap;
    });
  }

  void _selectMapLevel(int levelNumber) {
    if (levelNumber > _levelProgress.highestUnlockedLevel) {
      return;
    }
    setState(() {
      _selectedMapLevel = levelNumber;
    });
  }

  void _showItemDatabase({EncyclopediaGroup group = EncyclopediaGroup.danger}) {
    setState(() {
      _selectedGroup = group;
      _screen = AppScreen.itemDatabase;
    });
  }

  Future<void> _recordDiscovery(XrayObjectType type) async {
    if (_unlockedItems.contains(type)) {
      return;
    }

    setState(() {
      _unlockedItems = {..._unlockedItems, type};
    });
    await _storage?.unlockXrayItem(type);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      AppScreen.menu => MainMenuScreen(
        highestUnlockedLevel: _levelProgress.highestUnlockedLevel,
        highScore: _highScore,
        onPlay: _startHighestUnlockedLevel,
        onOpenLevelMap: _showLevelMap,
        onOpenDatabase: () => _showItemDatabase(),
      ),
      AppScreen.levelMap => LevelMapScreen(
        progress: _levelProgress,
        selectedLevel: _selectedMapLevel,
        coins: _highScore,
        gems: _unlockedItems.length,
        onSelectLevel: _selectMapLevel,
        onPlay: () => _startLevel(_selectedMapLevel),
        onOpenDatabase: () => _showItemDatabase(),
        onBack: _showMenu,
      ),
      AppScreen.playing || AppScreen.paused => Stack(
        children: [
          GameplayScreen(
            levelNumber: _activeLevelNumber,
            onLevelComplete: _finishLevelComplete,
            onLevelFailed: _finishLevelFailed,
            onItemDiscovered: (type) {
              _recordDiscovery(type);
            },
            onPause: _pauseGame,
            onGameCreated: (game) {
              _currentGame = game;
            },
          ),
          if (_screen == AppScreen.paused)
            PauseScreen(
              onResume: _resumeGame,
              onMenu: _showMenu,
              soundEnabled: _soundEnabled,
              onToggleSound: _toggleSound,
            ),
        ],
      ),
      AppScreen.levelClear => LevelClearScreen(
        levelNumber: _activeLevelNumber,
        score: _lastScore,
        bagsCleared: _lastBagsCleared,
        bagsToClear: _lastBagsToClear,
        starsEarned: _lastStarsEarned,
        bestStars: _lastBestStars,
        canPlayNext: _canPlayNextLevel,
        didUnlockNextLevel: _didUnlockNextLevel,
        unlockedDanger: _lastUnlockedDanger,
        onNext: () => _startLevel(_activeLevelNumber + 1),
        onRetry: () => _startLevel(_activeLevelNumber),
        onMenu: _showLevelMap,
      ),
      AppScreen.levelFailed => LevelFailedScreen(
        levelNumber: _activeLevelNumber,
        score: _lastScore,
        bagsCleared: _lastBagsCleared,
        bagsToClear: _lastBagsToClear,
        onRetry: () => _startLevel(_activeLevelNumber),
        onMenu: _showLevelMap,
        canContinueWithAd: _adBreakRules.canOfferRewardedContinue(
          rewardedAdAvailable: _rewardedAd != null,
          rewardedContinueUsed: _adBreakState.rewardedContinueUsed,
        ),
        onContinueWithAd: _handleRewardedContinue,
      ),
      AppScreen.itemDatabase => ItemDatabaseScreen(
        initialGroup: _selectedGroup,
        unlockedItems: _unlockedItems,
        onBack: _showMenu,
      ),
    };
  }
}

class MainMenuScreen extends StatelessWidget {
  static const _menuBackground = 'assets/images/backgrounds/bg_main_menu.png';

  const MainMenuScreen({
    required this.highestUnlockedLevel,
    required this.highScore,
    required this.onPlay,
    required this.onOpenLevelMap,
    required this.onOpenDatabase,
    super.key,
  });

  final int highestUnlockedLevel;
  final int highScore;
  final VoidCallback onPlay;
  final VoidCallback onOpenLevelMap;
  final VoidCallback onOpenDatabase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AirportBackdrop(
        imageAsset: _menuBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _IconPanelButton(
                        icon: Icons.volume_up_rounded,
                        onPressed: () {},
                        tooltip: 'Sound',
                      ),
                      const SizedBox(width: 10),
                      _IconPanelButton(
                        icon: Icons.settings_rounded,
                        onPressed: () {},
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'X-Ray Scan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: _XrayStyle.cyan,
                    letterSpacing: 0,
                    shadows: const [
                      Shadow(color: _XrayStyle.cyan, blurRadius: 18),
                    ],
                  ),
                ),
                Text(
                  'World Customs Adventure',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 18),
                _GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _InfoLine(label: 'Best Clearance', value: '$highScore'),
                      _InfoLine(
                        label: 'Current World',
                        value: 'International Terminal',
                      ),
                      _InfoLine(
                        label: 'Current Level',
                        value: '$highestUnlockedLevel',
                      ),
                    ],
                  ),
                ),
                const Expanded(child: _ScannerHero()),
                _XrayActionButton.primary(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: 'PLAY',
                ),
                const SizedBox(height: 12),
                _XrayActionButton.secondary(
                  onPressed: onOpenLevelMap,
                  icon: const Icon(Icons.map_rounded),
                  label: 'LEVEL MAP',
                ),
                const SizedBox(height: 10),
                _XrayActionButton.secondary(
                  onPressed: onOpenDatabase,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: 'ITEM DATABASE',
                ),
                const SizedBox(height: 18),
                const Center(child: XrayBannerAd()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LevelMapScreen extends StatelessWidget {
  static const _levelMapBackground = 'assets/images/backgrounds/bg_level_map.png';

  static const List<Alignment> levelPositions = [
    Alignment(-0.68, -0.80),
    Alignment(-0.08, -0.78),
    Alignment(0.52, -0.70),
    Alignment(0.66, -0.38),
    Alignment(0.35, -0.15),
    Alignment(-0.12, 0.04),
    Alignment(-0.66, 0.18),
    Alignment(-0.46, 0.48),
    Alignment(0.02, 0.62),
    Alignment(0.60, 0.74),
  ];

  const LevelMapScreen({
    required this.progress,
    required this.selectedLevel,
    required this.coins,
    required this.gems,
    required this.onSelectLevel,
    required this.onPlay,
    required this.onOpenDatabase,
    required this.onBack,
    super.key,
  });

  final LevelProgressSnapshot progress;
  final int selectedLevel;
  final int coins;
  final int gems;
  final ValueChanged<int> onSelectLevel;
  final VoidCallback onPlay;
  final VoidCallback onOpenDatabase;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AirportBackdrop(
        imageAsset: _levelMapBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'World:',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: _XrayStyle.muted),
                            ),
                            Text(
                              'International Terminal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: _XrayStyle.text,
                                    fontWeight: FontWeight.w900,
                                    height: 1.08,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const _VerticalDivider(),
                      _TopCurrency(
                        icon: Icons.monetization_on,
                        value: coins,
                        label: 'Coins',
                      ),
                      const _VerticalDivider(),
                      _TopCurrency(
                        icon: Icons.diamond_rounded,
                        value: gems,
                        label: 'Gems',
                      ),
                      const _VerticalDivider(),
                      _IconPanelButton(
                        icon: Icons.settings_rounded,
                        onPressed: () {},
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: _LevelRoutePainter(
                                alignments: levelPositions,
                              ),
                            ),
                            for (
                              var level = 1;
                              level <= LevelProgressionRules.maxLevelNumber;
                              level++
                            )
                              _MapNode(
                                level: level,
                                position: _mapNodePosition(level),
                                isSelected: selectedLevel == level,
                                isCompleted: progress.bestStarsFor(level) > 0,
                                isUnlocked:
                                    level <= progress.highestUnlockedLevel,
                                stars: progress.bestStarsFor(level),
                                onTap: () => onSelectLevel(level),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level $selectedLevel',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: _XrayStyle.muted),
                            ),
                            Text(
                              _levelTitle(selectedLevel),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                    height: 1.05,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Best stars',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: _XrayStyle.muted),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (var i = 1; i <= 3; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      i <= progress.bestStarsFor(selectedLevel)
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: i <= progress.bestStarsFor(selectedLevel)
                                          ? _XrayStyle.gold
                                          : Colors.white.withValues(alpha: 0.18),
                                      size: 28,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 172,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _XrayActionButton.primary(
                              onPressed: onPlay,
                              label: 'PLAY',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _XrayActionButton.secondary(
                                    onPressed: onOpenDatabase,
                                    label: 'Database',
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: _XrayActionButton.secondary(
                                    onPressed: onBack,
                                    label: 'Back',
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _mapNodePosition(int level) {
    if (level < 1 || level > levelPositions.length) {
      return Alignment.center;
    }
    return levelPositions[level - 1];
  }

  String _levelTitle(int level) {
    return switch (level) {
      1 => 'First Scan',
      2 => 'Sharp Shapes',
      3 => 'Mixed Bags',
      4 => 'Crowded Luggage',
      5 => 'Razor Alert',
      6 => 'False Tap Trap',
      7 => 'Double Threat',
      8 => 'Battery Warning',
      9 => 'Speed Check',
      _ => 'Final Security Gate',
    };
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            '$label:',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: _XrayStyle.muted),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _XrayStyle.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerHero extends StatelessWidget {
  const _ScannerHero();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerHeroPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _TopCurrency extends StatelessWidget {
  const _TopCurrency({
    required this.icon,
    required this.value,
    this.label,
  });

  final IconData icon;
  final int value;
  final String? label;

  String _formatNumber(int val) {
    final str = val.toString();
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(regExp, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = icon == Icons.monetization_on
        ? _formatNumber(value)
        : '$value';
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: _XrayStyle.muted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: icon == Icons.diamond_rounded
                  ? _XrayStyle.cyan
                  : _XrayStyle.gold,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _XrayStyle.text,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecurityGateNode extends StatelessWidget {
  const _SecurityGateNode({
    required this.isUnlocked,
    required this.isSelected,
    required this.isCompleted,
  });

  final bool isUnlocked;
  final bool isSelected;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isUnlocked ? _XrayStyle.cyan : Colors.blueGrey;
    return Center(
      child: SizedBox(
        width: 58,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glowing neon elliptical base platform at the bottom
            Positioned(
              bottom: 1,
              left: 2,
              right: 2,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _XrayStyle.cyan.withValues(alpha: 0.24)
                      : const Color(0xFF26333D).withValues(alpha: 0.3),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : (isCompleted ? _XrayStyle.cyan : color.withValues(alpha: 0.6)),
                    width: isSelected ? 2.2 : 1.6,
                  ),
                  borderRadius: const BorderRadius.all(Radius.elliptical(27, 7)),
                  boxShadow: [
                    if (isSelected || isUnlocked)
                      BoxShadow(
                        color: color.withValues(alpha: isSelected ? 0.8 : 0.3),
                        blurRadius: isSelected ? 12 : 6,
                      ),
                  ],
                ),
              ),
            ),
            // Left Pillar of the metal detector
            Positioned(
              left: 12,
              top: 4,
              bottom: 8,
              width: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Right Pillar of the metal detector
            Positioned(
              right: 12,
              top: 4,
              bottom: 8,
              width: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            // Top Arch Bar of the metal detector
            Positioned(
              left: 12,
              right: 12,
              top: 0,
              height: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                ),
                child: isUnlocked
                    ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isCompleted ? _XrayStyle.success : _XrayStyle.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            // Middle Content: Lock badge or Number or Check hanging inside the arch
            Align(
              alignment: const Alignment(0, -0.1),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: _XrayStyle.cyan,
                      size: 20,
                    )
                  : (!isUnlocked
                      ? Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white70,
                            size: 11,
                          ),
                        )
                      : Text(
                          '10',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _XrayStyle.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.level,
    required this.position,
    required this.isSelected,
    required this.isCompleted,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
  });

  final int level;
  final Alignment position;
  final bool isSelected;
  final bool isCompleted;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFinal = level == LevelProgressionRules.maxLevelNumber;
    final color = isUnlocked ? _XrayStyle.cyan : Colors.blueGrey;
    return Align(
      alignment: position,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: isFinal ? 86 : 72,
          height: isFinal ? 100 : 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                _MiniStars(stars: stars)
              else
                const SizedBox(height: 18),
              if (isFinal)
                _SecurityGateNode(
                  isUnlocked: isUnlocked,
                  isSelected: isSelected,
                  isCompleted: isCompleted,
                )
              else
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? const Color(0xFF0D4762).withValues(alpha: 0.72)
                        : const Color(0xFF26333D).withValues(alpha: 0.72),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : (isCompleted ? _XrayStyle.cyan : color.withValues(alpha: 0.7)),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      if (isSelected || isUnlocked)
                        BoxShadow(
                          color: color.withValues(alpha: isSelected ? 0.8 : 0.38),
                          blurRadius: isSelected ? 24 : 14,
                        ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isCompleted)
                        const Icon(
                          Icons.check_rounded,
                          color: _XrayStyle.cyan,
                          size: 34,
                        )
                      else
                        Text(
                          '$level',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: isUnlocked
                                    ? _XrayStyle.text
                                    : Colors.white54,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      if (!isUnlocked)
                        Positioned(
                          right: -3,
                          bottom: -3,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueGrey.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white70,
                              size: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStars extends StatelessWidget {
  const _MiniStars({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 3; i++)
          Icon(
            Icons.star_rounded,
            size: 16,
            color: i <= stars ? _XrayStyle.gold : Colors.white24,
          ),
      ],
    );
  }
}

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({
    required this.levelNumber,
    required this.onLevelComplete,
    required this.onLevelFailed,
    required this.onItemDiscovered,
    required this.onPause,
    required this.onGameCreated,
    super.key,
  });

  final int levelNumber;
  final Future<void> Function({
    required XrayInspectorSnapshot snapshot,
    required int bagsCleared,
  })
  onLevelComplete;
  final Future<void> Function({
    required XrayInspectorSnapshot snapshot,
    required int bagsCleared,
  })
  onLevelFailed;
  final ValueChanged<XrayObjectType> onItemDiscovered;
  final VoidCallback onPause;
  final ValueChanged<XrayInspectorGame> onGameCreated;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final XrayInspectorGame _game;
  XrayInspectorSnapshot _snapshot = const XrayInspectorSnapshot(
    score: 0,
    combo: 0,
    comboMultiplier: 1,
    lives: 3,
    isGameOver: false,
  );
  int _bagsToClear = 0;

  @override
  void initState() {
    super.initState();
    final levelConfig = LevelProgressionRules.configForLevel(
      widget.levelNumber,
    );
    _bagsToClear = levelConfig.bagsToClear;
    _game = XrayInspectorGame(
      levelConfig: levelConfig,
      onSnapshotChanged: (snapshot) {
        if (mounted) {
          setState(() => _snapshot = snapshot);
        }
      },
      onLevelComplete: ({required snapshot, required bagsCleared}) {
        return widget.onLevelComplete(
          snapshot: snapshot,
          bagsCleared: bagsCleared,
        );
      },
      onLevelFailed: ({required snapshot, required bagsCleared}) {
        return widget.onLevelFailed(
          snapshot: snapshot,
          bagsCleared: bagsCleared,
        );
      },
      onItemDiscovered: widget.onItemDiscovered,
    );
    widget.onGameCreated(_game);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _game.tapAt(details.localPosition),
              child: GameWidget(game: _game),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _Hud(
                snapshot: _snapshot,
                levelNumber: widget.levelNumber,
                bagsCleared: _game.bagsCleared,
                bagsToClear: _bagsToClear,
                onPause: widget.onPause,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MarkedCounter(
                      marked: _game.currentMarkedDangerCount,
                      total: _game.currentDangerCount,
                    ),
                    const SizedBox(height: 10),
                    _XrayActionButton.primary(
                      onPressed: _game.clearBag,
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: 'CLEAR',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PauseScreen extends StatelessWidget {
  const PauseScreen({
    required this.onResume,
    required this.onMenu,
    required this.soundEnabled,
    required this.onToggleSound,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onMenu;
  final bool soundEnabled;
  final VoidCallback onToggleSound;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.72),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PAUSED',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE5FEFF),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('RESUME'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onToggleSound,
                  icon: Icon(
                    soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                  ),
                  label: Text(soundEnabled ? 'SOUND ON' : 'SOUND OFF'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onMenu,
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('MAIN MENU'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LevelClearScreen extends StatelessWidget {
  static const _resultBackground =
      'assets/images/backgrounds/bg_result_checkpoint.png';

  const LevelClearScreen({
    required this.levelNumber,
    required this.score,
    required this.bagsCleared,
    required this.bagsToClear,
    required this.starsEarned,
    required this.bestStars,
    required this.canPlayNext,
    required this.didUnlockNextLevel,
    required this.unlockedDanger,
    required this.onNext,
    required this.onRetry,
    required this.onMenu,
    super.key,
  });

  final int levelNumber;
  final int score;
  final int bagsCleared;
  final int bagsToClear;
  final int starsEarned;
  final int bestStars;
  final bool canPlayNext;
  final bool didUnlockNextLevel;
  final XrayObjectType? unlockedDanger;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AirportBackdrop(
        imageAsset: _resultBackground,
        child: _ResultScreenFrame(
          card: _GlassPanel(
            child: Column(
              children: [
                Text(
                  'LEVEL CLEAR',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _XrayStyle.gold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  'International Terminal - Level $levelNumber',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _StarRow(stars: starsEarned),
                const SizedBox(height: 14),
                Text(
                  'Score: $score\nBest: ${_bestStarsLabel(bestStars)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 12),
                _ResultStrip(text: 'Bags Cleared: $bagsCleared/$bagsToClear'),
                if (unlockedDanger != null || didUnlockNextLevel) ...[
                  const SizedBox(height: 14),
                  _RewardPanel(
                    title: unlockedDanger != null
                        ? 'New threat profile:'
                        : 'Progress unlocked:',
                    value:
                        unlockedDanger?.displayName ??
                        'Level ${levelNumber + 1}',
                    icon: unlockedDanger != null
                        ? _itemIconFor(unlockedDanger!)
                        : Icons.lock_open_rounded,
                  ),
                ],
                const SizedBox(height: 22),
                if (canPlayNext)
                  _XrayActionButton.primary(
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: 'NEXT',
                  ),
                if (canPlayNext) const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _XrayActionButton.secondary(
                        onPressed: onRetry,
                        label: 'RETRY',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _XrayActionButton.secondary(
                        onPressed: onMenu,
                        label: 'MAP',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LevelFailedScreen extends StatelessWidget {
  static const _resultBackground =
      'assets/images/backgrounds/bg_result_checkpoint.png';

  const LevelFailedScreen({
    required this.levelNumber,
    required this.score,
    required this.bagsCleared,
    required this.bagsToClear,
    required this.onRetry,
    required this.onMenu,
    required this.canContinueWithAd,
    required this.onContinueWithAd,
    super.key,
  });

  final int levelNumber;
  final int score;
  final int bagsCleared;
  final int bagsToClear;
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  final bool canContinueWithAd;
  final VoidCallback onContinueWithAd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AirportBackdrop(
        imageAsset: _resultBackground,
        child: _ResultScreenFrame(
          card: _GlassPanel(
            borderColor: _XrayStyle.danger.withValues(alpha: 0.55),
            child: Column(
              children: [
                Text(
                  'LEVEL FAILED',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: _XrayStyle.gold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  'International Terminal - Level $levelNumber',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _ResultStrip(text: 'Bags Cleared: $bagsCleared/$bagsToClear'),
                const SizedBox(height: 12),
                _WarningPanel(),
                const SizedBox(height: 18),
                if (canContinueWithAd) ...[
                  _XrayActionButton.primary(
                    onPressed: onContinueWithAd,
                    icon: const Icon(Icons.ondemand_video_rounded),
                    label: 'CONTINUE +1 LIFE',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Watch ad to keep inspecting',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _XrayStyle.text),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _XrayActionButton.secondary(
                        onPressed: onRetry,
                        label: 'RETRY',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _XrayActionButton.secondary(
                        onPressed: onMenu,
                        label: 'MAP',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultScreenFrame extends StatelessWidget {
  const _ResultScreenFrame({required this.card});

  final Widget card;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: 520,
                      ),
                      child: Center(child: card),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: XrayBannerAd()),
          ],
        ),
      ),
    );
  }
}

class ItemDatabaseScreen extends StatefulWidget {
  const ItemDatabaseScreen({
    required this.initialGroup,
    required this.unlockedItems,
    required this.onBack,
    super.key,
  });

  final EncyclopediaGroup initialGroup;
  final Set<XrayObjectType> unlockedItems;
  final VoidCallback onBack;

  @override
  State<ItemDatabaseScreen> createState() => _ItemDatabaseScreenState();
}

class _ItemDatabaseScreenState extends State<ItemDatabaseScreen> {
  late EncyclopediaGroup _group;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
  }

  @override
  Widget build(BuildContext context) {
    final items = _group == EncyclopediaGroup.danger
        ? dangerXrayObjects
        : safeXrayObjects;
    final unlockedCount = items.where(widget.unlockedItems.contains).length;

    return Scaffold(
      body: _ScannerGridBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _BackButton(onPressed: widget.onBack),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Item Database',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: _XrayStyle.text,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          Text(
                            'Progress: $unlockedCount/${items.length} discovered',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: _XrayStyle.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 96),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _GlassPanel(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _DatabaseTabs(
                          selected: _group,
                          onChanged: (group) => setState(() => _group = group),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 28),
                            itemCount: items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.7,
                                ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _ItemDatabaseTile(
                                item: item,
                                isUnlocked: widget.unlockedItems.contains(item),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _group == EncyclopediaGroup.danger
                              ? 'Find threats during inspection to reveal profiles.'
                              : 'Clear safe bags to reveal passenger items.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: _XrayStyle.muted, height: 1.15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 3; i++)
          Icon(
            i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i <= stars
                ? const Color(0xFFFFD166)
                : Colors.white.withValues(alpha: 0.28),
            size: 42,
          ),
      ],
    );
  }
}

class _MarkedCounter extends StatelessWidget {
  const _MarkedCounter({required this.marked, required this.total});

  final int marked;
  final int total;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text(
          'MARKED: $marked/$total',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _XrayStyle.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ResultStrip extends StatelessWidget {
  const _ResultStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: _XrayStyle.text,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RewardPanel extends StatelessWidget {
  const _RewardPanel({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _XrayStyle.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.68)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _XrayStyle.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _XrayStyle.cyanSoft,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _XrayStyle.cyanSoft, size: 36),
          ),
        ],
      ),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _XrayStyle.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _XrayStyle.danger.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Threat left in bag',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFFFA7B5),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _XrayItemIcon(
            item: XrayObjectType.knife,
            color: _XrayStyle.danger,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _DatabaseTabs extends StatelessWidget {
  const _DatabaseTabs({required this.selected, required this.onChanged});

  final EncyclopediaGroup selected;
  final ValueChanged<EncyclopediaGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DatabaseTabButton(
              label: 'DANGER ITEMS',
              selected: selected == EncyclopediaGroup.danger,
              onTap: () => onChanged(EncyclopediaGroup.danger),
            ),
          ),
          Expanded(
            child: _DatabaseTabButton(
              label: 'SAFE ITEMS',
              selected: selected == EncyclopediaGroup.safe,
              onTap: () => onChanged(EncyclopediaGroup.safe),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatabaseTabButton extends StatelessWidget {
  const _DatabaseTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? _XrayStyle.cyan.withValues(alpha: 0.16)
              : Colors.transparent,
          border: selected
              ? Border.all(color: _XrayStyle.text.withValues(alpha: 0.75))
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: selected ? _XrayStyle.text : Colors.white54,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 48,
        width: 86,
        decoration: BoxDecoration(
          color: _XrayStyle.panelSoft,
          border: Border.all(color: _XrayStyle.cyan.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            SizedBox(width: 6),
            Text('Back'),
          ],
        ),
      ),
    );
  }
}

IconData _itemIconFor(XrayObjectType item) {
  return switch (item) {
    XrayObjectType.knife => Icons.hardware_rounded,
    XrayObjectType.scissors => Icons.content_cut_rounded,
    XrayObjectType.lighter => Icons.local_fire_department_rounded,
    XrayObjectType.razor => Icons.rectangle_rounded,
    XrayObjectType.batteryPack => Icons.battery_charging_full_rounded,
    XrayObjectType.phone => Icons.phone_iphone_rounded,
    XrayObjectType.laptop => Icons.laptop_mac_rounded,
    XrayObjectType.bottle => Icons.water_drop_rounded,
    XrayObjectType.sandwich => Icons.lunch_dining_rounded,
    XrayObjectType.keys => Icons.key_rounded,
    XrayObjectType.headphones => Icons.headphones_rounded,
  };
}

String _itemAssetPathFor(XrayObjectType item) {
  return switch (item) {
    XrayObjectType.knife => 'assets/images/items/danger/item_danger_knife.png',
    XrayObjectType.scissors =>
      'assets/images/items/danger/item_danger_scissors.png',
    XrayObjectType.lighter =>
      'assets/images/items/danger/item_danger_lighter.png',
    XrayObjectType.razor => 'assets/images/items/danger/item_danger_razor.png',
    XrayObjectType.batteryPack =>
      'assets/images/items/danger/item_danger_battery_pack.png',
    XrayObjectType.phone => 'assets/images/items/safe/item_safe_phone.png',
    XrayObjectType.laptop => 'assets/images/items/safe/item_safe_laptop.png',
    XrayObjectType.bottle => 'assets/images/items/safe/item_safe_bottle.png',
    XrayObjectType.sandwich =>
      'assets/images/items/safe/item_safe_sandwich.png',
    XrayObjectType.keys => 'assets/images/items/safe/item_safe_keys.png',
    XrayObjectType.headphones =>
      'assets/images/items/safe/item_safe_headphones.png',
  };
}

class _XrayItemIcon extends StatelessWidget {
  const _XrayItemIcon({
    required this.item,
    required this.color,
    required this.size,
    this.glow = true,
  });

  final XrayObjectType item;
  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final shouldUseSprite = color.r <= color.g && color.r <= color.b;
    final fallback = CustomPaint(
      size: Size.square(size),
      painter: _XrayItemIconPainter(item: item, color: color, glow: glow),
    );
    if (!shouldUseSprite) {
      return fallback;
    }

    return SizedBox.square(
      dimension: size,
      child: Opacity(
        opacity: glow ? 1 : 0.34,
        child: Image.asset(
          _itemAssetPathFor(item),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}

class _XrayItemIconPainter extends CustomPainter {
  const _XrayItemIconPainter({
    required this.item,
    required this.color,
    required this.glow,
  });

  final XrayObjectType item;
  final Color color;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.shortestSide * 0.07;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glow ? 0.55 : 0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.shortestSide * 0.09
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    void drawLine(Offset a, Offset b) {
      if (glow) canvas.drawLine(a, b, glowPaint);
      canvas.drawLine(a, b, stroke);
    }

    void drawRect(Rect rect, {bool rounded = true}) {
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(rounded ? size.width * 0.06 : 0),
      );
      canvas.drawRRect(rrect, fill);
      if (glow) canvas.drawRRect(rrect, glowPaint);
      canvas.drawRRect(rrect, stroke);
    }

    void drawOval(Rect rect) {
      canvas.drawOval(rect, fill);
      if (glow) canvas.drawOval(rect, glowPaint);
      canvas.drawOval(rect, stroke);
    }

    switch (item) {
      case XrayObjectType.knife:
        final blade = Path()
          ..moveTo(size.width * 0.2, size.height * 0.74)
          ..quadraticBezierTo(
            size.width * 0.55,
            size.height * 0.2,
            size.width * 0.84,
            size.height * 0.12,
          )
          ..quadraticBezierTo(
            size.width * 0.76,
            size.height * 0.42,
            size.width * 0.4,
            size.height * 0.68,
          )
          ..close();
        canvas.drawPath(blade, fill);
        if (glow) canvas.drawPath(blade, glowPaint);
        canvas.drawPath(blade, stroke);
        drawLine(
          Offset(size.width * 0.16, size.height * 0.8),
          Offset(size.width * 0.38, size.height * 0.67),
        );
        break;
      case XrayObjectType.scissors:
        drawOval(
          Rect.fromCircle(
            center: Offset(size.width * 0.32, size.height * 0.72),
            radius: size.width * 0.13,
          ),
        );
        drawOval(
          Rect.fromCircle(
            center: Offset(size.width * 0.68, size.height * 0.72),
            radius: size.width * 0.13,
          ),
        );
        drawLine(
          Offset(size.width * 0.42, size.height * 0.6),
          Offset(size.width * 0.8, size.height * 0.22),
        );
        drawLine(
          Offset(size.width * 0.58, size.height * 0.6),
          Offset(size.width * 0.2, size.height * 0.22),
        );
        break;
      case XrayObjectType.lighter:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.34,
            size.height * 0.32,
            size.width * 0.3,
            size.height * 0.52,
          ),
        );
        drawRect(
          Rect.fromLTWH(
            size.width * 0.42,
            size.height * 0.18,
            size.width * 0.3,
            size.height * 0.18,
          ),
        );
        final flame = Path()
          ..moveTo(size.width * 0.5, size.height * 0.24)
          ..quadraticBezierTo(
            size.width * 0.37,
            size.height * 0.06,
            size.width * 0.56,
            size.height * 0.02,
          )
          ..quadraticBezierTo(
            size.width * 0.72,
            size.height * 0.16,
            size.width * 0.5,
            size.height * 0.24,
          );
        canvas.drawPath(flame, fill);
        canvas.drawPath(flame, stroke);
        break;
      case XrayObjectType.razor:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.24,
            size.height * 0.18,
            size.width * 0.52,
            size.height * 0.16,
          ),
        );
        drawLine(
          Offset(size.width * 0.5, size.height * 0.34),
          Offset(size.width * 0.36, size.height * 0.84),
        );
        drawLine(
          Offset(size.width * 0.5, size.height * 0.34),
          Offset(size.width * 0.64, size.height * 0.84),
        );
        break;
      case XrayObjectType.batteryPack:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.22,
            size.height * 0.25,
            size.width * 0.56,
            size.height * 0.5,
          ),
        );
        drawRect(
          Rect.fromLTWH(
            size.width * 0.42,
            size.height * 0.16,
            size.width * 0.16,
            size.height * 0.1,
          ),
        );
        drawLine(
          Offset(size.width * 0.38, size.height * 0.5),
          Offset(size.width * 0.62, size.height * 0.5),
        );
        break;
      case XrayObjectType.phone:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.32,
            size.height * 0.16,
            size.width * 0.36,
            size.height * 0.68,
          ),
        );
        drawLine(
          Offset(size.width * 0.43, size.height * 0.76),
          Offset(size.width * 0.57, size.height * 0.76),
        );
        break;
      case XrayObjectType.laptop:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.22,
            size.height * 0.22,
            size.width * 0.56,
            size.height * 0.42,
          ),
        );
        drawLine(
          Offset(size.width * 0.16, size.height * 0.78),
          Offset(size.width * 0.84, size.height * 0.78),
        );
        break;
      case XrayObjectType.bottle:
        drawRect(
          Rect.fromLTWH(
            size.width * 0.38,
            size.height * 0.28,
            size.width * 0.24,
            size.height * 0.56,
          ),
        );
        drawRect(
          Rect.fromLTWH(
            size.width * 0.42,
            size.height * 0.14,
            size.width * 0.16,
            size.height * 0.16,
          ),
        );
        break;
      case XrayObjectType.sandwich:
        final triangle = Path()
          ..moveTo(size.width * 0.18, size.height * 0.72)
          ..lineTo(size.width * 0.82, size.height * 0.72)
          ..lineTo(size.width * 0.5, size.height * 0.18)
          ..close();
        canvas.drawPath(triangle, fill);
        if (glow) canvas.drawPath(triangle, glowPaint);
        canvas.drawPath(triangle, stroke);
        drawLine(
          Offset(size.width * 0.3, size.height * 0.58),
          Offset(size.width * 0.7, size.height * 0.58),
        );
        break;
      case XrayObjectType.keys:
        drawOval(
          Rect.fromCircle(
            center: Offset(size.width * 0.32, size.height * 0.34),
            radius: size.width * 0.12,
          ),
        );
        drawLine(
          Offset(size.width * 0.42, size.height * 0.44),
          Offset(size.width * 0.78, size.height * 0.78),
        );
        drawLine(
          Offset(size.width * 0.66, size.height * 0.66),
          Offset(size.width * 0.78, size.height * 0.58),
        );
        break;
      case XrayObjectType.headphones:
        final arc = Path()
          ..moveTo(size.width * 0.22, size.height * 0.54)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * 0.12,
            size.width * 0.78,
            size.height * 0.54,
          );
        if (glow) canvas.drawPath(arc, glowPaint);
        canvas.drawPath(arc, stroke);
        drawRect(
          Rect.fromLTWH(
            size.width * 0.16,
            size.height * 0.5,
            size.width * 0.18,
            size.height * 0.28,
          ),
        );
        drawRect(
          Rect.fromLTWH(
            size.width * 0.66,
            size.height * 0.5,
            size.width * 0.18,
            size.height * 0.28,
          ),
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _XrayItemIconPainter oldDelegate) {
    return oldDelegate.item != item ||
        oldDelegate.color != color ||
        oldDelegate.glow != glow;
  }
}

class EncyclopediaIndexScreen extends StatelessWidget {
  const EncyclopediaIndexScreen({
    required this.unlockedItems,
    required this.onSelectGroup,
    required this.onBack,
    super.key,
  });

  final Set<XrayObjectType> unlockedItems;
  final ValueChanged<EncyclopediaGroup> onSelectGroup;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScreenHeader(title: 'Item Database', onBack: onBack),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _DatabaseGroupCard(
                        title: 'DANGER ITEMS',
                        subtitle: 'Contraband profiles',
                        group: EncyclopediaGroup.danger,
                        unlockedCount: _countUnlocked(dangerXrayObjects),
                        totalCount: dangerXrayObjects.length,
                        onPressed: () =>
                            onSelectGroup(EncyclopediaGroup.danger),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _DatabaseGroupCard(
                        title: 'SAFE ITEMS',
                        subtitle: 'Cleared passenger objects',
                        group: EncyclopediaGroup.safe,
                        unlockedCount: _countUnlocked(safeXrayObjects),
                        totalCount: safeXrayObjects.length,
                        onPressed: () => onSelectGroup(EncyclopediaGroup.safe),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _countUnlocked(List<XrayObjectType> items) {
    return items.where(unlockedItems.contains).length;
  }
}

class EncyclopediaGroupScreen extends StatelessWidget {
  const EncyclopediaGroupScreen({
    required this.group,
    required this.unlockedItems,
    required this.onBack,
    super.key,
  });

  final EncyclopediaGroup group;
  final Set<XrayObjectType> unlockedItems;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final items = group == EncyclopediaGroup.danger
        ? dangerXrayObjects
        : safeXrayObjects;
    final unlockedCount = items.where(unlockedItems.contains).length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScreenHeader(title: _groupTitle(group), onBack: onBack),
              const SizedBox(height: 10),
              Text(
                '$unlockedCount/${items.length} discovered',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFB7EFF4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ItemDatabaseTile(
                      item: item,
                      isUnlocked: unlockedItems.contains(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _groupTitle(EncyclopediaGroup group) {
    return switch (group) {
      EncyclopediaGroup.danger => 'Danger Database',
      EncyclopediaGroup.safe => 'Safe Database',
    };
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE5FEFF),
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _DatabaseGroupCard extends StatelessWidget {
  const _DatabaseGroupCard({
    required this.title,
    required this.subtitle,
    required this.group,
    required this.unlockedCount,
    required this.totalCount,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final EncyclopediaGroup group;
  final int unlockedCount;
  final int totalCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = group == EncyclopediaGroup.danger
        ? const Color(0xFFFF3B5C)
        : const Color(0xFF37FFB5);

    return SizedBox.expand(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF061721),
            border: Border.all(
              color: accent.withValues(alpha: 0.58),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: 0.2), const Color(0xFF030912)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_groupIcon(group), size: 42, color: accent),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFB7EFF4),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$unlockedCount/$totalCount discovered',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _groupIcon(EncyclopediaGroup group) {
    return switch (group) {
      EncyclopediaGroup.danger => Icons.warning_rounded,
      EncyclopediaGroup.safe => Icons.verified_rounded,
    };
  }
}

class _ItemDatabaseTile extends StatelessWidget {
  const _ItemDatabaseTile({required this.item, required this.isUnlocked});

  final XrayObjectType item;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    const accent = _XrayStyle.cyanSoft;
    final iconColor = isUnlocked
        ? accent
        : _XrayStyle.cyan.withValues(alpha: 0.22);
    final borderColor = isUnlocked
        ? accent.withValues(alpha: 0.76)
        : _XrayStyle.cyan.withValues(alpha: 0.18);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xDD061721),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (isUnlocked)
            BoxShadow(color: accent.withValues(alpha: 0.18), blurRadius: 14),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUnlocked ? 'Unlocked' : 'Locked',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isUnlocked ? accent : Colors.white38,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: _XrayItemIcon(
                      item: item,
                      color: iconColor,
                      size: 74,
                      glow: isUnlocked,
                    ),
                  ),
                  if (!isUnlocked)
                    const Icon(
                      Icons.lock_rounded,
                      color: Colors.white70,
                      size: 34,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.displayName,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isUnlocked ? Colors.white : Colors.white24,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isUnlocked ? item.discoveryNote : '???',
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isUnlocked ? const Color(0xFFB7EFF4) : Colors.white30,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AirportScene extends StatelessWidget {
  const _AirportScene();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AirportScenePainter());
  }
}

class _AirportScenePainter extends CustomPainter {
  const _AirportScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = const Color(0xFF101927));

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D2A35), Color(0xFF82644D), Color(0xFF071826)],
        ).createShader(bounds),
    );

    final lightPaint = Paint()
      ..color = const Color(0xFFFFDFA8).withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    for (final x in [size.width * 0.18, size.width * 0.5, size.width * 0.82]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 58), width: 74, height: 28),
        lightPaint,
      );
    }

    final windowPaint = Paint()
      ..color = const Color(0xFF071826).withValues(alpha: 0.72);
    final glowPaint = Paint()
      ..color = _XrayStyle.cyan.withValues(alpha: 0.11)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final windowRect = Rect.fromLTWH(
      22,
      size.height * 0.18,
      size.width - 44,
      size.height * 0.32,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(12)),
      windowPaint,
    );
    for (var x = windowRect.left + 42; x < windowRect.right; x += 70) {
      canvas.drawLine(
        Offset(x, windowRect.top),
        Offset(x, windowRect.bottom),
        glowPaint,
      );
    }

    final floorTop = size.height * 0.56;
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFB08364).withValues(alpha: 0.36),
          const Color(0xFF071826).withValues(alpha: 0.82),
        ],
      ).createShader(Rect.fromLTWH(0, floorTop, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, floorTop, size.width, size.height - floorTop),
      floorPaint,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var y = floorTop; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final scannerRect = Rect.fromCenter(
      center: Offset(size.width * 0.36, size.height * 0.58),
      width: size.width * 0.42,
      height: size.height * 0.18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scannerRect, const Radius.circular(14)),
      Paint()..color = const Color(0xFF0E2230).withValues(alpha: 0.78),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scannerRect.deflate(8), const Radius.circular(8)),
      Paint()..color = _XrayStyle.cyan.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.52);
    final scanner = Rect.fromCenter(
      center: center.translate(-28, 0),
      width: size.width * 0.54,
      height: size.height * 0.36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanner, const Radius.circular(18)),
      Paint()..color = const Color(0xFF102333).withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanner.deflate(12), const Radius.circular(12)),
      Paint()
        ..color = _XrayStyle.cyan.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final belt = Rect.fromLTWH(
      scanner.left - 48,
      scanner.bottom - 4,
      scanner.width + 132,
      size.height * 0.18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(belt, const Radius.circular(10)),
      Paint()..color = const Color(0xFF09131C).withValues(alpha: 0.9),
    );
    final beltLine = Paint()
      ..color = _XrayStyle.cyan.withValues(alpha: 0.18)
      ..strokeWidth = 2;
    for (var y = belt.top + 10; y < belt.bottom; y += 14) {
      canvas.drawLine(Offset(belt.left, y), Offset(belt.right, y), beltLine);
    }

    final bag = Rect.fromCenter(
      center: scanner.center.translate(scanner.width * 0.33, 22),
      width: size.width * 0.34,
      height: size.height * 0.24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bag, const Radius.circular(18)),
      Paint()
        ..color = _XrayStyle.cyan.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bag, const Radius.circular(18)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _XrayStyle.cyanSoft.withValues(alpha: 0.78),
    );
    final iconPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = _XrayStyle.cyanSoft.withValues(alpha: 0.7);
    canvas.drawLine(
      bag.center.translate(-40, -8),
      bag.center.translate(-8, -8),
      iconPaint,
    );
    canvas.drawCircle(bag.center.translate(26, -8), 12, iconPaint);
    canvas.drawLine(
      bag.center.translate(-34, 24),
      bag.center.translate(36, 24),
      iconPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _XrayStyle.cyan.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 42.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelRoutePainter extends CustomPainter {
  _LevelRoutePainter({required this.alignments});

  final List<Alignment> alignments;

  @override
  void paint(Canvas canvas, Size size) {
    final points = alignments.map((alignment) => alignment.alongSize(size)).toList();
    if (points.isEmpty) return;

    final path = Path();
    if (points.length > 1) {
      // Use CatmullRomSpline for a beautifully smooth curve passing exactly through the level node centers!
      final controlPoints = [points.first, ...points, points.last];
      final spline = CatmullRomSpline(controlPoints);
      final start = spline.transform(0);
      path.moveTo(start.dx, start.dy);
      
      const samples = 80;
      for (var i = 1; i <= samples; i++) {
        final p = spline.transform(i / samples);
        path.lineTo(p.dx, p.dy);
      }
    } else {
      path.moveTo(points.first.dx, points.first.dy);
    }

    final glowOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _XrayStyle.cyan.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(path, glowOuter);

    final glowInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _XrayStyle.cyan.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowInner);

    final solidLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _XrayStyle.cyan.withValues(alpha: 0.85);
    canvas.drawPath(path, solidLine);

    final whiteCore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawPath(path, whiteCore);
  }

  @override
  bool shouldRepaint(covariant _LevelRoutePainter oldDelegate) {
    return oldDelegate.alignments != alignments;
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.snapshot,
    required this.levelNumber,
    required this.bagsCleared,
    required this.bagsToClear,
    required this.onPause,
  });

  final XrayInspectorSnapshot snapshot;
  final int levelNumber;
  final int bagsCleared;
  final int bagsToClear;
  final VoidCallback onPause;

  String _levelName(int level) {
    return switch (level) {
      1 => 'First Scan',
      2 => 'Sharp Shapes',
      3 => 'Mixed Bags',
      4 => 'Crowded Luggage',
      5 => 'Razor Alert',
      6 => 'False Tap Trap',
      7 => 'Double Threat',
      8 => 'Battery Warning',
      9 => 'Speed Check',
      _ => 'Final Security Gate',
    };
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.white,
      fontSize: 12,
      letterSpacing: 0.5,
    );

    final scoreLabelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white38,
      fontSize: 9,
      letterSpacing: 1.0,
    );

    final scoreValueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      fontSize: 16,
    );

    final comboStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFFEAB308), // Gold/yellow
      fontSize: 13,
    );

    // Format score with comma separator
    final formattedScore = snapshot.score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Level Name & Pause Button
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  border: Border.all(color: const Color(0x3338F6FF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    'Level $levelNumber  |  ${_levelName(levelNumber)}  ($bagsCleared/$bagsToClear)',
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 38,
              height: 38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  border: Border.all(color: const Color(0x3338F6FF)),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: onPause,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: Score, Combo, Lives
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score panel
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    border: Border.all(color: const Color(0x2238F6FF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SCORE', style: scoreLabelStyle),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(formattedScore, style: scoreValueStyle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Combo panel
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    border: Border.all(color: const Color(0x2238F6FF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Combo x${_formatMultiplier(snapshot.comboMultiplier)}',
                            style: comboStyle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (snapshot.combo % 5) / 5.0,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFEAB308),
                            ),
                            minHeight: 3.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Lives panel
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    border: Border.all(color: const Color(0x2238F6FF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isFilled = index < snapshot.lives;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              isFilled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFilled ? const Color(0xFFEF4444) : Colors.white24,
                              size: 16,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMultiplier(double multiplier) {
    if (multiplier == multiplier.roundToDouble()) {
      return multiplier.toStringAsFixed(0);
    }
    return multiplier.toStringAsFixed(1);
  }
}
