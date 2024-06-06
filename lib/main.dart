import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '/screen/finger_print_screen.dart';


void main() {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print(
          '${record.loggerName} ${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bitaka ID",
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)),
      home: const NfcApp(),
    );
  }
}

class NfcApp extends StatelessWidget {
  const NfcApp({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),

              // Spacer(),
              const Text(
                "Scan your Identity cards",
                style: TextStyle(fontSize: 20,color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: const Text(
                  "Click on the button below to start scanning",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),


              SizedBox(
                height: 300,
              ),




              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Change this color to match your theme
                  padding: EdgeInsets.symmetric(horizontal: 76, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FingerPrintPage(),
                    ),
                  );
                },
                child: const Text(
                  "Start",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Change this color to match your theme
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
