// design_gallery_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  _DesignGalleryScreenState createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  // Primary colors from app theme
  final Color primaryMaroon = Color(0xFF800020);
  final Color lightMaroon = Color(0xFFA04040);
  final Color darkMaroon = Color(0xFF600010);
  final List<DesignInspirationItem> _inspirationItems = [
    DesignInspirationItem(
      imageUrl: "assets/images/inspirations/living_room_1.png",
      title: "Modern Living",
      description: "Clean lines with natural elements and warm accents",
      roomType: "Living Room",
      saved: true,
    ),
    DesignInspirationItem(
      imageUrl: "assets/images/inspirations/bedroom_1.jpg",
      title: "Serene Bedroom",
      description: "Calm retreat with neutral tones and minimal decor",
      roomType: "Bedroom",
      saved: false,
    ),
    DesignInspirationItem(
      imageUrl: "assets/images/inspirations/dining_1.jpg",
      title: "Contemporary Dining",
      description: "Elegant space for entertaining with statement lighting",
      roomType: "Dining Room",
      saved: true,
    ),
    DesignInspirationItem(
      imageUrl: "assets/images/inspirations/office_1.jpg",
      title: "Home Office",
      description: "Productive workspace with ergonomic furniture",
      roomType: "Office",
      saved: false,
    ),
    DesignInspirationItem(
      imageUrl: "assets/images/inspirations/kitchen_1.jpg",
      title: "Gourmet Kitchen",
      description: "Chef-inspired kitchen with premium appliances",
      roomType: "Kitchen",
      saved: false,
    ),
  ];

  final List<String> _categories = [
    "All",
    "Living Room",
    "Bedroom",
    "Dining Room",
    "Kitchen",
    "Office"
  ];
  String _selectedCategory = "All";
  bool _showSavedOnly = false;

  Future<void> _launchExternalARApp() async {
    try {
      // Package name and activity for the AR app
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
      print('Error launching AR app: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'AR app not found. Please install the AR Interior Design app.'),
          backgroundColor: primaryMaroon,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Design Gallery",
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
            icon: Icon(_showSavedOnly ? Icons.favorite : Icons.favorite_border,
                color: Colors.white),
            onPressed: () {
              setState(() {
                _showSavedOnly = !_showSavedOnly;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkMaroon, primaryMaroon, lightMaroon],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Category Filter Tabs
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = _categories[index];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategory == _categories[index]
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: _selectedCategory == _categories[index]
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Inspiration Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: _inspirationItems
                        .where((item) =>
                            (_selectedCategory == "All" ||
                                item.roomType == _selectedCategory) &&
                            (!_showSavedOnly || item.saved))
                        .length,
                    itemBuilder: (context, index) {
                      final filteredItems = _inspirationItems
                          .where((item) =>
                              (_selectedCategory == "All" ||
                                  item.roomType == _selectedCategory) &&
                              (!_showSavedOnly || item.saved))
                          .toList();

                      return _buildInspirationCard(filteredItems[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryMaroon,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Implement upload custom inspiration
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload your own inspiration coming soon!'),
              backgroundColor: lightMaroon,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInspirationCard(DesignInspirationItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Stack(
              children: [
                // Background Color
                Positioned.fill(
                  child: Container(
                    color: darkMaroon.withOpacity(0.3),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryMaroon.withOpacity(0.4),
                      image: DecorationImage(
                        image: AssetImage(item.imageUrl),
                        fit: BoxFit.cover,
                        opacity: 0.9,
                      ),
                    ),
                    // Fallback in case the image fails to load
                    child: Builder(
                      builder: (context) {
                        try {
                          // Check if asset exists - this is just to trigger the error handling
                          precacheImage(AssetImage(item.imageUrl), context);
                          return Container();
                        } catch (e) {
                          print('Error loading image: $e');
                          return Center(
                            child: Icon(
                              _getIconForRoomType(item.roomType),
                              size: 80,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),

                // Details Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.roomType,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _launchExternalARApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryMaroon,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text("View in AR"),
                            ),
                            IconButton(
                              icon: Icon(
                                item.saved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  item.saved = !item.saved;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForRoomType(String roomType) {
    switch (roomType) {
      case "Living Room":
        return Icons.weekend;
      case "Bedroom":
        return Icons.bed;
      case "Dining Room":
        return Icons.table_restaurant;
      case "Kitchen":
        return Icons.kitchen;
      case "Office":
        return Icons.computer;
      case "Outdoor":
        return Icons.deck;
      default:
        return Icons.home;
    }
  }
}

class DesignInspirationItem {
  final String imageUrl;
  final String title;
  final String description;
  final String roomType;
  bool saved;

  DesignInspirationItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.roomType,
    this.saved = false,
  });
}
