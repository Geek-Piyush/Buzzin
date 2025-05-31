import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // void _submitMessage() async {
  //   final enteredMessage = _messageController.text;

  //   if (enteredMessage.trim().isEmpty) {
  //     return;
  //   }

  //   //Send to Firestore database
  //   final user = FirebaseAuth.instance.currentUser!;
  //   final userData = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .get();

  //   FirebaseFirestore.instance.collection('chat').add({
  //     'text': enteredMessage,
  //     'createdAt': Timestamp.now(),
  //     'userId': user.uid,
  //     'username': userData.data()!['username'],
  //     'userImage': userData.data()!['image_url'],
  //   });

  //   // Close the keyboard
  //   FocusScope.of(context).unfocus();
  //   _messageController.clear();
  // }

  void _submitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User data not found.")),
      );
      return;
    }

    final username = userData['username'] ?? 'Unknown';
    final userImage = userData['image_url'] ?? '';

    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': username,
      'userImage': userImage,
    });

    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
