import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IDCardFrontWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Uint8List? imageData;
  final Uint8List? signatureData;
  final String? personalNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? gender;

  IDCardFrontWidget({
    required this.userData,
    Key? key,
  })  : imageData = Uint8List.fromList(List<int>.from(userData['imageData'])),
        signatureData = userData.containsKey('signatureData') && userData['signatureData'] != null
            ? base64Decode(userData['signatureData'])
            : null,
        personalNumber = userData['nationalIdentificationNumber'],
        firstName = userData['firstName'],
        lastName = userData['lastName'],
        dateOfBirth = _parseDate(userData['dateOfBirth']),
        nationality = userData['nationality'],
        gender = userData['gender'],
        super(key: key);

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null) {
      return null;
    }
    try {
      return DateFormat('M/d/yyyy').parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550.2, // CR80 card size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/front_id_card.png'),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            if (imageData != null)
              Positioned(
                left: 255,
                top: 165,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.memory(
                    imageData!,
                    width: 90,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Positioned(
              right: 100,
              top: 146,
              child: Text(
                personalNumber ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 85,
              top: 199,
              child: Text(
                firstName ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 85,
              top: 177,
              child: Text(
                lastName ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 221,
              child: Text(
                dateOfBirth != null
                    ? DateFormat('dd.MM.yyyy').format(dateOfBirth!)
                    : '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 239,
              top: 247,
              child: Text(
                nationality ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 183,
              top: 247,
              child: Text(
                gender ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 183,
              top: 247,
              child: Text(
                gender ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
