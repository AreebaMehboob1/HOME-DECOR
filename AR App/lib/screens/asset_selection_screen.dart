import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class AssetSelectionScreen extends StatefulWidget {
  const AssetSelectionScreen({super.key});

  @override
  State<AssetSelectionScreen> createState() => _AssetSelectionScreenState();
}

class _AssetSelectionScreenState extends State<AssetSelectionScreen>
    with SingleTickerProviderStateMixin {
  // Asset Categories
  final Map<String, List<AssetItem>> categories = {
    "Beds": [
      AssetItem("assets/images/bed/bed 1.png", "Modern King",
          "Contemporary design with plush upholstery"),
      AssetItem("assets/images/bed/bed 2.png", "Classic Queen",
          "Elegant wooden frame with carved details"),
      AssetItem("assets/images/bed/bed 3.png", "Minimalist Double",
          "Clean lines with integrated storage"),
      AssetItem("assets/images/bed/bed 4.png", "Platform Bed",
          "Low profile with wooden slats"),
      AssetItem("assets/images/bed/bed 5.png", "Canopy Bed",
          "Four-poster design with fabric draping"),
    ],
    "Chairs": [
      AssetItem("assets/images/chair/chair 1.png", "Lounge Chair",
          "Ergonomic design with premium leather"),
      AssetItem("assets/images/chair/chair 2.png", "Dining Chair",
          "Sophisticated profile with wooden legs"),
      AssetItem("assets/images/chair/chair 3.png", "Accent Chair",
          "Statement piece with vibrant upholstery"),
      AssetItem("assets/images/chair/chair 4.png", "Office Chair",
          "Adjustable height with lumbar support"),
      AssetItem("assets/images/chair/chair 5.png", "Rocking Chair",
          "Classic design with curved runners"),
    ],
    "Sofas": [
      AssetItem("assets/images/sofa/sofa 1.png", "Sectional L-Shape",
          "Modular design for flexible arrangements"),
      AssetItem("assets/images/sofa/sofa 2.png", "Three-Seater",
          "Plush cushions with stain-resistant fabric"),
      AssetItem("assets/images/sofa/sofa 3.png", "Convertible Sofa",
          "Transforms into a comfortable bed"),
      AssetItem("assets/images/sofa/sofa 4.png", "Chesterfield",
          "Classic tufted design with rolled arms"),
      AssetItem("assets/images/sofa/sofa 5.png", "Loveseat",
          "Compact two-seater for small spaces"),
    ],
    "Lamps": [
      AssetItem("assets/images/lamp/lamp 1.png", "Floor Lamp",
          "Adjustable height with ambient lighting"),
      AssetItem("assets/images/lamp/lamp 2.png", "Table Lamp",
          "Contemporary design with touch controls"),
      AssetItem("assets/images/lamp/lamp 3.png", "Pendant Light",
          "Modern fixture for overhead lighting"),
      AssetItem("assets/images/lamp/lamp 4.png", "Desk Lamp",
          "Articulated arm with focused task lighting"),
      AssetItem("assets/images/lamp/lamp 5.png", "Wall Sconce",
          "Space-saving design with mood lighting"),
    ],
    "Tables": [
      AssetItem("assets/images/table/table 1.png", "Dining Table",
          "Extendable design for family gatherings"),
      AssetItem("assets/images/table/table 2.png", "Coffee Table",
          "Low profile with storage shelf"),
      AssetItem("assets/images/table/table 3.png", "Side Table",
          "Compact design for small spaces"),
      AssetItem("assets/images/table/table 4.png", "Console Table",
          "Narrow profile for hallways and entryways"),
      AssetItem("assets/images/table/table 5.png", "Desk",
          "Spacious workspace with storage drawers"),
    ],
    "Cabinets": [
      AssetItem("assets/images/cabinets/cab 1.png", "Wardrobe",
          "Tall storage with hanging space and shelves"),
      AssetItem("assets/images/cabinets/cab 2.png", "Sideboard",
          "Low profile storage for dining areas"),
      AssetItem("assets/images/cabinets/cab 3.png", "Bookcase",
          "Open shelving for books and displays"),
      AssetItem("assets/images/cabinets/cab 4.png", "Media Console",
          "Entertainment center with cable management"),
      AssetItem("assets/images/cabinets/cab 5.png", "Chest of Drawers",
          "Vertical storage with multiple drawers"),
    ],
  };

  // Selected category
  String _selectedCategory = "Beds";
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define royal maroon colors
    const Color primaryMaroon = Color(0xFF800020);
    const Color lightMaroon = Color(0xFFA04040);
    const Color darkMaroon = Color(0xFF600010);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Asset Library",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryMaroon.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Search bar and filter

                // Category tabs
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: categories.keys.map((category) {
                      bool isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryMaroon
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
                                width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Asset grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: categories[_selectedCategory]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final asset = categories[_selectedCategory]![index];
                        return _buildAssetCard(context, asset);
                      },
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

  Widget _buildAssetCard(BuildContext context, AssetItem asset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(
              asset: asset,
              allCategories: categories,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Hero(
                          tag: asset.imagePath,
                          child: Image.asset(
                            asset.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Asset name
                  Text(
                    asset.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Asset description
                  Text(
                    asset.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // View details button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF800020),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
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
    );
  }
}

class AssetItem {
  final String imagePath;
  final String name;
  final String description;

  AssetItem(this.imagePath, this.name, this.description);
}

class AssetDetailScreen extends StatefulWidget {
  final AssetItem asset;
  final Map<String, List<AssetItem>>? allCategories;

  const AssetDetailScreen({
    super.key,
    required this.asset,
    this.allCategories,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  late List<AssetItem> _randomItems;

  @override
  void initState() {
    super.initState();
    // Create list of random items from all categories
    _generateRandomItems();

    // Start auto-scrolling after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _startAutoScroll();
    });
  }

  void _generateRandomItems() {
    _randomItems = [];

    // If we have access to all categories, use them
    if (widget.allCategories != null) {
      List<AssetItem> allItems = [];

      // Collect all items from all categories
      widget.allCategories!.forEach((category, items) {
        allItems.addAll(items);
      });

      // Remove the current item
      allItems.removeWhere((item) => item.imagePath == widget.asset.imagePath);

      // Shuffle the items
      allItems.shuffle();

      // Take items for the scroll (or all if fewer than 15)
      _randomItems = allItems.take(min(15, allItems.length)).toList();
    } else {
      // If we don't have all categories, create some sample items
      _randomItems = [
        AssetItem(
            "assets/images/bed/bed 1.png", "Modern Bed", "Contemporary design"),
        AssetItem("assets/images/chair/chair 1.png", "Lounge Chair",
            "Comfortable seating"),
        AssetItem("assets/images/sofa/sofa 1.png", "Sectional Sofa",
            "Modular design"),
        AssetItem(
            "assets/images/lamp/lamp 1.png", "Floor Lamp", "Ambient lighting"),
        AssetItem("assets/images/table/table 1.png", "Dining Table",
            "Extendable design"),
        AssetItem(
            "assets/images/bed/bed 2.png", "Classic Bed", "Traditional style"),
        AssetItem("assets/images/chair/chair 2.png", "Dining Chair",
            "Elegant design"),
        AssetItem(
            "assets/images/lamp/lamp 2.png", "Table Lamp", "Task lighting"),
      ];

      // Remove the current item if it's in our sample list
      _randomItems
          .removeWhere((item) => item.imagePath == widget.asset.imagePath);
    }

    // Duplicate the items to ensure continuous scrolling
    List<AssetItem> duplicatedItems = [
      ..._randomItems,
      ..._randomItems,
      ..._randomItems
    ];
    _randomItems = duplicatedItems;
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        const delta = 0.5; // Slower scrolling speed

        if (currentScroll >= maxScroll) {
          // Reset to beginning when reaching the end
          _scrollController.jumpTo(0);
        } else {
          // Smooth scrolling
          _scrollController.animateTo(
            currentScroll + delta,
            duration: const Duration(milliseconds: 30),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF800020);
    const Color lightMaroon = Color(0xFFA04040);
    const Color darkMaroon = Color(0xFF600010);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AssetSelectionScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              lightMaroon,
              darkMaroon,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top half - image display
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                color: Colors.white.withOpacity(0.1),
                child: Hero(
                  tag: widget.asset.imagePath,
                  child: Image.asset(
                    widget.asset.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Bottom half - details
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Asset name
                        Text(
                          widget.asset.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Asset description
                        Text(
                          widget.asset.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        // Auto-scrolling items section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Explore More Items",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: _buildAutoScrollingItems(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoScrollingItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        itemCount: _randomItems.length,
        itemBuilder: (context, index) {
          final item = _randomItems[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetDetailScreen(
                    asset: item,
                    allCategories: widget.allCategories,
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item image
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.withOpacity(0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white70,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Item name
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
