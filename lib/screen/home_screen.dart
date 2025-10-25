import 'package:camera/camera.dart';
import 'package:camera_widget/screen/takepicture_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription camera;

  const HomeScreen({
    super.key,
    required this.camera,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TakePictureScreen(
        camera: camera
      ),
    );
  }
}
