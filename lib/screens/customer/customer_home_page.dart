import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waitless1_3/screens/customer/service_detail_page.dart';
import '../roll_selection_page.dart';
import 'package:waitless1_3/widgets/category_tile.dart';
import 'appointments_page.dart';
import 'profile_page.dart';

class CustomerHomePage extends StatefulWidget {
  final String userEmail; // Logged-in user's email
  final String userUid;   // Logged-in user's UID

  const CustomerHomePage({
    super.key,
    required this.userEmail,
    required this.userUid,
  });

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String? selectedCategory;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'local_hospital':
        return Icons.local_hospital;
      case 'build':
        return Icons.build_circle_outlined;
      case 'brush':
        return Icons.content_cut;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'hotel':
        return Icons.hotel;
      case 'account_balance':
        return Icons.account_balance;
      case 'flight_takeoff':
        return Icons.travel_explore;
      default:
        return Icons.miscellaneous_services;
    }
  }

  List<Widget> _pages() => [
    _homePageWidget(),
    AppointmentsPage(userEmail: widget.userEmail, userUid: widget.userUid),
    ProfilePage(userEmail: widget.userEmail, uid: widget.userUid),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _homePageWidget() {
    return Column(
      children: [
        // 🔹 Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: (val) {
              setState(() {
                searchQuery = val.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search for services...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // 🔹 Categories Horizontal List
        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final category = docs[index];
                  final name = category['name'];
                  final color = Color(int.parse(category['color']));
                  final iconName = category['icon'];
                  final isSelected = selectedCategory == name;

                  return CategoryTile(
                    title: name,
                    icon: _getIcon(iconName),
                    color: color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedCategory = name;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Services List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: (selectedCategory == null)
                ? FirebaseFirestore.instance.collection('services').snapshots()
                : FirebaseFirestore.instance
                .collection('services')
                .where('category', isEqualTo: selectedCategory)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs
                  .where((doc) =>
                  doc['name'].toString().toLowerCase().contains(searchQuery))
                  .toList();

              if (docs.isEmpty) return const Center(child: Text("No services found"));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final service = docs[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: const Icon(Icons.store, color: Colors.blue),
                      ),
                      title: Text(service['name']),
                      subtitle: Text(service['address']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailPage(
                              serviceId: service.id,
                              userName: widget.userEmail,
                              userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          "Visitor Dashboard",
          style: TextStyle(
              fontWeight: FontWeight.w500, fontSize: 22, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.swap_horiz),
            tooltip: "Switch Dashboard",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleSelectionPage(
                    uid: widget.userUid,
                    email: widget.userEmail,
                  ),
                ),
              );
            },
          ),

        ],
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlue,
        currentIndex: _selectedIndex,

        selectedItemColor: Colors.black,    // Color for selected item
        unselectedItemColor: Colors.black,  // Color for unselected items
        showUnselectedLabels: true,
        onTap: _onNavTap,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event_available), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
