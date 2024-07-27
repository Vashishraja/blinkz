import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/donor/donotions_screen.dart';
import 'package:blinkz/views/donor/volunteer_form.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardsScreen extends StatefulWidget {
  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  late String userName = ''; // Initialize name to empty string
  late String userEmail = ''; // Initialize email to empty string
  int blinkzPoints = 0; // Initialize points to 0

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

  @override
  void initState() {
    super.initState();
    _fetchBlinkzPoints();
  }

  Future<void> _fetchBlinkzPoints() async {
    final response = await Supabase.instance.client
        .from('donor')
        .select() // Fetch points, name, and email
        .eq('phone', SessionManager.userId.toString())
        .single();

    final points = response['points'] as int?;
    final name = response['name'] as String?;
    final email = response['email'] as String?;

    if (points != null) {
      setState(() {
        blinkzPoints = points;
        userName = name ?? '';
        userEmail = email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(userName.isEmpty){
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
          backgroundColor: Colors.deepOrange,
          title: Text('Rewards Screen', style: TextStyle(color: Colors.white),),
        ),
        drawer:CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(
                  height: 10,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                _buildBlinkzPoints(),
                SizedBox(height: 24),
                _buildRewardLevels(),
                Divider(
                  height: 10,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                _buildViewCertificates(context),
                SizedBox(height: 24),
                _buildActivityOptions(),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildViewCertificates(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement view certificates functionality
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange.shade400,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      icon: Icon(
        Icons.file_copy,
        size: 24,
      ),
      label: Text(
        'View Certificates',
        style: TextStyle(fontSize: 18,color: Colors.white),
      ),
    );
  }

  Widget _buildBlinkzPoints() {
    int pointsRequiredForNextBadge;

    if (blinkzPoints < 50) {
      pointsRequiredForNextBadge = 50 - blinkzPoints;
    } else if (blinkzPoints < 100) {
      pointsRequiredForNextBadge = 100 - blinkzPoints;
    } else if (blinkzPoints < 200) {
      pointsRequiredForNextBadge = 200 - blinkzPoints;
    } else if (blinkzPoints < 500) {
      pointsRequiredForNextBadge = 500 - blinkzPoints;
    } else {
      pointsRequiredForNextBadge = 0;
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.orange.shade400,
          ),
          color: Colors.deepOrange.shade400,
          borderRadius: const BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        children: [
          Text(
            'Blinkz Points',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            '$blinkzPoints Points',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Points required for next badge: $pointsRequiredForNextBadge',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardLevels() {
    int currentBadgeMinPoints;
    int currentBadgeMaxPoints;
    String currentBadge;

    if (blinkzPoints < 50) {
      currentBadge = 'Bronze';
      currentBadgeMinPoints = 0;
      currentBadgeMaxPoints = 50;
    } else if (blinkzPoints < 100) {
      currentBadge = 'Silver';
      currentBadgeMinPoints = 50;
      currentBadgeMaxPoints = 100;
    } else if (blinkzPoints < 200) {
      currentBadge = 'Gold';
      currentBadgeMinPoints = 100;
      currentBadgeMaxPoints = 200;
    } else if (blinkzPoints < 500) {
      currentBadge = 'Diamond';
      currentBadgeMinPoints = 200;
      currentBadgeMaxPoints = 500;
    } else {
      currentBadge = 'Diamond'; // If exceeding the last badge, keep it at Diamond
      currentBadgeMinPoints = 500;
      currentBadgeMaxPoints = 1000;
    }

    double progress = (blinkzPoints - currentBadgeMinPoints) / (currentBadgeMaxPoints - currentBadgeMinPoints);

    return Container(
      child: Column(
        children: [
          Text(
            currentBadge,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.deepOrange),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: Colors.deepOrange,
          ),
          SizedBox(height: 8),
          Text(
            '$currentBadgeMinPoints - $currentBadgeMaxPoints Points',
            style: TextStyle(fontSize: 16, color: Colors.deepOrange,fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOptions() {
    return Column(
      children: [
        _buildActivityOption('Donate Blood', 100),
        SizedBox(height: 16),
        _buildActivityOption('Eye Donation', 100),
        SizedBox(height: 16),
        _buildActivityOption('Tree Plantation', 100),
        SizedBox(height: 16),
        _buildActivityOption('Volunteer Registration', 100),
        SizedBox(height: 16),
        _buildActivityOption('Monetary Donation', 100),
      ],
    );
  }

  Widget _buildActivityOption(String activity, int points) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.deepOrange.shade400,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            activity,
            style: TextStyle(fontSize: 18,color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToForm(context, activity);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              '$points Points',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }


  void _handleButtonPress(BuildContext context, String option) {
    print('Button pressed: $option');
  }
  void _navigateToForm(BuildContext context, String activity) {
    if (activity == 'Volunteer Registration') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VolunteerRegistrationScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommonFormPage(activity: activity),
        ),
      );
    }
  }
}