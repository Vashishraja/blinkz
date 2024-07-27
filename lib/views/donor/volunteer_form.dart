import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VolunteerRegistrationScreen extends StatefulWidget {
  @override
  _VolunteerRegistrationScreenState createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _cityController;
  late DateTime _lastDonationDate = DateTime.now();
  String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _lastDonationDate) {
      setState(() {
        _lastDonationDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: const Text('Volunteer Registration',style: TextStyle(color: Colors.white),),
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildBloodGroupDropdown(),
              const SizedBox(height: 16),
              _buildTextField('Contact', _contactController),
              const SizedBox(height: 16),
              _buildTextField('City', _cityController),
              const SizedBox(height: 16),
              _buildLastDonationDateField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerVolunteer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Register Volunteer',
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((group) => DropdownMenuItem<String>(
        value: group,
        child: Text(group),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedBloodGroup = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Blood Group',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLastDonationDateField() {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Last Donation',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('${_lastDonationDate.year}-${_lastDonationDate.month}-${_lastDonationDate.day}'),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _registerVolunteer() async {
    final response = await Supabase.instance.client.from('volunteer').insert({
      'name': _nameController.text.trim(),
      'b_group': _selectedBloodGroup,
      'contact': _contactController.text.trim(),
      'city': _cityController.text.trim(),
      'last': _lastDonationDate.toString(),
      'donor_id': SessionManager.userId.toString(),
    });
    final donorResponse = await Supabase.instance.client.from('donor').select(
        'points')
        .eq('phone', SessionManager.userId.toString())
        .single();
    final donorData = donorResponse;
    final updateResponse = await Supabase.instance.client.from('donor')
        .update({
      'points': (donorData['points'] ?? 0) + 100,
    }).eq('phone', SessionManager.userId.toString());
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> DonorProfilePage()), (route) => false);
  }
}
