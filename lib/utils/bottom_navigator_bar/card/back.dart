import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../nfc/format/mrtd_data.dart';
import 'dart:typed_data';

class IDCardBackWidget extends StatelessWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  const IDCardBackWidget({required this.mrtdData, this.rawHandSignatureData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550.2, // CR80 card1 size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/back_id_card.png'),
          // fit: BoxFit.cover,
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
                mrtdData.dg1?.mrz.documentNumber ?? '',
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
                mrtdData.dg1 != null
                    ? DateFormat('dd.MM.yyyy').format(mrtdData.dg1!.mrz.dateOfExpiry)
                    : '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (rawHandSignatureData != null)
              Positioned(
                right: 20,
                top: 185,
                child: Container(
                  width: 150,
                  height: 70,
                  child: Image.memory(
                    rawHandSignatureData!,
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
