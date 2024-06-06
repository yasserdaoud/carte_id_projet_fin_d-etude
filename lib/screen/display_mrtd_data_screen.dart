import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/nfc/converter/jpeg2000_converter.dart';
import '../utils/nfc/format/format_dg11.dart';
import '../utils/nfc/format/format_dg12.dart';
import '../utils/nfc/format/format_efcom.dart';
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
      widgets.add(_buildDataSection('MRZ', formatMRZ(_mrtdData.dg1!.mrz)));
    }

    if (_mrtdData.dg11 != null) {
      widgets.add(_buildDataSection('EF.DG11', formatDG11(_mrtdData.dg11!)));
    }

    if (_mrtdData.dg12 != null) {
      widgets.add(_buildDataSection('EF.DG12', formatDG12(_mrtdData.dg12!)));
    }

    return widgets;
  }

  Widget _buildDataSection(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        SizedBox(height: 8),
        SelectableText(
          data,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        //elevation: 0,
        title: const Text(
          "Result",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[

// const SizedBox(height: 20),

//  if (jpegImage != null || jp2000Image != null)
//  Column(
//    children: [
//    Align(
//      alignment: Alignment.centerLeft,
//     child: Text(
//      "Image",
//     style: TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 20,
//       color: Colors.white,
//     ),
//   ),
//   ),
//  SizedBox(height: 10),
//  ClipRRect(
//   borderRadius: BorderRadius.circular(10),
//   child: Image.memory(
//     jpegImage!,
//      errorBuilder: (context, error, stackTrace) => SizedBox(),
//    ),
//   ),
//   ],
// ),
// if (rawHandSignatureData != null)
// Column(
//  mainAxisAlignment: MainAxisAlignment.start,
//   children: [
//    SizedBox(height: 20),
//   Text(
//     "Signature",
//    style: TextStyle(
//      fontWeight: FontWeight.bold,
//      fontSize: 20,
//     color: Colors.white,
//    ),
//   ),
//  SizedBox(height: 10),
//   ClipRRect(
//    borderRadius: BorderRadius.circular(10),
//    child: Image.memory(
//    rawHandSignatureData!,
//     errorBuilder: (context, error, stackTrace) => SizedBox(),
//    ),
//  ),
//  ],
// ),
// SizedBox(height: 20),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850]?.withOpacity(0.9), // Ajout de l'opacité ici
                    border: Border.all(color: Colors.amber, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildDataWidgets(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isSignedIn', true);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          mrtdData: _mrtdData,
                          rawHandSignatureData: rawHandSignatureData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.grey[850]?.withOpacity(0.9),),
                      SizedBox(width: 8),
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
      ),
    );
  }
}
