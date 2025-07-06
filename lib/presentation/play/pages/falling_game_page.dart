import 'package:flutter/material.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:cultura/presentation/play/controllers/falling_game_controller.dart';
import 'package:cultura/presentation/play/widgets/falling_word.dart';
import 'package:cultura/presentation/play/widgets/bottom_options.dart';

class FallingGamePage extends StatefulWidget {
  const FallingGamePage({super.key});

  @override
  State<FallingGamePage> createState() => _FallingGamePageState();
}

class _FallingGamePageState extends State<FallingGamePage> {
  final FallingGameController _gameController = FallingGameController();
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _gameController.startGame();
    _listenForGameOver();
  }

  void _listenForGameOver() {
    _gameController.isGameOver.addListener(() {
      if (_gameController.isGameOver.value) {
        _showGameOverDialog();
      }
    });
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
            Text(
              'Your Score: ${_gameController.score.value}',
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
              _gameController.startGame();
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

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF627B3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppNavigator.pop(context),
        ),
        title: ValueListenableBuilder<int>(
          valueListenable: _gameController.score,
          builder: (context, score, _) => Text(
            'Score: $score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _gameController.remainingTime,
            builder: (context, time, _) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Time: ${time}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
              });
              // Toggle sound in your sound service
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Game background
          Container(
            decoration: BoxDecoration(
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
          // Falling words
          FallingWord(gameController: _gameController),
          // Bottom options (answer buttons and word history)
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomOptions(gameController: _gameController),
          ),
        ],
      ),
    );
  }
}
