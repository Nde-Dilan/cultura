// Controllers
import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cultura/data/models/play/word_pair.dart';

class DualGameController {
  final List<WordPair> allWordPairs;
  List<String> leftColumnWords = [];
  List<String> rightColumnWords = [];
  String? selectedLeftWord;
  String? selectedRightWord;
  int score = 0;
  int secondsElapsed = 0;
  bool soundEnabled = true;
  final AudioPlayer correctPlayer = AudioPlayer();
  final AudioPlayer wrongPlayer = AudioPlayer();
  final AudioPlayer pronunciationPlayer = AudioPlayer();
  Timer? timer;
  final Function(int) onScoreChange;
  final Function(int) onTimeChange;
  final Function() onGameComplete;

  DualGameController({
    required this.allWordPairs,
    required this.onScoreChange,
    required this.onTimeChange,
    required this.onGameComplete,
  }) {
    setupGame();
    initAudio();
    startTimer();
  }

  Future<void> initAudio() async {
    // await correctPlayer.setAsset('assets/audio/correct_answer.mp3');
    // await wrongPlayer.setAsset('assets/audio/wrong_answer_buzzer.mp3');
  }

  void setupGame() {
    leftColumnWords = allWordPairs.map((pair) => pair.word).toList();
    rightColumnWords = allWordPairs.map((pair) => pair.translation).toList();

    // Shuffle both columns
    leftColumnWords.shuffle();
    rightColumnWords.shuffle();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsElapsed++;
      onTimeChange(secondsElapsed);
    });
  }

  void pauseTimer() {
    timer?.cancel();
  }

  void selectLeftWord(String word) {
    selectedLeftWord = word;
    checkMatch();
  }

  void selectRightWord(String word) {
    selectedRightWord = word;
    checkMatch();
  }

  void checkMatch() {
    if (selectedLeftWord != null && selectedRightWord != null) {
      // Create word-translation mappings
      Map<String, String> wordToTranslation = {};
      Map<String, String> translationToWord = {};

      for (var pair in allWordPairs) {
        wordToTranslation[pair.word] = pair.translation;
        translationToWord[pair.translation] = pair.word;
      }

      // Helper functions to check if a string is a word or translation
      bool isWord(String text) => wordToTranslation.containsKey(text);
      bool isTranslation(String text) => translationToWord.containsKey(text);

      bool isMatch = false;
      String? wordToSpeak;

      // Check for match in either direction
      if (isWord(selectedLeftWord!) && isTranslation(selectedRightWord!)) {
        isMatch = wordToTranslation[selectedLeftWord!] == selectedRightWord;
        wordToSpeak = selectedRightWord; // Speak the translation
      } else if (isTranslation(selectedLeftWord!) &&
          isWord(selectedRightWord!)) {
        isMatch = translationToWord[selectedLeftWord!] == selectedRightWord;
        wordToSpeak = selectedLeftWord; // Speak the translation
      }

      if (isMatch) {
        // Correct match
        if (soundEnabled) {
          playCorrectSound();
          if (wordToSpeak != null) {
            speakWord(wordToSpeak);
          }
        }

        leftColumnWords.remove(selectedLeftWord);
        rightColumnWords.remove(selectedRightWord);

        score++;
        onScoreChange(score);

        if (leftColumnWords.isEmpty && rightColumnWords.isEmpty) {
          timer?.cancel();
          onGameComplete();
        }
      } else {
        // Wrong match
        if (soundEnabled) {
          playWrongSound();
        }

        score = max(0, score - 1);
        onScoreChange(score);
      }

      // Always reset selections regardless of match result
      selectedLeftWord = null;
      selectedRightWord = null;
    }
  }

  Future<void> playCorrectSound() async {
    try {
      await correctPlayer.play(AssetSource('audio/correct_answer.mp3'));
    } catch (e) {
      print("Error playing correct sound: $e");
    }
  }

  Future<void> playWrongSound() async {
    try {
      await wrongPlayer.play(AssetSource('audio/wrong_answer_buzzer.mp3'));
    } catch (e) {
      print("Error playing wrong sound: $e");
    }
  }

  // speakWord method:
  Future<void> speakWord(String word) async {
    try {
      // This would use pre-recorded pronunciation files in a full implementation
      // await pronunciationPlayer.play(AssetSource('sounds/pronunciations/$word.mp3'));
    } catch (e) {
      print("Error playing pronunciation: $e");
    }
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  void dispose() {
    timer?.cancel();
    correctPlayer.dispose();
    wrongPlayer.dispose();
    pronunciationPlayer.dispose();
  }
}
