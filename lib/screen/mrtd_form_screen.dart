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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Please fill in the details below to proceed:',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: docNumberController,
              labelText: 'ID card number',
              icon: Icons.badge,
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return 'Please enter ID card number';
                }
                return null;
              },
              isEnabled: !isDisabled,
            ),
            const SizedBox(height: 16),
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
                if (value?.isEmpty ?? false) {
                  return 'Please select Date of Birth';
                }
                return null;
              },
              isEnabled: !isDisabled,
            ),
            const SizedBox(height: 16),
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
                if (value?.isEmpty ?? false) {
                  return 'Please select Date of Expiry';
                }
                return null;
              },
              isEnabled: !isDisabled,
            ),
            const SizedBox(height: 24),
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
                  }
                },
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18, color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
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
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.amber),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.amber),
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.amber),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
      enabled: isEnabled,
      onTap: onTap,
    );
  }
}
