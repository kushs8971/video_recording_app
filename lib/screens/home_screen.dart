import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_recording_app/screens/camera.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription camera;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

   HomeScreen({super.key, required this.camera});

  _signOut() async {
    await _firebaseAuth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Home Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: (){
            _signOut();
          }, child: Text('LOGOUT')),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(camera: camera),
                  ),
                );
              },
              child: Text('Open Camera'),
            ),
          ),
        ],
      ),
    );
  }
}