import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../firebase/authenticate_user/authenticate_user_page.dart';
import '../../../main.dart';
import '../../nfc/format/mrtd_data.dart';

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
  bool _nfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  void _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _nfcAvailable = isAvailable;
    });
    if (isAvailable) {
      _startNfcSession();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NFC is not available on this device')),
      );
    }
  }

  void _startNfcSession() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);
          if (ndef == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tag is not NDEF')),
            );
            NfcManager.instance.stopSession(errorMessage: "Tag is not NDEF");
            return;
          }

          await _sendNfcData(ndef);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent successfully')),
          );
          NfcManager.instance.stopSession();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending message: $e')),
          );
          NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
      onError: (error) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('NFC Error: $error')),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    var profileData = {
      'firstName': widget.mrtdData.dg1!.mrz.firstName,
      'lastName': widget.mrtdData.dg1!.mrz.lastName,
      'documentNumber': widget.mrtdData.dg1!.mrz.documentNumber,
      'dateOfBirth': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfBirth),
      'nationality': widget.mrtdData.dg1!.mrz.nationality,
      'expiryDate': DateFormat.yMd().format(widget.mrtdData.dg1!.mrz.dateOfExpiry),
      'image': base64Encode(widget.mrtdData.dg2!.imageData!), // Encoding image to base64 string
      'nationalIdentificationNumber': widget.mrtdData.dg11!.personalNumber,
    };

    // Save to Firestore
    FirebaseFirestore.instance.collection('users').add(profileData).then((docRef) {
      print("User data saved to Firestore with ID: ${docRef.id}");
      print("National identification number: ${widget.mrtdData.dg11!.personalNumber}");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AuthenticateUserPage(),
        ),
      );
    }).catchError((error) {
      print("Failed to save user data: $error");
    });
  }


  Future<void> _sendNfcData(Ndef ndef) async {
    try {
      final Map<String, dynamic> data = {
        'firstName': widget.mrtdData.dg1?.mrz.firstName,
        'lastName': widget.mrtdData.dg1?.mrz.lastName,
        'documentNumber': widget.mrtdData.dg1?.mrz.documentNumber,
        'dateOfBirth': widget.mrtdData.dg1?.mrz.dateOfBirth.toIso8601String(),
        'nationality': widget.mrtdData.dg1?.mrz.nationality,
        'dateOfExpiry': widget.mrtdData.dg1?.mrz.dateOfExpiry.toIso8601String(),
        'imageData': widget.mrtdData.dg2?.imageData != null
            ? base64Encode(widget.mrtdData.dg2!.imageData!)
            : null,
        'signatureData': widget.rawHandSignatureData != null
            ? base64Encode(widget.rawHandSignatureData!)
            : null,
      };
      final String jsonData = jsonEncode(data);

      // Create NDEF message
      NdefMessage ndefMessage = NdefMessage([
        NdefRecord.createText(jsonData),
      ]);

      await ndef.write(ndefMessage);
    } catch (e) {
      print('Failed to send NFC data: ${e.toString()}');
      throw e;
    }
  }

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
          ],
        ),
      ),
    );
  }

  void _showFullSizeImage(BuildContext context, Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
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
                child: widget.rawHandSignatureData != null
                    ? Image.memory(
                  widget.rawHandSignatureData!,
                  fit: BoxFit.contain,
                )
                    : Text('Pas de données de signature'),
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainApp()),
    );
  }
}
