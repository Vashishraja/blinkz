import 'package:blinkz/session_manager/session.dart';
import 'package:blinkz/views/blood_bank/blood_bank_profile.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewStockPage extends StatefulWidget {
  const ViewStockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<ViewStockPage> {
   Map<String, String>? bloodStock;

  @override
  void initState() {
    super.initState();
    _fetchBloodStock();
  }

  Future<void> _fetchBloodStock() async {
    final response = await Supabase.instance.client
        .from('bank')
        .select()
        .eq('phone', SessionManager.userId.toString())
        .single();
    if (response != null) {
      setState(() {
        bloodStock = {
          'A': response['a'] as String? ?? '0',
          'A+': response['a_plus'] as String? ?? '0',
          'B': response['b'] as String? ?? '0',
          'B+': response['b_plus'] as String? ?? '0',
          'AB': response['ab'] as String? ?? '0',
          'AB+': response['ab_plus'] as String? ?? '0',
          'O': response['o'] as String? ?? '0',
          'O+': response['o_plus'] as String? ?? '0',
        };
      });
    } else {
      // Handle null response, show an error message or retry fetching data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bloodStock == null){
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
          title: const Text('Blood Stock',style: TextStyle(color: Colors.white),),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            for (var bloodType in bloodStock!.keys)
              _buildBloodStockItem(bloodType),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async {
                await _updateBloodStock();
              },
              child: const Text(
                'Update Stock',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
  }

   Widget _buildBloodStockItem(String bloodType) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4.0),
       child: Container(
         padding: const EdgeInsets.all(10.0),
         decoration: BoxDecoration(
           color: Colors.deepOrange.shade50,
           borderRadius: BorderRadius.circular(12.0),
           boxShadow: [
             BoxShadow(
               color: Colors.deepOrange.withOpacity(0.2),
               spreadRadius: 1,
               blurRadius: 5,
               offset: Offset(0, 2),
             ),
           ],
         ),
         child: Row(
           children: [
             Expanded(
               child: Text(
                 bloodType,
                 style: TextStyle(
                   fontSize: 16.0,
                   fontWeight: FontWeight.bold,
                   color: Colors.deepOrange.shade400,
                 ),
               ),
             ),
             Expanded(
               child: TextField(
                 keyboardType: TextInputType.number,
                 decoration: InputDecoration(
                   hintText: bloodStock![bloodType],
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(8.0),
                     borderSide: BorderSide(
                       color: Colors.deepOrange.shade400,
                     ),
                   ),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                 ),
                 onChanged: (value) {
                   if (value.isNotEmpty) {
                     setState(() {
                       bloodStock![bloodType] = value;
                     });
                   }
                 },
               ),
             ),
           ],
         ),
       ),
     );
   }

  Future<void> _updateBloodStock() async {
    final updatedData = {
      'a': bloodStock!['A'],
      'a_plus': bloodStock!['A+'],
      'b': bloodStock!['B'],
      'b_plus': bloodStock!['B+'],
      'ab': bloodStock!['AB'],
      'ab_plus': bloodStock!['AB+'],
      'o': bloodStock!['O'],
      'o_plus': bloodStock!['O+'],
    };
    await Supabase.instance.client.from('bank').update(updatedData).eq('phone', SessionManager.userId.toString());
    _showUpdateDialog();
  }
   Future<void> _showUpdateDialog() async {
     await showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Stock Updated'),
         content: const Text('Blood stock has been updated successfully.'),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.of(context).pop();
             },
             child: const Text('OK'),
           ),
           TextButton(
             onPressed: () {
               Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BloodBankProfilePage()));
             },
             child: const Text('Home'),
           ),
         ],
       ),
     );
   }
}
