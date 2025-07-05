import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeScenario();
  }

  void _initializeScenario() {
    // Add initial AI message based on scenario
    final initialMessage = _getInitialMessage(widget.scenarioId);
    setState(() {
      _messages.add(ChatMessage(
        text: initialMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
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
        backgroundColor: Color(0xFFFF6B35),
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
              'AI Practice Session',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon:
                Icon(HugeIcons.strokeRoundedMoreVertical, color: Colors.white),
            onPressed: () {
              // Show options menu
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
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
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();

    // Simulate AI response (you'll replace this with actual AI integration)
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: "That's great! Let me help you with that...",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
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
              backgroundColor: Color(0xFFFF6B35),
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
                color: message.isUser ? Color(0xFFFF6B35) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                  fontSize: 16,
                ),
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
