import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '/main.dart';
import 'dart:async';
import '/screen/choose_screen.dart';





class FingerPrintPage extends StatefulWidget {
  const FingerPrintPage({Key? key}) : super(key: key);

  @override
  State<FingerPrintPage> createState() => _FingerPrintPageState();
}

class _FingerPrintPageState extends State<FingerPrintPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Please authenticate';
  bool _isAuthenticating = false;



  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authentification...';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'veuiller placer votre pouce sur le capteur d\'empreinte',
      );
      setState(() {
        _authorized = authenticated ? 'Succées' : 'réessayer';
      });
      if (authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanManual(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _authorized = 'Authentication Error: $e';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    //double width = SizeConfig.screenW!;
   // double height = SizeConfig.screenH!;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: BackButton(
           // style: ButtonStyle(),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NfcApp(),
                  ),
              );
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Mulish",
                  fontWeight: FontWeight.w900,
                  color: Colors.white
                  //fontSize: (width <= 550) ? 30 : 35,
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "Authenticate using your fingerprint instead of your password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Mulish",
                    height: 2,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  //Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.amber,
                  //Theme.of(context).colorScheme.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(
                      color: Colors.black,

                      //Theme.of(context).colorScheme.secondary,
                      width: 2.0,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 76.0, vertical: 12.0),
                ),
                onPressed: _isAuthenticating ? null : _authenticate,
                child: _isAuthenticating
                    ? CircularProgressIndicator()
                    : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fingerprint_sharp),
                  SizedBox(width: 8.0),
                  Text('Authenticate'),
                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


