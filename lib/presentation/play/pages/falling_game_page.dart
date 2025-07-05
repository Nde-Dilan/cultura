import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';

class FallingGamePage extends StatefulWidget {
  const FallingGamePage({super.key});

  @override
  State<FallingGamePage> createState() => _FallingGamePageState();
}

class _FallingGamePageState extends State<FallingGamePage>
    with TickerProviderStateMixin {
  // Game state
  int _score = 0;
  int _lives = 3;
  int _timeRemaining = 60;
  bool _isGameRunning = false;
  bool _isGamePaused = false;
  bool _soundEnabled = true;
  
  // Game controller
  late AnimationController _gameController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _gameController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _lives = 3;
      _timeRemaining = 60;
      _isGameRunning = true;
      _isGamePaused = false;
    });
    
    // Add your game logic here
  }

  void _pauseGame() {
    setState(() {
      _isGamePaused = !_isGamePaused;
    });
  }

  void _endGame() {
    setState(() {
      _isGameRunning = false;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Game Over!',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              HugeIcons.strokeRoundedCongruentTo,
              size: 60,
              color: Color(0xFFFF6B35),
            ),
            SizedBox(height: 16),
            Text(
              'Your Score: $_score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppNavigator.pop(context);
            },
            child: Text(
              'Exit',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PauseMenuBottomSheet(
        onResume: () {
          Navigator.pop(context);
          _pauseGame();
        },
        onRestart: () {
          Navigator.pop(context);
          _startGame();
        },
        onExit: () {
          Navigator.pop(context);
          AppNavigator.pop(context);
        },
        soundEnabled: _soundEnabled,
        onSoundToggle: () {
          setState(() {
            _soundEnabled = !_soundEnabled;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // Game Header
          GameHeader(
            score: _score,
            lives: _lives,
            timeRemaining: _timeRemaining,
            isGameRunning: _isGameRunning,
            soundEnabled: _soundEnabled,
            onPause: _showPauseMenu,
            onSoundToggle: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
              });
            },
          ),
          // Game Area
          Expanded(
            child: _isGameRunning 
                ? GameArea(
                    isGamePaused: _isGamePaused,
                    pulseController: _pulseController,
                  )
                : GameStartScreen(onStart: _startGame),
          ),
        ],
      ),
    );
  }
}

// Game Header Component
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.score,
    required this.lives,
    required this.timeRemaining,
    required this.isGameRunning,
    required this.soundEnabled,
    required this.onPause,
    required this.onSoundToggle,
  });

  final int score;
  final int lives;
  final int timeRemaining;
  final bool isGameRunning;
  final bool soundEnabled;
  final VoidCallback onPause;
  final VoidCallback onSoundToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      child: Stack(
        children: [
          // Background with gradient
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF627B3F),
                  Color.fromARGB(255, 151, 221, 52),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // Header content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => AppNavigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  // Title
                  Expanded(
                    child: Text(
                      'Word Drop Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Game controls
                  if (isGameRunning) ...[
                    // Pause button
                    GestureDetector(
                      onTap: onPause,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedPause,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                  // Sound toggle
                  GestureDetector(
                    onTap: onSoundToggle,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        soundEnabled 
                            ? HugeIcons.strokeRoundedVolumeHigh 
                            : HugeIcons.strokeRoundedVolumeMute01,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stats cards
          if (isGameRunning)
            Positioned(
              bottom: 0,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: GameStatCard(
                      icon: HugeIcons.strokeRoundedScooterElectric,
                      label: 'Score',
                      value: score.toString(),
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GameStatCard(
                      icon: HugeIcons.strokeRoundedHeartAdd,
                      label: 'Lives',
                      value: lives.toString(),
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GameStatCard(
                      icon: HugeIcons.strokeRoundedTime04,
                      label: 'Time',
                      value: '${timeRemaining}s',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Game Stat Card Component
class GameStatCard extends StatelessWidget {
  const GameStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Game Start Screen Component
class GameStartScreen extends StatelessWidget {
  const GameStartScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B35),
                  Color(0xFFFF8A50),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              HugeIcons.strokeRoundedGameController01,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          
          // Game title
          Text(
            'Word Drop',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          
          // Game description
          Text(
            'Catch falling words and match them\nwith their correct translations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 40),
          
          // Game instructions
          GameInstructionCard(),
          SizedBox(height: 40),
          
          // Start button
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B35),
                    Color(0xFFFF8A50),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Start Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

// Game Instruction Card Component
class GameInstructionCard extends StatelessWidget {
  const GameInstructionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How to Play',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 15),
          _buildInstruction(
            icon: HugeIcons.strokeRoundedMouse02,
            text: 'Tap falling words to catch them',
          ),
          SizedBox(height: 10),
          _buildInstruction(
            icon: HugeIcons.strokeRoundedTranslate,
            text: 'Match words with translations',
          ),
          SizedBox(height: 10),
          _buildInstruction(
            icon: HugeIcons.strokeRoundedTime04,
            text: 'Score points before time runs out',
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Color(0xFFFF6B35),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

// Game Area Component
class GameArea extends StatelessWidget {
  const GameArea({
    super.key,
    required this.isGamePaused,
    required this.pulseController,
  });

  final bool isGamePaused;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Game background pattern
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Game content
          Center(
            child: Text(
              'Game Area\n(Add your game logic here)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          // Pause overlay
          if (isGamePaused)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (pulseController.value * 0.1),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedPause,
                              size: 50,
                              color: Color(0xFFFF6B35),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Game Paused',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Pause Menu Bottom Sheet Component
class PauseMenuBottomSheet extends StatelessWidget {
  const PauseMenuBottomSheet({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
    required this.soundEnabled,
    required this.onSoundToggle,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;
  final bool soundEnabled;
  final VoidCallback onSoundToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          
          // Title
          Text(
            'Game Paused',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 30),
          
          // Menu options
          PauseMenuTile(
            icon: HugeIcons.strokeRoundedPlay,
            title: 'Resume Game',
            subtitle: 'Continue playing',
            onTap: onResume,
          ),
          SizedBox(height: 15),
          
          PauseMenuTile(
            icon: HugeIcons.strokeRoundedRefresh,
            title: 'Restart Game',
            subtitle: 'Start over from beginning',
            onTap: onRestart,
          ),
          SizedBox(height: 15),
          
          PauseMenuTile(
            icon: soundEnabled 
                ? HugeIcons.strokeRoundedVolumeHigh 
                : HugeIcons.strokeRoundedVolumeMute01,
            title: soundEnabled ? 'Sound On' : 'Sound Off',
            subtitle: 'Toggle game sounds',
            onTap: onSoundToggle,
          ),
          SizedBox(height: 15),
          
          PauseMenuTile(
            icon: HugeIcons.strokeRoundedLogout01,
            title: 'Exit Game',
            subtitle: 'Return to main menu',
            onTap: onExit,
            isDestructive: true,
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Pause Menu Tile Component
class PauseMenuTile extends StatelessWidget {
  const PauseMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Color(0xFFFF6B35);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}