import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class InsideVideo extends StatefulWidget {

  final String videoFile;
  final String videoTitle;
  final String videoCategory;
  final String userLocation;

  const InsideVideo({Key? key, required this.videoFile, required this.videoTitle, required this.videoCategory, required this.userLocation}) : super(key: key);

  @override
  State<InsideVideo> createState() => _InsideVideoState();
}

class _InsideVideoState extends State<InsideVideo> {

  late VideoPlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoFile.toString()))
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
    return SafeArea(child: Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10,top: 20),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                                size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text("PREVIEW SCREEN",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SF Compact',
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Container(
                width: double.maxFinite,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(children: [
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
                    ])),
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(20),
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                    Text(widget.videoTitle,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'SF Compact',
                      fontWeight: FontWeight.bold,
                      fontSize: 30
                    ),
                    ),
                    SizedBox(height: 10,),
                    Text(widget.videoCategory,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF Compact',
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(widget.userLocation,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SF Compact',
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
