import 'package:flutter/material.dart';
import 'package:id_card_example/utils/bottom_navigator_bar/profile/profile.dart';
import '../../screen/home_screen.dart';
import '../nfc/format/mrtd_data.dart';
import 'dart:typed_data';
import 'HCE/emulation_page.dart';
import 'card/card_page.dart';

class MainPage extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  const MainPage({
    Key? key,
    required this.mrtdData,
    this.rawHandSignatureData,
  }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [

      ProfilePage(
        mrtdData: widget.mrtdData,
        rawHandSignatureData: widget.rawHandSignatureData,
      ),

      EmulationPage(
        mrtdData: widget.mrtdData,
      ),
      CardPage(
        mrtdData: widget.mrtdData,
        rawHandSignatureData: widget.rawHandSignatureData,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc),
            label: 'Emulation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Card',
          ),
        ],
      ),
    );
  }
}