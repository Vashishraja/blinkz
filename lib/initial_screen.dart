import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/auth_screens/login_screen.dart';
import 'package:blinkz/views/auth_screens/registration_screen.dart';
import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/blood_bank/blood_bank_profile.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (SessionManager.isLoggedIn) {
      if (SessionManager.userType == 'donor') {
        return const DonorProfilePage();
      } else if (SessionManager.userType == 'bank') {
        return BloodBankProfilePage();
      } else {
        SessionManager.logout();
        return  SelectionPage();
      }
    }
    // User is not logged in, show initial page with login and registration buttons
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Image.asset(
                'assets/logo.png', // Replace 'logo.png' with your logo image asset
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            const SizedBox(height: 50),
            // Login button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>  SelectionPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Register button
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => RegistrationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.orange, backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  side: const BorderSide(color: Colors.orange),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
