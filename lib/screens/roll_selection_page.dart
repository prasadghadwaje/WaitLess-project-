import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitless1_3/screens/customer/customer_home_page.dart';
import 'package:waitless1_3/screens/business/business_home_page.dart';
import 'findYourLocation/find_location_page.dart';

class RoleSelectionPage extends StatefulWidget {
  final String uid;
  final String email;

  const RoleSelectionPage({
    super.key,
    required this.uid,
    required this.email,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void selectRole(String role) async {
    await _firestore.collection('users').doc(widget.uid).set({
      'role': role,
    }, SetOptions(merge: true));

    if (role == 'Visitor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerHomePage(
            userUid: widget.uid,
            userEmail: widget.email,
          ),
        ),
      );
    } else if (role == 'Business Owner') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessHomePage(
            userUid: widget.uid,
            userEmail: widget.email,
          ),
        ),
      );
    } else if (role == 'Find Destination') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FindYourLocation()),
      );
    }
  }

  Widget roleCard(String title, IconData icon, Color startColor, Color endColor) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        selectRole(title);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 300,
          height: MediaQuery.of(context).size.height * 0.22,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: endColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-page background image
          Positioned.fill(
            child: Image.asset(
              "assets/loginPhoto.jpeg", // your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Optional: dark overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Existing content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Waitless',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // changed to white for visibility
                      ),
                    ),
                    const SizedBox(height: 30),
                    roleCard('Visitor', Icons.person, Colors.blueAccent, Colors.lightBlue),
                    roleCard('Business Owner', Icons.storefront, Colors.orangeAccent, Colors.deepOrange),
                    roleCard('Find Destination', Icons.map, Colors.green, Colors.teal),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
