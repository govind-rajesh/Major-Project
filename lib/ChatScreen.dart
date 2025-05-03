import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isUserView;

  const ChatScreen({Key? key, required this.isUserView}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onMessagesUpdated);

    // Add initial message if it's the first load
    if (_chatService.messages.isEmpty && _isFirstLoad) {
      _isFirstLoad = false;
      if (widget.isUserView) {
        _chatService.sendDoctorMessage('Hello, how can I help you today?');
      } else {
        _chatService.sendUserMessage('Hi Doctor, I need some advice');
      }
    }
  }

  void _onMessagesUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isUserView ? 'User Chat' : 'Doctor Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _chatService.messages.length,
              itemBuilder: (context, index) {
                final message = _chatService.messages[_chatService.messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = (widget.isUserView && message.isFromUser) ||
        (!widget.isUserView && !message.isFromUser);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                if (widget.isUserView) {
                  _chatService.sendUserMessage(_messageController.text);
                } else {
                  _chatService.sendDoctorMessage(_messageController.text);
                }
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatService.removeListener(_onMessagesUpdated);
    super.dispose();
  }
}