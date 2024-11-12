import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_list_screen.dart';
import 'login_screen.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Determines if the user is authenticated or not
  Widget handleAuthState() {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const TaskListScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }

  // Sign out
  void signOut() {
    _auth.signOut();
  }
}
