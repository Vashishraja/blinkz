import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/donor/donor_appointment.dart';
import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/donor/request_blood.dart';
import 'package:blinkz/views/donor/reward_screen.dart';
import 'package:blinkz/views/donor/view_blood_bank_page.dart';
import 'package:blinkz/views/donor/view_request.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class CustomDrawer extends StatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final List<String> _options = [
    'Home',
    'View Blood Request',
    'Book Appointment',
    'Reward Section',
    'Request Blood',
    'View Blood Banks',
    'Edit Profile',
    'Privacy Policy',
    'Terms and Condition',
    'Refer app',
  ];

  late String userName = '';
  late String userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final response = await Supabase.instance.client
        .from('donor')
        .select()
        .eq('phone', SessionManager.userId.toString())
        .single();

    final name = response['name'] as String?;
    final email = response['email'] as String?;

    if (name != null) {
      setState(() {
        userName = name ?? '';
        userEmail = email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepOrange,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userName,
                style: TextStyle(fontSize: 18),
              ),
              accountEmail: Text(
                userEmail,
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/user_avatar.png'),
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _options.map((option) {
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _handleDrawerItemPress(context, option);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDrawerItemPress(BuildContext context, String option) {
    Navigator.pop(context); // Close the drawer

    switch (option) {
      case 'Home':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DonorProfilePage()),
        );
        break;
      case 'View Blood Request':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewRequestsPage()),
        );
        break;
      case 'Book Appointment':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookAppointmentScreen()),
        );
        break;
      case 'Reward Section':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RewardsScreen()),
        );
        break;
      case 'Request Blood':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RequestBloodPage()),
        );
        break;
      case 'View Blood Banks':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewBloodBank()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid option selected'),
          ),
        );
        break;
    }
  }
}
