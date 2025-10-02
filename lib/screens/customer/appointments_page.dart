import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsPage extends StatelessWidget {
  final String userEmail; // Logged-in user's email

  const AppointmentsPage({super.key, required this.userEmail, required String userUid});

  // Open Google Maps
  void _openMap(String address) async {
    final Uri googleMapsUrl =
    Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('customerEmail', isEqualTo: userEmail)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No appointments found"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final appointment = docs[index];
            final serviceName = appointment['serviceName'];
            final date = appointment['date'];
            final time = appointment['time'];
            final address = appointment['address'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("$date • $time\n$address"),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.navigation, color: Colors.blue),
                  onPressed: () => _openMap(address),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
