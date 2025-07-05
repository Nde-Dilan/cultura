import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing sound effects in the application
class SoundEffectService {
  // Singleton pattern
  static final SoundEffectService _instance = SoundEffectService._internal();

  factory SoundEffectService() {
    return _instance;
  }

  SoundEffectService._internal() {
    _initAudioPlayers();
  }

  final List<AudioPlayer> _audioPlayers = [];
  final int _maxPlayers = 3; // Maximum number of simultaneous sounds
  int _currentPlayerIndex = 0;
  bool _isMuted = false;
  double _volume = 1.0;

  // Sound asset paths
  static const String _correctAnswerSound = 'assets/audio/correct_answer.mp3';
  static const String _wrongAnswerSound = 'assets/audio/wrong_answer.mp3';
  // static const String _wrongAnswerSound = 'assets/audio/wrong_answer_buzzer.mp3';
  static const String _syllableSelectSound =
      'assets/audio/syllable_select.aiff';
  static const String _wordCompleteSound = 'assets/audio/word_complete.wav';

  void _initAudioPlayers() {
    for (int i = 0; i < _maxPlayers; i++) {
      _audioPlayers.add(AudioPlayer());
    }
  }

  Future<void> _playSound(String assetPath) async {
  if (_isMuted) return;

  try {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
    final player = _audioPlayers[_currentPlayerIndex];

    await player.setVolume(_volume);
    // Remove 'assets/' prefix if present, audioplayers adds it automatically
    String cleanPath = assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;
    await player.play(AssetSource(cleanPath));
  } catch (e) {
    if (kDebugMode) {
      print('Error playing sound: $e');
    }
  }
}

  /// Play sound for correct answer
  Future<void> playCorrectSound() async {
    await _playSound(_correctAnswerSound);
  }

  /// Play sound for wrong answer
  Future<void> playWrongSound() async {
    await _playSound(_wrongAnswerSound);
  }

  /// Play sound when a syllable is selected
  Future<void> playSyllableSelectSound() async {
    await _playSound(_syllableSelectSound);
  }

  /// Play sound when a word is completed
  Future<void> playWinningSound() async {
    await _playSound(_wordCompleteSound);
  }

  /// Set the volume for sound effects (0.0 to 1.0)
  void setVolume(double volume) {
  _volume = volume.clamp(0.0, 1.0);
  for (final player in _audioPlayers) {
    player.setVolume(_volume);
  }
}

  /// Mute or unmute sound effects
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// Toggle mute state
  bool toggleMute() {
    _isMuted = !_isMuted;
    return _isMuted;
  }

  /// Release resources when no longer needed
  void dispose() {
    for (final player in _audioPlayers) {
      player.dispose();
    }
    _audioPlayers.clear();
  }
}
