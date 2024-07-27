import 'dart:developer';
import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/blood_bank/blood_bank_profile.dart';

class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blinkz',style: TextStyle(color: Colors.orange,fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.12,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (context) => LoginPage(accountType: 'donor')),
                  );
                },
                child: Text('Login as Donor',style: TextStyle(fontWeight: FontWeight.bold ,color: Colors.orange),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.orange),

              ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.12,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage(accountType: 'bank')),
                  );
                },
                child: Text('Login as Blood Bank',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String accountType;

  const LoginPage({Key? key, required this.accountType}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome!',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orange),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BuildLogo(),
            SizedBox(height: 24,),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton(
                onPressed: widget.accountType == 'donor' ? _loginAsDonor : _loginAsBloodBank,
                child: Text('Login', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginAsDonor() async {
    final phoneNumber = phoneNumberController.text;
    final password = passwordController.text;

    final donorResponse = await Supabase.instance.client
        .from('donor')
        .select()
        .eq('phone', phoneNumber)
        .single();
    log(donorResponse.toString());

    final donorPassword = donorResponse['pass'].toString();
    if (donorPassword == password) {
      SessionManager.login(phoneNumber, 'donor');
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>DonorProfilePage()), (route) => false);
      return;
    }

    _showErrorDialog('Incorrect phone number or password.');
  }

  Future<void> _loginAsBloodBank() async {
    final phoneNumber = phoneNumberController.text;
    final password = passwordController.text;

    final bankResponse = await Supabase.instance.client
        .from('bank')
        .select()
        .eq('phone', phoneNumber)
        .single();
    log(bankResponse.toString());

    final bankPassword = bankResponse['pass'].toString();
    if (bankPassword == password) {
      SessionManager.login(phoneNumber, 'bank');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BloodBankProfilePage()), (route) => false
      );
      return;
    }

    _showErrorDialog('Incorrect phone number or password.');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
