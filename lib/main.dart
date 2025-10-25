import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_retouching_app/screen/food_camera.dart';
import 'package:photo_retouching_app/screen/home_screen.dart';
import 'package:photo_retouching_app/screen/person_camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        firstCamera: firstCamera,
      ),
    )
  );
}