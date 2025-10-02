import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'book_appointment_page.dart';

class ServiceDetailPage extends StatelessWidget {
  final String serviceId;
  final String userName;
  final String userEmail;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    required this.userName,
    required this.userEmail,
  });

  void _openMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('services').doc(serviceId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final service = snapshot.data!;
          if (!service.exists) return const Center(child: Text("Service not found"));

          double lat = service['latitude'] is String
              ? double.parse(service['latitude'])
              : service['latitude'];
          double lng = service['longitude'] is String
              ? double.parse(service['longitude'])
              : service['longitude'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Text(
                  service['name'],
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),

                // Category
                Chip(
                  label: Text(service['category']),
                  backgroundColor: Colors.blue[100],
                  avatar: const Icon(Icons.category, color: Colors.blueAccent),
                ),
                const SizedBox(height: 16),

                // Address Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.redAccent),
                    title: const Text("Address"),
                    subtitle: Text(service['address']),
                  ),
                ),
                const SizedBox(height: 12),

                // Timing Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.orange),
                    title: const Text("Working Hours"),
                    subtitle: Text(service['timing']),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(service['description']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openMap(lat, lng),
                      icon: const Icon(Icons.navigation,color: Colors.white,),
                      label: const Text("Navigate",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookAppointmentPage(
                              serviceId: serviceId,
                              serviceName: service['name'],
                              userName: userName,
                              userEmail: userEmail,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today,color: Colors.white,),
                      label: const Text("Book Appointment",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
