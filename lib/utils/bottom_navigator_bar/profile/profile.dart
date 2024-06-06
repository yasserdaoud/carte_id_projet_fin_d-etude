import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../nfc/format/mrtd_data.dart';
import 'data_save.dart';
import 'export_data.dart';

class ProfilePage extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;
  final bool isVotingStarted;

  ProfilePage({required this.mrtdData, this.rawHandSignatureData, this.isVotingStarted = false});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          '${widget.mrtdData.dg1?.mrz.firstName} ${widget.mrtdData.dg1?.mrz.lastName}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () => _showFullSizeImage(context, widget.mrtdData.dg2!.imageData!),
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: MemoryImage(widget.mrtdData.dg2!.imageData!),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _isVisible ? _profileDetails() : Container(),
            _isVisible ? _signatureSection() : Container(),
            SizedBox(height: 40),
            _saveButton(),
            _nfcButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFullSizeImage(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
          _showFullSizeImageWithoutBackground(context, imageData);
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              ModalBarrier(color: Colors.black.withOpacity(0.5)),
              Positioned(
                bottom: 280.0,
                left: 27.0,
                right: 27.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.amber, width: 2.0),
                    color: Colors.grey[850],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                      image: MemoryImage(imageData),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16.0,
                right: 16.0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.amber),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullSizeImageWithoutBackground(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image(
                  image: MemoryImage(imageData),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: Border.all(color: Colors.amber, width: 2.0),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailsChip('NIN', widget.mrtdData.dg11!.personalNumber!),
                const SizedBox(height: 5),
                _detailsChip('Document Number', widget.mrtdData.dg1!.mrz.documentNumber),
                const SizedBox(height: 5),
                _detailsChip('Date of Birth', DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth)),
                const SizedBox(height: 5),
                _detailsChip('Nationality', widget.mrtdData.dg1!.mrz.nationality),
                const SizedBox(height: 5),
                _detailsChip('Date of Expiry', DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _signatureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          border: Border.all(color: Colors.amber, width: 2.0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Signature',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.amber,
                ),
              ),
            ),
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.memory(
                  widget.rawHandSignatureData!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: () async {
          if (!widget.isVotingStarted) {
            await _saveProfile();
          }
          await exportDatabaseToTxt();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile saved and profile exported')),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.black),
            SizedBox(width: 8),
            Text(
              widget.isVotingStarted ? 'Start Voting' : 'Save',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nfcButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: _sendDataViaNFC,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Send via NFC',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendDataViaNFC() async {
    var profileData = {
      'documentNumber': widget.mrtdData.dg1!.mrz.documentNumber,
      'firstName': widget.mrtdData.dg1!.mrz.firstName,
      'lastName': widget.mrtdData.dg1!.mrz.lastName,
      'dateOfBirth': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth),
      'nationality': widget.mrtdData.dg1!.mrz.nationality,
      'dateOfExpiry': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry),
      'imageData': base64Encode(widget.mrtdData.dg2!.imageData!),
      'signatureData': base64Encode(widget.rawHandSignatureData!)
    };

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      print('NFC: NFC is available');

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Convert profile data to JSON and then to bytes
            String profileDataString = jsonEncode(profileData);
            Uint8List profileDataBytes = Uint8List.fromList(profileDataString.codeUnits);

            // Create an NDEF message
            NdefMessage ndefMessage = NdefMessage([
              NdefRecord.createMime('application/json', profileDataBytes),
            ]);

            // Write the NDEF message to the tag
            Ndef? ndef = Ndef.from(tag);
            if (ndef == null) {
              print('NFC: Tag is not NDEF compliant');
              NfcManager.instance.stopSession(errorMessage: 'NFC tag is not NDEF compliant');
              return;
            }

            await ndef.write(ndefMessage);
            print('NFC: Data sent via NFC');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data sent via NFC')),
            );
            NfcManager.instance.stopSession();
          } catch (e) {
            print('NFC: Error - ${e.toString()}');
            NfcManager.instance.stopSession(errorMessage: e.toString());
          }
        },
        onError: (NfcError error) async {
          print('NFC: Error - ${error.message}');
        },
      );
    } else {
      print('NFC: NFC is not available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC is not available on this device')),
      );
    }
  }

  Future<void> _saveProfile() async {
    var profileData = {
      'documentNumber': widget.mrtdData.dg1!.mrz.documentNumber,
      'firstName': widget.mrtdData.dg1!.mrz.firstName,
      'lastName': widget.mrtdData.dg1!.mrz.lastName,
      'dateOfBirth': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth),
      'nationality': widget.mrtdData.dg1!.mrz.nationality,
      'dateOfExpiry': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry),
      'imageData': widget.mrtdData.dg2!.imageData,
      'signatureData': widget.rawHandSignatureData
    };

    final dbHelper = DatabaseHelper.instance;
    int id = await dbHelper.insertProfile(profileData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileSaved', true);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainApp()),
    );
  }
}
