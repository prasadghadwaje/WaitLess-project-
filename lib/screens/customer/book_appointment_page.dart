import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookAppointmentPage extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final String userEmail; // Pass logged-in user's email
  final String userName; // Optional prefill

  const BookAppointmentPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date and time")));
      return;
    }

    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final data = {
      "serviceId": widget.serviceId,
      "serviceName": widget.serviceName,
      "customerName": _nameController.text.trim(),
      "customerEmail": widget.userEmail,
      "phone": _phoneController.text.trim(), // <-- Added phone field
      "date": DateFormat('yyyy-MM-dd').format(appointmentDateTime),
      "time": DateFormat('hh:mm a').format(appointmentDateTime),
      "createdAt": Timestamp.now(),
    };

    try {
      await _firestore.collection("appointments").add(data);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment booked successfully!")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to book appointment: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(widget.serviceName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Your Name", border: OutlineInputBorder()),
                validator: (val) =>
                val!.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: "Phone Number", border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please enter your phone number";
                  } else if (val.length < 10) {
                    return "Enter a valid phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null
                    ? "Select Date"
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                onTap: _pickDate,
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(_selectedTime == null
                    ? "Select Time"
                    : _selectedTime!.format(context)),
                onTap: _pickTime,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAppointment,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.all(16)),
                  child: const Text("Book Appointment",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
