import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../nfc/format/mrtd_data.dart';
import 'id_card_class.dart';



class CardPage extends StatefulWidget {
  final MrtdData mrtdData;

  CardPage({required this.mrtdData});
  @override
  _CardPageState createState() => _CardPageState();
}
class _CardPageState extends State<CardPage> {
  final PageController _pageController = PageController();
  bool _isShown = true; // Add this line


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics:  NeverScrollableScrollPhysics(),
              children:   [

                Center(child: CardView()),

              ],
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}


class CardView extends StatelessWidget {
  const CardView({super.key});

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: Theme.of(context).colorScheme.background,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: Theme.of(context).colorScheme.background,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          animSpeedFactor: 2,
          child: ListView(
            children: const [
              Padding(
                padding: EdgeInsets.all(0), // Adjust the padding as needed
                child: Align(
                  alignment: Alignment.topCenter, // Changed to topCenter for slight lower positioning
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: IDCard(),
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