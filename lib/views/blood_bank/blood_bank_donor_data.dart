import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewDonorDataPage extends StatefulWidget {
  @override
  _ViewDonorDataPageState createState() => _ViewDonorDataPageState();
}

class _ViewDonorDataPageState extends State<ViewDonorDataPage> {
  List<Map<String, dynamic>>? donorData;

  @override
  void initState() {
    super.initState();
    _fetchDonorData();
  }

  Future<void> _fetchDonorData() async {
    final response = await Supabase.instance.client.from('volunteer').select();



    final List<Map<String, dynamic>> data = response as List<Map<String, dynamic>>;
    setState(() {
      donorData = data;
    });
    log(donorData.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade400,
        title: Text('View Donor Data',style: TextStyle(color: Colors.white),),
      ),
      body: _buildDonorList(),
    );
  }

  Widget _buildDonorList() {
    if (donorData == null) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/splash.json'
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: donorData!.length,
      itemBuilder: (context, index) {
        final donor = donorData![index];
        return ListTile(
          title: Text(donor['name'] ?? ''),
          subtitle: Text('Blood Group: ${donor['b_group']} - City: ${donor['city']}'),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green
            ),
            onPressed: () => _callDonor(donor['contact'] ?? ''),
            child: Text('Call',style: TextStyle(color: Colors.white),),
          ),
        );
      },
    );
  }

  Future<void> _callDonor(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
