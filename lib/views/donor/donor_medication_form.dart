import 'package:flutter/material.dart';

class MedicationForm extends StatefulWidget {
  @override
  _MedicationFormState createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  bool onMedication = false;
  bool onCycle = false;
  bool isPregnant = false;
  bool consumesAlcohol = false;
  bool hasCertainMedicalConditions = false;
  TextEditingController medicalConditionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildSwitchTile(
              title: 'Are you on any kind of medication?',
              value: onMedication,
              onChanged: (value) {
                setState(() {
                  onMedication = value;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Are you on your menstrual cycle?',
              value: onCycle,
              onChanged: (value) {
                setState(() {
                  onCycle = value;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Are you pregnant?',
              value: isPregnant,
              onChanged: (value) {
                setState(() {
                  isPregnant = value;
                });
              },
            ),
            _buildSwitchTile(
              title: 'Do you consume alcohol?',
              value: consumesAlcohol,
              onChanged: (value) {
                setState(() {
                  consumesAlcohol = value;
                });
                if (value) {
                  _showSpecificationTextField();
                }
              },
            ),
            if (consumesAlcohol)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: medicalConditionsController,
                  decoration: InputDecoration(
                    labelText: 'Specify Alcohol Consumption Details',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            _buildSwitchTile(
              title: 'Do you have certain medical conditions? (Specify below if yes)',
              value: hasCertainMedicalConditions,
              onChanged: (value) {
                setState(() {
                  hasCertainMedicalConditions = value;
                });
                if (value) {
                  _showSpecificationTextField();
                }
              },
            ),
            if (hasCertainMedicalConditions)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: medicalConditionsController,
                  decoration: InputDecoration(
                    labelText: 'Specify Medical Conditions',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              onPressed: _validateAndSubmitForm,
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  void _validateAndSubmitForm() {
    if (!onMedication &&
        !onCycle &&
        !isPregnant &&
        (!consumesAlcohol || medicalConditionsController.text.isNotEmpty) &&
        (!hasCertainMedicalConditions || medicalConditionsController.text.isNotEmpty)) {
      // Add logic for submitting the form
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Form Submitted'),
            content: Text('The medication form has been successfully submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Show a dialog or message indicating ineligibility
      _showIneligibleMessage();
    }
  }

  void _showSpecificationTextField() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Additional Information Required'),
          content: Text(
            'Please specify details about your alcohol consumption or medical conditions in the text box below.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showIneligibleMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ineligible Submission'),
          content: Text('You are not eligible to submit the form. Please review your answers.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
