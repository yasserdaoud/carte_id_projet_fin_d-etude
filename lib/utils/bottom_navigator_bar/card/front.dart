import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../nfc/format/mrtd_data.dart';

class IDCardFrontWidget extends StatelessWidget {
  final MrtdData mrtdData;

  IDCardFrontWidget({required this.mrtdData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550.2, // CR80 card1 size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/front_id_card.png'),
          // fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 4,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 255,
              top: 165,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.memory(
                  mrtdData.dg2!.imageData!,
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
                mrtdData.dg11?.personalNumber ?? '',
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
                mrtdData.dg1?.mrz.firstName ?? '',
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
                mrtdData.dg1?.mrz.lastName ?? '',
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
                mrtdData.dg1 != null
                    ? DateFormat('dd.MM.yyyy').format(mrtdData.dg1!.mrz.dateOfBirth)
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
                mrtdData.dg1?.mrz.nationality ?? '',
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
                mrtdData.dg1?.mrz.gender ?? '',
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
