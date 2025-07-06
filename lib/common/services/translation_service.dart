import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cultura/common/services/local_dictionary_service.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String _baseUrl = 'https://cultura-1sej.onrender.com';
  final LocalDictionaryService _localDictionary = LocalDictionaryService();

  /// Translate text using local dictionary first, then API fallback
  Future<TranslationResult> translateText({
    required String text,
    String sourceLanguage = 'eng',
    String targetLanguage = 'fub',
  }) async {
    try {
      log('Starting translation: "$text" from $sourceLanguage to $targetLanguage');

      // 1. Try local dictionary first
      // final localResult = await _localDictionary.translateLocally(
      //   text: text,
      //   sourceLanguage: sourceLanguage,
      //   targetLanguage: targetLanguage,
      // );
      var localResult;

      if (localResult != null) {
        log('Local translation found: ${localResult.translation} (confidence: ${localResult.confidence}, source: ${localResult.source})');

        return TranslationResult.success(
          originalFile: 'text_input',
          translatedContent: localResult.translation,
          targetLanguage: _getLanguageName(targetLanguage),
          sourceLanguage: _getLanguageName(sourceLanguage),
          fileName: 'Text Translation',
          confidence: localResult.confidence,
          translationSource: 'local_dictionary',
          translationDetails: _buildLocalTranslationDetails(localResult),
        );
      }

      log('No local translation found, trying API...');

      // 2. If not found locally, try API
      return await _translateTextViaAPI(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      log('Translation error: $e');
      return TranslationResult.error(
          'Failed to translate text: ${e.toString()}');
    }
  }

  Map<String, dynamic> _buildLocalTranslationDetails(
      LocalTranslationResult localResult) {
    return {
      'confidence': localResult.confidence,
      'source': localResult.source,
      'originalMatch': localResult.originalMatch,
      'matchType': _getMatchTypeDescription(localResult.source),
      'availableTranslations':
          localResult.allEntries.map((e) => e.translation).toList(),
      'partOfSpeech': localResult.allEntries.isNotEmpty
          ? localResult.allEntries.first.partOfSpeech
          : null,
      'examples': localResult.allEntries.isNotEmpty
          ? localResult.allEntries.first.examples
          : null,
    };
  }

  String _getMatchTypeDescription(String source) {
    switch (source) {
      case 'exact_match':
        return 'Exact dictionary match';
      case 'fuzzy_match':
        return 'Similar word found';
      case 'phrase_translation':
        return 'Word-by-word translation';
      default:
        return 'Dictionary translation';
    }
  }

  /// API-based text translation using the word endpoint
  Future<TranslationResult> _translateTextViaAPI({
    required String text,
    String sourceLanguage = 'eng',
    String targetLanguage = 'fub',
  }) async {
    try {
      log('Attempting API translation...');

      // Create multipart request for the word endpoint
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/word'));

      // Add form fields
      request.fields.addAll({
        'word': text,
        'source': _getFullLanguageName(sourceLanguage),
        'target': _getFullLanguageName(targetLanguage),
      });

      log('Sending word translation request to API...');
      log('Word: $text, Source: ${_getFullLanguageName(sourceLanguage)}, Target: ${_getFullLanguageName(targetLanguage)}');

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        Duration(seconds: 300),
        onTimeout: () {
          throw Exception('Word translation request timed out');
        },
      );

      log('API response status: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        log('API translation successful: $responseBody');

        // Try to parse as JSON first, if it fails, treat as plain text
        String translatedText;
        double confidence = 0.8;

        try {
          final jsonResponse = jsonDecode(responseBody);
          translatedText = jsonResponse['translation'] ??
              jsonResponse['translated_text'] ??
              jsonResponse['result'] ??
              responseBody;
          confidence = jsonResponse['confidence']?.toDouble() ?? 0.8;
        } catch (e) {
          // If not JSON, use the raw response
          translatedText = responseBody;
        }

        return TranslationResult.success(
          originalFile: 'text_input',
          translatedContent: translatedText,
          targetLanguage: _getLanguageName(targetLanguage),
          sourceLanguage: _getLanguageName(sourceLanguage),
          fileName: 'Text Translation',
          confidence: confidence,
          translationSource: 'api',
          translationDetails: {
            'confidence': confidence,
            'source': 'api',
            'provider': 'Backend API',
            'endpoint': 'word',
          },
        );
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        log('API translation failed with status: ${streamedResponse.statusCode}');
        log('Error response: $errorBody');

        return TranslationResult.error(
            'API translation failed (${streamedResponse.statusCode}): ${streamedResponse.reasonPhrase ?? 'Unknown error'}');
      }
    } catch (e) {
      log('API translation failed: $e');
      return TranslationResult.error(
          'Failed to translate via API: ${e.toString()}');
    }
  }

