import 'dart:io';
import 'package:camera/camera.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_recording_app/screens/profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class VideoPreviewScreen extends StatefulWidget {

  final File videoFile;
  final CameraDescription camera;

  VideoPreviewScreen({required this.videoFile, required this.camera,});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {

  late String userLocation = 'Loading location...'; // Default message
  String videoTitle = '';
  String videoCategory = '';


  Future<void> fetchUserLocation() async {
    final PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      try {
        final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          final Placemark placemark = placemarks[0];
          final String city = placemark.locality ?? '';
          final String state = placemark.administrativeArea ?? '';

          setState(() {
            userLocation = '$city, $state';
          });
        } else {
          setState(() {
            userLocation = 'Location not found';
          });
        }
      } catch (e) {
        print('Error fetching location: $e');
        setState(() {
          userLocation = 'Error fetching location';
        });
      }
    } else {
      setState(() {
        userLocation = 'Location permission denied.';
      });
    }
  }

  Future<void> uploadVideoAndMetadata({
    required String videoPath,
    required String title,
    required String category,
    required String location,
  }) async {
    try {

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      final userId = sharedPreferences.getString('userID');

      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId!)
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '.mp4');

      final File videoFile = File(videoPath);

      final UploadTask uploadTask = storageReference.putFile(videoFile);
      final TaskSnapshot storageSnapshot = await uploadTask;

      final String downloadUrl = await storageSnapshot.ref.getDownloadURL();

      // Store video metadata in Firestore under the user's collection
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('videos').add({
        'title': title,
        'category': category,
        'location': location,
        'videoUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Video and metadata uploaded successfully');
    } catch (e) {
      print('Error uploading video and metadata: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Preview'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40,),
            VideoThumbnail(videoFile: widget.videoFile),
            SizedBox(height: 20),
            Text(userLocation,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'SF Compact',
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    videoTitle = value;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    labelText: 'ENTER VIDEO TITLE',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'SF Compact',
                  fontWeight: FontWeight.bold
                )
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    videoCategory = value;
                  });
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    labelText: 'ENTER VIDEO CATEGORY',
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: 'SF Compact',
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () async {
                if (videoTitle.isNotEmpty && videoCategory.isNotEmpty) {
                  print('Video Title: $videoTitle');
                  print('Video Category: $videoCategory');
                  print('User Location: $userLocation');
                  await uploadVideoAndMetadata(videoPath: widget.videoFile.path, title: videoTitle, category: videoCategory, location: userLocation);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(camera: widget.camera,),
                    ),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter both title and category.'),
                    ),
                  );
                }
              },
              child: Container(
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text("SUBMIT",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SF Compact',
                          fontWeight: FontWeight.bold
                      ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class VideoThumbnail extends StatelessWidget {
  final File videoFile;

  VideoThumbnail({required this.videoFile});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20)
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: VideoPlayerWidget(videoFile: videoFile,)),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  VideoPlayerWidget({required this.videoFile,});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
        });
      });

    controller.setLooping(true);

  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(controller),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                  isPlaying = !isPlaying;
                });
              },
              child: Container(
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
