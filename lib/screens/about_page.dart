import 'package:buzzin/screens/add_event_page.dart';
import 'package:buzzin/screens/chat.dart';
import 'package:buzzin/screens/interested_events_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const AboutPage()),
            );
          },
          child: Text(
            "About Buzzin'",
            style: GoogleFonts.bangers(
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 22,
              ),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "🎉 Welcome to Buzzin' 🎉",
                style: GoogleFonts.bangers(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 42, 174, 210),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: const Text(
                "Buzzin' is your go-to app for discovering, sharing, and managing events. "
                "Whether you're hosting a workshop, attending a fest, or promoting a meetup, Buzzin' has got you covered!",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "📌 Features:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "• Enlist your own events\n"
              "• Delete or manage events you've created\n"
              "• Explore a buzzing community chat\n"
              "• Find and mark events you're interested in\n"
              "• Connect with like-minded people",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            const Text(
              "Let's make a difference in how events are managed and discovered!",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "Designed & Developed by Piyush Nashikkar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
