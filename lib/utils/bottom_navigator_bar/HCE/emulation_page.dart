import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../nfc/format/mrtd_data.dart';

class EmulationPage extends StatelessWidget {
  final MrtdData mrtdData;

  EmulationPage({required this.mrtdData});



  static const MethodChannel _hceChannel = MethodChannel('com.yourcompany.yourapp/hce');

  Future<void> startEmulation(BuildContext context) async {
    try {
      final bool isServiceStarted = await _hceChannel.invokeMethod('startHceService');
      if (isServiceStarted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HCE Service Started')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start HCE Service')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start HCE Service: ${e.toString()}')),
      );
    }
  }



  Future<void> stopEmulation(BuildContext context) async {
    try {
      await _hceChannel.invokeMethod('stopHceService');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('HCE Service Stopped')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop HCE Service: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        //elevation: 0,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Use the buttons below to start or stop card.dart emulation.',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startEmulation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
                  Icon(Icons.play_circle_sharp, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Start Emulation', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => stopEmulation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
                  Icon(Icons.stop_circle_sharp, color: Colors.black),
                  SizedBox(width: 8),
                  Text('Stop Emulation', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
