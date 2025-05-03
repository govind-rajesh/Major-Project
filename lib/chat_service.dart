import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isFromUser; // true=from user, false=from doctor
  final String senderName;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isFromUser,
    required this.senderName,
  });
}

class ChatService with ChangeNotifier {
  // Singleton instance
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void sendUserMessage(String text) {
    _addMessage(text, true, 'You');
  }

  void sendDoctorMessage(String text) {
    _addMessage(text, false, 'Dr. Smith');
  }

  void _addMessage(String text, bool isFromUser, String senderName) {
    _messages.add(ChatMessage(
      text: text,
      timestamp: DateTime.now(),
      isFromUser: isFromUser,
      senderName: senderName,
    ));
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}