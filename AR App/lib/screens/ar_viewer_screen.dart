import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ArViewerScreen extends StatefulWidget {
  const ArViewerScreen({super.key});

  @override
  _ArViewerScreenState createState() => _ArViewerScreenState();
}

class _ArViewerScreenState extends State<ArViewerScreen>
    with SingleTickerProviderStateMixin {
  // Remove CameraController related variables
  bool _isLaunching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Define royal maroon colors to maintain consistency
  final Color primaryMaroon = const Color(0xFF800020);
  final Color lightMaroon = const Color(0xFFA04040);
  final Color darkMaroon = const Color(0xFF600010);

  @override
  void initState() {
    super.initState();
    // Remove camera initialization code

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // Remove camera controller disposal
    _animationController.dispose();
    super.dispose();
  }

  // 2. Updated method to launch the AR app with the specific activity
  Future<void> _launchARApp() async {
    setState(() {
      _isLaunching = true;
    });

    try {
      // Package name and component for the AR app
      const String packageName = "com.CE.ARInteriorDesign";
      const String activityName = "com.unity3d.player.UnityPlayerGameActivity";

      // Use the method channel to launch the app
      const MethodChannel channel = MethodChannel('app_launcher');
      bool launched = false;

      try {
        launched = await channel.invokeMethod('launchApp',
                {'package': packageName, 'activity': activityName}) ??
            false;
      } catch (e) {
        print("Method channel failed: $e");
      }

      // If direct activity launch failed, try URL methods
      if (!launched) {
        final Uri uri = Uri.parse("android-app://$packageName/$activityName");

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          final Uri simpleUri = Uri.parse("android-app://$packageName");
          if (await canLaunchUrl(simpleUri)) {
            await launchUrl(simpleUri);
          } else {
            throw 'Could not launch AR app';
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error launching AR app: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "AR Interior Design",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryMaroon.withOpacity(0.9),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightMaroon,
              darkMaroon,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _buildStartScreen(),
        ),
      ),
    );
  }

  // Preview screen after capturing an image
  // Widget _buildImagePreviewScreen() {
  //   return Stack(
  //     fit: StackFit.expand,
  //     children: [
  //       // Image preview with rounded corners
  //       Container(
  //         margin: const EdgeInsets.all(16),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(20),
  //           child: Image.file(
  //             File(_capturedImage!.path),
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //       ),
  //
  //       // Overlay with dark gradient
  //       Positioned(
  //         bottom: 0,
  //         left: 0,
  //         right: 0,
  //         height: 120,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               begin: Alignment.bottomCenter,
  //               end: Alignment.topCenter,
  //               colors: [
  //                 Colors.black.withOpacity(0.7),
  //                 Colors.transparent,
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //
  //       // Buttons for retake or exit preview
  //       Positioned(
  //         bottom: 30,
  //         left: 0,
  //         right: 0,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             // Discard button
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 setState(() => _capturedImage = null);
  //               },
  //               icon: const Icon(Icons.replay),
  //               label: const Text("Retake"),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.white,
  //                 foregroundColor: primaryMaroon,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //               ),
  //             ),
  //
  //             // Save button
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 // Here you would implement saving the image
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text("Image saved"),
  //                     backgroundColor: Colors.green,
  //                     behavior: SnackBarBehavior.floating,
  //                   ),
  //                 );
  //                 _toggleArView();
  //               },
  //               icon: const Icon(Icons.check),
  //               label: const Text("Save"),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: primaryMaroon,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30),
  //                 ),
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Start screen when AR is not active
  Widget _buildStartScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AR logo/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.view_in_ar,
                  size: 70,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Title and description
            const Text(
              "Augmented Reality Viewer",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Experience your furniture in your space before you buy. Place virtual items in your room to see how they fit and look.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Action button - only show the Launch AR App button
            ElevatedButton.icon(
              onPressed: _isLaunching ? null : _launchARApp,
              icon: _isLaunching
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.view_in_ar),
              label: Text(_isLaunching ? "Launching..." : "Launch AR App"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Tips section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Tips for best results:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTipItem("Ensure your space is well-lit"),
                  _buildTipItem("Move your device slowly to scan surfaces"),
                  _buildTipItem("Clear clutter for better surface detection"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? primaryMaroon : Colors.white,
        foregroundColor: isPrimary ? Colors.white : primaryMaroon,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle,
              color: Colors.white.withOpacity(0.7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
