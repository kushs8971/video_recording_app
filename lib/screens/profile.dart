import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_recording_app/screens/camera.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as videoThumbnail;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_recording_app/screens/model.dart';

import 'inside_video.dart';

class Profile extends StatefulWidget {

  final CameraDescription camera;
  const Profile({Key? key, required this.camera}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState() {
    super.initState();
  }
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<List<Video>> getVideosForUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uid = sharedPreferences.getString('userID');

    List<Video> videos = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('videos')
          .get();
      print("Fetched ${querySnapshot.docs.length} documents");
      videos = querySnapshot.docs.map((doc) => Video.fromFirestore(doc.data() as Map<String, dynamic>)).toList();

      for(int i = 0; i<videos.length; ++i){
        print('IMG PREVIOUS - ' + videos[i].videoUrl.toString());
        final imgFile = await videoThumbnail.VideoThumbnail.thumbnailFile(
          video: videos[i].videoUrl,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: videoThumbnail.ImageFormat.JPEG,
          maxHeight: 300, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
          quality: 75,
        );
        print("IMG FILE URL - " + imgFile.toString());
        videos[i].imgFile = imgFile.toString();
      }

    } catch (e) {
      print('Error getting videos for user: $e');
    }

    return videos;
  }
  _signOut() async {
    await _firebaseAuth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: FutureBuilder<List<Video>>(
        future: getVideosForUser(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData){
            final list = snapshot.data as List<Video>;
            return Container(
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("ALL VIDEOS",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'SF Compact',
                                fontWeight: FontWeight.bold,
                                fontSize: 24
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: (){
                            _signOut();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.black,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index){
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InsideVideo(videoFile: list[index].videoUrl.toString(), videoTitle: list[index].title, videoCategory: list[index].category, userLocation: list[index].location,),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              width: double.maxFinite,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          topLeft: Radius.circular(20)
                                      ),
                                      child: AspectRatio(
                                          aspectRatio: 1,
                                      child: Image.file(File(list[index].imgFile.toString()),
                                      fit: BoxFit.cover,
                                      ),
                                      )
                                  ),
                                  SizedBox(width: 10,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(list[index].title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF Compact',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(list[index].category,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF Compact',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(list[index].location,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'SF Compact',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScreen(camera: widget.camera),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.lightBlueAccent
                            ),
                            margin: EdgeInsets.only(bottom: 40),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                                size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          else{
            return Container(
              child: Text("ERROR FETCHING DATA"),
            );
          }
        },
      ),
    ));
  }
}
