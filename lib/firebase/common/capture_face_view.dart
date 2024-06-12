import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';


class CaptureFaceView extends StatefulWidget {
  final void Function(Uint8List) onImageCaptured;
  const CaptureFaceView({
    required this.onImageCaptured,
    super.key,
  });

  @override
  State<CaptureFaceView> createState() => _CaptureFaceViewState();
}

class _CaptureFaceViewState extends State<CaptureFaceView> {
  late final ImagePicker picker;
  File? _image;

  @override
  void initState() {
    super.initState();

    picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //SizedBox(height: 80),
        Text(
          'FaceID authentication',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[850]?.withOpacity(0.9),
          ),
        ),
       // SizedBox(height: 50),

        Text(
          'take a picture and click on the button.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[850]?.withOpacity(0.9),
          ),
        ),
        SizedBox(height: 50),
        Container(
          width: 220, // Adjust based on the size you need
          height: 220, // Adjust based on the size you need
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.amber, // Border color
              width: 4.0, // Border width
            ),
          ),
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.black,
            backgroundImage: _image == null ? null : FileImage(_image!),
            child: _image == null
                ? Center(
              child: Image.asset(
                "assets/face_id.png",
                height: 200,
                fit: BoxFit.cover, // Ensures the image fits well
              ),
            )
                : null,
          ),
        ),

        GestureDetector(
          onTap: () async {
            setState(() {
              _image = null;
            });
            final pickedImage = await picker.pickImage(
              source: ImageSource.camera,
              maxHeight: 400,
              maxWidth: 400,
            );

            if (pickedImage == null) {
              return;
            }

            final imagePath = pickedImage.path;

            setState(() {
              _image = File(imagePath);
            });

            final imageBytes = _image!.readAsBytesSync();

            widget.onImageCaptured(imageBytes);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 60),
            height: 80,
            width: 80, // Ensure the container is circular
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                focal: Alignment.center,
                focalRadius: 0.1,
                stops: [0.7, 1.0],
                colors: [
                  Colors.black,
                  Colors.amber,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Changes position of shadow
                ),
              ],
              border: Border.all(
                color: Colors.amber,
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt, // Replace with the desired icon
                color: Colors.amber,
                size: 48,
              ),
            ),
          ),

        ),
        const SizedBox(height: 10),
        Text(
          'take a picture',
          style: TextStyle(
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 20),

      ],
    );
  }
}
