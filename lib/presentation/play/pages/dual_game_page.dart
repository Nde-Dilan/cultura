import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';

class DualGamePage extends StatefulWidget {
  const DualGamePage({super.key});

  @override
  State<DualGamePage> createState() => _DualGamePageState();
}

class _DualGamePageState extends State<DualGamePage>
    with TickerProviderStateMixin {
  // Game state
  int _score = 0;
  int _timeRemaining = 120;
  bool _isGameRunning = false;
  bool _isGamePaused = false;
  bool _soundEnabled = true;
  bool _gameCompleted = false;

  // Game controller
  late AnimationController _gameController;
  late AnimationController _pulseController;

  // Word matching game state
  String? _selectedLeftWord;
  String? _selectedRightWord;
  List<String> _leftWords = [];
  List<String> _rightWords = [];

  // Sample word pairs for demo
  final Map<String, String> _wordPairs = {
    'Hello': 'Bonjour',
    'Water': 'Eau',
    'House': 'Maison',
    'Food': 'Nourriture',
    'Friend': 'Ami',
    'Love': 'Amour',
    'Peace': 'Paix',
    'Hope': 'Espoir',
  };

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

    _setupWordPairs();
  }

  void _setupWordPairs() {
    _leftWords = _wordPairs.keys.toList();
    _rightWords = _wordPairs.values.toList();
    _rightWords.shuffle(); // Shuffle the right words for the game
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
      _timeRemaining = 120;
      _isGameRunning = true;
      _isGamePaused = false;
      _gameCompleted = false;
      _selectedLeftWord = null;
      _selectedRightWord = null;
    });

    _setupWordPairs();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isGameRunning && !_isGamePaused && _timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        if (_timeRemaining > 0) {
          _startTimer();
        } else {
          _endGame();
        }
      }
    });
  }

  void _pauseGame() {
    setState(() {
      _isGamePaused = !_isGamePaused;
    });
    if (!_isGamePaused) {
      _startTimer();
    }
  }

  void _endGame() {
    setState(() {
      _isGameRunning = false;
      _gameCompleted = true;
    });
    _showGameOverDialog();
  }

  void _selectLeftWord(String word) {
    setState(() {
      _selectedLeftWord = word;
      _checkMatch();
    });
  }

  void _selectRightWord(String word) {
    setState(() {
      _selectedRightWord = word;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (_selectedLeftWord != null && _selectedRightWord != null) {
      if (_wordPairs[_selectedLeftWord] == _selectedRightWord) {
        // Correct match
        setState(() {
          _score += 10;
          _leftWords.remove(_selectedLeftWord);
          _rightWords.remove(_selectedRightWord);
          _selectedLeftWord = null;
          _selectedRightWord = null;
        });

        // Check if game completed
        if (_leftWords.isEmpty) {
          _endGame();
        }
      } else {
        // Wrong match
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _selectedLeftWord = null;
            _selectedRightWord = null;
          });
        });
      }
    }
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
          _leftWords.isEmpty ? 'Congratulations!' : 'Game Over!',
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
              _leftWords.isEmpty
                  ? HugeIcons.strokeRoundedStackStar
                  : HugeIcons.strokeRoundedTime04,
              size: 60,
              color: Color(0xFF5D340A),
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
            SizedBox(height: 8),
            Text(
              'Time: ${_formatTime(_timeRemaining)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
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
              backgroundColor: Color(0xFF5D340A),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                ? DualGameArea(
                    isGamePaused: _isGamePaused,
                    pulseController: _pulseController,
                    leftWords: _leftWords,
                    rightWords: _rightWords,
                    selectedLeftWord: _selectedLeftWord,
                    selectedRightWord: _selectedRightWord,
                    onLeftWordSelect: _selectLeftWord,
                    onRightWordSelect: _selectRightWord,
                  )
                : GameStartScreen(onStart: _startGame),
          ),
        ],
      ),
    );
  }
}

// Game Header Component (similar to falling game but adapted for dual game)
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.score,
    required this.timeRemaining,
    required this.isGameRunning,
    required this.soundEnabled,
    required this.onPause,
    required this.onSoundToggle,
  });

  final int score;
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
                      'Word Match Game',
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
                      icon: HugeIcons.strokeRoundedActivity02,
                      label: 'Score',
                      value: score.toString(),
                      color: Color(0xFF5D340A),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GameStatCard(
                      icon: HugeIcons.strokeRoundedTime04,
                      label: 'Time',
                      value: _formatTime(timeRemaining),
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// Game Stat Card Component (reused from falling game)
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
                  Color(0xFF5D340A),
                  Color(0xFFFF8A50),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF5D340A).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              HugeIcons.strokeRoundedTranslate,
              size: 60,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),

          // Game title
          Text(
            'Word Match',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),

          // Game description
          Text(
            'Match words from the left column\nwith their translations on the right!',
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
                    Color(0xFF5D340A),
                    Color(0xFFFF8A50),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF5D340A).withOpacity(0.3),
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
            text: 'Tap words from both columns',
          ),
          SizedBox(height: 10),
          _buildInstruction(
            icon: HugeIcons.strokeRoundedConnect,
            text: 'Match words with their translations',
          ),
          SizedBox(height: 10),
          _buildInstruction(
            icon: HugeIcons.strokeRoundedTime04,
            text: 'Complete all matches before time runs out',
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
          color: Color(0xFF5D340A),
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

// Dual Game Area Component
class DualGameArea extends StatelessWidget {
  const DualGameArea({
    super.key,
    required this.isGamePaused,
    required this.pulseController,
    required this.leftWords,
    required this.rightWords,
    required this.selectedLeftWord,
    required this.selectedRightWord,
    required this.onLeftWordSelect,
    required this.onRightWordSelect,
  });

  final bool isGamePaused;
  final AnimationController pulseController;
  final List<String> leftWords;
  final List<String> rightWords;
  final String? selectedLeftWord;
  final String? selectedRightWord;
  final Function(String) onLeftWordSelect;
  final Function(String) onRightWordSelect;

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
          // Game content
          Row(
            children: [
              // Left Column
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Words',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: leftWords.length,
                          itemBuilder: (context, index) {
                            final word = leftWords[index];
                            final isSelected = selectedLeftWord == word;
                            return WordButton(
                              word: word,
                              isSelected: isSelected,
                              onTap: () => onLeftWordSelect(word),
                              color: Colors.blue,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(
                width: 2,
                color: Colors.grey[200],
                margin: EdgeInsets.symmetric(vertical: 20),
              ),

              // Right Column
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Translations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rightWords.length,
                          itemBuilder: (context, index) {
                            final word = rightWords[index];
                            final isSelected = selectedRightWord == word;
                            return WordButton(
                              word: word,
                              isSelected: isSelected,
                              onTap: () => onRightWordSelect(word),
                              color: Colors.green,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
                              color: Color(0xFF5D340A),
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

// Word Button Component
class WordButton extends StatelessWidget {
  const WordButton({
    super.key,
    required this.word,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String word;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? color : Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Pause Menu Bottom Sheet Component (reused from falling game)
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

// Pause Menu Tile Component (reused from falling game)
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
    final color = isDestructive ? Colors.red : Color(0xFF5D340A);

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
