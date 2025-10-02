import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class FindYourLocation extends StatefulWidget {
  const FindYourLocation({super.key});

  @override
  State<FindYourLocation> createState() => _FindYourLocationState();
}

class _FindYourLocationState extends State<FindYourLocation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedCountry;
  String? selectedState;
  String? selectedDistrict;
  Map<String, dynamic>? selectedSpotData;

  List<String> countries = ['India'];
  List<String> states = [];
  List<String> districts = [];
  List<Map<String, dynamic>> spots = [];
  List<Map<String, dynamic>> filteredSpots = [];

  TextEditingController searchController = TextEditingController();

  // Why Choose Us Horizontal Scroll
  final PageController _whyChooseController = PageController(viewportFraction: 0.75);
  int _whyChooseIndex = 0;
  Timer? _whyChooseTimer;

  final List<Map<String, String>> whyChooseUs = [
    {"title": "Best Spots", "subtitle": "Curated top destinations.", "icon": "🏞️"},
    {"title": "Easy Navigation", "subtitle": "Find spots effortlessly.", "icon": "🧭"},
    {"title": "Trusted Reviews", "subtitle": "Verified feedback.", "icon": "⭐"},
    {"title": "Travel Deals", "subtitle": "Exclusive discounts.", "icon": "💰"},
    {"title": "24/7 Support", "subtitle": "Always here to help.", "icon": "📞"},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _fetchPopularSpots();
  }

  @override
  void dispose() {
    _whyChooseController.dispose();
    _whyChooseTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _whyChooseTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_whyChooseController.hasClients) {
        _whyChooseIndex++;
        if (_whyChooseIndex >= whyChooseUs.length) _whyChooseIndex = 0;
        _whyChooseController.animateToPage(
          _whyChooseIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchPopularSpots() async {
    final querySnapshot = await _firestore.collection('tourist_spots').limit(6).get();
    final spotList = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      spots = spotList;
      filteredSpots = List.from(spotList);
    });
  }

  Future<void> fetchStates() async {
    if (selectedCountry == null) return;
    final querySnapshot = await _firestore
        .collection('tourist_spots')
        .where('country', isEqualTo: selectedCountry)
        .get();
    final allStates = querySnapshot.docs.map((doc) => doc['state'] as String).toSet().toList();
    setState(() {
      states = allStates;
      selectedState = null;
      districts = [];
      selectedDistrict = null;
      searchController.clear();
    });
  }

  Future<void> fetchDistricts() async {
    if (selectedState == null) return;
    final querySnapshot = await _firestore
        .collection('tourist_spots')
        .where('country', isEqualTo: selectedCountry)
        .where('state', isEqualTo: selectedState)
        .get();
    final allDistricts = querySnapshot.docs.map((doc) => doc['district'] as String).toSet().toList();
    setState(() {
      districts = allDistricts;
      selectedDistrict = null;
      searchController.clear();
    });
  }

  Future<void> fetchSpots() async {
    if (selectedDistrict == null) return;
    final querySnapshot = await _firestore
        .collection('tourist_spots')
        .where('country', isEqualTo: selectedCountry)
        .where('state', isEqualTo: selectedState)
        .where('district', isEqualTo: selectedDistrict)
        .get();
    final spotList = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      spots = spotList;
      filteredSpots = List.from(spotList);
      selectedSpotData = null; // Reset selected spot
    });
  }

  void filterSpots(String query) {
    final filtered = spots.where((spot) {
      final name = spot['spot_name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredSpots = filtered;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }

  Widget buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget buildSpotCard(Map<String, dynamic> spot) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSpotData = spot;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade300, Colors.purple.shade100]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.purple.shade100.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            const Icon(Icons.place, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                spot['spot_name'],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget buildWhyChooseUs() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _whyChooseController,
        itemCount: whyChooseUs.length,
        itemBuilder: (context, index) {
          final item = whyChooseUs[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors:[
               // Color(0xFF7B3F00), // Dark Burnt Orange (depth)
                Color(0xFFD35400), // Rich Premium Orange
                Color(0xFFFFD580), // Very light silver/white for shine
              ],),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.orange.shade200.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['icon']!, style: const TextStyle(fontSize: 38)),
                const SizedBox(height: 8),
                Text(item['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(item['subtitle']!, style: const TextStyle(fontSize: 14)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange
          ),
          onPressed: () => _launchURL(selectedSpotData!['description_link']),
          icon: const Icon(Icons.info_outline),
          label: const Text("See Description",style: TextStyle(color: Colors.white),),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent
          ),
          onPressed: () => _launchURL(selectedSpotData!['location_link']),
          icon: const Icon(Icons.map),
          label: const Text("Find Location",style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => selectedSpotData = null),
          child: const Text("Choose Another Spot", style: TextStyle(color: Colors.blueAccent)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool formCompleted = selectedCountry != null && selectedState != null && selectedDistrict != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Destination", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildWhyChooseUs(),
              const SizedBox(height: 40),
              Center(child: Text("Find Your Location Here...", style: TextStyle(color: Colors.black, fontSize: 18))),
              const SizedBox(height: 20),

              // Dropdowns
              buildDropdown("Select Country", selectedCountry, countries, (value) async {
                selectedCountry = value;
                await fetchStates();
              }),
              const SizedBox(height: 16),
              if (states.isNotEmpty)
                buildDropdown("Select State", selectedState, states, (value) async {
                  selectedState = value;
                  await fetchDistricts();
                }),
              const SizedBox(height: 16),
              if (districts.isNotEmpty)
                buildDropdown("Select District", selectedDistrict, districts, (value) async {
                  selectedDistrict = value;
                  await fetchSpots();
                }),
              const SizedBox(height: 24),

              // Search & Spot List
              if (formCompleted && spots.isNotEmpty && selectedSpotData == null)
                Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search Spots...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(width: 1),
                        ),
                      ),
                      onChanged: filterSpots,
                    ),
                    const SizedBox(height: 16),
                    ...filteredSpots.map((spot) => buildSpotCard(spot)).toList(),
                  ],
                ),

              // Spot Buttons
              if (selectedSpotData != null) buildButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.lightBlue, // same color
        child: SizedBox(
          height: 60, // height of empty bar
        ),
      ),
    );
  }
}
