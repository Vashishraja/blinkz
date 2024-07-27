import 'package:blinkz/views/donor/donor_profile.dart';
import 'package:blinkz/views/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:blinkz/session_manager/session.dart';
import 'package:intl/intl.dart';

class CommonFormPage extends StatefulWidget {
  final String activity;

  CommonFormPage({required this.activity});

  @override
  _CommonFormPageState createState() => _CommonFormPageState();
}

class _CommonFormPageState extends State<CommonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedImage != null && _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final fileName = "${widget.activity}/${SessionManager.userId}_${DateTime.now().day}";
        final fileBytes = await _selectedImage!.readAsBytes();
        final response = await Supabase.instance.client.storage
            .from('donations')
            .uploadBinary(fileName, fileBytes);

        final imageUrl = Supabase.instance.client.storage
            .from('donations')
            .getPublicUrl(fileName);

        final donationData = {
          'user_id': SessionManager.userId,
          'image': imageUrl,
          'type': widget.activity,
          'description': _descriptionController.text,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        };

        await Supabase.instance.client.from('donations').insert(donationData);
        final donorResponse = await Supabase.instance.client.from('donor').select(
            'points')
            .eq('phone', SessionManager.userId.toString())
            .single();
        final donorData = donorResponse;
        final updateResponse = await Supabase.instance.client.from('donor')
            .update({
          'points': (donorData['points'] ?? 0) + 100,
        }).eq('phone', SessionManager.userId.toString());
        _showSuccessDialog();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading data: $e'),
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please complete all fields and select an image.'),
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thank You!'),
          content: Text('Thanks for your valuable contribution.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>DonorProfilePage()), (route) => false);
              },
              child: Text('Back to Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.shade400,
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: Lottie.asset('assets/splash.json'))
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Please upload an image proof and enter the date for ${widget.activity}.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Camera'),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: _selectedDate == null
                      ? ''
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
