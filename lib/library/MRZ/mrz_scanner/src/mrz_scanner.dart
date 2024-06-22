import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:id_card_example/library/MRZ/mrz_parser/src/mrz_result.dart';
import 'package:id_card_example/library/MRZ/mrz_scanner/mrz_scanner.dart';
import 'camera_view.dart';
import 'mrz_helper.dart';

class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key? controller,
    required this.onSuccess,
    this.initialDirection = CameraLensDirection.back,
    this.showOverlay = true,
  }) : super(key: controller);

  final Function(MRZResult mrzResult, List<String> lines) onSuccess;
  final CameraLensDirection initialDirection;
  final bool showOverlay;

  @override
  MRZScannerState createState() => MRZScannerState();
}

class MRZScannerState extends State<MRZScanner> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  List<String> _results = [];

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MRZCameraView(
      showOverlay: widget.showOverlay,
      initialDirection: widget.initialDirection,
      onImage: _processImage,
    );
  }

  void _parseScannedText(List<String> lines) {
    try {
      final data = MRZParser.parse(lines);
      widget.onSuccess(data, lines);
    } catch (e) {
      // Handle parsing error if needed
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      String fullText = recognizedText.text.replaceAll(' ', '');
      List<String> allText = fullText.split('\n');
      List<String> ableToScanText = [];

      for (var line in allText) {
        String processedLine = MRZHelper.testTextLine(line);
        if (processedLine.isNotEmpty) {
          ableToScanText.add(processedLine);
        }
      }

      List<String>? result = MRZHelper.getFinalListToParse(ableToScanText);

      if (result != null) {
        _results.add(result.join());

        if (_results.length > 3) {
          _results.removeAt(0);
        }

        if (_results.length == 3 && _results.toSet().length == 1) {
          _parseScannedText(result);
        } else {
          _isBusy = false;
        }
      } else {
        _isBusy = false;
      }
    } catch (e) {
      // Handle any processing errors if needed
      _isBusy = false;
    }
  }
}
