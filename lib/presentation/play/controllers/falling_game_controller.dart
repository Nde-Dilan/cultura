import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cultura/common/services/sound_effect_service.dart';
import 'package:cultura/data/models/play/fulfulde_game_data_falling_game.dart';


class FallingGameController {
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> remainingTime =
      ValueNotifier<int>(60); // Game duration in seconds
  final ValueNotifier<List<WordPair>> fallingWords =
      ValueNotifier<List<WordPair>>([]);
  final ValueNotifier<WordPair?> currentWord = ValueNotifier<WordPair?>(null);
  final ValueNotifier<bool> isGameOver = ValueNotifier<bool>(false);
  final SoundEffectService _soundEffectService = SoundEffectService();

  Timer? _timer;
  Timer? _wordGenerationTimer;
  Timer? _animationTimer;
  final Random _random = Random();
  bool _processingAnswer =
      false; // Flag to track if we're waiting for user response

  final List<WordPair> _wordBank = FulfuldeFallingGameData.getRandomWordPairs( 
  );
  // Add this ValueNotifier to track word history
  final ValueNotifier<List<WordPair>> wordHistory =
      ValueNotifier<List<WordPair>>([]);

  void startGame() {
    score.value = 0;
    remainingTime.value = 60;
    fallingWords.value = [];

    wordHistory.value = [];
    isGameOver.value = false;

    _startTimer();
    // _startWordGeneration();
    _startAnimation();

    _addNewWord();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value <= 0) {
        _endGame("Time's up!");
        _soundEffectService.playWinningSound();
      } else {
        remainingTime.value--;
      }
    });
  }

  void _startWordGeneration() {
    _wordGenerationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (isGameOver.value) {
        timer.cancel();
        return;
      }

      if (fallingWords.value.length < 5) {
        // Limit concurrent words
        _addNewWord();
      }
    });
  }

  void _startAnimation() {
    const animationStep = 0.005; // How much to move per frame
    _animationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (isGameOver.value) {
        timer.cancel();
        return;
      }

      if (fallingWords.value.isEmpty && !_processingAnswer) {
        // If there are no falling words and we're not processing an answer,
        // add a new word
        _addNewWord();
        return;
      }

      final updatedWords = <WordPair>[];
      final missedWords = <WordPair>[];

      for (final word in fallingWords.value) {
        final newPosition = word.topPosition + animationStep;

        // Check if word reached the bottom
        if (newPosition >= (0.75 - (wordHistory.value.length * 0.05))) {
          // Dynamic bottom threshold based on stack height
          // Each word in history reduces available space by 0.05
          missedWords.add(word);
          _soundEffectService.playWrongSound();
        } else {
          updatedWords.add(word.copyWith(topPosition: newPosition));
        }
      }

      // Add any missed words to history
      if (missedWords.isNotEmpty) {
        wordHistory.value = [...wordHistory.value, ...missedWords];

        // Important: Only update currentWord when a word is missed
        currentWord.value = null;

        // Check if word history is too long (stack too high)
        if (wordHistory.value.length >= 10) {
          // Adjust this threshold as needed
          _endGame("Stack too high!");
          _soundEffectService.playWinningSound();
        }
        // Schedule next word after a short delay
        _processingAnswer = true;
        Future.delayed(const Duration(milliseconds: 1000), () {
          _processingAnswer = false;
        });
      }

      fallingWords.value = updatedWords;
    });
  }

  void _addNewWord() {
    if (isGameOver.value ||
        _processingAnswer ||
        fallingWords.value.isNotEmpty) {
      // Don't add a new word if:
      // - Game is over
      // - Already processing an answer
      // - There's already a word falling
      return;
    }

    // Pick a random word from the bank
    final wordIndex = _random.nextInt(_wordBank.length);
    final word = _wordBank[wordIndex];

    // Randomize horizontal position (0.2 to 0.8 to keep it in visible area)
    final randomPosition = 0.2 + (_random.nextDouble() * 0.6);

    // Add the word to the falling words list
    final newWord = WordPair(
      sourceWord: word.sourceWord,
      correctTranslation: word.correctTranslation,
      allPossibleTranslations: word.allPossibleTranslations,
      position: randomPosition,
      topPosition: 0.0, // Start at the top
    );

    fallingWords.value = [newWord];
    currentWord.value = newWord;
  }

  void checkAnswer(String selectedTranslation) {
    if (currentWord.value == null || _processingAnswer) return;
    _processingAnswer = true;
    final isCorrect =
        selectedTranslation == currentWord.value!.correctTranslation;

    if (isCorrect) {
      score.value += 10;
      _soundEffectService.playCorrectSound();

      // Remove the word that was answered correctly
      fallingWords.value = [];

      // Clear current word immediately after answering
      currentWord.value = null;

      // Wait a moment before showing the next word
      Future.delayed(const Duration(milliseconds: 1000), () {
        _processingAnswer = false;
      });
    } else {
      score.value = max(0, score.value - 10); // Don't go below 0
      _soundEffectService.playWrongSound();

      // Add the incorrectly answered word to history
      if (currentWord.value != null) {
        wordHistory.value = [...wordHistory.value, currentWord.value!];

        // Remove the word from falling words
        fallingWords.value = [];

        // Clear current word immediately after answering
        currentWord.value = null;

        // Check if word history is too long (stack too high)
        if (wordHistory.value.length >= 10) {
          _endGame("Stack too high!");
          _soundEffectService.playWinningSound();

          return;
        }
        // Wait a moment before showing the next word
        Future.delayed(const Duration(milliseconds: 1000), () {
          _processingAnswer = false;
        });
      }
    }
  }

  void _endGame(String reason) {
    isGameOver.value = true;
    _timer?.cancel();
    _wordGenerationTimer?.cancel();
    _animationTimer?.cancel();

    // This could be extended to show a dialog with the reason
    debugPrint('Game over: $reason');
  }

  void dispose() {
    _timer?.cancel();
    _wordGenerationTimer?.cancel();
    _animationTimer?.cancel();
    score.dispose();
    remainingTime.dispose();
    fallingWords.dispose();
    currentWord.dispose();
    isGameOver.dispose();
    wordHistory.dispose();
  }
}
