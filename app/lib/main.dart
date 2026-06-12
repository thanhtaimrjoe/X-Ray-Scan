import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/systems/xray_inspector_rules.dart';
import 'game/xray_inspector_game.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TapSortRushApp());
}

class TapSortRushApp extends StatelessWidget {
  const TapSortRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-Ray Inspector',
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

enum AppScreen { menu, playing, gameOver }

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
  bool _isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final storage = await StorageService.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _storage = storage;
      _highScore = storage.getHighScore();
    });
  }

  void _startGame() {
    setState(() {
      _screen = AppScreen.playing;
      _lastScore = 0;
      _isNewHighScore = false;
    });
  }

  Future<void> _finishGame(XrayInspectorSnapshot snapshot) async {
    final storage = _storage;
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
      _lastScore = snapshot.score;
      _isNewHighScore = newHighScore;
      _screen = AppScreen.gameOver;
    });
  }

  void _showMenu() {
    setState(() {
      _screen = AppScreen.menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      AppScreen.menu => MainMenuScreen(
        highScore: _highScore,
        onPlay: _startGame,
      ),
      AppScreen.playing => GameplayScreen(
        onGameOver: (snapshot) {
          _finishGame(snapshot);
        },
      ),
      AppScreen.gameOver => GameOverScreen(
        score: _lastScore,
        highScore: _highScore,
        isNewHighScore: _isNewHighScore,
        onRetry: _startGame,
        onMenu: _showMenu,
      ),
    };
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.highScore,
    required this.onPlay,
    super.key,
  });

  final int highScore;
  final VoidCallback onPlay;

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
                'X-Ray Inspector',
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
              const SizedBox(height: 10),
              Text(
                'Best clearance: $highScore',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFB7EFF4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              const Expanded(child: _AssetHero()),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('SCAN'),
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
              const SizedBox(height: 18),
              const _BannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({required this.onGameOver, super.key});

  final ValueChanged<XrayInspectorSnapshot> onGameOver;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final XrayInspectorGame _game;
  XrayInspectorSnapshot _snapshot = const XrayInspectorSnapshot(
    score: 0,
    combo: 0,
    lives: 3,
    isGameOver: false,
  );

  @override
  void initState() {
    super.initState();
    _game = XrayInspectorGame(
      onSnapshotChanged: (snapshot) {
        if (mounted) {
          setState(() => _snapshot = snapshot);
        }
      },
      onGameFinished: widget.onGameOver,
    );
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
              padding: const EdgeInsets.all(14),
              child: _Hud(snapshot: _snapshot),
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

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRetry,
    required this.onMenu,
    super.key,
  });

  final int score;
  final int highScore;
  final bool isNewHighScore;
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
                'Inspection Closed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
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
                isNewHighScore
                    ? 'New best: $highScore'
                    : 'Best clearance: $highScore',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
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
              const _BannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
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
  const _Hud({required this.snapshot});

  final XrayInspectorSnapshot snapshot;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score ${snapshot.score}', style: textStyle),
            Text('Combo ${snapshot.combo}', style: textStyle),
            Text('Lives ${snapshot.lives}', style: textStyle),
            Text(_eventLabel(snapshot.lastEvent), style: textStyle),
          ],
        ),
      ),
    );
  }

  String _eventLabel(XrayFeedbackEvent event) {
    return switch (event) {
      XrayFeedbackEvent.none => 'READY',
      XrayFeedbackEvent.dangerFound => 'FOUND',
      XrayFeedbackEvent.safeTapped => 'SAFE -5',
      XrayFeedbackEvent.safeBagCleared => 'CLEAR +5',
      XrayFeedbackEvent.dangerMissed => 'MISS',
      XrayFeedbackEvent.falseClear => 'HOLD',
    };
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Ad banner area',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}
