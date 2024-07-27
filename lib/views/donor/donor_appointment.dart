import 'dart:developer';

import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/logo_widget.dart';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late DateTime _lastDonationDate = DateTime.now();
  late String _bloodGroup = 'A+';
  late String _bloodBank;
  late String _timeSlot = '11 am - 1 pm';
  List<Map<String, String>> bloodBankOptions = [];
  late String _selectedBankPhone = '';

  @override
  void initState() {
    super.initState();
    _fetchBloodBanks();
  }

  Future<void> _fetchBloodBanks() async {
    final response = await Supabase.instance.client.from('bank').select();


      setState(() {
        bloodBankOptions = (response as List)
            .map((bank) => {'name': bank['name'] as String, 'phone': bank['phone'] as String})
            .toList();
        if (bloodBankOptions.isNotEmpty) {
          _bloodBank = bloodBankOptions[0]['name']!;
          _selectedBankPhone = bloodBankOptions[0]['phone']!;
        }
      });
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
    if (bloodBankOptions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Lottie.asset('assets/splash.json'),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange.shade400,
          title: const Text('Book Appointment',style: TextStyle(color: Colors.white),),
        ),
        drawer: CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BuildLogo(),
                const SizedBox(height: 16),
                _buildAppointmentForm(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildAppointmentForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildLastDonationDateField(),
          const SizedBox(height: 16),
          _buildBloodGroupDropdown(),
          const SizedBox(height: 16),
          _buildBloodBankDropdown(),
          const SizedBox(height: 16),
          _buildTimeSlotDropdown(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _bookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange.shade400,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Book Appointment',
              style: TextStyle(fontSize: 18,color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastDonationDateField() {
    return InkWell(
      onTap: () {
        _selectDate(context);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Last Donation',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${_lastDonationDate.year}-${_lastDonationDate.month}-${_lastDonationDate.day}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    List<String> bloodGroupOptions = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];

    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: 'Blood Group'),
      value: _bloodGroup,
      onChanged: (newValue) {
        setState(() {
          _bloodGroup = newValue.toString();
        });
      },
      items: bloodGroupOptions.map((bloodGroup) {
        return DropdownMenuItem(
          value: bloodGroup,
          child: Text(bloodGroup),
        );
      }).toList(),
    );
  }

  Widget _buildBloodBankDropdown() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: 'Select Blood Bank'),
      value: _bloodBank.isNotEmpty ? _bloodBank : null,
      onChanged: (newValue) {
        setState(() {
          _bloodBank = newValue.toString();
          _selectedBankPhone = bloodBankOptions
              .firstWhere((bank) => bank['name'] == _bloodBank)['phone']!;
        });
      },
      items: bloodBankOptions.map((bloodBank) {
        return DropdownMenuItem(
          value: bloodBank['name'],
          child: Text(bloodBank['name']!),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotDropdown() {
    List<String> timeSlotOptions = ['11 am - 1 pm', '1 pm - 3 pm', '3 pm - 5 pm'];

    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: 'Select Time Slot'),
      value: _timeSlot,
      onChanged: (newValue) {
        setState(() {
          _timeSlot = newValue.toString();
        });
      },
      items: timeSlotOptions.map((timeSlot) {
        return DropdownMenuItem(
          value: timeSlot,
          child: Text(timeSlot),
        );
      }).toList(),
    );
  }

  Future<void> _bookAppointment() async {
    final response = await Supabase.instance.client.from('appointment').insert({
      'user_id': SessionManager.userId.toString(),
      'last_donation': _lastDonationDate.toString(),
      'bgroup': _bloodGroup,
      'bank': _bloodBank,
      'slot': _timeSlot,
      'bank_id': _selectedBankPhone,
    });

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DonorProfilePage()));
  }
}
