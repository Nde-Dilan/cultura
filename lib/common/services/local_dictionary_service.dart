import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

class LocalDictionaryService {
  static final LocalDictionaryService _instance =
      LocalDictionaryService._internal();
  factory LocalDictionaryService() => _instance;
  LocalDictionaryService._internal();

  Map<String, Map<String, List<DictionaryEntry>>> _dictionaries = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the combined dictionaries JSON file
      final String jsonString =
          await rootBundle.loadString('assets/data/combined_dictionaries.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Parse the data into our structure
      _dictionaries = _parseDictionaryData(data);
      _isInitialized = true;

      log('Local dictionary initialized with ${_dictionaries.length} language pairs');
    } catch (e) {
      log('Failed to initialize local dictionary: $e');
      // Initialize with empty dictionaries so the app doesn't crash
      _dictionaries = {};
      _isInitialized = true;
    }
  }

  Map<String, Map<String, List<DictionaryEntry>>> _parseDictionaryData(
      Map<String, dynamic> data) {
    final Map<String, Map<String, List<DictionaryEntry>>> result = {};

    // Expected structure: language_pair -> source_word -> translation_string
    data.forEach((languagePair, translations) {
      result[languagePair] = {};

      if (translations is Map<String, dynamic>) {
        translations.forEach((sourceWord, targetWord) {
          result[languagePair]![sourceWord.toLowerCase()] = [];

          // Since your data is just string translations, not lists
          if (targetWord is String) {
            result[languagePair]![sourceWord.toLowerCase()]!
                .add(DictionaryEntry(
              sourceWord: sourceWord,
              translation: targetWord,
              confidence: 0.9, // High confidence for dictionary entries
            ));
          }
        });
      }
    });

    return result;
  }

  Future<LocalTranslationResult?> translateLocally({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final languagePair = '${sourceLanguage}_to_$targetLanguage';
    final reversePair = '${targetLanguage}_to_$sourceLanguage';

    // Try direct language pair first
    LocalTranslationResult? result = _searchInDictionary(text, languagePair);

    // If not found, try reverse pair (for bidirectional translation)
    if (result == null) {
      result = _searchInDictionary(text, reversePair);
    }

    return result;
  }

  LocalTranslationResult? _searchInDictionary(
      String text, String languagePair) {
    log('Starting the lookup:  ');
    print(_dictionaries);

    final dictionary = _dictionaries[languagePair];

    if (dictionary == null) return null;

    final cleanText = text.toLowerCase().trim();

    // 1. Exact match
    if (dictionary.containsKey(cleanText)) {
      final entries = dictionary[cleanText]!;
      return LocalTranslationResult(
        translation: entries.first.translation,
        confidence: entries.first.confidence,
        source: 'exact_match',
        allEntries: entries,
      );
    }

    // 2. Fuzzy match (contains, starts with, ends with)
    List<MapEntry<String, List<DictionaryEntry>>> fuzzyMatches = [];

    // Check if the text contains any dictionary word or vice versa
    for (var entry in dictionary.entries) {
      final dictWord = entry.key;
      double similarity = _calculateSimilarity(cleanText, dictWord);

      if (similarity > 0.7) {
        // 70% similarity threshold
        fuzzyMatches.add(entry);
      }
    }

    if (fuzzyMatches.isNotEmpty) {
      // Sort by similarity and take the best match
      fuzzyMatches.sort((a, b) {
        double simA = _calculateSimilarity(cleanText, a.key);
        double simB = _calculateSimilarity(cleanText, b.key);
        return simB.compareTo(simA);
      });

      final bestMatch = fuzzyMatches.first;
      final entries = bestMatch.value;

      return LocalTranslationResult(
        translation: entries.first.translation,
        confidence:
            entries.first.confidence * 0.8, // Reduce confidence for fuzzy match
        source: 'fuzzy_match',
        originalMatch: bestMatch.key,
        allEntries: entries,
      );
    }

    // 3. Word-by-word translation for phrases
    if (cleanText.contains(' ')) {
      return _translatePhrase(cleanText, dictionary);
    }

    return null;
  }

  LocalTranslationResult? _translatePhrase(
      String phrase, Map<String, List<DictionaryEntry>> dictionary) {
    final words = phrase.split(' ');
    List<String> translatedWords = [];
    double totalConfidence = 0.0;
    int foundWords = 0;

    for (String word in words) {
      final cleanWord = word.toLowerCase().trim();
      if (dictionary.containsKey(cleanWord)) {
        translatedWords.add(dictionary[cleanWord]!.first.translation);
        totalConfidence += dictionary[cleanWord]!.first.confidence;
        foundWords++;
      } else {
        // Try fuzzy match for individual words
        String? fuzzyTranslation = _findFuzzyWordMatch(cleanWord, dictionary);
        if (fuzzyTranslation != null) {
          translatedWords.add(fuzzyTranslation);
          totalConfidence += 0.6; // Lower confidence for fuzzy word match
          foundWords++;
        } else {
          translatedWords.add(word); // Keep original if not found
        }
      }
    }

    if (foundWords > 0) {
      return LocalTranslationResult(
        translation: translatedWords.join(' '),
        confidence: totalConfidence / words.length,
        source: 'phrase_translation',
        allEntries: [],
      );
    }

    return null;
  }

  String? _findFuzzyWordMatch(
      String word, Map<String, List<DictionaryEntry>> dictionary) {
    for (var entry in dictionary.entries) {
      if (_calculateSimilarity(word, entry.key) > 0.8) {
        return entry.value.first.translation;
      }
    }
    return null;
  }

  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Simple similarity calculation
    if (a.contains(b) || b.contains(a)) return 0.8;
    if (a.startsWith(b.substring(0, (b.length / 2).floor())) ||
        b.startsWith(a.substring(0, (a.length / 2).floor()))) return 0.7;

    // Levenshtein distance-based similarity
    int distance = _levenshteinDistance(a, b);
    int maxLength = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLength);
  }

  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<List<int>> matrix = List.generate(
        a.length + 1, (i) => List.generate(b.length + 1, (j) => 0));

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  List<String> getSupportedLanguagePairs() {
    return _dictionaries.keys.toList();
  }

  bool isLanguagePairSupported(String sourceLanguage, String targetLanguage) {
    final pair1 = '${sourceLanguage}_to_$targetLanguage';
    final pair2 = '${targetLanguage}_to_$sourceLanguage';
    return _dictionaries.containsKey(pair1) || _dictionaries.containsKey(pair2);
  }
}

class DictionaryEntry {
  final String sourceWord;
  final String translation;
  final double confidence;
  final String? partOfSpeech;
  final List<String>? examples;

  DictionaryEntry({
    required this.sourceWord,
    required this.translation,
    required this.confidence,
    this.partOfSpeech,
    this.examples,
  });
}

class LocalTranslationResult {
  final String translation;
  final double confidence;
  final String source; // 'exact_match', 'fuzzy_match', 'phrase_translation'
  final String?
      originalMatch; // For fuzzy matches, shows what was actually matched
  final List<DictionaryEntry> allEntries;

  LocalTranslationResult({
    required this.translation,
    required this.confidence,
    required this.source,
    this.originalMatch,
    required this.allEntries,
  });
}
