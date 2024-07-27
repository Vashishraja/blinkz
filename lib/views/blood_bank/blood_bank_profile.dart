import 'dart:developer';
import 'dart:io';
import 'package:blinkz/initial_screen.dart';
import 'package:blinkz/session_manager/session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'blood_bank_donor_data.dart';
import 'blood_bank_view_appintment.dart';
import 'blood_bank_view_request.dart';
import 'blood_bank_view_stock.dart';

class BloodBankProfilePage extends StatefulWidget {
  @override
  _BloodBankProfilePageState createState() => _BloodBankProfilePageState();
}

class _BloodBankProfilePageState extends State<BloodBankProfilePage> {
  String bloodBankName = '';
  String city = '';
  String image = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
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
          .from('bank')
          .uploadBinary(fileName, fileBytes);

      final imageUrl = Supabase.instance.client.storage.from('bank')
          .getPublicUrl(fileName);

      final donorResponse = await Supabase.instance.client.from('bank').select(
          'image')
          .eq('phone', SessionManager.userId.toString())
          .single();
      final donorData = donorResponse;

      if (donorData['image'] == null || donorData['image'].isEmpty) {
        final updateResponse = await Supabase.instance.client.from('bank')
            .update({
          'image': imageUrl,
        })
            .eq('phone', SessionManager.userId.toString());
      }

    }
  }
  void fetchUserDetails() async {
    final currentUser = SessionManager.userId;
      final response = await Supabase.instance.client
          .from('bank')
          .select()
          .eq('phone', SessionManager.userId.toString());

        final user = response[0];
        log(user.toString());
        setState(() {
          bloodBankName = user['name'] as String;
          city = user['city'] as String;
          image = user['image'] as String;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      body: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Center(
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.78,
                    height: MediaQuery.of(context).size.height * 0.29,
                    child: Center(

                      child: Image.asset(
                        'assets/bglogo.png', // Replace with your asset image path
                        fit: BoxFit.cover,
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
              ),
            ),
            const SizedBox(height: 1),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Container(
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
                      '${bloodBankName}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
                                 ),
                     const SizedBox(height: 8),
                     Text(
                       'City: $city',
                       style: TextStyle(fontSize: 18,color: Colors.white),
                     ),
                   ],
                 ),
               ),
             ),

            const Divider(
              thickness: 2,
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // View Requests Button Pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewRequestsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'View Requests',
                        style: TextStyle(fontSize: 18,color: Colors.white),
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // View Stock Button Pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewStockPage()),
                  );
                },
                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.deepOrange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'View Stock',
                        style: TextStyle(fontSize: 18,color:  Colors.white),
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // View Appointments Button P
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAppointmentsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
backgroundColor: Colors.deepOrange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'View Appointments',
                        style: TextStyle(fontSize: 18, color:  Colors.white),
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // View Donors Data Button Pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewDonorDataPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'View Donors Data',
                        style: TextStyle(fontSize: 18,color:  Colors.white),
                      ),
                      Icon(Icons.arrow_forward_ios,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                SessionManager.logout();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>InitialPage()), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'LogOut',
                        style: TextStyle(fontSize: 18,color:  Colors.white),
                      ),
                      Icon(Icons.logout,color: Colors.white,),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




