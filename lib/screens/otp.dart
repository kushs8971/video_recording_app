import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_recording_app/screens/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_recording_app/screens/profile.dart';

class OtpVerification extends StatefulWidget {
  final CameraDescription camera;
  late String userId;

  OtpVerification({Key? key, required this.camera}) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  TextEditingController _phoneController = TextEditingController();

  TextEditingController _otpController = TextEditingController();

  bool isOtpVisible = false;
  late String verificationId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  if (!isOtpVisible) Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text("+91",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF Compact',
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: TextFormField(
                            maxLength: 10,
                            decoration: InputDecoration(
                              counterText: "",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'SF Compact',
                                    fontWeight: FontWeight.bold
                                ),
                                labelText: "ENTER NUMBER"
                            ),
                            controller: _phoneController,
                          ),
                        ),
                      ],
                    ),
                  ) else Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.isEmpty) {
                            showToast('Field cannot be empty');
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SF Compact',
                            fontWeight: FontWeight.bold
                          ),
                          labelText: "ENTER OTP"
                        ),
                        controller: _otpController,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () {
                      String phoneNumber = _phoneController.text.trim(); // Trim any leading/trailing whitespace
                      if (isOtpVisible) {
                        if (_otpController.text.isEmpty) {
                          showToast('Field cannot be empty');
                        } else {
                          verifyOtp(_otpController.text);
                        }
                      } else {
                        if (phoneNumber.length != 10) {
                          showToast("ENTER 10 DIGIT PHONE NUMBER");
                        } else {
                          sendOtp('+91' + phoneNumber, context);
                        }
                      }
                    },
                    child: Text("Submit"),
                  )
                ]
            ),
          )
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }


  Future sendOtp(String mobile, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    print("registerUser");
    setState(() {
      isOtpVisible = true;
    });
    _auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential authCredential){ },
      verificationFailed: (FirebaseAuthException authException){
        print("error msg : "+authException.message.toString());
      },
      codeSent:  (String verificationId, int? resendToken) async {
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifyOtp(otp) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String smsCode = otp.trim();
      PhoneAuthCredential _credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await auth.signInWithCredential(_credential);
      if(userCredential==null){
        return;
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("userID", userCredential.user?.uid ?? '');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profile(camera: widget.camera)), // Replace 'HomePage' with your actual home page widget
      );
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            child: Text(
              "WRONG OTP", // Show the 'WRONG OTP' message for incorrect OTP
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SF Compact',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }
}
