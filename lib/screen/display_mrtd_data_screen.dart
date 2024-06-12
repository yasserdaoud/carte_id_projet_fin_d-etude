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
              //if (jpegImage != null) _buildImageSection(jpegImage!),
              //if (rawHandSignatureData != null) _buildImageSection(rawHandSignatureData!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveProfile(context);



                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuthenticateUserPage( mrtdData: _mrtdData,
                            rawHandSignatureData: rawHandSignatureData,),
                       //MainPage(
                       // mrtdData: _mrtdData,
                        //rawHandSignatureData: rawHandSignatureData,
                      // )
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 76.0, vertical: 12.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm',
                      style: TextStyle(fontSize: 18, color: Colors.black),
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
        'documentNumber': _mrtdData.dg1!.mrz.documentNumber,
        'firstName': _mrtdData.dg1!.mrz.firstName,
        'lastName': _mrtdData.dg1!.mrz.lastName,
        'dateOfBirth': DateFormat.yMd().format(_mrtdData.dg1!.mrz.dateOfBirth),
        'nationality': _mrtdData.dg1!.mrz.nationality,
        'dateOfExpiry': DateFormat.yMd().format(_mrtdData.dg1!.mrz.dateOfExpiry),
        'imageData': _mrtdData.dg2!.imageData,
        'nationalIdentificationNumber': _mrtdData.dg11!.personalNumber,
      };


    // Save to Firestore
    FirebaseFirestore.instance.collection('users').add(profileData).then((docRef) {
      print("User data saved to Firestore with ID: ${docRef.id}");
      print("National identification number: ${_mrtdData.dg11!.personalNumber}");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthenticateUserPage( mrtdData: _mrtdData,
            rawHandSignatureData: rawHandSignatureData,),
        ),
      );
    }).catchError((error) {
      print("Failed to save user data: $error");
    });
  }
}