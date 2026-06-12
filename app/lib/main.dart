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

enum AppScreen {
  menu,
  playing,
  paused,
  gameOver,
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
  bool _isNewHighScore = false;
  Set<XrayObjectType> _unlockedItems = {};
  EncyclopediaGroup _selectedGroup = EncyclopediaGroup.danger;
  bool _soundEnabled = true;
  XrayInspectorGame? _currentGame;

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
      _unlockedItems = storage.getUnlockedXrayItems();
      _soundEnabled = storage.getSoundEnabled();
    });
  }

  void _startGame() {
    setState(() {
      _screen = AppScreen.playing;
      _lastScore = 0;
      _isNewHighScore = false;
    });
  }

  void _pauseGame() {
    _currentGame?.pause();
    setState(() {
      _screen = AppScreen.paused;
    });
  }

  void _resumeGame() {
    _currentGame?.resume();
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
        highScore: _highScore,
        onPlay: _startGame,
        onOpenDatabase: _showEncyclopediaIndex,
      ),
      AppScreen.playing => GameplayScreen(
        onGameOver: (snapshot) {
          _finishGame(snapshot);
        },
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
      AppScreen.gameOver => GameOverScreen(
        score: _lastScore,
        highScore: _highScore,
        isNewHighScore: _isNewHighScore,
        onRetry: _startGame,
        onMenu: _showMenu,
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
    required this.highScore,
    required this.onPlay,
    required this.onOpenDatabase,
    super.key,
  });

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
              const _BannerPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }
}

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({
    required this.onGameOver,
    required this.onItemDiscovered,
    required this.onPause,
    required this.onGameCreated,
    super.key,
  });

  final ValueChanged<XrayInspectorSnapshot> onGameOver;
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
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Hud(snapshot: _snapshot),
                  IconButton(
                    icon: const Icon(
                      Icons.pause_circle_outline,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: widget.onPause,
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
                        title: '⚠️ DANGER ITEMS',
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
                        title: '✅ SAFE ITEMS',
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
              const SizedBox(height: 16),
              const _BannerPlaceholder(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Score ${snapshot.score}', style: textStyle),
            const SizedBox(width: 12),
            Text('Combo ${snapshot.combo}', style: textStyle),
            const SizedBox(width: 12),
            Text('Lives ${snapshot.lives}', style: textStyle),
            const SizedBox(width: 12),
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
