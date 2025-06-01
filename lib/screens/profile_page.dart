import 'dart:io';
import 'package:buzzin/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:buzzin/Widget/event_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String? username;
  String? email;
  String? imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      setState(() {
        username = data?['username'];
        email = data?['email'];
        imageUrl = data?['image_url'];
        isLoading = false;
      });
    }
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_image')
        .child('${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(picked.path));
    final newImageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'image_url': newImageUrl});

    setState(() {
      imageUrl = newImageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image updated')),
    );
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(text: username);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'username': newName});
                setState(() => username = newName);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final passwordController = TextEditingController();

    final confirmPassword = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter your password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmPassword != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // Delete events
      final events = await FirebaseFirestore.instance
          .collection('events')
          .where('creatorId', isEqualTo: user.uid)
          .get();
      for (final doc in events.docs) {
        await doc.reference.delete();
      }

      // Delete chats
      final chats = await FirebaseFirestore.instance
          .collection('chat')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (final doc in chats.docs) {
        await doc.reference.delete();
      }

      // Delete user Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const AuthScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to delete account.';
      if (e.code == 'wrong-password') {
        msg = 'Incorrect password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during deletion.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 42, 174, 210),
        title: Text(
          "Profile",
          style: GoogleFonts.bangers(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 26,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _changeProfileImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : const AssetImage('assets/images/chat.png')
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username ?? '',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: _editUsername,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: _deleteAccount,
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Your Events",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .where('creatorId', isEqualTo: userId)
                            .snapshots(),
                        builder: (ctx, eventSnapshot) {
                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final userEvents = eventSnapshot.data?.docs ?? [];

                          if (userEvents.isEmpty) {
                            return const Center(
                                child: Text('No events created yet.'));
                          }

                          return ListView.builder(
                            itemCount: userEvents.length,
                            itemBuilder: (ctx, index) {
                              final eventDoc = userEvents[index];
                              return EventCard(
                                eventData: eventDoc,
                                onDelete: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('events')
                                        .doc(eventDoc.id)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Event deleted')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to delete event')),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
