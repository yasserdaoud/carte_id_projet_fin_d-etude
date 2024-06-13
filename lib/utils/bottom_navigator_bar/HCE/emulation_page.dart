import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../nfc/format/mrtd_data.dart';

class EmulationPage extends StatefulWidget {
  final MrtdData mrtdData;

  EmulationPage({required this.mrtdData});

  @override
  _EmulationPageState createState() => _EmulationPageState();
}

class _EmulationPageState extends State<EmulationPage> {
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
}
