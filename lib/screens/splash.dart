import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_recording_app/screens/otp.dart';
import 'package:video_recording_app/screens/profile.dart';

class SplashScreen extends StatefulWidget {
  final CameraDescription camera;

  const SplashScreen({Key? key, required this.camera}) : super(key: key,);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfUserIsLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(),
    ));
  }

  checkIfUserIsLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userID');
    if(userId == null){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerification(camera: widget.camera,),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Profile(camera: widget.camera,),
        ),
      );    }
  }

}
