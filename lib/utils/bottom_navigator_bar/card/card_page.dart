import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../nfc/format/mrtd_data.dart';
import 'back.dart';
import 'front.dart';
import 'dart:typed_data';




class CardPage extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  CardPage({required this.mrtdData,this.rawHandSignatureData});
  @override
  _CardPageState createState() => _CardPageState();
}
class _CardPageState extends State<CardPage> {
  final PageController _pageController = PageController();
  bool _isShown = true; // Add this line


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
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics:  NeverScrollableScrollPhysics(),
              children:   [

                Center(child: IDCard(mrtdData: widget.mrtdData,
                  rawHandSignatureData: widget.rawHandSignatureData, )),

              ],
            ),
          ],
        ),
      ),

    );
  }


}


class IDCard extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  const IDCard({required this.mrtdData, this.rawHandSignatureData, Key? key}) : super(key: key);

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
            child: angle >= pi / 2 ? IDCardBackWidget(mrtdData: widget.mrtdData,
              rawHandSignatureData: widget.rawHandSignatureData,) :
            IDCardFrontWidget(mrtdData: widget.mrtdData),
          );
        },
      ),
    );
  }
}