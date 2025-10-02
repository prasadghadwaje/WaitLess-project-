import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid; // Pass the logged-in user's UID

  const ProfilePage({super.key, required this.uid, required String userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String email = "";
  String role = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection('users').doc(widget.uid).get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          name = data?['name'] ?? "";
          email = data?['email'] ?? "";
          role = data?['role'] ?? "";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint("No user found with this UID");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(String field, String currentValue, String firestoreKey) {
    TextEditingController controller =
    TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Edit ${field[0].toUpperCase()}${field.substring(1)}"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter new $field",
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                await _firestore.collection('users').doc(widget.uid).update({
                  firestoreKey: controller.text.trim(),
                });

                setState(() {
                  if (firestoreKey == 'name') name = controller.text.trim();
                  if (firestoreKey == 'email') email = controller.text.trim();
                  if (firestoreKey == 'role') role = controller.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSignOut() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sign Out",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person,
                        size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person,
                              color: Colors.blue),
                          title: const Text("Name"),
                          subtitle: Text(
                              name.isNotEmpty ? name : "Not available"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showEditDialog('name', name, 'name'),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email,
                              color: Colors.orange),
                          title: const Text("Email"),
                          subtitle: Text(
                              email.isNotEmpty ? email : "Not available"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showEditDialog('email', email, 'email'),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.work,
                              color: Colors.green),
                          title: const Text("Role"),
                          subtitle: Text(
                              role.isNotEmpty ? role : "Not available"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showEditDialog('role', role, 'role'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
