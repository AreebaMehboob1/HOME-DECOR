import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PersonalizedRecommendationsScreen extends StatefulWidget {
  const PersonalizedRecommendationsScreen({super.key});

  @override
  State<PersonalizedRecommendationsScreen> createState() =>
      _PersonalizedRecommendationsScreenState();
}

class _PersonalizedRecommendationsScreenState
    extends State<PersonalizedRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Define royal maroon colors to maintain consistency
  final Color primaryMaroon = const Color(0xFF800020);
  final Color lightMaroon = const Color(0xFFA04040);
  final Color darkMaroon = const Color(0xFF600010);

  // Store recommendation items
  List<RecommendationItem> _recommendations = [];
  List<String> _favoriteIds = [];

  bool _isLoading = true;
  String _searchQuery = 'interior design';
  TextEditingController _searchController = TextEditingController();
  bool _showDetailView = false;
  RecommendationItem? _selectedItem;

  // Unsplash API Key - Replace with your own
  final String _unsplashApiKey = 'bgNDxRwuQgPaLNZ2v9Y24pV2Jzjf4OSv3Fe2kCyloAM';

  String _generateRandomDescription(String originalTitle) {
    // List of adjectives to describe interior elements
    final List<String> adjectives = [
      'elegant',
      'stylish',
      'contemporary',
      'refined',
      'sophisticated',
      'cozy',
      'sleek',
      'luxurious',
      'charming',
      'pristine',
      'stunning',
      'polished',
      'distinctive',
      'harmonious',
      'serene'
    ];

    // List of room types
    final List<String> roomTypes = [
      'living space',
      'interior',
      'home design',
      'living area',
      'room concept',
      'décor style',
      'living environment',
      'interior concept',
      'design idea',
      'home space'
    ];

    // Random object
    final random = Random();

    // Get random adjective and room type
    final adjective = adjectives[random.nextInt(adjectives.length)];
    final roomType = roomTypes[random.nextInt(roomTypes.length)];

    // Keep any color or material mentions from the original title
    final List<String> keywords = originalTitle.toLowerCase().split(' ');
    final List<String> colorsMaterials = [
      'white',
      'black',
      'green',
      'blue',
      'red',
      'yellow',
      'brown',
      'gray',
      'grey',
      'wooden',
      'marble',
      'metal',
      'glass',
      'steel',
      'leather',
      'concrete'
    ];

    final List<String> foundKeywords = [];
    for (final keyword in keywords) {
      if (colorsMaterials.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }

    // Build a randomized description
    String randomDescription =
        '$adjective ${foundKeywords.join(' ')} $roomType';

    // Capitalize first letter
    return randomDescription[0].toUpperCase() + randomDescription.substring(1);
  }

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

    // Set initial value for search controller
    _searchController.text = 'interior design';

    // Fetch initial recommendations
    _fetchRecommendations(_searchQuery);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearchQuery(String query) {
    // If the query is empty, use default
    if (query.trim().isEmpty) {
      query = 'interior design';
    } else {
      query += ' interior design'; // Append interior design to improve results
    }

    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    // Fetch recommendations based on query
    _fetchRecommendations(query);
  }

  Future<void> _fetchRecommendations(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.unsplash.com/search/photos?query=$query&per_page=30'),
        headers: {'Authorization': 'Client-ID $_unsplashApiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        setState(() {
          _recommendations = results
              .map((item) => RecommendationItem.fromUnsplash(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _recommendations = [];
          _isLoading = false;
        });
        print('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _recommendations = [];
        _isLoading = false;
      });
      print('Error fetching recommendations: $e');
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  bool _isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  void _viewItemDetail(RecommendationItem item) {
    setState(() {
      _selectedItem = item;
      _showDetailView = true;
    });
  }

  void _closeDetailView() {
    setState(() {
      _showDetailView = false;
      _selectedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Personalized Recommendations",
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _showDetailView
                ? _buildDetailView()
                : _buildRecommendationGrid(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Search Design Ideas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Type to search (e.g., dark room furniture)',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: primaryMaroon),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: primaryMaroon),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onSubmitted: (value) => _updateSearchQuery(value),
                ),
              ),
              const SizedBox(height: 16),
              // Popular searches suggestions
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSearchSuggestion('Modern'),
                  _buildSearchSuggestion('Minimalist'),
                  _buildSearchSuggestion('Dark room'),
                  _buildSearchSuggestion('Small space'),
                  _buildSearchSuggestion('Bedroom'),
                  _buildSearchSuggestion('Kitchen'),
                ],
              ),
            ],
          ),
        ),

        // Current search query
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Showing results for: "$_searchQuery"',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ),

        // Results
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : _recommendations.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final item = _recommendations[index];
                          return _buildRecommendationCard(item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestion(String label) {
    return InkWell(
      onTap: () {
        _searchController.text = label;
        _updateSearchQuery(label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationItem item) {
    return GestureDetector(
      onTap: () => _viewItemDetail(item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                // Image
                AspectRatio(
                  aspectRatio: item.aspectRatio,
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite(item.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFavorite(item.id) ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title and tags
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryMaroon.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: primaryMaroon,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedItem == null) return Container();

    final item = _selectedItem!;

    // Generate a randomized description title
    final randomizedTitle = _generateRandomDescription(item.title);

    return Column(
      children: [
        // Top bar with back button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _closeDetailView,
              ),
              Expanded(
                child: Text(
                  randomizedTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isFavorite(item.id) ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite(item.id) ? Colors.red : Colors.white,
                ),
                onPressed: () => _toggleFavorite(item.id),
              ),
            ],
          ),
        ),

        // Image and details
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image - improved as per your previous request
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.5,
                  color: Colors.black,
                  child: Hero(
                    tag: 'image_${item.id}',
                    child: CachedNetworkImage(
                      imageUrl: item.fullImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // Details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and description
                      Text(
                        randomizedTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        randomizedTitle.toLowerCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),

                      // Tags
                      if (item.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Style Elements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: item.tags.map((tag) {
                            return InkWell(
                              onTap: () {
                                _closeDetailView();
                                _searchController.text = tag;
                                _updateSearchQuery(tag);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // View in AR button
                      // const SizedBox(height: 32),
                      // Center(
                      //   child: ElevatedButton.icon(
                      //     onPressed: () {
                      //       // Implement AR functionality or navigation to AR app
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(
                      //           content: Text('AR View coming soon!'),
                      //           backgroundColor: primaryMaroon,
                      //         ),
                      //       );
                      //     },
                      //     icon: Icon(Icons.view_in_ar),
                      //     label: Text('View in AR'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.white,
                      //       foregroundColor: primaryMaroon,
                      //       padding: const EdgeInsets.symmetric(
                      //         horizontal: 24,
                      //         vertical: 12,
                      //       ),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(30),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // Source attribution (replaced with Home Decor)
                      const SizedBox(height: 24),
                      Text(
                        'Source:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home Decor',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for recommendation items
class RecommendationItem {
  final String id;
  final String imageUrl;
  final String fullImageUrl;
  final String title;
  final String description;
  final List<String> tags;
  final String photographer;
  final int width;
  final int height;
  final double aspectRatio;

  RecommendationItem({
    required this.id,
    required this.imageUrl,
    required this.fullImageUrl,
    required this.title,
    required this.description,
    required this.tags,
    required this.photographer,
    required this.width,
    required this.height,
    required this.aspectRatio,
  });

  factory RecommendationItem.fromUnsplash(Map<String, dynamic> json) {
    // Extract tags if available
    List<String> tags = [];
    if (json['tags'] != null) {
      tags =
          (json['tags'] as List).map((tag) => tag['title'] as String).toList();
    }

    // Get title and description
    String title = json['description'] ??
        json['alt_description'] ??
        'Interior Design Idea';

    // Format title (capitalize first letter of each word)
    title = title.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');

    // Calculate aspect ratio with fallback
    double aspectRatio = 1.0;
    if (json['width'] != null && json['height'] != null) {
      aspectRatio = json['width'] / json['height'];

      // Constrain extreme aspect ratios
      if (aspectRatio > 2.5) aspectRatio = 2.5;
      if (aspectRatio < 0.4) aspectRatio = 0.4;
    }

    return RecommendationItem(
      id: json['id'] ?? '',
      imageUrl: json['urls']['small'] ?? '',
      fullImageUrl: json['urls']['regular'] ?? '',
      title: title,
      description: json['description'] ?? json['alt_description'] ?? '',
      tags: tags,
      photographer: json['user']['name'] ?? 'Unknown',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      aspectRatio: aspectRatio,
    );
  }
}
