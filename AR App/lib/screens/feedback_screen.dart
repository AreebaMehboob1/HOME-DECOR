import 'package:flutter/material.dart';
import 'dart:ui';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of FAQ items with questions and answers
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: "How does AR furniture placement work?",
      answer: "Our app uses your device's camera to scan your room and detect flat surfaces like floors and tables. Once detected, you can select furniture from our catalog and place it virtually in your space. The AR technology ensures the furniture appears at the correct scale and perspective, giving you a realistic preview of how it would look in your home."
    ),
    FAQItem(
      question: "Can I adjust the size of furniture items?",
      answer: "Yes, you can adjust the size of furniture items to match your space requirements. Simply use the pinch gesture to scale the item larger or smaller. Note that our app maintains the proportions of the furniture to ensure a realistic representation."
    ),
    FAQItem(
      question: "Why isn't the AR camera detecting my floor?",
      answer: "For optimal surface detection, ensure your area is well-lit and the floor has some visual texture or features. Completely blank, reflective, or very dark surfaces may be difficult for the camera to detect. Try moving your device slowly to help the camera scan the environment properly."
    ),
    FAQItem(
      question: "How do I save my AR designs?",
      answer: "To save your AR design, use the camera button in the AR viewer to take a screenshot. Your designs will be saved in the 'My Designs' section of your profile. You can also share these images directly from the app to social media or via email."
    ),
    FAQItem(
      question: "Can I place multiple furniture items in one scene?",
      answer: "Yes, you can place multiple items in a single AR scene. Simply add one item, position it where you want, then return to the catalog to select another item. This allows you to design complete room layouts with various furniture pieces."
    ),
    FAQItem(
      question: "How accurate are the furniture dimensions?",
      answer: "All furniture models are created to scale based on the actual product dimensions. While the AR placement provides a very good approximation, we recommend checking the exact product measurements (available in the product details) for perfect fitting."
    ),
    FAQItem(
      question: "Can I change the color or material of furniture in AR view?",
      answer: "Yes, many of our furniture items offer multiple finish options. When viewing an item in AR, tap on it to bring up the properties panel, then select from available color and material options to see how different variations look in your space."
    ),
    FAQItem(
      question: "My furniture appears to be floating. How do I fix this?",
      answer: "If furniture appears to be floating above the floor, try resetting the AR session by tapping the refresh icon. Also, ensure you're placing items on a detected surface (highlighted with dots or grid). For more precise placement, use the height adjustment slider that appears when you select a placed item."
    ),
    FAQItem(
      question: "Can I use this app without enabling camera access?",
      answer: "The AR features require camera access to function properly. However, you can still browse our furniture catalog and view 3D models without the AR placement functionality if you prefer not to enable camera access."
    ),
    FAQItem(
      question: "How do I measure my space using the app?",
      answer: "Our app includes a built-in measurement tool. In the AR view, tap the measuring tool icon, then place points on the screen to measure distances between objects or wall lengths. This can help you determine if furniture will fit in your space before placing items."
    ),
  ];

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
          'Frequently Asked Questions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryMaroon.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                // Header section with search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Have questions?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Find answers to commonly asked questions about using our AR furniture app.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search for answers...",
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // FAQ list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _faqItems.length,
                    itemBuilder: (context, index) {
                      return _buildFAQItem(_faqItems[index], index);
                    },
                  ),
                ),

                // Support contact section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Column(
                        children: [
                          const Text(
                            "Can't find what you're looking for?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Contact support action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mail_outline, size: 18),
                                SizedBox(width: 8),
                                Text("Contact Support"),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFAQItem(FAQItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              colorScheme: ColorScheme.dark(
                surface: Colors.transparent,
                primary: Colors.white,
                secondary: const Color(0xFF800020),
              ),
            ),
            child: ExpansionTile(
              title: Text(
                item.question,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF800020).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white70,
              children: [
                Text(
                  item.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Model class for FAQ items
class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}