import 'package:cultura/common/constants.dart';
import 'package:flutter/material.dart';

import 'package:cultura/data/models/play/fulfulde_game_data_falling_game.dart';
import 'package:cultura/presentation/play/controllers/falling_game_controller.dart';

class BottomOptions extends StatelessWidget {
  final FallingGameController gameController;

  const BottomOptions({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Word history stack - shows accumulating words
        Container(
          width: double.infinity,
          color: teal.withAlpha(80),
           // constraints: const BoxConstraints(maxHeight: 150),
           padding: const EdgeInsets.symmetric(vertical: 8),
          child: ValueListenableBuilder<List<WordPair>>(
            valueListenable: gameController.wordHistory,
            builder: (context, history, _) {
              if (history.isEmpty) {
                return const SizedBox(height: 8);
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: history.map((word) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(word.sourceWord,
                            style:
                                const TextStyle(color: white, fontSize: 18)),
                        const SizedBox(width: 20),
                        Text(word.correctTranslation,
                            style:
                                const TextStyle(color: white, fontSize: 18)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        // Answer options
        ValueListenableBuilder<WordPair?>(
          valueListenable: gameController.currentWord,
          builder: (context, currentWord, _) {
            if (currentWord == null) {
              return const SizedBox(height: 60); // Empty space if no word
            }

            // Create a stable list of options that won't change during animations
            // We'll use a key based on the word to ensure the options only change when the word changes
            return OptionButtons(
              key: ValueKey(
                  currentWord.sourceWord), // Use key to prevent rebuilding
              currentWord: currentWord,
              gameController: gameController,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Create a separate stateful widget for option buttons to maintain stable shuffled options
class OptionButtons extends StatefulWidget {
  final WordPair currentWord;
  final FallingGameController gameController;

  const OptionButtons({
    super.key,
    required this.currentWord,
    required this.gameController,
  });

  @override
  State<OptionButtons> createState() => _OptionButtonsState();
}

class _OptionButtonsState extends State<OptionButtons> {
  late List<String> options;

  @override
  void initState() {
    super.initState();
    // Shuffle options only once when this widget is created
    options = List.from(widget.currentWord.allPossibleTranslations);
    options.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => widget.gameController.checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(option),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
