import 'package:cultura/common/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/services/translation_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final TranslationService _translationService = TranslationService();
    final GeminiService _geminiService = GeminiService();
  final List<String> _conversationHistory = [];
  bool _isLoading = false;
  int _messageCount = 0;
  static const int _maxMessages = 6;

  @override
  void initState() {
    super.initState();
    _initializeScenario();
  }

  void _initializeScenario() async {
    final initialMessage = _getInitialMessage(widget.scenarioId);
    
    setState(() {
      _isLoading = true;
    });

    // Translate the initial message
    final translationResult = await _translationService.translateText(
      text: initialMessage,
      sourceLanguage: 'eng',
      targetLanguage: 'fub',
    );

    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(
        originalText: initialMessage,
        translatedText: translationResult.isSuccess 
            ? translationResult.translatedContent! 
            : 'Translation failed',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _messageCount++;
      _conversationHistory.add('Bot: $initialMessage');
    });
  }

  String _getInitialMessage(String scenarioId) {
    switch (scenarioId) {
      case "all":
        return "Hello! Welcome to your conversation hub. I'm your speaking partner today. What can I help you with?";
      case 'restaurant':
        return "Hello! Welcome to our restaurant. I'm your waiter today. What can I get you to drink?";
      case 'shopping':
        return "Hi there! Welcome to our store. Are you looking for anything specific today?";
      case 'doctor':
        return "Good morning! I'm Dr. Smith. What brings you in today?";
      case 'job_interview':
        return "Hello! Thank you for coming in today. Please, have a seat. Tell me a bit about yourself.";
      case 'airport':
        return "Good day! Welcome to the airport. How can I assist you today?";
      case 'bank':
        return "Hello! Welcome to our bank. How may I help you today?";
      default:
        return "Hello! Let's start practicing. How can I help you today?";
    }
  }

  String _getScenarioTitle(String scenarioId) {
    switch (scenarioId) {
      case 'all':
        return "All & Nothing";
      case 'restaurant':
        return "Restaurant";
      case 'shopping':
        return "Shopping";
      case 'doctor':
        return "Doctor Visit";
      case 'job_interview':
        return "Job Interview";
      case 'airport':
        return "Airport/Travel";
      case 'bank':
        return "Bank Visit";
      default:
        return "Chat";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF5D340A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getScenarioTitle(widget.scenarioId),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'AI Practice Session (${_messageCount}/$_maxMessages messages)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedMoreVertical, color: Colors.white),
            onPressed: () {
              _showSessionInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return LoadingBubble();
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading && _messageCount < _maxMessages,
                    decoration: InputDecoration(
                      hintText: _messageCount >= _maxMessages 
                          ? 'Session completed' 
                          : 'Type your message in English...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: _isLoading || _messageCount >= _maxMessages ? null : _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isLoading || _messageCount >= _maxMessages 
                          ? Colors.grey[400] 
                          : Color(0xFF5D340A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading || _messageCount >= _maxMessages) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Translate user message
      final userTranslationResult = await _translationService.translateText(
        text: userMessage,
        sourceLanguage: 'eng',
        targetLanguage: 'fub',
      );

      // 2. Add user message to chat
      setState(() {
        _messages.add(ChatMessage(
          originalText: userMessage,
          translatedText: userTranslationResult.isSuccess 
              ? userTranslationResult.translatedContent! 
              : 'Translation failed',
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _messageCount++;
        _conversationHistory.add('User: $userMessage');
      });

      // 3. Check if we've reached the message limit
      if (_messageCount >= _maxMessages) {
        setState(() {
          _isLoading = false;
        });
        _showSessionComplete();
        return;
      }

      // 4. Generate AI response using Gemini
      final geminiResponse = await _geminiService.generateConversationResponse(
        userMessage: userMessage,
        scenarioId: widget.scenarioId,
        conversationHistory: _conversationHistory,
      );

      final aiResponse = geminiResponse.content ?? 'Sorry, I couldn\'t generate a response.';

      // 5. Translate AI response
      final aiTranslationResult = await _translationService.translateText(
        text: aiResponse,
        sourceLanguage: 'eng',
        targetLanguage: 'fub',
      );

      // 6. Add AI message to chat
      setState(() {
        _messages.add(ChatMessage(
          originalText: aiResponse,
          translatedText: aiTranslationResult.isSuccess 
              ? aiTranslationResult.translatedContent! 
              : 'Translation failed',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _messageCount++;
        _conversationHistory.add('Bot: $aiResponse');
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to process message: ${e.toString()}');
    }
  }

  
  void _showSessionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Session Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scenario: ${_getScenarioTitle(widget.scenarioId)}'),
            SizedBox(height: 8),
            Text('Messages: $_messageCount/$_maxMessages'),
            SizedBox(height: 8),
            Text('Languages: English ↔ Fulfulde'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFF5D340A))),
          ),
        ],
      ),
    );
  }

  void _showSessionComplete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Session Complete!'),
        content: Text('You\'ve completed the practice session. Great job!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back to Scenarios', style: TextStyle(color: Color(0xFF5D340A))),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String originalText;
  final String translatedText;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.originalText,
    required this.translatedText,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF5D340A),
              child: Icon(
                HugeIcons.strokeRoundedRobotic,
                size: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Color(0xFF5D340A) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original text
                  Text(
                    message.originalText,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Translated text in italic
                  Text(
                    message.translatedText,
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.8) 
                          : Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF5D340A),
            child: Icon(
              HugeIcons.strokeRoundedRobotic,
              size: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D340A)),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Translating...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}