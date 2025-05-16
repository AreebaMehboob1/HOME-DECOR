import 'package:ar_home_decoration/screens/auth_service.dart';
import 'package:ar_home_decoration/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
// Import your new AuthService
import 'package:ar_home_decoration/screens/auth_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(), // Add the AuthService provider here
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Home Decor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800020)),
          useMaterial3: true,
        ),
        home: SplashScreen(), // Keep your splash screen as the initial route
      ),
    );
  }
}
