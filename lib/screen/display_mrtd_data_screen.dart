import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/authenticate_user/authenticate_user_page.dart';
import '../utils/nfc/format/format_dg11.dart';
import '../utils/nfc/format/format_dg12.dart';
import '../utils/nfc/format/format_mrz.dart';
import '../utils/nfc/format/mrtd_data.dart';
import '../utils/bottom_navigator_bar/main_page.dart';

class ResultPage extends StatelessWidget {
  final String _alertMessage = "";
  final MrtdData _mrtdData;
  final Uint8List? rawHandSignatureData;
  final ScrollController _scrollController = ScrollController();

  Uint8List? jpegImage;
  Uint8List? jp2000Image;

  ResultPage({required MrtdData mrtdData, this.rawHandSignatureData})
      : _mrtdData = mrtdData;

  List<Widget> _buildDataWidgets() {
    List<Widget> widgets = [];

    if (_mrtdData.dg1 != null) {
      widgets.add(_buildDataSection(formatMRZ(_mrtdData.dg1!.mrz)));
    }

    if (_mrtdData.dg11 != null) {
      widgets.add(_buildDataSection(formatDG11(_mrtdData.dg11!)));
    }

    if (_mrtdData.dg12 != null) {
      widgets.add(_buildDataSection(formatDG12(_mrtdData.dg12!)));
    }

    return widgets;
  }

  Widget _buildDataSection(String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          data,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10), // Add spacing between sections
      ],
    );
  }

  Widget _buildImageSection(Uint8List imageData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            imageData,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 10), // Add spacing between sections
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Result",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850]?.withOpacity(0.9),
                  border: Border.all(color: Colors.amber, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDataWidgets(),
                ),
              ),
              const SizedBox(height: 20),
              if (jpegImage != null) _buildImageSection(jpegImage!),
              if (rawHandSignatureData != null) _buildImageSection(rawHandSignatureData!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveProfile(context);

                 // SharedPreferences prefs = await SharedPreferences.getInstance();
                 // await prefs.setBool('isSignedIn', true);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthenticateUserPage(),
                       // MainPage(
                        //  mrtdData: _mrtdData,
                         // rawHandSignatureData: rawHandSignatureData,
                       // )
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.grey[850]?.withOpacity(0.9)),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[850]?.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _saveProfile(BuildContext context) async {
    var profileData = {
      'firstName': _mrtdData.dg1!.mrz.firstName,
      'lastName': _mrtdData.dg1!.mrz.lastName,
      'documentNumber': _mrtdData.dg1!.mrz.documentNumber,
      'dateOfBirth': DateFormat.yMd().format(_mrtdData.dg1!.mrz.dateOfBirth),
      'nationality': _mrtdData.dg1!.mrz.nationality,
      'expiryDate': DateFormat.yMd().format(_mrtdData.dg1!.mrz.dateOfExpiry),
      'image': base64Encode(_mrtdData.dg2!.imageData!), // Encoding image to base64 string
      'nationalIdentificationNumber': _mrtdData.dg11!.personalNumber,
    };

    // Save to Firestore
    FirebaseFirestore.instance.collection('users').add(profileData).then((docRef) {
      print("User data saved to Firestore with ID: ${docRef.id}");
      print("National identification number: ${_mrtdData.dg11!.personalNumber}");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthenticateUserPage(),
        ),
      );
    }).catchError((error) {
      print("Failed to save user data: $error");
    });
  }
}