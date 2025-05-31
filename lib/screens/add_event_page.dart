import 'dart:io';
import 'package:buzzin/screens/chat.dart';
import 'package:buzzin/screens/interested_events_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  String _eventName = '';
  String _location = '';
  String _description = '';
  String _contact = '';
  String _shortDescription = '';
  String _googleFormLink = '';
  XFile? _posterImage;
  XFile? _qrCodeImage;
  DateTime? _eventDate;

  bool _isSubmitting = false;

  void _submitEvent() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _eventDate == null) {
      if (_eventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the date of the event.')),
        );
      }
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });

    try {
      String? posterUrl;
      String? qrCodeUrl;

      if (_posterImage != null) {
        final posterRef = FirebaseStorage.instance
            .ref()
            .child('event_posters')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await posterRef.putFile(File(_posterImage!.path));
        posterUrl = await posterRef.getDownloadURL();
      }

      if (_qrCodeImage != null) {
        final qrRef = FirebaseStorage.instance
            .ref()
            .child('qr_codes')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await qrRef.putFile(File(_qrCodeImage!.path));
        qrCodeUrl = await qrRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('events').add({
        'eventName': _eventName,
        'location': _location,
        'description': _description,
        'contact': _contact,
        'shortDescription': _shortDescription,
        'googleFormLink': _googleFormLink,
        'posterImage': posterUrl,
        'qrCode': qrCodeUrl,
        'timestamp': Timestamp.now(),
        'eventDate': Timestamp.fromDate(_eventDate!),
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add event. Please try again.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, bool isPoster) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        if (isPoster) {
          _posterImage = image;
        } else {
          _qrCodeImage = image;
        }
      });
    }
  }

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
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
        title: Text(
          "Add Event",
          style: GoogleFonts.bangers(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900, // Extra bold
              letterSpacing: 1.2,
              fontSize: 30,
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Poster Picker Box
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery, true),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _posterImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_posterImage!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Tap to select Poster Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Event Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _eventName = value!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _location = value!.trim(),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _description = value!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Contact (Email/Phone)'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _contact = value!.trim(),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Short Description (Max 120 characters)'),
                      maxLength: 120,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _shortDescription = value!.trim(),
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Google Form Link'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                      onSaved: (value) => _googleFormLink = value!.trim(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _eventDate == null
                      ? 'Select Date of Event'
                      : 'Event Date: ${DateFormat('dd MMM yyyy').format(_eventDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEventDate,
              ),
              const SizedBox(height: 20),

              // QR Code Picker Box
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery, false),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _qrCodeImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_qrCodeImage!.path),
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Tap to select QR Code Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              if (_isSubmitting)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitEvent,
                  child: const Text('Submit Event'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
