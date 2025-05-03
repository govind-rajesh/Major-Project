import 'package:flutter/material.dart';
import'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatelessWidget {


  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> handleSignOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      print('User signed out!');
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings Page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => handleSignOut(context),
              icon: Icon(Icons.logout),
              label: Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}