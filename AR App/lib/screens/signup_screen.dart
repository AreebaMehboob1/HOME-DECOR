import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _verificationEmailSent = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Reset verification email status
    setState(() {
      _verificationEmailSent = false;
    });

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Input validation
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorSnackBar("All fields are required");
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackBar("Passwords do not match");
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters");
      return;
    }

    // Email format validation using regex
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showErrorSnackBar("Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();
        setState(() {
          _verificationEmailSent = true;
        });

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'uid': user.uid,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _showSuccessSnackBar(
            "Account created! Please verify your email before logging in.");

        // Delay navigation to allow user to read the message
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        });
      }
    } catch (e) {
      // Handle Firebase Auth exceptions
      String errorMessage = "Registration failed";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email is already registered";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email format";
            break;
          case 'weak-password':
            errorMessage = "Password is too weak";
            break;
          case 'operation-not-allowed':
            errorMessage = "Email/password accounts are not enabled";
            break;
          case 'too-many-requests':
            errorMessage = "Too many requests. Try again later";
            break;
          default:
            errorMessage = "Registration failed: ${e.code}";
        }
      }
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Send verification email again if needed
  Future<void> _resendVerificationEmail() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await currentUser.sendEmailVerification();
        _showSuccessSnackBar(
            "Verification email sent again. Please check your inbox.");
      } else {
        // If there's no current user, try to sign in first (silently)
        String email = emailController.text.trim();
        String password = passwordController.text.trim();

        if (email.isNotEmpty && password.isNotEmpty) {
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(email: email, password: password);

          if (userCredential.user != null) {
            await userCredential.user!.sendEmailVerification();
            _showSuccessSnackBar(
                "Verification email sent again. Please check your inbox.");
            await _auth.signOut(); // Sign out after sending verification
          }
        } else {
          _showErrorSnackBar("Please enter your email and password first");
        }
      }
    } catch (e) {
      String errorMessage = "Failed to send verification email";
      if (e is FirebaseAuthException) {
        errorMessage = "Error: ${e.message}";
      }
      _showErrorSnackBar(errorMessage);
    }

    setState(() => _isLoading = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF800020),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define royal maroon colors
    const Color primaryMaroon = Color(0xFF800020);
    const Color lightMaroon = Color(0xFFA04040);
    const Color darkMaroon = Color(0xFF600010);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightMaroon, darkMaroon],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App logo with subtle shimmer effect
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryMaroon.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Image.asset(
                                  'assets/images/icon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Header text
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryMaroon,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign up to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Verification email sent alert
                          if (_verificationEmailSent)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Verification email sent!',
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please check your inbox and verify your email address before logging in.',
                                    style:
                                        TextStyle(color: Colors.blue.shade700),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _resendVerificationEmail,
                                    child: Text(
                                      'Didn\'t receive? Send again',
                                      style: TextStyle(color: primaryMaroon),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Name field
                          _buildTextField(
                            controller: nameController,
                            label: 'Full Name',
                            prefixIcon: Icons.person_outline,
                            inputType: TextInputType.name,
                          ),
                          const SizedBox(height: 15),

                          // Email field
                          _buildTextField(
                            controller: emailController,
                            label: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),

                          // Password field
                          _buildTextField(
                            controller: passwordController,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Confirm Password field
                          _buildTextField(
                            controller: confirmPasswordController,
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Password strength indicator
                          _buildPasswordStrengthIndicator(
                              passwordController.text),

                          const SizedBox(height: 15),

                          // Terms and Conditions checkbox
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: primaryMaroon,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'By signing up, you agree to our Terms & Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Signup button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryMaroon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: primaryMaroon.withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'SIGN UP',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.app_registration),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login redirect
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: primaryMaroon,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    // Calculate password strength
    double strength = 0;
    String comment = "Enter a password";

    if (password.isNotEmpty) {
      // Length check
      if (password.length >= 6) strength += 0.25;
      if (password.length >= 8) strength += 0.25;

      // Complexity checks
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.1;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

      // Set comment based on strength
      if (strength < 0.3)
        comment = "Weak password";
      else if (strength < 0.7)
        comment = "Moderate password";
      else
        comment = "Strong password";
    }

    // Determine color based on strength
    Color indicatorColor;
    if (strength < 0.3)
      indicatorColor = Colors.red;
    else if (strength < 0.7)
      indicatorColor = Colors.orange;
    else
      indicatorColor = Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              comment,
              style: TextStyle(
                color: indicatorColor,
                fontSize: 12,
              ),
            ),
            Text(
              password.isNotEmpty ? "${(strength * 100).toInt()}%" : "",
              style: TextStyle(
                color: indicatorColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          minHeight: 5,
          borderRadius: BorderRadius.circular(2.5),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscureText,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.black87),
      onChanged: isPassword
          ? (_) => setState(() {})
          : null, // Rebuild for password strength
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF800020)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF800020), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
