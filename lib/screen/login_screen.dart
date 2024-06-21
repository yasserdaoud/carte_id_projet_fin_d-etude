import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/bottom_navigator_bar_one/main_page_one.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _documentNumberController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login(BuildContext context) async {
    final documentNumber = _documentNumberController.text.trim();

    if (documentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your document number.')),
      );
      return;
    }

    if (documentNumber.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your document number is incorrect, try again.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch user data from Firestore based on the personal number
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('documentNumber', isEqualTo: documentNumber)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        print("User data fetched from Firestore: $userData");

        // Navigate to the success animation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen(userData: userData)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please check your document number.')),
        );
      }
    } catch (error) {
      print("Failed to fetch user data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/login_id.png', // Ensure you have this image in your assets folder
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please enter your document Number to login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Mulish",
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  controller: _documentNumberController,
                  labelText: 'Document Number',
                  icon: Icons.person,
                  validator: (value) {
                    if (value?.isEmpty ?? false) {
                      return 'Please enter your document number';
                    }
                    if (value!.length < 9) {
                      return 'Your document number is incorrect, try again.';
                    }
                    return null;
                  },
                  isEnabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 76.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => _login(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login_outlined, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String? Function(String?) validator,
    bool isEnabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.amber),
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.amber),
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.amber),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
      enabled: isEnabled,
      inputFormatters: [
        LengthLimitingTextInputFormatter(9),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class SuccessScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SuccessScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    try {
      imageData = Uint8List.fromList(List<int>.from(widget.userData['imageData']));
    } catch (e) {
      print('Failed to load image data: $e');
    }
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPageOne(userData: widget.userData)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Bitaka ID",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${widget.userData['lastName']} ${widget.userData['firstName']}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            if (imageData != null)
              CircleAvatar(
                radius: 70,
                backgroundImage: MemoryImage(imageData!),
              )
            else
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 50),
              ),
            SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              child: Image.asset(
                'assets/check.png',
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 20),
            Text(
              'You have been successfully authenticated!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
