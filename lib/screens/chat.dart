import 'package:buzzin/Widget/chat_messages.dart';
import 'package:buzzin/screens/add_event_page.dart';
import 'package:buzzin/screens/interested_events_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buzzin/Widget/new_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _goToChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ChatScreen()),
    );
  }

  void _goToAddEvent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddEventPage()),
    );
  }

  void _goToInterestedEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const InterestedEventsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: Text(
          "Global Chat",
          style: GoogleFonts.bangers(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900, // Extra bold
              letterSpacing: 1.2,
              fontSize: 24,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _goToChat(context),
            icon: const Icon(Icons.chat, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _goToAddEvent(context),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _goToInterestedEvents(context),
            icon: const Icon(Icons.star_border, color: Colors.white),
          ),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
