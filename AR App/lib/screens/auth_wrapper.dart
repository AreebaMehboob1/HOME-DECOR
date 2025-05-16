import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: true);

    // Show loading while determining auth state
    if (!authService.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user is authenticated and email is verified
    if (authService.isAuthenticated) {
      // If email is verified or verification check is complete, go to home
      if (authService.isEmailVerified) {
        return const HomeScreen();
      } else {
        // Check email verification status
        authService.checkAndUpdateVerificationStatus().then((isVerified) {
          if (isVerified) {
            // This will trigger a rebuild thanks to notifyListeners()
          }
        });

        // While checking, show login screen where verification dialog will appear
        return const LoginScreen();
      }
    } else {
      // Not authenticated, show login screen
      return const LoginScreen();
    }
  }
}
