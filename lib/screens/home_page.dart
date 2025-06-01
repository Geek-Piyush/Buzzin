import 'package:buzzin/screens/about_page.dart';
import 'package:buzzin/screens/add_event_page.dart';
import 'package:buzzin/screens/interested_events_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buzzin/Widget/event_card.dart';
import 'package:buzzin/screens/chat.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buzzin/screens/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get(),
          builder: (ctx, snapshot) {
            final userData = snapshot.hasData
                ? snapshot.data?.data() as Map<String, dynamic>?
                : null;
            final imageUrl = userData?['image_url'];

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/images/default_pp.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const AboutPage()),
                    );
                  },
                  child: Text(
                    "Buzzin'",
                    style: GoogleFonts.bangers(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final eventDocs = snapshot.data!.docs;

          final ongoingEvents = eventDocs.where((doc) {
            final data = doc.data();
            final Timestamp? ts = data['eventDate'];
            return ts != null && ts.toDate().isAfter(now);
          }).toList();

          final pastEvents = eventDocs.where((doc) {
            final data = doc.data();
            final Timestamp? ts = data['eventDate'];
            return ts != null && ts.toDate().isBefore(now);
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (ongoingEvents.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Text(
                      "Ongoing Events",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ...ongoingEvents.map((event) => EventCard(eventData: event)),
              ],
              if (pastEvents.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Text(
                      "Past Events",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                ...pastEvents.map((event) => EventCard(eventData: event)),
              ],
            ],
          );
        },
      ),
    );
  }
}
