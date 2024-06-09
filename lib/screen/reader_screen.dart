import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:convert/convert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import '../library/MRZ/mrz_parser/src/mrz_result.dart';
import '../utils/nfc/converter/date_converter.dart';
import '../utils/nfc/internal.dart';
import 'display_mrtd_data_screen.dart';

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
  Timer? _nfcCheckTimer;

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

  @override
  void dispose() {
    _nfcCheckTimer?.cancel();
    super.dispose();
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

  void _checkNfcAvailabilityPeriodically() {
    _nfcCheckTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      bool isNfcAvailable;
      try {
        NfcStatus status = await NfcProvider.nfcStatus;
        isNfcAvailable = status == NfcStatus.enabled;
      } on PlatformException {
        isNfcAvailable = false;
      }

      if (isNfcAvailable) {
        _nfcCheckTimer?.cancel();
        setState(() {
          _isNfcAvailable = true;
        });
        _readMRTD();
      }
    });
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(mrtdData: mrtdData, rawHandSignatureData: rawHandSignatureData),
        ),
      );

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

  void _openSettings() async {
    final intent = AndroidIntent(
      action: 'android.settings.NFC_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
    _checkNfcAvailabilityPeriodically();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
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
                if (_isNfcAvailable && !_isReading) ...[
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/back.png', // Ensure this path is correct
                    height: 100, // Adjust height as needed
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Please hold your NFC-enabled device near the document to start reading.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: _readMRTD,
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
                        Icon(Icons.nfc_outlined, color: Colors.grey[850]?.withOpacity(0.9)),
                        SizedBox(width: 8),
                        Text(
                          'Start read NFC',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[850]?.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!_isNfcAvailable) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _openSettings,
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
                        Icon(Icons.settings, color: Colors.grey[850]?.withOpacity(0.9)),
                        SizedBox(width: 8),
                        Text(
                          'Enable NFC',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[850]?.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
