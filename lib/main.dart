import 'dart:async';
import 'package:blinkz/initial_screen.dart';
import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/auth_screens/registration_screen.dart';
import 'package:blinkz/views/blood_bank/blood_bank_profile.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hjerohyhvbfkdlczzejm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqZXJvaHlodmJma2RsY3p6ZWptIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTI4MTk4NjIsImV4cCI6MjAwODM5NTg2Mn0.GecxN4z63CT3MetXHDPsoLw0eoM5c4rTvZkE0ev4w94',
  );
  SessionManager.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Display splash screen initially
    );
  }
}
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false; // Variable to control the visibility of the image

  @override
  void initState() {
    super.initState();
    // After 3 seconds, set _visible to true triggering the animation
    Timer(Duration(seconds: 1), () {
      setState(() {
        _visible = true;
      });
    });
    // After 5 seconds, navigate to the login page
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => InitialPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0, // Set opacity based on _visible value
          duration: Duration(seconds: 1), // Duration of the animation
          child: Lottie.asset(
            'assets/splash.json',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}