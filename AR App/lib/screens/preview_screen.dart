import 'package:flutter/material.dart';
import 'dart:io';

class PreviewScreen extends StatelessWidget {
  final String imagePath; // Path of the captured image

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Preview"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.cover),

          // Buttons at the bottom
          Positioned(
            bottom: 20,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Retake Button
                FloatingActionButton(
                  onPressed: () => Navigator.pop(context, false),
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.replay),
                ),

                // Confirm Button
                FloatingActionButton(
                  onPressed: () => Navigator.pop(context, true),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
