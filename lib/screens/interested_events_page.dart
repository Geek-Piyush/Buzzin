import 'package:buzzin/screens/add_event_page.dart';
import 'package:buzzin/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buzzin/Widget/event_card.dart';
import 'package:buzzin/screens/event_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';

class InterestedEventsPage extends StatelessWidget {
  const InterestedEventsPage({super.key});

  void _goToEventDetail(BuildContext context, DocumentSnapshot eventData) {
    final rawData = eventData.data();
    if (rawData == null || rawData is! Map<String, dynamic>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This event no longer exists.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => EventDetailPage(eventData: eventData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    void signOut() {
      FirebaseAuth.instance.signOut();
    }

    void goToChat(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => const ChatScreen()),
      );
    }

    void goToAddEvent(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => const AddEventPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: Text(
          "Interested Events",
          style: GoogleFonts.bangers(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 17,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => goToChat(context),
            icon: const Icon(Icons.chat, color: Colors.white),
          ),
          IconButton(
            onPressed: () => goToAddEvent(context),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('interestedEvents')
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventDocs = snapshot.data!.docs;

          if (eventDocs.isEmpty) {
            return const Center(child: Text("No interested events yet."));
          }

          return ListView.builder(
            itemCount: eventDocs.length,
            itemBuilder: (ctx, index) {
              final eventData = eventDocs[index];
              return GestureDetector(
                onTap: () => _goToEventDetail(context, eventData),
                child: EventCard(
                  eventData: eventData,
                  onDelete: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('interestedEvents')
                          .doc(eventData.id)
                          .delete();

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from Interested Events'),
                        ),
                      );
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to remove event'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
