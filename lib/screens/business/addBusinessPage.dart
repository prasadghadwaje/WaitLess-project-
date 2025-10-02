import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBusinessPage extends StatefulWidget {
  final String businessUid;

  const AddBusinessPage({super.key, required this.businessUid});

  @override
  State<AddBusinessPage> createState() => _AddBusinessPageState();
}

class _AddBusinessPageState extends State<AddBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? _category;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timingController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final List<String> _categories = [
    "Hospitality",
    "Salons & Beauty Parlors",
    "Garage & Service Stations",
    "Personal Appointments",
    "Retail & Shops",
    "Healthcare & Clinics",
    "Educational Services",
    "Other"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _timingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitBusiness() async {
    if (_formKey.currentState!.validate() && _category != null) {
      await FirebaseFirestore.instance.collection('services').add({
        "address": _addressController.text.trim(),
        "category": _category!,
        "contact": _contactController.text.trim(),
        "description": _descriptionController.text.trim(),
        "email": _emailController.text.trim(),
        "latitude": _latitudeController.text.trim(),
        "longitude": _longitudeController.text.trim(),
        "name": _nameController.text.trim(),
        "timing": _timingController.text.trim(),
        "businessUid": widget.businessUid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Business added successfully!")),
      );

      Navigator.pop(context);
    } else if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category.")),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Business"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: "Business Name",
                validator: (value) =>
                value == null || value.isEmpty ? "Enter business name" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                value: _category,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _category = val),
                validator: (value) =>
                value == null ? "Please select a category" : null,
              ),
              _buildTextField(
                controller: _addressController,
                label: "Address",
                validator: (value) =>
                value == null || value.isEmpty ? "Enter address" : null,
              ),
              _buildTextField(
                controller: _contactController,
                label: "Contact Number",
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? "Enter contact number" : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                maxLines: 3,
              ),
              _buildTextField(
                controller: _timingController,
                label: "Timing (e.g., 10:00 AM - 8:00 PM)",
                validator: (value) =>
                value == null || value.isEmpty ? "Enter timing" : null,
              ),
              _buildTextField(
                controller: _latitudeController,
                label: "Latitude",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _longitudeController,
                label: "Longitude",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBusiness,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "Add Business",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
