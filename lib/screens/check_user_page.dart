import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:waitless1_3/screens/roll_selection_page.dart';

class CheckUserPage extends StatefulWidget {
  const CheckUserPage({super.key});

  @override
  State<CheckUserPage> createState() => _CheckUserPageState();
}

class _CheckUserPageState extends State<CheckUserPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    User? currentUser = _auth.currentUser;

    await Future.delayed(const Duration(seconds: 1)); // Small delay for spinner

    if (currentUser != null) {
      // User is logged in → Navigate to RoleSelectionPage with real uid & email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSelectionPage(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
          ),
        ),
      );
    } else {
      // No user logged in → Navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Loading spinner
      ),
    );
  }
}
