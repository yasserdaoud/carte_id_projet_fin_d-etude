import 'package:flutter/material.dart';

class MRZCameraOverlay extends StatelessWidget {
  const MRZCameraOverlay({
    required this.child,
    Key? key,
  }) : super(key: key);

  static const _documentFrameRatio = 1.585; // Passport's size (ISO/IEC 7810 ID-3) is 125mm × 88mm
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final overlayRect = _calculateOverlaySize(constraints.biggest);
        return Stack(
          children: [
            child,
            _buildClipPath(overlayRect),
            _buildWhiteOverlay(overlayRect),
            _buildGuidanceText(overlayRect),
          ],
        );
      },
    );
  }

  Widget _buildClipPath(RRect overlayRect) {
    return ClipPath(
      clipper: _DocumentClipper(rect: overlayRect),
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
        ),
      ),
    );
  }

  Widget _buildWhiteOverlay(RRect overlayRect) {
    return Positioned(
      left: overlayRect.left,
      top: overlayRect.top,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        width: overlayRect.width,
        height: overlayRect.height,
        decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: Colors.amber),
          borderRadius: BorderRadius.all(overlayRect.tlRadius),
        ),
      ),
    );
  }

  Widget _buildGuidanceText(RRect overlayRect) {
    return Positioned(
      left: overlayRect.left,
      top: overlayRect.top - 30,
      width: overlayRect.width,
      child: Text(
        'Align the document within the frame',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.amber,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  RRect _calculateOverlaySize(Size size) {
    double width, height;
    if (size.height > size.width) {
      height = size.width * 0.9; // Inverted height and width calculations
      width = height / _documentFrameRatio;
    } else {
      width = size.height * 0.75; // Inverted width and height calculations
      height = width * _documentFrameRatio;
    }
    final topOffset = (size.height - height) / 2;
    final leftOffset = (size.width - width) / 2;

    return RRect.fromLTRBR(leftOffset, topOffset, leftOffset + width, topOffset + height, const Radius.circular(8));
  }
}

class _DocumentClipper extends CustomClipper<Path> {
  _DocumentClipper({
    required this.rect,
  });

  final RRect rect;

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(rect)
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_DocumentClipper oldClipper) => false;
}
