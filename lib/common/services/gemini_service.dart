import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // Replace with your actual Gemini API key
  static const String _apiKey = 'AIzaSyDk-8RIN1xBNt0PUo4uuu-9G4zkbWu3BXg';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  /// Generate AI response for conversation scenarios
  Future<GeminiResponse> generateConversationResponse({
    required String userMessage,
    required String scenarioId,
    required List<String> conversationHistory,
  }) async {
    try {
      log('Generating Gemini response for scenario: $scenarioId');
      log('User message: $userMessage');

      final prompt = _buildScenarioPrompt(userMessage, scenarioId, conversationHistory);
      
      final response = await _callGeminiAPI(prompt);
      
      if (response.isSuccess) {
        log('Gemini response generated successfully: ${response.content}');
        return response;
      } else {
        log('Gemini API failed: ${response.errorMessage}');
        // Fallback to predefined responses
        return _getFallbackResponse(scenarioId, conversationHistory.length);
      }
    } catch (e) {
      log('Gemini service error: $e');
      // Return fallback response on error
      return _getFallbackResponse(scenarioId, conversationHistory.length);
    }
  }

  /// Build context-aware prompt for different scenarios
  String _buildScenarioPrompt(String userMessage, String scenarioId, List<String> conversationHistory) {
    final scenarioContext = _getScenarioContext(scenarioId);
    final historyContext = conversationHistory.isNotEmpty 
        ? '\n\nConversation so far:\n${conversationHistory.join('\n')}'
        : '';

    return '''
$scenarioContext

$historyContext

User just said: "$userMessage"

Please respond with a single, natural sentence (maximum 20 words) that:
1. Stays in character for this scenario
2. Keeps the conversation flowing naturally
3. Is appropriate for language learning practice
4. Uses simple, clear English

Response:''';
  }

  /// Get scenario-specific context for prompts
  String _getScenarioContext(String scenarioId) {
    switch (scenarioId) {
      case 'all':
        return '''You are a friendly conversation partner helping someone practice English. 
You can talk about any topic. Keep responses casual and encouraging.''';
      
      case 'restaurant':
        return '''You are a friendly waiter/waitress in a restaurant. 
Help the customer order food, make recommendations, and provide good service.
Stay professional but warm.''';
      
      case 'shopping':
        return '''You are a helpful sales assistant in a clothing store.
Help customers find what they need, suggest sizes, and provide good customer service.
Be friendly and helpful.''';
      
      case 'doctor':
        return '''You are a caring doctor speaking with a patient.
Ask about symptoms, provide reassurance, and give simple medical advice.
Be professional, empathetic, and clear.''';
      
      case 'job_interview':
        return '''You are an interviewer conducting a job interview.
Ask relevant questions about experience, skills, and goals.
Be professional but encouraging.''';
      
      case 'bank':
        return '''You are a helpful bank teller assisting a customer.
Help with banking needs, explain procedures clearly, and be professional.
Be patient and thorough.''';
      
      default:
        return '''You are a helpful conversation partner for English practice.
Keep responses natural and encouraging.''';
    }
  }

  /// Make actual API call to Gemini
  Future<GeminiResponse> _callGeminiAPI(String prompt) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 100,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      log('Sending request to Gemini API...');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 30));

      log('Gemini API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['candidates'] != null && 
            jsonResponse['candidates'].isNotEmpty &&
            jsonResponse['candidates'][0]['content'] != null &&
            jsonResponse['candidates'][0]['content']['parts'] != null &&
            jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final generatedText = jsonResponse['candidates'][0]['content']['parts'][0]['text'] as String;
          final cleanedText = _cleanGeneratedText(generatedText);
          
          return GeminiResponse.success(cleanedText);
        } else {
          log('Invalid response structure from Gemini API');
          return GeminiResponse.error('Invalid response from AI service');
        }
      } else {
        final errorBody = response.body;
        log('Gemini API error: ${response.statusCode} - $errorBody');
        return GeminiResponse.error('AI service error: ${response.statusCode}');
      }
    } catch (e) {
      log('Gemini API call failed: $e');
      return GeminiResponse.error('Failed to connect to AI service: ${e.toString()}');
    }
  }

  /// Clean and format the generated text
  String _cleanGeneratedText(String text) {
    // Remove common prefixes and suffixes
    String cleaned = text.trim();
    
    // Remove quotes if they wrap the entire response
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    
    // Remove "Response:" prefix if present
    if (cleaned.toLowerCase().startsWith('response:')) {
      cleaned = cleaned.substring(9).trim();
    }
    
    // Ensure it ends with proper punctuation
    if (!cleaned.endsWith('.') && !cleaned.endsWith('!') && !cleaned.endsWith('?')) {
      cleaned += '.';
    }
    
    // Limit length for safety
    if (cleaned.length > 200) {
      cleaned = cleaned.substring(0, 197) + '...';
    }
    
    return cleaned;
  }

  /// Fallback responses when Gemini API fails
  GeminiResponse _getFallbackResponse(String scenarioId, int conversationLength) {
    final responses = {
      'all': [
        "That's interesting! Tell me more about that.",
        "I understand. What would you like to explore next?",
        "Great point! How do you feel about that?"
      ],
      'restaurant': [
        "Excellent choice! Would you like to see our appetizers?",
        "Perfect! I'll get that started for you. Anything else?",
        "That sounds delicious! What would you like to drink with that?"
      ],
      'shopping': [
        "That's a great choice! What size are you looking for?",
        "We have that in stock! Would you like to try it on?",
        "Perfect! That would look great on you. Anything else?"
      ],
      'doctor': [
        "I see. How long have you been experiencing this?",
        "That's helpful information. Are there any other symptoms?",
        "I understand. Let me prescribe something that should help."
      ],
      'job_interview': [
        "That's impressive experience! Tell me about a challenge you faced.",
        "Excellent! What interests you most about this position?",
        "Great answer! Where do you see yourself in five years?"
      ],
      'bank': [
        "I can help you with that! Do you have your ID with you?",
        "Perfect! Let me process that for you right away.",
        "That's all set! Is there anything else I can help you with today?"
      ],
    };

    final scenarioResponses = responses[scenarioId] ?? responses['all']!;
    final responseIndex = conversationLength % scenarioResponses.length;
    
    return GeminiResponse.success(scenarioResponses[responseIndex], isFallback: true);
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey != 'YOUR_GEMINI_API_KEY_HERE' && _apiKey.isNotEmpty;
}

class GeminiResponse {
  final bool isSuccess;
  final String? content;
  final String? errorMessage;
  final bool isFallback;

  GeminiResponse._({
    required this.isSuccess,
    this.content,
    this.errorMessage,
    this.isFallback = false,
  });

  factory GeminiResponse.success(String content, {bool isFallback = false}) {
    return GeminiResponse._(
      isSuccess: true,
      content: content,
      isFallback: isFallback,
    );
  }

  factory GeminiResponse.error(String errorMessage) {
    return GeminiResponse._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}