import 'dart:io';
import 'package:blinkz/initial_screen.dart';
import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/donor/donor_appointment.dart';
import 'package:blinkz/views/donor/donor_notification.dart';
import 'package:blinkz/views/donor/request_blood.dart';
import 'package:blinkz/views/donor/reward_screen.dart';
import 'package:blinkz/views/donor/view_blood_bank_page.dart';
import 'package:blinkz/views/donor/view_request.dart';
import 'package:blinkz/views/donor/volunteer_form.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  bool isActive = true;
  int blinkzPoints = 0;
  String? name;
  String? bloodGroup;
  String image = '';

  @override
  void initState() {
    super.initState();
    _fetchDonorDetails();
  }
  Future<void> _uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      final fileName = "${SessionManager.userId.toString()}${DateTime
          .now()
          .millisecondsSinceEpoch}";
      final fileBytes = await file.readAsBytes();

      final response = await Supabase.instance.client.storage
          .from('donor')
          .uploadBinary(fileName, fileBytes);

      final imageUrl = Supabase.instance.client.storage.from('donor')
          .getPublicUrl(fileName);

      final donorResponse = await Supabase.instance.client.from('donor').select(
          'image, points')
          .eq('phone', SessionManager.userId.toString())
          .single();
      final donorData = donorResponse;

      // Check if image was previously uploaded
      if (donorData['image'].toString() == 'https://stanfordbloodcenter.org/wp-content/uploads/2018/03/0318-SouthBay-Center-Infographics_Compatibility-WEB.jpg' || donorData['image'].isEmpty) {
        // Update the image URL and increment points
        final updateResponse = await Supabase.instance.client.from('donor')
            .update({
          'image': imageUrl,
          'points': (donorData['points'] ?? 0) + 50,
        })
            .eq('phone', SessionManager.userId.toString());

        _fetchDonorDetails();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text(
                  'Successfully credited 50 Blinkz points for uploading the image.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      else {
        final updateResponse = await Supabase.instance.client.from(
            'donor').update({
          'image': imageUrl,
        }).eq('phone', SessionManager.userId.toString());
        _fetchDonorDetails();
      }
    }
  }

  Future<void> _fetchDonorDetails() async {
    final response = await Supabase.instance.client
        .from('donor')
        .select()
        .eq('phone', SessionManager.userId.toString())
        .single();

    setState(() {
      name = response['name'] as String;
      bloodGroup = response['bgroup'] as String;
      blinkzPoints = response['points'] as int;
        image = response['image'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if(bloodGroup == null  && name == null){
      return   Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/splash.json'
          ),
        ),
      );
    }
    else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange.shade400,
          title: const Text('Donor Profile',style:TextStyle(color: Colors.white) ,),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications,color: Colors.white,),
              onPressed: () {
                _notificationPage(context);
              },
            ),
          ],
        ),
        drawer: CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfilePhoto(),
                const SizedBox(height: 1),
                _buildActiveToggle(),
                const SizedBox(height: 6),
                _buildProfileDetails(),
                const SizedBox(height: 8),
                _buildOptions(context),
                const SizedBox(height: 6),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: ElevatedButton.icon(
                    icon:Icon(
                        Icons.logout,
                      color: Colors.black,
                    ) ,
                      onPressed: (){
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>InitialPage()), (route) => false);
                  },
                    style: ElevatedButton.styleFrom(
                      shape:  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                  ),
                      backgroundColor: Colors.deepOrange.shade400
                    ),
                    label: Text('Logout',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildProfilePhoto() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.25,
          child: Center(
            child: Image.network(
              image, // Replace with your network image URL
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.78,
          height: MediaQuery.of(context).size.height * 0.29,
          child: Center(

            child: Image.asset(
              'assets/bglogo.png', // Replace with your asset image path
              fit: BoxFit.fill,
            ),
          ),
        ),
         Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 16,
            child: GestureDetector(
              onTap: (){
                _uploadImage(context);
              },
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  Widget _buildProfileDetails() {
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
          const SizedBox(height: 2,),
          Text(
            name ?? 'Loading...',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Blood Group: ' + bloodGroup! ?? 'Loading...',
            style: const TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                'Blinkz Points - ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${blinkzPoints.toString()} Points',
                style: const TextStyle(fontSize: 16,color: Colors.white , fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 1,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        return _buildOptionCard(context, option['title'], option['icon'], option['color']);
      },
    );
  }

  final List<Map<String, dynamic>> _options = [
    {'title': 'View Blood Requests', 'icon': Icons.view_list, 'color': Colors.white},
    {'title': 'Book Appointment to Donate', 'icon': Icons.event, 'color': Colors.blue},
    {'title': 'Rewards Section', 'icon': Icons.star, 'color': Colors.green},
    {'title': 'Request Blood', 'icon': Icons.add, 'color': Colors.white},
    {'title': 'Become Volunteer', 'icon': Icons.person, 'color': Colors.blue},
    {'title': 'View Blood Banks', 'icon': Icons.bloodtype, 'color': Colors.green},
  ];


  Widget _buildOptionCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (title == 'Rewards Section') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RewardsScreen()));
        } else if (title == 'Book Appointment to Donate') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookAppointmentScreen()));
        } else if (title == 'View Blood Banks') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewBloodBank()));
        } else if (title == 'Become Volunteer') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => VolunteerRegistrationScreen()));
        } else if (title == 'View Blood Requests') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewRequestsPage()));
        } else if (title == 'Request Blood') {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => RequestBloodPage()));
        } else if (title == 'Logout') {
          SessionManager.logout();
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => InitialPage()), (route) => false);
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DonorProfilePage()));
        }
      },
      child: Card(
        elevation: 4,
        color: Colors.deepOrange.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _notificationPage(BuildContext context) {
   Navigator.of(context).push(MaterialPageRoute(builder: (context)=> DonorNotificationsScreen()));
  }
}
