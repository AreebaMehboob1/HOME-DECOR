import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _name = "";
  String _email = "";
  String _phoneNumber = "";
  String _address = "";
  bool _isLoading = true;
  bool _isEditMode = false;
  SharedPreferences? _prefs;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Color constants to match app theme
  final Color primaryMaroon = Color(0xFF800020);
  final Color lightMaroon = Color(0xFFA04040);
  final Color darkMaroon = Color(0xFF600010);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          // Safely get data with null checks
          final userData = userDoc.data() as Map<String, dynamic>? ?? {};

          setState(() {
            _name = userData['name'] ?? user.displayName ?? "No Name";
            _email = userData['email'] ?? user.email ?? "No Email";

            // Safely check if fields exist before accessing them
            _phoneNumber = userData.containsKey('phoneNumber')
                ? userData['phoneNumber'] ?? "Not provided"
                : "Not provided";

            _address = userData.containsKey('address')
                ? userData['address'] ?? "Not provided"
                : "Not provided";

            // Set controller values
            _nameController.text = _name;
            _phoneController.text = _phoneNumber;
            _addressController.text = _address;

            _isLoading = false;
          });
        } else {
          // Create user document if it doesn't exist
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? "User",
            'email': user.email,
            'phoneNumber': "",
            'address': "",
            'emailVerified': user.emailVerified,
            'createdAt': FieldValue.serverTimestamp(),
          });

          setState(() {
            _name = user.displayName ?? "User";
            _email = user.email ?? "No Email";
            _phoneNumber = "Not provided";
            _address = "Not provided";

            // Set controller values
            _nameController.text = _name;
            _phoneController.text = _phoneNumber;
            _addressController.text = _address;

            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        // Handle error gracefully
        setState(() {
          _name = user.displayName ?? "User";
          _email = user.email ?? "No Email";
          _phoneNumber = "Not provided";
          _address = "Not provided";

          // Set controller values
          _nameController.text = _name;
          _phoneController.text = _phoneNumber;
          _addressController.text = _address;

          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Try to update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phoneNumber': _phoneController.text,
          'address': _addressController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Firestore update error: $e");
        // Continue even if Firestore update fails
      }

      // Update local state regardless of Firestore success
      setState(() {
        _name = _nameController.text;
        _phoneNumber = _phoneController.text;
        _address = _addressController.text;
        _isEditMode = false;
        _isLoading = false;
      });

      // Try to update Firebase Auth displayName if possible
      try {
        await user.updateDisplayName(_nameController.text);
      } catch (e) {
        print("Failed to update displayName: $e");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: lightMaroon,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryMaroon)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Use the AuthService to sign out
                await authService.signOut();

                // Close the dialog first
                Navigator.pop(context);

                // Navigate to login screen and clear the stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                // Handle any errors
                print("Error during logout: $e");
                // Close the dialog
                Navigator.pop(context);
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Logout failed. Please try again."),
                  backgroundColor: Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaroon,
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryMaroon,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit,
                color: Colors.white),
            onPressed: _isEditMode ? _updateUserData : _toggleEditMode,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkMaroon, primaryMaroon, lightMaroon],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Glassmorphism Pattern Overlay
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white10, Colors.white.withOpacity(0.05)],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryMaroon.withOpacity(0.5),
                      darkMaroon.withOpacity(0.8)
                    ],
                  ),
                ),
              ),
            ),
          ),

          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: EdgeInsets.only(top: 120, bottom: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile Avatar with Glass Effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15),
                          ],
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: primaryMaroon.withOpacity(0.5),
                          child:
                              Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),

                      // User Name
                      Text(
                        _name,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 5),

                      // User Email
                      Text(
                        _email,
                        style: TextStyle(
                            fontSize: 18, color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(height: 40),

                      // Profile Info Card with Glassmorphism
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  _isEditMode
                                      ? _buildEditableProfileField(
                                          Icons.person, "Name", _nameController)
                                      : _buildProfileDetail(
                                          Icons.person, "Name", _name),
                                  Divider(color: Colors.white.withOpacity(0.3)),
                                  _buildProfileDetail(
                                      Icons.email, "Email", _email),
                                  Divider(color: Colors.white.withOpacity(0.3)),
                                  _isEditMode
                                      ? _buildEditableProfileField(Icons.phone,
                                          "Phone", _phoneController)
                                      : _buildProfileDetail(
                                          Icons.phone, "Phone", _phoneNumber),
                                  Divider(color: Colors.white.withOpacity(0.3)),
                                  _isEditMode
                                      ? _buildEditableProfileField(
                                          Icons.location_on,
                                          "Address",
                                          _addressController)
                                      : _buildProfileDetail(Icons.location_on,
                                          "Address", _address),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),

                      // Recent Activities Card
                      if (!_isEditMode) ...[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Recent Activities",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _buildActivityItem(
                                        Icons.chair,
                                        "Viewed Modern Sofa",
                                        "Today, 10:25 AM"),
                                    _buildActivityItem(
                                        Icons.table_restaurant,
                                        "Added Coffee Table to Favorites",
                                        "Yesterday, 3:45 PM"),
                                    _buildActivityItem(
                                        Icons.weekend,
                                        "Used AR to view Lounge Chair",
                                        "Apr 21, 2025"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],

                      // Settings Buttons
                      if (!_isEditMode) ...[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              _buildSettingsButton(
                                Icons.favorite_border,
                                "My Favorites",
                                () {
                                  // Navigate to favorites
                                },
                              ),
                              SizedBox(height: 10),
                              _buildSettingsButton(
                                Icons.history,
                                "View History",
                                () {
                                  // Navigate to history
                                },
                              ),
                              SizedBox(height: 10),
                              _buildSettingsButton(
                                Icons.settings,
                                "App Settings",
                                () {
                                  // Navigate to settings
                                },
                              ),
                              SizedBox(height: 10),
                              _buildSettingsButton(
                                Icons.help_outline,
                                "Help & Support",
                                () {
                                  // Navigate to help
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                      ],

                      // Logout Button
                      if (!_isEditMode)
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout, color: Colors.white),
                          label: Text("Logout",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryMaroon,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 5,
                          ),
                        ),

                      if (_isEditMode) ...[
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Text("Cancel",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _updateUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryMaroon,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              child: Text("Save Changes",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // Profile Detail Row Widget
  Widget _buildProfileDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Editable Profile Field Widget
  Widget _buildEditableProfileField(
      IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Activity Item Widget
  Widget _buildActivityItem(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightMaroon.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                      fontSize: 12, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Settings Button Widget
  Widget _buildSettingsButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
