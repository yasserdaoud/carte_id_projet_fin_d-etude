import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../../main.dart';
import '../../nfc/format/mrtd_data.dart';
import 'back_one.dart';
import 'front_one.dart';
import 'dart:typed_data';




class CardPageOne extends StatefulWidget {
  final Map<String, dynamic> userData;

  CardPageOne({
    required this.userData,Key? key,

  }) : super(key: key);
  @override
  _CardPageOneState createState() => _CardPageOneState();
}
class _CardPageOneState extends State<CardPageOne> {
  final PageController _pageController = PageController();
  bool _isShown = true;
  String? errorMessage;
  Uint8List? imageData;


  @override
  void initState() {
    super.initState();
    try {
      imageData = Uint8List.fromList(List<int>.from(widget.userData['imageData']));

    } catch (e) {
      errorMessage = "Failed to load image data: $e";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "MyID",
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
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics:  NeverScrollableScrollPhysics(),
              children:   [

                Center(child: IDCard(userData: widget.userData )),

              ],
            ),
          ],
        ),
      ),

    );
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainApp()),
    );
  }
}


class IDCard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const IDCard({
    required this.userData,Key? key,

  }) : super(key: key);

  @override
  _IDCardState createState() => _IDCardState();
}

class _IDCardState extends State<IDCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final angle = _controller.value * pi;
          // Adjust the angle for a smoother transition and perspective.
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // add perspective
            ..rotateX(angle);

          // Toggle the child widget at the half rotation point.
          if (angle >= pi / 2) {
            transform.rotateX(pi); // complete the flip
          }

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= pi / 2 ? IDCardBackWidget(userData: widget.userData) :
            IDCardFrontWidget(userData: widget.userData),
          );
        },
      ),
    );
  }
}