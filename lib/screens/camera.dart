
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_recording_app/screens/third_screen.dart';


class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Initialize the camera controller with the provided camera description
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePausePlay() async {
    if (_isRecording) {
      // Pause recording if already recording
      await _controller.pauseVideoRecording();
    } else {
      // Start recording if not already recording
      await _initializeControllerFuture;
      await _controller.startVideoRecording();
    }
    _isRecording = !_isRecording;
    setState(() {
    });
  }

  Future<void> _stopRecording() async {
    final xfile = await _controller.stopVideoRecording();
    File file = File(xfile.path);
    setState(() => _isRecording = false);
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => VideoPreviewScreen(videoFile: file, camera: widget.camera,),
    );
    Navigator.push(context, route);
    setState(() {
    });
  }

  Future<void> _toggleCamera() async {
    // Switch between front and back cameras
    if (_controller.description == widget.camera) {
      final cameras = await availableCameras();
      // If currently using the provided camera, switch to the other available camera
      _controller = CameraController(cameras.last, ResolutionPreset.medium);
    } else {
      // If currently using a different camera, switch back to the provided camera
      _controller = CameraController(widget.camera, ResolutionPreset.medium);
    }
    // Re-initialize the controller with the new camera
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Camera Screen'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller), // Display the camera preview
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _togglePausePlay,
                      icon: Icon(_isRecording ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: _toggleCamera,
                      icon: Icon(Icons.switch_camera),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _stopRecording();
                      },
                      icon: Icon(Icons.stop),
                    ),
                  ],
                ),
              ],
            );
          }
          else {
            return Center(child: CircularProgressIndicator()); // Display loading indicator while initializing
          }
        },
      ),
    );
  }
}