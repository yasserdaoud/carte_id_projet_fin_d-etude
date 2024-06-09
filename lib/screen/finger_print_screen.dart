import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../main.dart';
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
        _authorized = 'Authenticating...';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Please place your thumb on the fingerprint sensor',
      );
      setState(() {
        _authorized = authenticated ? 'Success' : 'Try again';
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: BackButton(
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
                  color: Colors.white,
                  fontSize: 32,
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
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: _isAuthenticating
                    ? Lottie.asset(
                  'assets/animation/Animation.json',
                  width: 100,
                  height: 100,
                  key: ValueKey('loading'),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 76.0, vertical: 12.0),
                  ),
                  onPressed: _isAuthenticating ? null : _authenticate,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fingerprint_sharp),
                      SizedBox(width: 8.0),
                      Text('Authenticate'),
                    ],
                  ),
                  key: ValueKey('button'),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _isAuthenticating ? 0.5 : 1.0,
                duration: Duration(milliseconds: 500),
                child: Text(
                  _authorized,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
