import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestBloodPage extends StatefulWidget {
  @override
  _RequestBloodPageState createState() => _RequestBloodPageState();
}

class _RequestBloodPageState extends State<RequestBloodPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  String? _bloodGroup;
  String? _bloodBank;
  DateTime? _requiredDate;
  List<String> _bloodBankOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchBloodBanks();
  }

  Future<void> _fetchBloodBanks() async {
    final response = await Supabase.instance.client.from('bank').select('name');


      setState(() {
        _bloodBankOptions = (response as List).map((bank) => bank['name'] as String).toList();
        if (_bloodBankOptions.isNotEmpty) {
          _bloodBank = _bloodBankOptions[0];
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if(_bloodBankOptions.isEmpty){
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/splash.json'
          ),
        ),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange.shade400,
          title: Text('Request Blood', style: TextStyle(color: Colors.white)),
        ),
        drawer: CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _bloodGroup,
                  decoration: InputDecoration(labelText: 'Blood Group'),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((group) =>
                      DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _bloodGroup = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a blood group';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _hospitalNameController,
                  decoration: InputDecoration(labelText: 'Hospital Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the hospital name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _bloodBank,
                  decoration: InputDecoration(labelText: 'Blood Bank Name'),
                  items: _bloodBankOptions
                      .map((bank) =>
                      DropdownMenuItem<String>(
                        value: bank,
                        child: Text(bank),
                      ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _bloodBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a blood bank';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the contact number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  _requiredDate == null
                      ? 'Select Required Date'
                      : 'Required Date: ${DateFormat('yyyy-MM-dd').format(
                      _requiredDate!)}',
                  style: TextStyle(fontSize: 16,
                      color: _requiredDate == null ? Colors.grey : Colors
                          .black),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Required Date'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange.shade400
                  ),
                  onPressed: _submitRequest,
                  child: Text(
                    'Submit Request', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _requiredDate = pickedDate;
      });
    }
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final requestData = {
        'b_group': _bloodGroup,
        'hospital_name': _hospitalNameController.text,
        'bank_name': _bloodBank,
        'required_date': _requiredDate != null ? DateFormat('yyyy-MM-dd').format(_requiredDate!) : null,
        'phone': _contactNumberController.text,
        'donor_id': SessionManager.userId,
      };

      final response = await Supabase.instance.client.from('request').insert(requestData);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blood request submitted successfully')));
        Navigator.pop(context);

    }
  }
}
