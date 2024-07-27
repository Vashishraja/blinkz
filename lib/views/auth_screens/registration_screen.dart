import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blinkz/session_manager/session.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blinkz/views/blood_bank/blood_bank_profile.dart';
import 'package:blinkz/views/donor/donor_profile.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String bloodGroup = 'A+';
  UserType userType = UserType.donor; // Default user type is donor
  String? otp;
  bool isOtpVerified = false; // State variable to track OTP verification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blinkz',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(nameController, 'Full Name'),
              const SizedBox(height: 12),
              _buildDateField(),
              const SizedBox(height: 12),
              _buildBloodGroupDropdown(),
              const SizedBox(height: 12),
              _buildTextField(mobileNumberController, 'Mobile Number', TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(emailController, 'Email', TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(passwordController, 'Password', TextInputType.visiblePassword, true),
              const SizedBox(height: 12),
              _buildTextField(addressController, 'Address'),
              const SizedBox(height: 12),
              _buildTextField(cityController, 'City'),
              const SizedBox(height: 12),
              _buildUserTypeRadioButtons(),
              const SizedBox(height: 12),
              _buildOtpField(),
              const SizedBox(height: 12),
              _buildSendOtpButton(),
              const SizedBox(height: 12),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isOtpVerified ? _registerUser : _verifyAndRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.orange, // Set button color to orange
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, [TextInputType keyboardType = TextInputType.text, bool obscureText = false]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: _buildTextField(dobController, 'Date of Birth (DOB)'),
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Group',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: bloodGroup.isNotEmpty ? bloodGroup : 'A+',
          items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
              .map((group) => DropdownMenuItem<String>(value: group, child: Text(group)))
              .toList(),
          onChanged: (value) => setState(() => bloodGroup = value!),
          style: const TextStyle(fontSize: 18, color: Colors.black),
          isExpanded: true,
          underline: Container(height: 2, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildUserTypeRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<UserType>(
              value: UserType.donor,
              groupValue: userType,
              onChanged: (value) => setState(() => userType = value!),
              activeColor: Colors.orange,
            ),
            const Text('Donor'),
            Radio<UserType>(
              value: UserType.bloodBank,
              groupValue: userType,
              onChanged: (value) => setState(() => userType = value!),
              activeColor: Colors.orange,
            ),
            const Text('Blood Bank'),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return _buildTextField(otpController, 'OTP', TextInputType.number);
  }

  Widget _buildSendOtpButton() {
    return ElevatedButton(
      onPressed: _sendOtp,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: Colors.orange, // Set button color to orange
      ),
      child: const Text(
        'Send OTP',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final randomNumber = Random().nextInt(9000) + 1000;
    otp = randomNumber.toString();
    await sendOtp(mobileNumberController.text, otp!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP has been sent to your mobile number')),
    );
    setState(() {}); // Trigger a rebuild to show the OTP verification field
  }

  Future<void> sendOtp(String phone, String token) async {
    final Map<String, String> data = {
      "authorization": "SOtq7kywLeozgV1dhTibYUKJGuxvDspjfH5IX9lNrMWcPR8A64X7vzFlDMWhEQxrCLdym3ie65TuK2Zj",
      'route': "otp",
      'variables_values': token,
      'numbers': phone,
    };

    final Uri url = Uri.parse("https://www.fast2sms.com/dev/bulkV2?").replace(
        queryParameters: data);
    print(url.toString());
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
  }

  Future<void> _verifyAndRegister() async {
    if (otpController.text == otp) {
      setState(() {
        isOtpVerified = true;
      });
      _registerUser();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  Future<void> _registerUser() async {
    final Map<String, String> userData = {
      'email': emailController.text,
      'dob': dobController.text,
      'bgroup': bloodGroup,
      'pass': passwordController.text,
      'name': nameController.text,
      'phone': mobileNumberController.text,
      'city': cityController.text,
      'address': addressController.text,
    };

    final response = await Supabase.instance.client.from(userType == UserType.donor ? 'donor' : 'bank').insert([userData]);

      SessionManager.login(mobileNumberController.text, userType == UserType.donor ? 'donor' : 'bank');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => userType == UserType.donor ? DonorProfilePage() : BloodBankProfilePage()),
            (route) => false,
      );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 6575)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}

enum UserType { donor, bloodBank }
