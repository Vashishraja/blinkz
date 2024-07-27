import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewBloodBank extends StatefulWidget {
  @override
  _ViewBloodBankState createState() => _ViewBloodBankState();
}

class _ViewBloodBankState extends State<ViewBloodBank> {
  late TextEditingController _cityController;
  late List<Map<String, dynamic>> _bloodBanks = [];
  late List<Map<String, dynamic>> _filteredBloodBanks = [];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
    _fetchBloodBanks();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchBloodBanks() async {
    final response = await Supabase.instance.client.from('bank').select();

    setState(() {
      _bloodBanks = response as List<Map<String, dynamic>>;
      _filteredBloodBanks = List.from(_bloodBanks);
    });
  }

  void _filterBloodBanks(String city) {
    setState(() {
      _filteredBloodBanks = _bloodBanks
          .where((bank) => bank['city']!.toString().toLowerCase().contains(city.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_bloodBanks.isEmpty){
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
          title: Text(
            'View Blood Banks',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepOrange.shade400,
        ),
        drawer: CustomDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Filter by City',
                  labelStyle: TextStyle(color: Colors.deepOrange.shade400),
                  prefixIcon: Icon(
                      Icons.search, color: Colors.deepOrange.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _filterBloodBanks,
              ),
            ),
            Expanded(
              child: _filteredBloodBanks.isEmpty
                  ? Center(
                child: Text(
                  'No blood banks found',
                  style: TextStyle(
                      color: Colors.deepOrange.shade400, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredBloodBanks.length,
                itemBuilder: (context, index) {
                  final bloodBank = _filteredBloodBanks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.local_hospital,
                          color: Colors.deepOrange.shade400),
                      title: Text(
                        bloodBank['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.deepOrange.shade400),
                      ),
                      subtitle: Text(
                        '${bloodBank['address'] ?? ''}, ${bloodBank['city'] ??
                            ''}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
