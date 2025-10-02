import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessAppointmentsPage extends StatelessWidget {
  final String userUid;

  const BusinessAppointmentsPage({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments",style:TextStyle(color: Colors.white) ,),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('businessUid', isEqualTo: userUid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            // Empty state decoration
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 120,
                      color: Colors.blue.shade200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "No appointments booked yet!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Once your customers start booking, their appointments will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final customerName = appointment['customerName'] ?? "";
              final date = appointment['date'] ?? "";
              final time = appointment['time'] ?? "";
              final contact = appointment['customerContact'] ?? "";

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                shadowColor: Colors.blue.shade100,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue, size: 28),
                  ),
                  title: Text(
                    customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Date: $date"),
                      Text("Time: $time"),
                      Text("Contact: $contact"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                  onTap: () {
                    // Optional: Show detailed appointment info or actions
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
