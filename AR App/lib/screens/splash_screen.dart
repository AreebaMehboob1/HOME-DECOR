import 'package:ar_home_decoration/screens/welcome_screen.dart';
import 'package:ar_home_decoration/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ar_home_decoration/screens/auth_service.dart';

import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for splash screen animation
    Future.delayed(Duration(seconds: 3), () {
      // Check auth status after splash screen delay
      checkAuthAndNavigate();
    });
  }

  void checkAuthAndNavigate() {
    final authService = Provider.of<AuthService>(context, listen: false);

    // If the auth service is still initializing, wait for it
    if (!authService.isInitialized) {
      // Add a small delay and check again
      Future.delayed(Duration(milliseconds: 500), () {
        checkAuthAndNavigate();
      });
      return;
    }

    // After auth is initialized, navigate based on auth state
    if (authService.isAuthenticated && authService.isEmailVerified) {
      // User is logged in and verified - go to home screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      // User is not logged in or not verified - go to welcome screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image added in center
            Image.asset(
              'assets/images/icon.png', // Replace with your image path
              height: 250, // Set image height
              width: 250, // Set image width
              fit: BoxFit.cover, // Adjust image size
            ),
          ],
        ),
      ),
    );
  }
}
