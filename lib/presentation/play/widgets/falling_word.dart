import 'package:cultura/common/constants.dart';
import 'package:cultura/data/models/play/fulfulde_game_data_falling_game.dart';
import 'package:cultura/presentation/play/controllers/falling_game_controller.dart';
import 'package:flutter/material.dart'; 

class FallingWord extends StatelessWidget {
  final FallingGameController gameController;

  const FallingWord({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return ValueListenableBuilder<List<WordPair>>(
      valueListenable: gameController.fallingWords,
      builder: (context, words, _) {
        return Stack(
          children: words.map((word) {
            // Calculate actual positions
            final topPosition = word.topPosition * screenSize.height;
            final leftPosition = word.position * screenSize.width - 50; // Center the word
            
            return Positioned(
              top: topPosition,
              left: leftPosition,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  word.sourceWord,
                  style: TextStyle(
                    color: white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}