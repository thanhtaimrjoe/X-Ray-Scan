import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/systems/tap_sort_rules.dart';
import 'game/tap_sort_game.dart';
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
      title: 'Tap Sort Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF111827),
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

  Future<void> _finishGame(TapSortSnapshot snapshot) async {
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Tap Sort Rush',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'High score: $highScore',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 34),
              FilledButton(onPressed: onPlay, child: const Text('Play')),
              const Spacer(),
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

  final ValueChanged<TapSortSnapshot> onGameOver;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final TapSortGame _game;
  TapSortSnapshot _snapshot = const TapSortSnapshot(
    score: 0,
    combo: 0,
    lives: 3,
    isGameOver: false,
  );

  @override
  void initState() {
    super.initState();
    _game = TapSortGame(
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
          Positioned.fill(child: GameWidget(game: _game)),
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Row(
                  children: [
                    for (final lane in SortLane.values)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _LaneButton(
                            lane: lane,
                            onPressed: () => _game.tapLane(lane),
                          ),
                        ),
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
                'Game Over',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
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
                    ? 'New high score: $highScore'
                    : 'High score: $highScore',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onMenu, child: const Text('Menu')),
              const Spacer(),
              const _BannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.snapshot});

  final TapSortSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score ${snapshot.score}', style: textStyle),
            Text('Combo ${snapshot.combo}', style: textStyle),
            Text('Lives ${snapshot.lives}', style: textStyle),
          ],
        ),
      ),
    );
  }
}

class _LaneButton extends StatelessWidget {
  const _LaneButton({required this.lane, required this.onPressed});

  final SortLane lane;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: laneColor(lane),
          foregroundColor: lane == SortLane.yellow
              ? Colors.black
              : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          '${laneGlyph(lane)}  ${laneLabel(lane)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
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
