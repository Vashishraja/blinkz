import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blinkz/session_manager/session.dart';

class ViewAppointmentsPage extends StatefulWidget {
  @override
  _ViewAppointmentsPageState createState() => _ViewAppointmentsPageState();
}

class _ViewAppointmentsPageState extends State<ViewAppointmentsPage> {
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final response = await Supabase.instance.client
        .from('appointment')
        .select()
        .eq('bank_id', SessionManager.userId.toString());


      setState(() {
        _appointments = response as List<Map<String, dynamic>>;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Appointments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: _appointments.isEmpty
          ? Center(child: Lottie.asset('assets/splash.json'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                'User ID: ${appointment['user_id']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade400,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blood Group: ${appointment['bgroup']}'),
                  Text('Time Slot: ${appointment['slot']}'),
                  Text('Last Donation Date: ${appointment['last_donation']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
