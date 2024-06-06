/*
import 'package:convert/convert.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../library/MRZ/mrz_parser/src/mrz_result.dart';
import '../utils/bottom_navigator_bar/main_page.dart';
import '../utils/nfc/converter/date_converter.dart';
import '../utils/nfc/format/format_dg11.dart';
import '../utils/nfc/format/format_dg12.dart';
import '../utils/nfc/format/format_mrz.dart';
import '../utils/nfc/internal.dart';
import 'bouton.dart';




class MrtdHomePage extends StatefulWidget {
  const MrtdHomePage({super.key, required this.mrzResult});
  final MRZResult mrzResult;

  @override
  _MrtdHomePageState createState() => _MrtdHomePageState();
}

class _MrtdHomePageState extends State<MrtdHomePage> {
  var _alertMessage = "";
  final _log = Logger("mrtdeg.app");
  var _isNfcAvailable = false;
  var _isReading = false;
  String? docNumber;
  String? dob;
  String? doe;

  MrtdData? _mrtdData;

  final NfcProvider _nfc = NfcProvider();
  final _scrollController = ScrollController();


  @override
  void initState() {
    docNumber = widget.mrzResult.documentNumber;
    dob = convertDateTimeToDateString(widget.mrzResult.birthDate);
    doe = convertDateTimeToDateString(widget.mrzResult.expiryDate);

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _initPlatformState();
  }

  DateTime? _getDOBDate() {
    if (dob!.isEmpty) return null;
    return DateFormat.yMd().parse(dob!);
  }

  DateTime? _getDOEDate() {
    if (doe!.isEmpty) return null;
    return DateFormat.yMd().parse(doe!);
  }

  Uint8List? rawImageData;
  Uint8List? rawHandSignatureData;

  String extractImageData(String inputHex) {
    int startIndex = inputHex.indexOf('ffd8');
    int endIndex = inputHex.indexOf('ffd9');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      String extractedImageData = inputHex.substring(startIndex, endIndex + 4);
      return extractedImageData;
    } else {
      print("FFD8 and/or FFD9 markers not found in the input hex string.");
      return inputHex;
    }
  }

  Future<void> _initPlatformState() async {
    bool isNfcAvailable;
    try {
      NfcStatus status = await NfcProvider.nfcStatus;
      isNfcAvailable = status == NfcStatus.enabled;
    } on PlatformException {
      isNfcAvailable = false;
    }

    if (!mounted) return;

    setState(() {
      _isNfcAvailable = isNfcAvailable;
    });

    if (!_isNfcAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't access device NFC, please try again")),
      );
    }
  }

  void _readMRTD() async {
    try {
      setState(() {
        _mrtdData = null;
        _alertMessage = "Waiting for Document tag ...";
        _isReading = true;
      });

      await _nfc.connect(
          iosAlertMessage: "Hold your phone near Biometric Document");
      final passport = Passport(_nfc);

      setState(() {
        _alertMessage = "Reading Document ...";
      });

      _nfc.setIosAlertMessage("Trying to read EF.CardAccess ...");
      final mrtdData = MrtdData();

      try {
        mrtdData.cardAccess = await passport.readEfCardAccess();
      } on PassportError {}

      _nfc.setIosAlertMessage("Trying to read EF.CardSecurity ...");

      try {
        mrtdData.cardSecurity = await passport.readEfCardSecurity();
      } on PassportError {}

      _nfc.setIosAlertMessage("Initiating session ...");
      final bacKeySeed = DBAKeys(docNumber!, _getDOBDate()!, _getDOEDate()!);
      await passport.startSession(bacKeySeed);

      _nfc.setIosAlertMessage(formatProgressMsg("Reading EF.COM ...", 0));
      mrtdData.com = await passport.readEfCOM();

      _nfc.setIosAlertMessage(formatProgressMsg("Reading Data Groups ...", 20));

      if (mrtdData.com!.dgTags.contains(EfDG1.TAG)) {
        mrtdData.dg1 = await passport.readEfDG1();
      }

      if (mrtdData.com!.dgTags.contains(EfDG2.TAG)) {
        mrtdData.dg2 = await passport.readEfDG2();
      }

      if (mrtdData.com!.dgTags.contains(EfDG7.TAG)) {
        mrtdData.dg7 = await passport.readEfDG7();
        String? imageHex = extractImageData(mrtdData.dg7!.toBytes().hex());
        Uint8List? decodeImageHex =
        Uint8List.fromList(List<int>.from(hex.decode(imageHex)));
        rawHandSignatureData = decodeImageHex;
      }

      if (mrtdData.com!.dgTags.contains(EfDG11.TAG)) {
        mrtdData.dg11 = await passport.readEfDG11();
      }

      if (mrtdData.com!.dgTags.contains(EfDG12.TAG)) {
        mrtdData.dg12 = await passport.readEfDG12();
      }

      /*if (mrtdData.com!.dgTags.contains(EfDG15.TAG)) {
        mrtdData.dg15 = await passport.readEfDG15();
        _nfc.setIosAlertMessage(formatProgressMsg("Doing AA ...", 60));
        mrtdData.aaSig = await passport.activeAuthenticate(Uint8List(8));
      }*/

      _nfc.setIosAlertMessage(formatProgressMsg("Reading EF.SOD ...", 80));
      mrtdData.sod = await passport.readEfSOD();

      setState(() {
        _mrtdData = mrtdData;
        _alertMessage = "";
      });

      if (mrtdData.dg2?.imageData != null) {
        rawImageData = mrtdData.dg2?.imageData;
        tryDisplayingJpg();
      }
      _scrollController.animateTo(300.0,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);

      setState(() {});
    } on Exception catch (e) {
      final se = e.toString().toLowerCase();
      String alertMsg = "An error has occurred while reading Document!";
      if (e is PassportError) {
        if (se.contains("security status not satisfied")) {
          alertMsg =
          "Failed to initiate session with passport.\nCheck input profile!";
        }
        _log.error("PassportError: ${e.message}");
      } else {
        _log.error(
            "An exception was encountered while trying to read Document: $e");
      }

      if (se.contains('timeout')) {
        alertMsg = "Timeout while waiting for Document tag";
      } else if (se.contains("tag was lost")) {
        alertMsg = "Tag was lost. Please try again!";
      } else if (se.contains("invalidated by user")) {
        alertMsg = "";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(se)));

      setState(() {
        _alertMessage = alertMsg;
      });
    } finally {
      if (_alertMessage.isNotEmpty) {
        await _nfc.disconnect(iosErrorMessage: _alertMessage);
      } else {
        await _nfc.disconnect(
            iosAlertMessage: formatProgressMsg("Finished", 100));
      }

      setState(() {
        _isReading = false;
      });
      //startShowcaseTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPage(context);
  }

  Widget _makeMrtdDataWidget({
    required String? header,
    required String collapsedText,
    required String? dataText,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Background color for the ListTile
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(
          header ?? "",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.amber, // Updated text color to amber
          ),
        ),
        onLongPress: () => Clipboard.setData(ClipboardData(text: dataText ?? "Null")),
        subtitle: SelectableText(
          dataText ?? "Null",
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white),
        ),
        //trailing: IconButton(
        // icon: const Icon(
        //   Icons.copy,
        //   color: Colors.amber, // Updated icon color to amber
        //  ),
        //  onPressed: () {
        //   Clipboard.setData(ClipboardData(text: dataText ?? "Null"));
        //  ScaffoldMessenger.of(context).showSnackBar(
        //    const SnackBar(content: Text("Copied")),
        //  );
        // },
        // ),
      ),
    );
  }
  List<Widget> _mrtdDataWidgets() {
    List<Widget> list = [];
    if (_mrtdData == null) return list;

    if (_mrtdData!.com != null) {
      list.add(_makeMrtdDataWidget(
          header: 'EF.COM',
          collapsedText: '',
          dataText: formatEfCom(_mrtdData!.com!)));
    }

    if (_mrtdData?.dg1 != null) {
      list.add(_makeMrtdDataWidget(
          header: null,
          collapsedText: '',
          dataText: formatMRZ(_mrtdData!.dg1!.mrz)));
    }
    //if (_mrtdData?.dg7 != null) {
    // list.add(_makeMrtdDataWidget(
    //     header: 'EF.DG7',
    //     collapsedText: '',
    //     dataText: _mrtdData?.dg7?.toBytes().toString()));
    if (_mrtdData!.dg11 != null) {
      list.add(_makeMrtdDataWidget(
          header: 'EF.DG11',
          collapsedText: '',
          dataText: formatDG11(_mrtdData!.dg11!)));
    }

    if (_mrtdData!.dg12 != null) {
      list.add(_makeMrtdDataWidget(
          header: 'EF.DG12',
          collapsedText: '',
          dataText: formatDG12(_mrtdData!.dg12!)));
    }

    /*if (_mrtdData!.dg15 != null) {
      list.add(_makeMrtdDataWidget(
          header: 'EF.DG15',
          collapsedText: '',
          dataText: formatDG15(_mrtdData!.dg15!)));
    }*/

    return list;
  }

  Scaffold _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Device NFC available:',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isNfcAvailable ? "Yes" : "No",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: _isNfcAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                if (_isNfcAvailable && _isReading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 18,
                    ),
                  ),

                if (_isNfcAvailable && !_isReading)

                  StartReadButton(
                    onPressed: () {
                      _initPlatformState();
                      _readMRTD();
                    },
                  ),

                const SizedBox(height: 10),
                Text(
                  _alertMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                if (jpegImage != null || jp2000Image != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Image",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (jpegImage != null)

                  Column(
                    children: [
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          jpegImage!,
                          errorBuilder: (context, error, stackTrace) => SizedBox(),
                        ),
                      ),
                    ],
                  ),

                if (rawHandSignatureData != null)

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Signature",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          rawHandSignatureData!,
                          errorBuilder: (context, error, stackTrace) => SizedBox(),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _mrtdData != null ? "NFC Scan Data:" : "",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: _mrtdDataWidgets(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_mrtdData != null) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isSignedIn', true);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainPage(
                            mrtdData: _mrtdData!,
                            rawHandSignatureData: rawHandSignatureData,
                          ),
                        ),
                      );
                    }
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
                      Icon(Icons.check, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

  Uint8List? jpegImage;
  Uint8List? jp2000Image;

  void tryDisplayingJpg() {
    try {
      jpegImage = rawImageData;
      setState(() {});
    } catch (e) {
      jpegImage = null;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image is not in jpg format, trying jpeg2000")));
    }
  }

  void tryDisplayingJp2() async {
    try {
      jp2000Image = await decodeImage(rawImageData!, context);
      setState(() {});
    } catch (e) {
      jpegImage = null;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image is not in jpeg2000")));
    }
  }
}
*/
