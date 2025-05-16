import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class RoomPlannerScreen extends StatefulWidget {
  const RoomPlannerScreen({super.key});

  @override
  _RoomPlannerScreenState createState() => _RoomPlannerScreenState();
}

class _RoomPlannerScreenState extends State<RoomPlannerScreen>
    with SingleTickerProviderStateMixin {
  // Primary colors from app theme
  final Color primaryMaroon = Color(0xFF800020);
  final Color lightMaroon = Color(0xFFA04040);
  final Color darkMaroon = Color(0xFF600010);

  late TabController _tabController;
  final List<RoomPlan> _savedPlans = [
    RoomPlan(
        name: "Living Room Plan",
        createdDate: "Apr 20, 2025",
        roomType: "Living Room",
        dimensions: "5m x 4m",
        itemCount: 6),
    RoomPlan(
        name: "Master Bedroom",
        createdDate: "Apr 18, 2025",
        roomType: "Bedroom",
        dimensions: "4m x 3.5m",
        itemCount: 4),
    RoomPlan(
        name: "Home Office Setup",
        createdDate: "Apr 15, 2025",
        roomType: "Office",
        dimensions: "3m x 3m",
        itemCount: 5),
  ];

  final List<FloorTemplate> _floorTemplates = [
    FloorTemplate(name: "L-Shaped Living Room", roomType: "Living Room"),
    FloorTemplate(name: "Square Bedroom", roomType: "Bedroom"),
    FloorTemplate(name: "Open Concept Kitchen", roomType: "Kitchen"),
    FloorTemplate(name: "Rectangular Dining", roomType: "Dining Room"),
    FloorTemplate(name: "Small Office Space", roomType: "Office"),
    FloorTemplate(name: "Studio Apartment", roomType: "Studio"),
  ];

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
      // Show error message to user
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          false, // Changed to false to prevent body extending behind AppBar
      appBar: AppBar(
        title: Text(
          "Room Planner",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryMaroon,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48), // Fixed height for tab bar
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: [
              Tab(text: "My Plans"),
              Tab(text: "Templates"),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkMaroon, primaryMaroon, lightMaroon],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // My Plans Tab
            _buildSavedPlansTab(),

            // Templates Tab
            _buildTemplatesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryMaroon,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showCreatePlanDialog(context);
        },
      ),
    );
  }

  Widget _buildSavedPlansTab() {
    return _savedPlans.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.room_preferences,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
                ),
                SizedBox(height: 20),
                Text(
                  "No room plans yet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Create your first room plan",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreatePlanDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Create Plan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _savedPlans.length,
            itemBuilder: (context, index) {
              return _buildRoomPlanCard(_savedPlans[index]);
            },
          );
  }

  Widget _buildTemplatesTab() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8, // Changed from 0.85 to make cards taller
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _floorTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(_floorTemplates[index]);
      },
    );
  }

  Widget _buildRoomPlanCard(RoomPlan plan) {
    return Container(
      margin: EdgeInsets.only(bottom: 10), // Further reduced
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: 10), // Further reduced, asymmetric
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this to minimize height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with plan title and menu
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Ensure alignment
                  children: [
                    Container(
                      padding: EdgeInsets.all(6), // Further reduced
                      decoration: BoxDecoration(
                        color: lightMaroon.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconForRoomType(plan.roomType),
                        color: Colors.white,
                        size: 16, // Further reduced
                      ),
                    ),
                    SizedBox(width: 8), // Further reduced
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Further reduced
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // Prevent line wrapping
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis for long text
                          ),
                          Text(
                            "Created: ${plan.createdDate}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10, // Further reduced
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu button
                    SizedBox(
                      width: 32, // Fixed width
                      height: 32, // Fixed height
                      child: PopupMenuButton(
                        icon: Icon(Icons.more_vert,
                            color: Colors.white, size: 18),
                        color: darkMaroon,
                        padding: EdgeInsets.zero,
                        iconSize: 18, // Explicit size setting
                        splashRadius: 20, // Smaller splash
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            height: 36, // Even smaller
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            height: 36, // Even smaller
                            child: Row(
                              children: [
                                Icon(Icons.copy, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Duplicate',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            height: 36, // Even smaller
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            setState(() {
                              _savedPlans.remove(plan);
                            });
                          } else if (value == 'edit') {
                            _editRoomPlan(plan);
                          } else if (value == 'duplicate') {
                            _duplicateRoomPlan(plan);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8), // Further reduced
                // Info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn("Room Type", plan.roomType),
                    _buildInfoColumn("Dimensions", plan.dimensions),
                    _buildInfoColumn("Items", plan.itemCount.toString()),
                  ],
                ),
                SizedBox(height: 8), // Further reduced
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: "Edit",
                        icon: Icons.edit,
                        onTap: () {
                          _editRoomPlan(plan);
                        },
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: _buildActionButton(
                        label: "AR View",
                        icon: Icons.view_in_ar,
                        primary: true,
                        onTap: () {
                          _launchExternalARApp();
                        },
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: _buildActionButton(
                        label: "Share",
                        icon: Icons.share,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Sharing functionality coming soon!'),
                              backgroundColor: lightMaroon,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(FloorTemplate template) {
    return Container(
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
            mainAxisSize: MainAxisSize.min, // Ensure minimum height
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Template Icon
              Container(
                padding: EdgeInsets.all(12), // Reduced from 15
                decoration: BoxDecoration(
                  color: lightMaroon.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForRoomType(template.roomType),
                  color: Colors.white,
                  size: 32, // Reduced from 40
                ),
              ),
              SizedBox(height: 8), // Reduced from 12

              // Template Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  template.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Reduced from 16
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4),

              // Room Type Tag
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2), // Reduced vertical padding
                decoration: BoxDecoration(
                  color: primaryMaroon.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  template.roomType,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10, // Reduced from 12
                  ),
                ),
              ),
              SizedBox(height: 8), // Reduced from 12

              // Use Template Button - made smaller
              SizedBox(
                height: 30, // Fixed height
                width: 110, // Fixed width
                child: ElevatedButton(
                  onPressed: () {
                    _createPlanFromTemplate(template);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4), // Reduced padding
                    minimumSize: Size.zero, // Allow smaller sizes
                    tapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // Reduce tap target size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Use Template",
                    style: TextStyle(fontSize: 12), // Smaller text
                  ),
                ),
              ),
              SizedBox(height: 4), // Add bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Added this to prevent expansion
        children: [
          Container(
            padding: EdgeInsets.all(8), // Reduced from 10
            decoration: BoxDecoration(
              color: primary ? primaryMaroon : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10), // Reduced from 12
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18, // Reduced from 20
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center, // Ensures centered text
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context) {
    String planName = "";
    String selectedRoomType = "Living Room";
    List<String> roomTypes = [
      "Living Room",
      "Bedroom",
      "Kitchen",
      "Dining Room",
      "Office",
      "Bathroom",
      "Other"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkMaroon, primaryMaroon],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create New Room Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    planName = value;
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Plan Name",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRoomType,
                  onChanged: (value) {
                    selectedRoomType = value!;
                  },
                  dropdownColor: darkMaroon,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Room Type",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  items: roomTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (planName.isNotEmpty) {
                          setState(() {
                            _savedPlans.add(
                              RoomPlan(
                                name: planName,
                                createdDate: "Apr 23, 2025",
                                roomType: selectedRoomType,
                                dimensions: "0m x 0m",
                                itemCount: 0,
                              ),
                            );
                          });
                          Navigator.pop(context);

                          // Navigate to edit room plan screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Room plan created! Now you can add dimensions and furniture.'),
                              backgroundColor: lightMaroon,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please enter a name for your plan'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryMaroon,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Create"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editRoomPlan(RoomPlan plan) {
    String planName = plan.name;
    String roomType = plan.roomType;
    String dimensions = plan.dimensions;

    TextEditingController nameController =
        TextEditingController(text: planName);
    TextEditingController dimensionsController =
        TextEditingController(text: dimensions);

    List<String> roomTypes = [
      "Living Room",
      "Bedroom",
      "Kitchen",
      "Dining Room",
      "Office",
      "Bathroom",
      "Other"
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkMaroon, primaryMaroon],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Room Plan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Plan Name",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: roomType,
                  onChanged: (value) {
                    roomType = value!;
                  },
                  dropdownColor: darkMaroon,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Room Type",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  items: roomTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: dimensionsController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Dimensions (e.g., 4m x 3m)",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final index = _savedPlans.indexOf(plan);
                          if (index != -1) {
                            setState(() {
                              _savedPlans[index] = RoomPlan(
                                name: nameController.text,
                                createdDate: plan.createdDate,
                                roomType: roomType,
                                dimensions: dimensionsController.text,
                                itemCount: plan.itemCount,
                              );
                            });
                          }
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room plan updated successfully!'),
                              backgroundColor: lightMaroon,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Plan name cannot be empty'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryMaroon,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _duplicateRoomPlan(RoomPlan plan) {
    setState(() {
      _savedPlans.add(
        RoomPlan(
          name: "${plan.name} (Copy)",
          createdDate: "Apr 23, 2025",
          roomType: plan.roomType,
          dimensions: plan.dimensions,
          itemCount: plan.itemCount,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room plan duplicated successfully!'),
        backgroundColor: lightMaroon,
      ),
    );
  }

  void _createPlanFromTemplate(FloorTemplate template) {
    setState(() {
      _savedPlans.add(
        RoomPlan(
          name: "New ${template.name}",
          createdDate: "Apr 23, 2025",
          roomType: template.roomType,
          dimensions: _getDefaultDimensions(template.roomType),
          itemCount: 0,
        ),
      );
    });

    _tabController.animateTo(0); // Switch to My Plans tab

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.name} created! Now you can customize it.'),
        backgroundColor: lightMaroon,
      ),
    );
  }

  String _getDefaultDimensions(String roomType) {
    switch (roomType) {
      case "Living Room":
        return "5m x 4m";
      case "Bedroom":
        return "4m x 3.5m";
      case "Kitchen":
        return "3.5m x 3m";
      case "Dining Room":
        return "3.5m x 3.5m";
      case "Office":
        return "3m x 3m";
      case "Bathroom":
        return "2.5m x 2m";
      default:
        return "4m x 4m";
    }
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
      case "Bathroom":
        return Icons.bathtub;
      case "Studio":
        return Icons.apartment;
      default:
        return Icons.home;
    }
  }
}

class RoomPlan {
  final String name;
  final String createdDate;
  final String roomType;
  final String dimensions;
  final int itemCount;

  RoomPlan({
    required this.name,
    required this.createdDate,
    required this.roomType,
    required this.dimensions,
    required this.itemCount,
  });
}

class FloorTemplate {
  final String name;
  final String roomType;

  FloorTemplate({
    required this.name,
    required this.roomType,
  });
}
