import 'package:camera/camera.dart';
import 'package:camera_widget/screen/home_screen.dart';
import 'package:camera_widget/screen/takepicture_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 사용 가능한 camera 받아오기.
  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        camera: firstCamera,
      ),
    ),
  );
}