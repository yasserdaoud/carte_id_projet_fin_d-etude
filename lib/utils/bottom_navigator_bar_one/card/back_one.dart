import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

class IDCardBackWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Uint8List? signatureData;
  final String? dateOfExpiry;
  final String? documentNumber;

  IDCardBackWidget({
    required this.userData,
    Key? key,
  })  : signatureData = userData.containsKey('signatureData') && userData['signatureData'] != null
      ? base64Decode(userData['signatureData'])
      : null,
        dateOfExpiry = _parseDate(userData['dateOfExpiry']),
        documentNumber = userData['documentNumber'],
        super(key: key);

  static String? _parseDate(String? dateString) {
    if (dateString == null) {
      return null;
    }
    try {
      final dateTime = DateFormat('M/d/yyyy').parse(dateString);
      return DateFormat('dd.MM.yyyy').format(dateTime);
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
          image: AssetImage('assets/back_id_card.png'),
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 140,
              top: 107,
              child: Text(
                documentNumber ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 110,
              top: 139,
              child: Text(
                dateOfExpiry ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (signatureData != null)
              Positioned(
                right: 20,
                top: 185,
                child: Container(
                  width: 150,
                  height: 70,
                  child: Image.memory(
                    signatureData!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
