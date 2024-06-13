import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';


class EmulationPageOne extends StatefulWidget {
  final Map<String, dynamic> userData;

  EmulationPageOne({Key? key, required this.userData}) : super(key: key);

  @override
  _EmulationPageOneState createState() => _EmulationPageOneState();
}

class _EmulationPageOneState extends State<EmulationPageOne> {
  Uint8List? imageData;
  Uint8List? signatureData;
  String? errorMessage;


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
    setState(() {});
  }




  static const MethodChannel _hceChannel = MethodChannel('com.yourcompany.yourapp/hce');
  bool isServiceRunning = false;

  Future<void> toggleEmulation(BuildContext context) async {
    try {
      if (isServiceRunning) {
        await _hceChannel.invokeMethod('stopHceService');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HCE1 Service Stopped')),
        );
      } else {
        final bool isServiceStarted = await _hceChannel.invokeMethod('startHceService');
        if (isServiceStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('HCE1 Service Started')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to start HCE1 Service')),
          );
        }
      }
      setState(() {
        isServiceRunning = !isServiceRunning;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${isServiceRunning ? 'stop' : 'start'} HCE1 Service: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: imageData != null
            ? GestureDetector(
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
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],

      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Use the button below to start or stop card.dart emulation.',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => toggleEmulation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isServiceRunning ? Colors.red : Colors.green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isServiceRunning ? Icons.stop_circle_sharp : Icons.play_circle_sharp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isServiceRunning ? 'Stop Emulation' : 'Start Emulation',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
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
