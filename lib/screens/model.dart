import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String title;
  final String category;
  final String location;
  final String videoUrl;
  String? imgFile;

  Video({
    required this.title,
    required this.category,
    required this.location,
    required this.videoUrl,
  });

  factory Video.fromFirestore(Map<String, dynamic> data) {
    return Video(
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}