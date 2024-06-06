import 'package:flutter/material.dart';

class IDCardFrontWidget extends StatelessWidget {
  final String uniqueCardNumber = '402837090';
  final String issuingAuthority = 'بلدية عنابة-عنابة';
  final String releaseDate = '2022.09.05';
  final String expiryDate = '2032.09.04';
  final String nationalIdNumber = '109980773022950005';
  final String lastName = 'ياسر';
  final String firstName = 'داود';
  final String dateOfBirth = '1998.10.12';
  final String placeOfBirth = 'الحروش';
  final String sex = 'ذكر';
  final String bloodType = 'B+';

  IDCardFrontWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 583.2, // CR80 card size in points
      height: 367.2,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/back1.png'),
          //fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
       // boxShadow: const [
        //  BoxShadow(
         //   color: Colors.black12,
         //   blurRadius: 4,
         //   offset: Offset(0, 4),
         // ),
      //  ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: <Widget>[
            Positioned(left: 190, top: 80, child: Text(uniqueCardNumber, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 110, top: 96, child: Text(issuingAuthority, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 110, top: 124, child: Text(releaseDate, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 110, top: 148, child: Text(expiryDate, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 147, top: 205, child: Text(nationalIdNumber, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 70, top: 261, child: Text(lastName, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 70, top: 220, child: Text(firstName, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(right: 100, top: 299, child: Text(dateOfBirth, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
            Positioned(right: 100, top: 318, child: Text(placeOfBirth, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(left: 300, top: 296, child: Text(sex, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold))),
            Positioned(left: 230, top: 298, child: Text(bloodType, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}