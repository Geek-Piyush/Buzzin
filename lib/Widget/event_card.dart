import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../screens/event_detail_page.dart';

class EventCard extends StatelessWidget {
  final DocumentSnapshot eventData;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.eventData,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = eventData.data() as Map<String, dynamic>;
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isOwner = data['creatorId'] == currentUser?.uid;

    // Format the event date if available
    String? formattedDate;
    if (data['eventDate'] != null) {
      final DateTime date = (data['eventDate'] as Timestamp).toDate();
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => EventDetailPage(eventData: eventData),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['posterUrl'] != null || data['posterImage'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['posterUrl'] ?? data['posterImage'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['eventName'] ?? 'Unnamed Event',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['shortDescription'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    if (formattedDate != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(data['location'] ?? '',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                )
              else if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await eventData.reference.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event deleted')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete event')),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
