import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class ChatSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: ListView(
        children: [
          ListTile(
            title: Text('User Chat'),
            subtitle: Text('Chat as a patient'),
            leading: Icon(Icons.person),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(isUserView: true),
              ),
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Doctor Chat'),
            subtitle: Text('Chat as a doctor'),
            leading: Icon(Icons.medical_services),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(isUserView: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}