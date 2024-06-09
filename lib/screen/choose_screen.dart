import 'package:flutter/material.dart';
import 'package:id_card_example/screen/home_screen.dart';
import 'package:intl/intl.dart';
import '../library/MRZ/mrz_parser/src/mrz_result.dart';
import 'reader_screen.dart';
import 'mrtd_form_screen.dart';
import 'mrz_screen.dart';

class ScanManual extends StatefulWidget {
  const ScanManual({super.key});

  @override
  _ScanManualState createState() => _ScanManualState();
}

class _ScanManualState extends State<ScanManual> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _doeController = TextEditingController();

  @override
  void dispose() {
    _docNumberController.dispose();
    _dobController.dispose();
    _doeController.dispose();
    super.dispose();
  }

  Future<String?> _pickDate(BuildContext context, DateTime firstDate, DateTime initDate, DateTime lastDate) async {
    final locale = Localizations.localeOf(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initDate,
      lastDate: lastDate,
      locale: locale,
    );
    if (picked != null) {
      return DateFormat.yMd().format(picked);
    }
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final mrzResult = MRZResult(
        documentType: 'P',
        countryCode: '',
        surnames: '',
        givenNames: '',
        documentNumber: _docNumberController.text,
        nationalityCountryCode: '',
        birthDate: DateFormat.yMd().parse(_dobController.text),
        sex: Sex.none,
        expiryDate: DateFormat.yMd().parse(_doeController.text),
        personalNumber: '',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MrtdHomePage(mrzResult: mrzResult,),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/carte_ID_logo.png', // Assurez-vous d'avoir une image à cet emplacement
                height: 130,
              ),
              const SizedBox(height: 40),
              const Text(
                'Please choose an option to proceed',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MrzScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Scan MRZ',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Colors.amber, width: 2),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text(
                            "Bitaka ID",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.black,
                        ),
                        body: Center(
                          child: MrtdForm(
                            formKey: _formKey,
                            docNumberController: _docNumberController,
                            dobController: _dobController,
                            doeController: _doeController,
                            isDisabled: false,
                            pickDate: _pickDate,
                            onSubmit: _onSubmit,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Enter Manual',
                      style: TextStyle(fontSize: 18, color: Colors.amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
