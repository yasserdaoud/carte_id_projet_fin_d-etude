import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MrtdForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController docNumberController;
  final TextEditingController dobController;
  final TextEditingController doeController;
  final bool isDisabled;
  final Future<String?> Function(BuildContext context, DateTime firstDate, DateTime initDate, DateTime lastDate) pickDate;
  final VoidCallback onSubmit;

  MrtdForm({
    required this.formKey,
    required this.docNumberController,
    required this.dobController,
    required this.doeController,
    required this.isDisabled,
    required this.pickDate,
    required this.onSubmit,
  });

  DateTime? _getDOBDate() {
    if (dobController.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(dobController.text);
  }

  DateTime? _getDOEDate() {
    if (doeController.text.isEmpty) {
      return null;
    }
    return DateFormat.yMd().parse(doeController.text);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Please fill in the details below:',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: docNumberController,
                labelText: 'ID card number',
                icon: Icons.badge,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter ID card number';
                  }
                  return null;
                },
                isEnabled: !isDisabled,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: dobController,
                labelText: 'Date of Birth',
                icon: Icons.calendar_today,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final now = DateTime.now();
                  final firstDate = DateTime(now.year - 90, now.month, now.day);
                  final lastDate = DateTime(now.year - 15, now.month, now.day);
                  final initDate = _getDOBDate();
                  final date = await pickDate(context, firstDate, initDate ?? lastDate, lastDate);
                  if (date != null) {
                    dobController.text = date;
                  }
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please select Date of Birth';
                  }
                  return null;
                },
                isEnabled: !isDisabled,
              ),
              const SizedBox(height: 15),
              _buildTextFormField(
                controller: doeController,
                labelText: 'Date of Expiry',
                icon: Icons.calendar_today,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final now = DateTime.now();
                  final firstDate = DateTime(now.year, now.month, now.day + 1);
                  final lastDate = DateTime(now.year + 10, now.month + 6, now.day);
                  final initDate = _getDOEDate();
                  final date = await pickDate(context, firstDate, initDate ?? firstDate, lastDate);
                  if (date != null) {
                    doeController.text = date;
                  }
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please select Date of Expiry';
                  }
                  return null;
                },
                isEnabled: !isDisabled,
              ),
              const SizedBox(height: 14),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  onPressed: isDisabled
                      ? null
                      : () {
                    if (formKey.currentState?.validate() ?? false) {
                      onSubmit();
                    } else {
                      _showErrorDialog(context, 'Please fix the errors in red before submitting.');
                    }
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
    bool isEnabled = true,
    void Function()? onTap,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.amber),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.amber),
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.amber),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      validator: validator,
      enabled: isEnabled,
      onTap: onTap,
      keyboardType: keyboardType,
    );
  }
}
