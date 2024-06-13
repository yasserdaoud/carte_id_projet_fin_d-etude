import 'package:flutter/material.dart';
import 'package:id_card_example/utils/bottom_navigator_bar_one/profile/profile_one.dart';
import 'HCE/emulation_page_one.dart';
import 'card/card_page_one.dart';

class MainPageOne extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MainPageOne({
    required this.userData,Key? key,

  }) : super(key: key);

  @override
  _MainPageOneState createState() => _MainPageOneState();
}

class _MainPageOneState extends State<MainPageOne> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [

      ProfilePageOne(
          userData: widget.userData
      ),

      EmulationPageOne(
          userData: widget.userData
      ),
      CardPageOne(
          userData: widget.userData
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