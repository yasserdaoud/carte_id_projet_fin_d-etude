/*

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/bottom_navigator_bar/main_page.dart';
import 'dart:typed_data';
import '../../utils/nfc/format/mrtd_data.dart';





class UserAuthenticatedPage extends StatelessWidget {
  final String Firstname;
  final String Lastname;
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  const UserAuthenticatedPage({
    required this.Firstname,
    required this.Lastname,
    required this.mrtdData,
    this.rawHandSignatureData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(

        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome $Lastname $Firstname !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold, // Make the text bold for emphasis
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              child: Image.asset(
                'assets/check.png',
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 80),
            Text(
              'You have been successfully authenticated!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isSignedIn', true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(
                        mrtdData: mrtdData,
                        rawHandSignatureData: rawHandSignatureData,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(
                      color: Colors.amber,
                      width: 2.0,
                    ),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/