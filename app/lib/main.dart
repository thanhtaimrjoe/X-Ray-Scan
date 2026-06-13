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
  playing,
  paused,
  levelClear,
  levelFailed,
  encyclopediaIndex,
  encyclopediaGroup,
}

enum EncyclopediaGroup { danger, safe }

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
    setState(() {
      _adBreakState = _adBreakRules.onLevelAttemptStarted(_adBreakState);
      _activeLevelNumber = levelNumber;
      _screen = AppScreen.playing;
      _lastScore = 0;
      _lastBagsCleared = 0;
      _lastBagsToClear = LevelProgressionRules.configForLevel(
        levelNumber,
      ).bagsToClear;
      _lastStarsEarned = 0;
      _lastBestStars = 0;
      _canPlayNextLevel = false;
      _didUnlockNextLevel = false;
      _lastUnlockedDanger = null;
    });
  }

  void _startHighestUnlockedLevel() {
    _startLevel(_levelProgress.highestUnlockedLevel);
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

  void _showEncyclopediaIndex() {
    setState(() {
      _screen = AppScreen.encyclopediaIndex;
    });
  }

  void _showEncyclopediaGroup(EncyclopediaGroup group) {
    setState(() {
      _selectedGroup = group;
      _screen = AppScreen.encyclopediaGroup;
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
        onOpenDatabase: _showEncyclopediaIndex,
      ),
      AppScreen.playing => GameplayScreen(
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
      AppScreen.paused => PauseScreen(
        onResume: _resumeGame,
        onMenu: _showMenu,
        soundEnabled: _soundEnabled,
        onToggleSound: _toggleSound,
      ),
      AppScreen.levelClear => LevelClearScreen(
        levelNumber: _activeLevelNumber,
        score: _lastScore,
        starsEarned: _lastStarsEarned,
        bestStars: _lastBestStars,
        canPlayNext: _canPlayNextLevel,
        didUnlockNextLevel: _didUnlockNextLevel,
        unlockedDanger: _lastUnlockedDanger,
        onNext: () => _startLevel(_activeLevelNumber + 1),
        onRetry: () => _startLevel(_activeLevelNumber),
        onMenu: _showMenu,
      ),
      AppScreen.levelFailed => LevelFailedScreen(
        levelNumber: _activeLevelNumber,
        score: _lastScore,
        bagsCleared: _lastBagsCleared,
        bagsToClear: _lastBagsToClear,
        onRetry: () => _startLevel(_activeLevelNumber),
        onMenu: _showMenu,
        canContinueWithAd: _adBreakRules.canOfferRewardedContinue(
          rewardedAdAvailable: _rewardedAd != null,
          rewardedContinueUsed: _adBreakState.rewardedContinueUsed,
        ),
        onContinueWithAd: _handleRewardedContinue,
      ),
      AppScreen.encyclopediaIndex => EncyclopediaIndexScreen(
        unlockedItems: _unlockedItems,
        onSelectGroup: _showEncyclopediaGroup,
        onBack: _showMenu,
      ),
      AppScreen.encyclopediaGroup => EncyclopediaGroupScreen(
        group: _selectedGroup,
        unlockedItems: _unlockedItems,
        onBack: _showEncyclopediaIndex,
      ),
    };
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.highestUnlockedLevel,
    required this.highScore,
    required this.onPlay,
    required this.onOpenDatabase,
    super.key,
  });

  final int highestUnlockedLevel;
  final int highScore;
  final VoidCallback onPlay;
  final VoidCallback onOpenDatabase;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: const Color(0xFFE5FEFF),
      letterSpacing: 0,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              Text(
                'X-Ray Scan',
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'Level $highestUnlockedLevel unlocked',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFB7EFF4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Best clearance: $highScore',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF8FDDE4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              const Expanded(child: _AssetHero()),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('PLAY LEVEL $highestUnlockedLevel'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onOpenDatabase,
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('ITEM DATABASE'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(child: XrayBannerAd()),
            ],
          ),
        ),
      ),
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
              child: Row(
                children: [
                  Expanded(
                    child: _Hud(
                      snapshot: _snapshot,
                      levelNumber: widget.levelNumber,
                      bagsCleared: _game.bagsCleared,
                      bagsToClear: _bagsToClear,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.pause_circle_outline,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: widget.onPause,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: FilledButton.icon(
                  onPressed: _game.clearBag,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('CLEAR'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
  const LevelClearScreen({
    required this.levelNumber,
    required this.score,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Level $levelNumber Clear',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 18),
              _StarRow(stars: starsEarned),
              const SizedBox(height: 8),
              Text(
                'Best stars: $bestStars',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFB7EFF4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $score',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (didUnlockNextLevel) ...[
                const SizedBox(height: 12),
                Text(
                  'Level ${levelNumber + 1} unlocked',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF37FFB5),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              if (unlockedDanger != null) ...[
                const SizedBox(height: 8),
                Text(
                  'New threat profile: ${unlockedDanger!.displayName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFF3B5C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (canPlayNext)
                FilledButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text('NEXT LEVEL ${levelNumber + 1}'),
                ),
              if (canPlayNext) const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('RETRY'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onMenu,
                icon: const Icon(Icons.home_rounded),
                label: const Text('MENU'),
              ),
              const Spacer(),
              const Center(child: XrayBannerAd()),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelFailedScreen extends StatelessWidget {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Level $levelNumber Failed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  color: const Color(0xFFFF3B5C),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Score: $score',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Bags cleared: $bagsCleared/$bagsToClear',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              if (canContinueWithAd) ...[
                FilledButton.icon(
                  onPressed: onContinueWithAd,
                  icon: const Icon(Icons.ondemand_video_rounded),
                  label: const Text('CONTINUE (WATCH AD)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD166),
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('RETRY'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onMenu,
                icon: const Icon(Icons.home_rounded),
                label: const Text('MENU'),
              ),
              const Spacer(),
              const Center(child: XrayBannerAd()),
            ],
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
    final accent = item.isDangerous
        ? const Color(0xFFFF3B5C)
        : const Color(0xFF37FFB5);
    final iconColor = isUnlocked ? accent : Colors.black;
    final borderColor = isUnlocked
        ? accent.withValues(alpha: 0.68)
        : Colors.white.withValues(alpha: 0.16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF061721),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  _itemIcon(item),
                  size: 54,
                  color: iconColor,
                  shadows: isUnlocked
                      ? [
                          Shadow(
                            color: accent.withValues(alpha: 0.9),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isUnlocked ? item.displayName : '???',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isUnlocked ? Colors.white : Colors.white38,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isUnlocked ? item.discoveryNote : 'Unknown profile',
              textAlign: TextAlign.center,
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

  IconData _itemIcon(XrayObjectType item) {
    return switch (item) {
      XrayObjectType.knife => Icons.restaurant_rounded,
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
}

class _AssetHero extends StatelessWidget {
  const _AssetHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x6638F6FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/xray_asset_sheet_approved.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF030912).withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({
    required this.snapshot,
    required this.levelNumber,
    required this.bagsCleared,
    required this.bagsToClear,
  });

  final XrayInspectorSnapshot snapshot;
  final int levelNumber;
  final int bagsCleared;
  final int bagsToClear;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: 0,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        border: Border.all(color: const Color(0x5538F6FF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('L$levelNumber', style: textStyle),
              const SizedBox(width: 10),
              Text('Bags $bagsCleared/$bagsToClear', style: textStyle),
              const SizedBox(width: 10),
              Text('Score ${snapshot.score}', style: textStyle),
              const SizedBox(width: 12),
              Text(
                'Combo ${snapshot.combo} x${_formatMultiplier(snapshot.comboMultiplier)}',
                style: textStyle,
              ),
              const SizedBox(width: 12),
              Text('Lives ${snapshot.lives}', style: textStyle),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMultiplier(double multiplier) {
    if (multiplier == multiplier.roundToDouble()) {
      return multiplier.toStringAsFixed(0);
    }
    return multiplier.toStringAsFixed(1);
  }
}
