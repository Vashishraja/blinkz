import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewRequestsPage extends StatefulWidget {
  @override
  _ViewRequestsPageState createState() => _ViewRequestsPageState();
}

class _ViewRequestsPageState extends State<ViewRequestsPage> {
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final response = await Supabase.instance.client.from('request').select();

      setState(() {
        _requests = response as List<Map<String, dynamic>>;
      });
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_requests.isEmpty){
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
          title: Text('View Requests', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepOrange.shade400,
        ),
        drawer: CustomDrawer(),
        body: ListView.builder(
          itemCount: _requests.length,
          itemBuilder: (context, index) {
            final request = _requests[index];
            return Card(
              color: Colors.deepOrange.shade400,
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  'Blood Group: ${request['b_group']}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Hospital: ${request['hospital_name']}',
                      style: TextStyle(color: Colors.white),),
                    SizedBox(height: 4),
                    Text('Blood Bank: ${request['bank_name']}',
                      style: TextStyle(color: Colors.white),),
                    SizedBox(height: 4),
                    Text('Required Date: ${request['required_date']}',
                      style: TextStyle(color: Colors.white),),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    _launchPhoneDialer(request['phone']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Call',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
