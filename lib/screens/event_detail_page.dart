import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buzzin/screens/chat.dart';
import 'package:buzzin/screens/interested_events_page.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatefulWidget {
  final DocumentSnapshot eventData;

  const EventDetailPage({super.key, required this.eventData});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isInterested = false;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool _isCreator = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkInterestStatus();
    _checkIfCreator();
    _checkIfRegistered();
  }

  void _checkIfCreator() {
    final creatorId = widget.eventData['creatorId'];
    setState(() {
      _isCreator = userId == creatorId;
    });
  }

  Future<void> _checkIfRegistered() async {
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventData.id)
        .collection('registrations')
        .doc(userId)
        .get();

    if (mounted) {
      setState(() {
        _isRegistered = doc.exists;
      });
    }
  }

  void _checkInterestStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('interestedEvents')
        .doc(widget.eventData.id)
        .get();

    if (mounted) {
      setState(() {
        _isInterested = doc.exists;
      });
    }
  }

  Future<void> _toggleInterest() async {
    final eventRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('interestedEvents')
        .doc(widget.eventData.id);

    final data = widget.eventData.data() as Map<String, dynamic>;

    if (_isInterested) {
      await eventRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from Interested Events')),
      );
    } else {
      await eventRef.set({
        'eventName': data['eventName'],
        'posterImage': data['posterImage'],
        'location': data['location'],
        'shortDescription': data['shortDescription'],
        'qrCode': data['qrCode'],
        'description': data['description'],
        'eventDate': data['eventDate'],
        'googleFormLink': data['googleFormLink'],
        'contact': data['contact'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as Interested')),
      );
    }

    if (mounted) {
      setState(() {
        _isInterested = !_isInterested;
      });
    }
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _goToChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ChatScreen()),
    );
  }

  void _goToInterestedEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const InterestedEventsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.eventData.data() as Map<String, dynamic>;
    String? formattedDate;

    if (data['eventDate'] != null) {
      final DateTime date = (data['eventDate'] as Timestamp).toDate();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: Text(
          data['eventName'] ?? 'Event Details',
          style: GoogleFonts.bangers(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontSize: 22,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isInterested ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleInterest,
          ),
          IconButton(
            onPressed: () => _goToChat(context),
            icon: const Icon(Icons.chat, color: Colors.white),
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
      body: _buildBody(data, formattedDate),
    );
  }

  Widget _buildBody(Map<String, dynamic> data, String? formattedDate) {
    final double fontSize = (data['eventName']?.length ?? 0) > 20 ? 24 : 28;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (data['posterImage'] != null)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(data['posterImage']),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    data['eventName'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['shortDescription'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text("About Event",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 6),
                        Text(data['description'] ?? '',
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        if (formattedDate != null)
                          Row(
                            children: [
                              const Icon(Icons.event, size: 20),
                              const SizedBox(width: 6),
                              Text('Date: $formattedDate',
                                  style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 6),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final location = Uri.encodeComponent(
                                      data['location'] ?? '');
                                  final url = Uri.parse(
                                      "https://www.google.com/maps/search/?api=1&query=$location");
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Could not launch Maps')),
                                    );
                                  }
                                },
                                child: Text(
                                  data['location'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.phone),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(data['contact'] ?? '',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: data['contact'] ?? ''));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Contact copied')),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!_isCreator)
            ElevatedButton.icon(
              icon: Icon(
                _isRegistered ? Icons.check_circle : Icons.how_to_reg,
                color: Colors.white,
              ),
              label: Text(_isRegistered ? "Registered" : "Register Now"),
              onPressed: _isRegistered
                  ? null
                  : () async {
                      final currentUser = FirebaseAuth.instance.currentUser!;
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .get();

                      final userData = userDoc.data()!;
                      await FirebaseFirestore.instance
                          .collection('events')
                          .doc(widget.eventData.id)
                          .collection('registrations')
                          .doc(currentUser.uid)
                          .set({
                        'username': userData['username'],
                        'email': userData['email'],
                      });

                      if (mounted) {
                        setState(() {
                          _isRegistered = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You are registered!')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRegistered ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          const SizedBox(height: 20),
          if (data['googleFormLink'] != null &&
              data['googleFormLink'].toString().isNotEmpty)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("Registration Link",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(data['googleFormLink']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Could not open registration link')),
                          );
                        }
                      },
                      child: Text(
                        data['googleFormLink'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          if (data['qrCode'] != null && data['qrCode'].toString().isNotEmpty)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Register Here!!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data['qrCode'],
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (_isCreator)
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('events')
                            .doc(widget.eventData.id)
                            .collection('registrations')
                            .get(),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          final registrations = snapshot.data?.docs ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Registrations',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Sr. No')),
                                    DataColumn(label: Text('Username')),
                                    DataColumn(label: Text('Contact')),
                                  ],
                                  rows: List.generate(
                                    registrations.length,
                                    (index) {
                                      final reg = registrations[index].data()!
                                          as Map<String, dynamic>;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text('${index + 1}')),
                                          DataCell(Text(reg['username'] ?? '')),
                                          DataCell(Text(reg['email'] ?? '')),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
