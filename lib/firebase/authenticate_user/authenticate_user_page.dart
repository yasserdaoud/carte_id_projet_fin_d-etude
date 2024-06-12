import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:shared_preferences/shared_preferences.dart';
import '../common/capture_face_view.dart';
import '../common/snack_bars.dart';
import '../models/user.dart';
import 'scanning_animation/animated_view.dart';
import 'user_authenticated_page.dart';
import 'dart:typed_data';
import '../../utils/nfc/format/mrtd_data.dart';

class AuthenticateUserPage extends StatefulWidget {
  final MrtdData mrtdData;
  final Uint8List? rawHandSignatureData;

  const AuthenticateUserPage({
    Key? key,
    required this.mrtdData,
    this.rawHandSignatureData,
  }) : super(key: key);

  @override
  State<AuthenticateUserPage> createState() => _AuthenticateUserPageState();
}

class _AuthenticateUserPageState extends State<AuthenticateUserPage> {
  final image1 = regula.MatchFacesImage();
  final image2 = regula.MatchFacesImage();

  bool canAuthenticate = false;
  bool faceMatched = false;
  bool isMatching = false;

  String similarity = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 60), // Add some space below the AppBar

            SizedBox(height: 20),
            Stack(
              children: [
                CaptureFaceView(
                  onImageCaptured: (imageBytes) {
                    setState(() {
                      image1.bitmap = base64Encode(imageBytes);
                      image1.imageType = regula.ImageType.PRINTED;
                      canAuthenticate = true;
                    });
                  },
                ),
                if (isMatching)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 110),
                      child: AnimatedView(),
                    ),
                  ),
              ],
            ),
            if (canAuthenticate)
              Padding(
                padding: const EdgeInsets.only(top: 20), // Added top padding
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMatching = true;
                      });

                      FirebaseFirestore.instance
                          .collection('users')
                          .get()
                          .then((snap) async {
                        if (snap.docs.isNotEmpty) {
                          for (var doc in snap.docs) {
                            try {
                              final user = User.fromJson(doc.data() ?? {});

                              if (user.image == null || user.image.isEmpty) {
                                print('User image is null or empty');
                                continue;
                              }

                              image2.bitmap = user.image;
                              image2.imageType = regula.ImageType.PRINTED;

                              var request = regula.MatchFacesRequest();
                              request.images = [image1, image2];

                              var value = await regula.FaceSDK.matchFaces(jsonEncode(request));
                              var response = regula.MatchFacesResponse.fromJson(json.decode(value));

                              if (response != null && response.results != null) {
                                var str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(jsonEncode(response.results), 0.75);
                                var split = regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));

                                if (split != null && split.matchedFaces.isNotEmpty) {
                                  final matchedFace = split.matchedFaces[0];
                                  if (matchedFace != null && matchedFace.similarity != null) {
                                    similarity = (matchedFace.similarity! * 100).toStringAsFixed(2);
                                    print('Similarity: $similarity'); // Debug line

                                    if (double.parse(similarity) > 90.00) {
                                      faceMatched = true;

                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      await prefs.setBool('isSignedIn', true);

                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => UserAuthenticatedPage(Firstname: user.firstName,
                                            Lastname: user.lastName,
                                            mrtdData: widget.mrtdData,
                                            rawHandSignatureData: widget.rawHandSignatureData,),
                                        ),
                                      );
                                      break;
                                    }
                                  }
                                }
                              }
                            } catch (e) {
                              print('Error processing user: $e'); // Debug line
                            }
                          }

                          setState(() {
                            isMatching = false;
                          });

                          if (!faceMatched) {
                            errorSnackBar(context, 'You are Not the Owner Of this ID card \n If you insist take another Picture and Try again ! ');
                          }
                        } else {
                          errorSnackBar(context, 'Sorry retry');
                        }
                      }).catchError((error) {
                        setState(() {
                          isMatching = false;
                        });
                        print('Error during authentication: $error'); // Debug line
                        errorSnackBar(context, 'Error during authentication. Please try again.');
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_outlined, color: Colors.black,),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                     // elevation: 5,
                    ),
                  ),
                ),
              ),
            SizedBox()
          ],
        ),
      ),
    );
  }
}