// Add this helper method to convert language codes to full names
  String _getFullLanguageName(String languageCode) {
    final languageMap = {
      'eng': 'english',
      'fra': 'francais',
      'fub': 'fulfulde',
      'bbj': 'ghomala',
      'ewo': 'ewondo',
      'spa': 'spanish',
      'deu': 'german',
      'ita': 'italian',
      'por': 'portuguese',
    };
    return languageMap[languageCode] ?? languageCode;
  }

  /// Document translation (keeps existing implementation)
  Future<TranslationResult> translateDocument({
    required String filePath,
    required String fileName,
    String sourceLanguage = 'eng',
    String targetLanguage = 'fub',
  }) async {
    try {
      log('Starting document translation: $fileName');
      log('Source: $sourceLanguage, Target: $targetLanguage');
      log('File path: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/extract'));

      request.fields.addAll({
        'source': '$sourceLanguage+$targetLanguage',
        'target': targetLanguage,
      });

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      log('Sending document to API...');

      final streamedResponse = await request.send().timeout(
        Duration(minutes: 5),
        onTimeout: () {
          throw Exception(
              'Document translation request timed out. Please try again with a smaller file.');
        },
      );

      log('Document translation response status: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        log('Document translation successful');

        String translatedContent;
        try {
          final jsonResponse = jsonDecode(responseBody);
          translatedContent = jsonResponse['translated_content'] ??
              jsonResponse['result'] ??
              jsonResponse['content'] ??
              responseBody;
        } catch (e) {
          translatedContent = responseBody;
        }

        return TranslationResult.success(
          originalFile: filePath,
          translatedContent: translatedContent,
          targetLanguage: _getLanguageName(targetLanguage),
          sourceLanguage: _getLanguageName(sourceLanguage),
          fileName: fileName,
          confidence: 0.8,
          translationSource: 'api_document',
        );
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        log('Document translation failed: ${streamedResponse.statusCode}');

        return TranslationResult.error(
            'Document translation failed (${streamedResponse.statusCode}): ${streamedResponse.reasonPhrase ?? 'Unknown error'}');
      }
    } catch (e) {
      log('Document translation error: $e');
      return TranslationResult.error(
          'Failed to translate document: ${e.toString()}');
    }
  }

  String _getLanguageCode(String displayCode) {
    final codeMap = {
      'EN': 'eng',
      'FR': 'fra',
      'FUB': 'fub',
      'BBJ': 'bbj',
    };
    return codeMap[displayCode] ?? displayCode.toLowerCase();
  }

  String _getLanguageName(String languageCode) {
    final languageMap = {
      'eng': 'English',
      'fra': 'French',
      'fub': 'Fulfulde',
      'bbj': 'Ghomala',
    };
    return languageMap[languageCode] ?? languageCode.toUpperCase();
  }

  Future<bool> checkApiHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      log('API health check failed: $e');
      return false;
    }
  }
}

class TranslationResult {
  final bool isSuccess;
  final String? originalFile;
  final String? translatedContent;
  final String? targetLanguage;
  final String? sourceLanguage;
  final String? fileName;
  final String? errorMessage;
  final double? confidence;
  final String? translationSource; // 'local_dictionary', 'api', 'api_document'
  final Map<String, dynamic>? translationDetails;

  TranslationResult._({
    required this.isSuccess,
    this.originalFile,
    this.translatedContent,
    this.targetLanguage,
    this.sourceLanguage,
    this.fileName,
    this.errorMessage,
    this.confidence,
    this.translationSource,
    this.translationDetails,
  });

  factory TranslationResult.success({
    required String originalFile,
    required String translatedContent,
    required String targetLanguage,
    required String fileName,
    String? sourceLanguage,
    double? confidence,
    String? translationSource,
    Map<String, dynamic>? translationDetails,
  }) {
    return TranslationResult._(
      isSuccess: true,
      originalFile: originalFile,
      translatedContent: translatedContent,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      fileName: fileName,
      confidence: confidence,
      translationSource: translationSource,
      translationDetails: translationDetails,
    );
  }

  factory TranslationResult.error(String errorMessage) {
    return TranslationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
