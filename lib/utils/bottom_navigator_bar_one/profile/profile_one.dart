import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

class ProfilePageOne extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePageOne({Key? key, required this.userData}) : super(key: key);

  @override
  _ProfilePageOneState createState() => _ProfilePageOneState();
}

class _ProfilePageOneState extends State<ProfilePageOne> {
  Uint8List? imageData;
  Uint8List? signatureData;
  String? errorMessage;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    try {
      imageData = Uint8List.fromList(List<int>.from(widget.userData['imageData']));
      if (widget.userData.containsKey('signatureData') && widget.userData['signatureData'] != null) {
        signatureData = base64Decode(widget.userData['signatureData']);
      }
    } catch (e) {
      errorMessage = "Failed to load image data: $e";
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Encode user data as JSON string
  String encodeUserData(Map<String, dynamic> userData) {
    return jsonEncode(userData);
  }

  // Convert string to hex representation
  String toHex(String input) {
    List<int> bytes = utf8.encode(input);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  // Start NFC data transfer
  Future<void> _startNFCTransfer() async {
    try {
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        if (mounted) {
          setState(() {
            errorMessage = 'NFC is not available on this device';
          });
        }
        return;
      }

      await FlutterNfcKit.poll();
      var userDataString = encodeUserData(widget.userData);
      var userDataHex = toHex(userDataString);  // Convert data to hex string

      // Start NFC transmission in chunks to handle large data
      for (int i = 0; i < userDataHex.length; i += 256) {
        var chunk = userDataHex.substring(i, i + 256 > userDataHex.length ? userDataHex.length : i + 256);
        await FlutterNfcKit.transceive(chunk);
      }

      await FlutterNfcKit.finish();
      if (mounted) {
        setState(() {
          errorMessage = 'Data transferred successfully';
        });
      }
    } catch (e) {
      print("NFC Transfer Error: $e");
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to transfer data: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          '${widget.userData['lastName']} ${widget.userData['firstName']}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: imageData != null
            ? GestureDetector(
          onTap: () => _showFullSizeImage(context, imageData!),
          child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: MemoryImage(imageData!),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
        )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _isVisible = !_isVisible;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(Icons.nfc, color: Colors.white),
            onPressed: _startNFCTransfer,
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
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
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
                _detailsChip('NIN', widget.userData['nationalIdentificationNumber']),
                const SizedBox(height: 5),
                _detailsChip('Document Number', widget.userData['documentNumber']),
                const SizedBox(height: 5),
                _detailsChip('Date of Birth', widget.userData['dateOfBirth']),
                const SizedBox(height: 5),
                _detailsChip('Nationality', widget.userData['nationality']),
                const SizedBox(height: 5),
                _detailsChip('Date of Expiry', widget.userData['dateOfExpiry']),
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
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainApp()),
      );
    }
  }
}
